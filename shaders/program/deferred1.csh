#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#define TEX_DEPTH depthtex0

layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);


shared int sharedLightList[256];
shared uint depthMinInt, depthMaxInt;
shared uint counter;

layout(rgba16f) uniform image2D IMG_FINAL;

uniform sampler2D TEX_DEPTH;
uniform sampler2D TEX_FINAL;
uniform usampler2D TEX_REFLECT_NORMAL;
uniform usampler2D TEX_REFLECT_SPECULAR;
uniform sampler2D texPhotonicsIndirect;

uniform float near;
uniform float farPlane;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform int frameCounter;
uniform vec2 viewSize;
uniform vec2 taa_offset = vec2(0.0);

#include "/photonics/photonics.glsl"
#include "/lib/sampling/depth.glsl"
#include "/lib/octohedral.glsl"


vec3 unprojectCorner(const in float screenPosX, const in float screenPosY) {
    vec3 ndcPos = vec3(screenPosX, screenPosY, 1.0) * 2.0 - 1.0;
    return project(gbufferProjectionInverse, ndcPos);
}


void main() {
    if (gl_LocalInvocationIndex == 0) {
        depthMinInt = UINT_MAX;
        depthMaxInt = 0u;
        counter = 0u;
    }

//    GroupMemoryBarrierWithGroupSync();
    barrier();

    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    bool on_screen = all(lessThan(uv, viewSize));
    float depth;

    if (on_screen) {
        depth = texelFetch(TEX_DEPTH, uv, 0).r;

        if (depth < 1.0) {
            float depthL = linearizeDepth(depth * 2.0 - 1.0, near, farPlane);
            float depthInt = depthL / farPlane * UINT_MAX;
            atomicMin(depthMinInt, uint(floor(depthInt)));
            atomicMax(depthMaxInt, uint(ceil(depthInt)));
        }
    }

//    GroupMemoryBarrierWithGroupSync();
    barrier();

    float depthMin = depthMinInt / float(UINT_MAX) * farPlane;
    float depthMax = depthMaxInt / float(UINT_MAX) * farPlane;

    if (gl_LocalInvocationIndex < PH_MAX_LIGHTS) {
//        PointLight light = ap.lights[gl_LocalInvocationIndex];
        Light light = load_light(int(gl_LocalInvocationIndex));

//        if (any(greaterThan(light.color, vec3(0.0)))) {
            float lightRange = 15.0;//ap.blocks[light.block].emission + 0.5;

            // compute view-space position and collision test
            vec3 lightLocalPos = light.position - (cameraPosition - world_offset);
            vec3 lightViewPos = mul3(gbufferModelView, lightLocalPos);
            bool hit = true;

            if (-lightViewPos.z + lightRange < depthMin) hit = false;
            if (-lightViewPos.z - lightRange > depthMax) hit = false;

            // test X/Y
            uvec2 groupPos = gl_WorkGroupID.xy * 16u;
            vec2 groupPosMin = groupPos / viewSize;
            vec2 groupPosMax = (groupPos + 16u) / viewSize;

            vec3 c1 = unprojectCorner(groupPosMin.x, groupPosMin.y);
            vec3 c2 = unprojectCorner(groupPosMax.x, groupPosMin.y);
            vec3 c3 = unprojectCorner(groupPosMin.x, groupPosMax.y);
            vec3 c4 = unprojectCorner(groupPosMax.x, groupPosMax.y);

            vec3 clipDown  = normalize(cross(c2, c1));
            vec3 clipRight = normalize(cross(c4, c2));
            vec3 clipUp    = normalize(cross(c3, c4));
            vec3 clipLeft  = normalize(cross(c1, c3));

            if (dot(clipDown,  lightViewPos) > lightRange) hit = false;
            if (dot(clipRight, lightViewPos) > lightRange) hit = false;
            if (dot(clipUp,    lightViewPos) > lightRange) hit = false;
            if (dot(clipLeft,  lightViewPos) > lightRange) hit = false;

            if (hit) {
                uint index = atomicAdd(counter, 1u);
                sharedLightList[index] = int(gl_LocalInvocationIndex);
            }
        //}
    }

//    GroupMemoryBarrierWithGroupSync();
    barrier();

    if (!on_screen) return;

    vec3 lighting = vec3(0.0);

    if (depth < 1.0 && counter > 0) {
        vec2 texcoord = (gl_GlobalInvocationID.xy + 0.5) / viewSize;

        #ifdef TAA_ENABLED
            texcoord -= taa_offset;
        #endif

        vec3 ndcPos = vec3(texcoord, depth) * 2.0 - 1.0;

        // TODO: fix hand depth

        vec3 viewPos = project(gbufferProjectionInverse, ndcPos);
        vec3 localPos = mul3(gbufferModelViewInverse, viewPos);

        uint reflectNormalData = texelFetch(TEX_REFLECT_NORMAL, uv, 0).r;
        vec3 viewTexNormal = OctDecode(unpackUnorm2x16(reflectNormalData));
        vec3 localTexNormal = mat3(gbufferModelViewInverse) * viewTexNormal;

        for (uint i = 0; i < counter; i++) {
            int lightIndex = sharedLightList[i];
            Light light = load_light(lightIndex);

            vec3 lightLocalPos = light.position - (cameraPosition - world_offset);
            vec3 lightOffset = lightLocalPos - localPos;
            float lightDist = length(lightOffset);
            vec3 lightDir = lightOffset / lightDist;
            vec3 lightColor = 3.0 * light.color;
            float lightRange = 15.0; // TODO

            float NoLm = max(dot(localTexNormal, lightDir), 0.0);
            float att = 1.0 - saturate(lightDist / lightRange);


            vec3 rtOrigin = light.position;

            RayJob ray = RayJob(rtOrigin, -lightDir,
                vec3(0), vec3(0), vec3(0), false);

            RAY_ITERATION_COUNT = PHOTONICS_LIGHT_STEPS;
            // breakOnEmpty=true;

            trace_ray(ray, true);

            if (ray.result_hit) {
                lightColor *= result_tint_color;

                if (lengthSq(rtOrigin - ray.result_position) < _pow2(lightDist) - 0.02) {
                    att = 0.0;
                }
            }

            lighting += NoLm * _pow2(att) * lightColor;
        }

        uvec2 reflectData = texelFetch(TEX_REFLECT_SPECULAR, uv, 0).rg;
        vec4 reflectDataR = unpackUnorm4x8(reflectData.r);
        lighting *= RGBToLinear(reflectDataR.rgb);
    }

    vec3 ph_indirect = texelFetch(texPhotonicsIndirect, uv, 0).rgb;
    lighting += 10.0 * ph_indirect;

    vec3 src = texelFetch(TEX_FINAL, uv, 0).rgb;
    imageStore(IMG_FINAL, uv, vec4(src + lighting, 1.0));
}
