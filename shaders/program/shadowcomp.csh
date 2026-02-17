#include "/lib/constants.glsl"
#include "/lib/common.glsl"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

#if LIGHTING_VOXEL_SIZE == 256
    const ivec3 workGroups = ivec3(32, 32, 32);
#elif LIGHTING_VOXEL_SIZE == 128
    const ivec3 workGroups = ivec3(16, 16, 16);
#elif LIGHTING_VOXEL_SIZE == 64
    const ivec3 workGroups = ivec3(8, 8, 8);
#endif

const float LpvFalloff = 0.998;


//layout(r16ui) uniform readonly uimage3D imgVoxels;

layout(rgba8) uniform image3D imgFloodFillA;
layout(rgba8) uniform image3D imgFloodFillB;

uniform usampler3D texVoxels;
uniform sampler2D texBlockLight;

//#ifdef LIGHTING_FLICKER
//    uniform sampler2D noisetex;
//#endif

//uniform float frameTime;
uniform int frameCounter;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;

//#ifdef ANIM_WORLD_TIME
//    uniform int worldTime;
//#else
//    uniform float frameTimeCounter;
//#endif

//#include "/lib/blocks.glsl"
//#include "/lib/lights.glsl"

//#include "/lib/buffers/scene.glsl"
//#include "/lib/buffers/block_static.glsl"
//#include "/lib/buffers/block_voxel.glsl"
//#include "/lib/buffers/light_static.glsl"
//#include "/lib/buffers/volume.glsl"

#include "/lib/hsv.glsl"
#include "/lib/voxel.glsl"
#include "/lib/floodfill.glsl"

//#include "/lib/voxel/lpv/lpv.glsl"
//#include "/lib/voxel/lights/mask.glsl"
//#include "/lib/voxel/blocks.glsl"
//#include "/lib/lighting/voxel/tinting.glsl"

//#include "/lib/sampling/noise.glsl"

//#ifdef LIGHTING_FLICKER
//    #include "/lib/utility/anim.glsl"
//    #include "/lib/lighting/blackbody.glsl"
//    #include "/lib/lighting/flicker.glsl"
//#endif

//#include "/lib/lighting/voxel/lights_render.glsl"

vec3 GetLpvValue(const in ivec3 texCoord) {
    if (!IsInVoxelBounds(texCoord)) return vec3(0.0);

    vec3 lpvSample = (frameCounter % 2) == 0
        ? imageLoad(imgFloodFillB, texCoord).rgb
        : imageLoad(imgFloodFillA, texCoord).rgb;

    lpvSample = RGBToLinear(lpvSample);

    vec3 hsv = RgbToHsv(lpvSample);
    hsv.z = exp2(hsv.z * LpvBlockRange) - 1.0;
    lpvSample = HsvToRgb(hsv);

    return lpvSample;
}

ivec3 GetVoxelFrameOffset() {
    return ivec3(floor(cameraPosition)) - ivec3(floor(previousCameraPosition));


    vec3 viewDir = gbufferModelViewInverse[2].xyz;
    vec3 posNow = GetVoxelCenter(cameraPosition, viewDir);

    vec3 viewDirPrev = vec3(gbufferPreviousModelView[0].z, gbufferPreviousModelView[1].z, gbufferPreviousModelView[2].z);
    vec3 posPrev = GetVoxelCenter(previousCameraPosition, viewDirPrev);

    vec3 posLast = posNow + (previousCameraPosition - cameraPosition) - (posPrev - posNow);

    return ivec3(posNow) - ivec3(posLast);
}

const ivec3 lpvFlatten = ivec3(1, 10, 100);

shared uint voxelSharedData[10*10*10];
shared vec3 lpvBuffer[10*10*10];

int getSharedCoord(const in ivec3 pos) {
    return sumOf(pos * lpvFlatten);
}

vec3 sampleShared(const in ivec3 pos, const in int mask_index, out float weight) {
    int shared_index = getSharedCoord(pos + 1);

    //float mixWeight = 1.0;
    uint mixMask = 0xFFFF;
    uint blockId = voxelSharedData[shared_index];
    weight = blockId == 0 ? 1.0 : 0.0;

//    if (blockId > 0 && blockId != 0u)
//        ParseBlockLpvData(StaticBlockMap[blockId].lpv_data, mixMask, weight);

    uint wMask = bitfieldExtract(mixMask, mask_index, 1);
    return lpvBuffer[shared_index] * wMask;// * mixWeight;
}

