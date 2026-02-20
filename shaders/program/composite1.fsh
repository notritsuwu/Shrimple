#include "/lib/constants.glsl"
#include "/lib/common.glsl"

const bool colortex0MipmapEnabled = true;


#define MATERIAL_REFLECT_STEPS 32
#define MATERIAL_REFLECT_REFINE_STEPS 8

in vec2 texcoord;

uniform sampler2D depthtex0;
uniform sampler2D TEX_FINAL;
uniform usampler2D TEX_REFLECT_DATA;

uniform float near;
uniform float farPlane;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform int isEyeInWater;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform vec2 taa_offset = vec2(0.0);


#include "/lib/sampling/bayer.glsl"
#include "/lib/sampling/depth.glsl"
#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"
#include "/lib/material.glsl"


vec3 projectToScreenBounds(const in vec3 screenPos, const in vec3 screenDir) {
    vec3 stepDir = sign(screenDir);
    vec3 nextDist = stepDir * 0.5 + 0.5;
    nextDist = (nextDist - fract(screenPos)) / screenDir;

    float closestDist = max(minOf(nextDist) - 0.00001, 0.0);
    return screenDir * closestDist + screenPos;
}

vec3 projectScreenTrace(const in vec3 viewPos, const in vec3 screenPos, const in vec3 viewDir) {
    float viewDist = length(viewPos);

    vec3 dest_viewPos = 0.1 * viewDist * viewDir + viewPos;
    vec3 dest_clipPos = project(gbufferProjection, dest_viewPos);
    // float4 dest_clipPos = mul(ap.camera.projection, float4(dest_viewPos, 1.0));
    // dest_clipPos.xyz = clamp(dest_clipPos.xyz, float3(-1.0, -1.0, 0.00001), 1.0) / dest_clipPos.w;
    vec3 dest_screenPos = dest_clipPos.xyz * 0.5 + 0.5;

    vec3 screenDir = normalize(dest_screenPos - screenPos);

    return projectToScreenBounds(screenPos, screenDir);
}


/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 outFinal;

void main() {
    ivec2 uv = ivec2(gl_FragCoord.xy);
    float depth = textureLod(depthtex0, texcoord, 0).r;
    vec3 reflectColor = vec3(0.0);

    if (depth < 1.0) {
        vec3 screenPos = vec3(texcoord, depth);
        vec3 ndcPos = screenPos * 2.0 - 1.0;

    //    #ifdef TAA_ENABLED
    //        ndcPos.xy += taa_offset * 2.0;
    //    #endif

        vec3 viewPos = project(gbufferProjectionInverse, ndcPos);
        vec3 viewDir = normalize(viewPos);

        uvec2 reflectData = texelFetch(TEX_REFLECT_DATA, uv, 0).rg;
        vec4 reflectDataR = unpackUnorm4x8(reflectData.r);
        vec4 reflectDataG = unpackUnorm4x8(reflectData.g);

        float specular_r = reflectDataR.a;

        vec3 viewNormal = normalize(reflectDataG.xyz * 2.0 - 1.0);
        float specular_g = reflectDataG.w;

        float roughness = mat_roughness(specular_r);
        float smoothness = 1.0 - roughness;

        vec3 reflectViewDir = normalize(reflect(viewDir, viewNormal));

        vec3 screenEnd = projectScreenTrace(viewPos, screenPos, reflectViewDir);
        vec3 traceClipEnd = screenEnd * 2.0 - 1.0;
        vec3 traceClipStart = ndcPos;

        vec3 traceClipPos;
        vec3 traceClipPos_prev = traceClipStart;
        vec2 traceScreenPos;

        bool hit = false;
        float dither = 0.5;//GetBayerValue(uv);
        for (uint i = 0; i < MATERIAL_REFLECT_STEPS; i++) {
            float f = (i + dither) / float(MATERIAL_REFLECT_STEPS);
            traceClipPos = mix(traceClipStart, traceClipEnd, saturate(f));
            traceScreenPos = traceClipPos.xy * 0.5 + 0.5;
            if (saturate(traceScreenPos) != traceScreenPos) break;

            float sampleClipDepth = textureLod(depthtex0, traceScreenPos, 0).r * 2.0 - 1.0;
            float screenDepthL = linearizeDepth(sampleClipDepth, near, farPlane);
            float traceDepthL = linearizeDepth(traceClipPos.z, near, farPlane);

            if (screenDepthL < traceDepthL) {
                hit = true;
                break;
            }

            traceClipPos_prev = traceClipPos;
            // traceDepthL_prev = traceDepthL;
        }

        if (hit) {
            traceClipStart = traceClipPos_prev;
            traceClipEnd = traceClipPos;

            for (uint i = 0; i <= MATERIAL_REFLECT_REFINE_STEPS; i++) {
                float f = (i + dither) / float(MATERIAL_REFLECT_REFINE_STEPS);
                traceClipPos = mix(traceClipStart, traceClipEnd, saturate(f));
                vec2 testPos = traceClipPos.xy * 0.5 + 0.5;
                if (saturate(testPos) != testPos) break;

                float sampleClipDepth = textureLod(depthtex0, testPos, 0).r * 2.0 - 1.0;
                float screenDepthL = linearizeDepth(sampleClipDepth, near, farPlane);
                float traceDepthL = linearizeDepth(traceClipPos.z, near, farPlane);

                if (screenDepthL < traceDepthL) {
                    break;
                }

                traceScreenPos = testPos;
            }
        }

//        hit = false;
        if (hit) {
    //        float roughL = _pow2(roughness);
            float mip = roughness * 4.0;

            reflectColor = textureLod(TEX_FINAL, traceScreenPos, mip).rgb;
        }
        else {
            vec3 reflectLocalDir = mat3(gbufferModelViewInverse) * reflectViewDir;
            reflectColor = GetSkyFogColor(RGBToLinear(skyColor), RGBToLinear(fogColor), reflectLocalDir.y);
//            reflectColor *= lmcoord_y; TODO
        }

        float NoVm = max(dot(viewNormal, -viewDir), 0.0);
        reflectColor *= pow(1.0 - NoVm, 5.0);

        reflectColor *= _pow2(smoothness);

        vec3 albedo = RGBToLinear(reflectDataR.rgb);
        float metalness = mat_metalness(specular_g);
        vec3 tint = mix(vec3(1.0), albedo, metalness);
        reflectColor *= tint;
    }

    vec3 src = texelFetch(TEX_FINAL, uv, 0).rgb;
    outFinal = src + reflectColor;
}
