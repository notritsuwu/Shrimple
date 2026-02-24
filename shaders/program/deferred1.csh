#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#define TEX_DEPTH depthtex0

layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);


layout(rgba16f) uniform image2D IMG_FINAL;

uniform sampler2D TEX_DEPTH;
uniform sampler2D TEX_FINAL;
uniform usampler2D TEX_TEX_NORMAL;
uniform usampler2D TEX_GEO_NORMAL;
uniform usampler2D TEX_REFLECT_SPECULAR;
//uniform sampler2D texPhotonicsIndirect;
uniform sampler2D texBlockLight;

//uniform float near;
//uniform float farPlane;
uniform vec3 cameraPosition;
//uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
//uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform int frameCounter;
uniform vec2 viewSize;
//uniform float aspectRatio;
uniform int heldItemId;
uniform int heldItemId2;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform bool firstPersonCamera;
uniform vec3 relativeEyePosition;
uniform vec2 taa_offset = vec2(0.0);

#include "/photonics/photonics.glsl"

//#include "/lib/blocks.glsl"
//#include "/lib/sampling/depth.glsl"
#include "/lib/octohedral.glsl"
#include "/lib/hand-light.glsl"


void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    bool on_screen = all(lessThan(uv, viewSize));
    if (!on_screen) return;

    float depth = texelFetch(TEX_DEPTH, uv, 0).r;
    vec3 lighting = vec3(0.0);

    if (depth < 1.0) {
        vec2 texcoord = (gl_GlobalInvocationID.xy + 0.5) / viewSize;

        #ifdef TAA_ENABLED
            texcoord -= taa_offset;
        #endif

        vec3 ndcPos = vec3(texcoord, depth) * 2.0 - 1.0;

        // TODO: fix hand depth

        vec3 viewPos = project(gbufferProjectionInverse, ndcPos);
        vec3 localPos = mul3(gbufferModelViewInverse, viewPos);

        uint reflectNormalData = texelFetch(TEX_TEX_NORMAL, uv, 0).r;
        vec3 viewTexNormal = OctDecode(unpackUnorm2x16(reflectNormalData));
        vec3 localTexNormal = mat3(gbufferModelViewInverse) * viewTexNormal;

//        uint geoNormalData = texelFetch(TEX_GEO_NORMAL, uv, 0).r;
//        vec3 localGeoNormal = OctDecode(unpackUnorm2x16(geoNormalData));

        vec3 handLightPos = GetHandLightPosition();
        float handDist = distance(localPos, handLightPos);

        float handLight1 = max(heldBlockLightValue  - handDist, 0.0) / 15.0;
        float handLight2 = max(heldBlockLightValue2 - handDist, 0.0) / 15.0;

        vec3 handLightColor1 = vec3(1.0);
        if (heldItemId >= 0) {
            ivec2 blockLightUV1 = ivec2(heldItemId % 256, heldItemId / 256);
            vec4 lightColorRange1 = texelFetch(texBlockLight, blockLightUV1, 0);
            handLightColor1 = RGBToLinear(lightColorRange1.rgb);
        }

        vec3 handLightColor2 = vec3(1.0);
        if (heldItemId2 >= 0) {
            ivec2 blockLightUV2 = ivec2(heldItemId2 % 256, heldItemId2 / 256);
            vec4 lightColorRange2 = texelFetch(texBlockLight, blockLightUV2, 0);
            handLightColor2 = RGBToLinear(lightColorRange2.rgb);
        }

        vec3 lightDir = normalize(localPos - handLightPos);
        float NoLm = max(dot(localTexNormal, -lightDir), 0.0);

        if (heldBlockLightValue > 0 || heldBlockLightValue2 > 0) {
            vec3 rtOrigin = handLightPos + (cameraPosition - world_offset);

            RayJob ray = RayJob(rtOrigin, lightDir,
                vec3(0), vec3(0), vec3(0), false);

            RAY_ITERATION_COUNT = PHOTONICS_LIGHT_STEPS;
            // breakOnEmpty=true;

            trace_ray(ray, true);

            vec3 tint = vec3(1.0);
            if (ray.result_hit) {
                tint = result_tint_color;

                if (lengthSq(rtOrigin - ray.result_position) < _pow2(handDist) - 0.02) {
                    NoLm = 0.0;
                }
            }

            lighting += NoLm * result_tint_color * (_pow2(handLight1) * handLightColor1 + _pow2(handLight2) * handLightColor2);
        }

//        #ifdef PH_ENABLE_GI
//            vec3 ph_indirect = texelFetch(texPhotonicsIndirect, uv, 0).rgb;
//            lighting += 10.0 * ph_indirect;
//        #endif

        uvec2 reflectData = texelFetch(TEX_REFLECT_SPECULAR, uv, 0).rg;
        vec4 reflectDataR = unpackUnorm4x8(reflectData.r);
        lighting *= RGBToLinear(reflectDataR.rgb);
    }

    vec3 src = texelFetch(TEX_FINAL, uv, 0).rgb;
    imageStore(IMG_FINAL, uv, vec4(src + lighting, 1.0));
}