vec3 mixNeighboursDirect(const in ivec3 fragCoord, const in uint mask) {
    uvec3 m1 = (uvec3(mask) >> uvec3(0, 2, 4)) & uvec3(1u);
    uvec3 m2 = (uvec3(mask) >> uvec3(1, 3, 5)) & uvec3(1u);

    vec3 w1, w2;
    vec3 nX1 = sampleShared(fragCoord + ivec3(-1,  0,  0), 1, w1.x) * m1.x;
    vec3 nX2 = sampleShared(fragCoord + ivec3( 1,  0,  0), 0, w2.x) * m2.x;
    vec3 nY1 = sampleShared(fragCoord + ivec3( 0, -1,  0), 3, w1.y) * m1.y;
    vec3 nY2 = sampleShared(fragCoord + ivec3( 0,  1,  0), 2, w2.y) * m2.y;
    vec3 nZ1 = sampleShared(fragCoord + ivec3( 0,  0, -1), 5, w1.z) * m1.z;
    vec3 nZ2 = sampleShared(fragCoord + ivec3( 0,  0,  1), 4, w2.z) * m2.z;

    const float wMaxInv = 1.0 / 6.0;//max(sumOf(w1 + w2), 1.0);
    float avgFalloff = wMaxInv * LpvFalloff;
    return (nX1 + nX2 + nY1 + nY2 + nZ1 + nZ2) * avgFalloff;
}

void PopulateShared() {
    uint i1 = uint(gl_LocalInvocationIndex) * 2u;
    if (i1 >= 1000u) return;

    uint i2 = i1 + 1u;
    // ivec3 voxelOffset = GetLpvVoxelOffset();
    ivec3 imgCoordOffset = GetVoxelFrameOffset();
    ivec3 workGroupOffset = ivec3(gl_WorkGroupID * gl_WorkGroupSize) - 1;

    ivec3 pos1 = workGroupOffset + ivec3(i1 / lpvFlatten) % 10;
    ivec3 pos2 = workGroupOffset + ivec3(i2 / lpvFlatten) % 10;

    ivec3 lpvPos1 = imgCoordOffset + pos1;
    ivec3 lpvPos2 = imgCoordOffset + pos2;

    lpvBuffer[i1] = GetLpvValue(lpvPos1);
    lpvBuffer[i2] = GetLpvValue(lpvPos2);

    uint blockId1 = 0u;
    uint blockId2 = 0u;

    if (IsInVoxelBounds(pos1)) {
//        blockId1 = imageLoad(imgVoxels, pos1).r;
        blockId1 = texelFetch(texVoxels, pos1, 0).r;
    }

    if (IsInVoxelBounds(pos2)) {
//        blockId2 = imageLoad(imgVoxels, pos2).r;
        blockId2 = texelFetch(texVoxels, pos2, 0).r;
    }

    voxelSharedData[i1] = blockId1;
    voxelSharedData[i2] = blockId2;
}

void main() {
    uvec3 chunkPos = gl_WorkGroupID * gl_WorkGroupSize;
    if (any(greaterThanEqual(chunkPos, VoxelBufferSize))) return;

    PopulateShared();

    barrier();

    ivec3 imgCoord = ivec3(gl_GlobalInvocationID);
    if (any(greaterThanEqual(imgCoord, VoxelBufferSize))) return;

    vec3 viewDir = gbufferModelViewInverse[2].xyz;
    vec3 lpvCenter = GetVoxelCenter(cameraPosition, viewDir);
    vec3 blockLocalPos = imgCoord - lpvCenter + 0.5;

    uint blockId = voxelSharedData[getSharedCoord(ivec3(gl_LocalInvocationID) + 1)];

    vec3 lightValue = vec3(0.0);

    float mixWeight = blockId == 0u ? 1.0 : 0.0;
    uint mixMask = 0xFFFF;
    vec3 tint = vec3(1.0);

    // TODO: which is it?
//    if (blockId > 0u && blockId != 0u)
//        ParseBlockLpvData(StaticBlockMap[blockId].lpv_data, mixMask, mixWeight);

    #ifdef LPV_GLASS_TINT
        if (blockId >= BLOCK_HONEY && blockId <= BLOCK_TINTED_GLASS) {
            tint = GetLightGlassTint(blockId);
            mixWeight = 1.0;
        }
    #endif

    if (mixWeight > EPSILON) {
        vec3 lightMixed = mixNeighboursDirect(ivec3(gl_LocalInvocationID), mixMask);
        lightMixed *= mixWeight * tint;
        lightValue += lightMixed;
    }

//    lightValue = vec3(0.0);

    if (blockId > 0) {
        ivec2 blockLightUV = ivec2(blockId % 256, blockId / 256);
        vec4 lightColorRange = texelFetch(texBlockLight, blockLightUV, 0);

        vec3 lightColor = RGBToLinear(lightColorRange.rgb);
        float lightRange = lightColorRange.a * 255.0;

        vec3 hsv = RgbToHsv(lightColor);
        hsv.z = exp2(lightRange) - 1.0;
        // hsv.z = lightRange / 15.0;
        lightValue += HsvToRgb(hsv);

//        lightValue = vec3(100,0,0);
    }

    vec3 hsv = RgbToHsv(lightValue);
    hsv.z = log2(hsv.z + 1.0) / LpvBlockRange;
    lightValue = HsvToRgb(hsv);

    lightValue = LinearToRGB(lightValue);

    if (frameCounter % 2 == 0)
        imageStore(imgFloodFillA, imgCoord, vec4(lightValue, 1.0));
    else
        imageStore(imgFloodFillB, imgCoord, vec4(lightValue, 1.0));
}
