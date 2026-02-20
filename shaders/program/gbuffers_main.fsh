#define RENDER_FRAGMENT

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 lmcoord;
    vec2 texcoord;
    vec3 localPos;
    vec3 localNormal;

    #if defined(RENDER_TERRAIN) && defined(IRIS_FEATURE_FADE_VARIABLE)
        float chunkFade;
    #endif

    #ifdef MATERIAL_PBR_ENABLED
        flat vec4 localTangent;
        flat int blockId;
    #endif

    #ifdef MATERIAL_PARALLAX_ENABLED
        vec3 tangentViewPos;
        flat vec2 atlasTilePos;
        flat vec2 atlasTileSize;
    #endif
} vIn;


uniform sampler2D gtexture;

#ifdef MATERIAL_PBR_ENABLED
    uniform sampler2D normals;
    uniform sampler2D specular;
#endif

#if LIGHTING_MODE == LIGHTING_MODE_VANILLA
    uniform sampler2D lightmap;
#endif

#ifdef LIGHTING_COLORED
    uniform sampler3D texFloodFillA;
    uniform sampler3D texFloodFillB;
#endif

#ifdef IRIS_FEATURE_SEPARATE_HARDWARE_SAMPLERS
    uniform sampler2DShadow shadowtex1HW;
#else
    uniform sampler2D shadowtex1;
#endif

uniform float far;
uniform vec3 fogColor;
uniform float fogDensity;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 skyColor;
uniform vec4 entityColor;
uniform float alphaTestRef;
uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 cameraPosition;
uniform int frameCounter;
uniform int isEyeInWater;
uniform ivec2 atlasSize;
uniform vec2 viewSize;

uniform int textureFilteringMode;
uniform int vxRenderDistance;

#include "/lib/blocks.glsl"
#include "/lib/oklab.glsl"
#include "/lib/hsv.glsl"
#include "/lib/fog.glsl"
#include "/lib/tbn.glsl"
#include "/lib/sampling/lightmap.glsl"

#ifdef MATERIAL_PBR_ENABLED
    #include "/lib/fresnel.glsl"
    #include "/lib/material.glsl"
#endif

#ifdef MATERIAL_PARALLAX_ENABLED
    #include "/lib/sampling/atlas.glsl"
    #include "/lib/sampling/linear.glsl"
    #include "/lib/parallax.glsl"
#endif

#if LIGHTING_MODE == LIGHTING_MODE_ENHANCED
    #include "/lib/enhanced-lighting.glsl"
#endif

#ifdef LIGHTING_COLORED
    #include "/lib/voxel.glsl"
    #include "/lib/floodfill-render.glsl"
#endif

#ifdef SHADOWS_ENABLED
    #include "/lib/shadows.glsl"
#endif

#ifdef LIGHTING_REFLECT_ENABLED
    #include "/lib/octohedral.glsl"
#endif


#ifdef LIGHTING_REFLECT_ENABLED
    /* RENDERTARGETS: 0,1,2 */
    layout(location = 0) out vec4 outFinal;
    layout(location = 1) out uint outReflectNormal;
    layout(location = 2) out uvec2 outReflectSpecular;
#else
    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 outFinal;
#endif


void main() {
    vec2 texcoord = vIn.texcoord;
	float mip = textureQueryLod(gtexture, texcoord).y;
    vec3 localGeoNormal = normalize(vIn.localNormal);
    float viewDist = length(vIn.localPos);
    vec3 localViewDir = vIn.localPos / viewDist;

    #ifdef MATERIAL_PARALLAX_ENABLED
        bool skipParallax = false;
        if (vIn.blockId == BLOCK_LAVA || vIn.blockId == BLOCK_END_PORTAL) skipParallax = true;

        float texDepth = 1.0;
        vec3 traceCoordDepth = vec3(1.0);
        vec3 tanViewDir = normalize(vIn.tangentViewPos);

        if (!skipParallax && viewDist < MATERIAL_PARALLAX_MAX_DIST) {
            vec2 localCoord = GetLocalCoord(texcoord, vIn.atlasTilePos, vIn.atlasTileSize);
            texcoord = GetParallaxCoord(localCoord, mip, tanViewDir, viewDist, texDepth, traceCoordDepth);
        }
    #endif

    vec4 color = textureLod(gtexture, texcoord, mip);

    #ifndef RENDER_SOLID
        if (color.a < alphaTestRef) discard;
    #endif

    #if defined(RENDER_TERRAIN) && LIGHTING_MODE == LIGHTING_MODE_ENHANCED
        color.rgb *= vIn.color.rgb;
    #else
        color *= vIn.color;
    #endif

    #ifdef RENDER_ENTITY
        color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
    #endif

    #ifdef MATERIAL_PBR_ENABLED
        vec4 normalData = textureLod(normals, texcoord, mip);
        vec3 tex_normal = mat_normal(normalData.xyz);
        float tex_occlusion = mat_occlusion(normalData.w);

        #if defined(MATERIAL_PARALLAX_ENABLED) && MATERIAL_PARALLAX_TYPE == PARALLAX_SHARP
            float depthDiff = max(texDepth - traceCoordDepth.z, 0.0);

            if (depthDiff >= ParallaxSharpThreshold) {
                tex_normal = GetParallaxSlopeNormal(texcoord, mip, traceCoordDepth.z, tanViewDir);
            }
        #endif

        vec3 localTangent = normalize(vIn.localTangent.xyz);
        mat3 matLocalTBN = BuildTBN(localGeoNormal, localTangent, vIn.localTangent.w);
        vec3 localTexNormal = normalize(matLocalTBN * tex_normal);

        vec4 specularData = textureLod(specular, texcoord, mip);

        if (vIn.blockId == BLOCK_WATER) {
            specularData = vec4(0.98, 0.02, 0.0, 0.0);
        }

        // TODO: DEBUG ONLY!
//        if (specularData.g >= 0.9) {
//            color.rgb = vec3(1.0);
//            specularData.rg = vec2(1.0);
//        }
    #else
        vec3 localTexNormal = localGeoNormal;
        const float tex_occlusion = 1.0;
    #endif

    vec3 albedo = RGBToLinear(color.rgb);

    #ifdef DEBUG_WHITEWORLD
        albedo = vec3(0.86);
    #endif

    vec3 localSkyLightDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    float shadow = 1.0;
    #ifdef SHADOWS_ENABLED
        vec3 shadowPos = vIn.localPos;
        shadowPos += 0.08 * localGeoNormal;
        shadowPos = mul3(shadowModelView, shadowPos);
        shadowPos.z += 0.032 * viewDist;
        shadowPos = (shadowProjection * vec4(shadowPos, 1.0)).xyz;

        distort(shadowPos.xy);
        shadowPos = shadowPos * 0.5 + 0.5;

        #ifdef IRIS_FEATURE_SEPARATE_HARDWARE_SAMPLERS
            shadow = texture(shadowtex1HW, shadowPos).r;
        #else
            float shadowDepth = textureLod(shadowtex1, shadowPos.xy, 0).r;
            shadow = step(shadowPos.z, shadowDepth);
        #endif

        float shadow_NoL = dot(localTexNormal, localSkyLightDir);
        shadow *= pow(saturate(shadow_NoL), 0.2);
    #endif

    #ifdef LIGHTING_COLORED
        vec3 voxelPos = GetVoxelPosition(vIn.localPos);
        float lpvFade = GetVoxelFade(voxelPos);
    #endif

    vec2 lmcoord = vIn.lmcoord;
    #if LIGHTING_MODE == LIGHTING_MODE_ENHANCED
        lmcoord = _pow3(lmcoord);

        const vec3 blockLightColor = pow(vec3(0.922, 0.871, 0.686), vec3(2.2));
        vec3 blockLight = lmcoord.x * blockLightColor;

        #ifdef LIGHTING_COLORED
            vec3 samplePos = GetFloodFillSamplePos(voxelPos, localTexNormal);
            vec3 lpvSample = SampleFloodFill(samplePos) * 3.0;
            blockLight = mix(blockLight, lpvSample, lpvFade);
        #endif

        vec3 localSunLightDir = normalize(mat3(gbufferModelViewInverse) * sunPosition);
        vec3 skyLightColor = GetSkyLightColor(localSunLightDir.y);

        float skyLight_NoLm = max(dot(localSkyLightDir, localTexNormal), 0.0);
        vec3 skyLight = lmcoord.y * ((skyLight_NoLm * shadow)*0.7 + 0.3) * skyLightColor;

        color.rgb = albedo * (blockLight + skyLight);

        #ifdef RENDER_TERRAIN
            color.rgb *= _pow2(vIn.color.a);
        #endif

        // TODO: move to ambient lighting?
        color.rgb *= tex_occlusion;
    #else
        lmcoord.y = min(lmcoord.y, shadow * 0.5 + 0.5);

        float sky_NoLM = dot(localTexNormal * localTexNormal, vec3(0.6, 0.25 * localTexNormal.y + 0.75, 0.8));
        lmcoord.y *= saturate(sky_NoLM);

        #ifdef LIGHTING_COLORED
            lmcoord.x *= 1.0 - lpvFade;
        #endif

        lmcoord = LightMapTex(lmcoord);
        vec3 lit = textureLod(lightmap, lmcoord, 0).rgb;
        lit = RGBToLinear(lit);

        #ifdef LIGHTING_COLORED
            vec3 samplePos = GetFloodFillSamplePos(voxelPos, localTexNormal);
            vec3 lpvSample = SampleFloodFill(samplePos, pow(vIn.lmcoord.x, 2.2));
            lit += lpvFade * lpvSample;
        #endif

        color.rgb = albedo * lit;
        color.rgb *= tex_occlusion;
    #endif

    #ifdef MATERIAL_PBR_ENABLED
        #ifdef LIGHTING_REFLECT_ENABLED
            float smoothness = 1.0 - mat_roughness(specularData.r);
            float metalness = mat_metalness(specularData.g);
            color.rgb *= 1.0 - metalness * sqrt(smoothness);

            float f0 = mat_f0(specularData.g);
            float NoV = dot(localTexNormal, -localViewDir);

            color.rgb *= 1.0 - F_schlick(NoV, f0, 1.0) * _pow2(smoothness);
        #endif

        float emission = mat_emission(specularData);
        color.rgb += albedo * emission;
    #endif


//    color.rgb = localTexNormal * 0.5 + 0.5;
//    color.rgb = vec3(lmcoord, 0);


    #ifdef VOXY
        #define _far (vxRenderDistance * 16.0)
    #else
        #define _far far
    #endif

    float borderFogF = smoothstep(0.94 * _far, _far, viewDist);
    float envFogF = smoothstep(fogStart, fogEnd, viewDist);
    float fogF = max(borderFogF, envFogF);

    #if defined(RENDER_TERRAIN) && defined(IRIS_FEATURE_FADE_VARIABLE)
        #ifdef RENDER_TRANSLUCENT
            color.a *= vIn.chunkFade;
        #else
            fogF = max(fogF, 1.0 - vIn.chunkFade);
        #endif
    #endif

    vec3 fogColorL = RGBToLinear(fogColor);
    vec3 skyColorL = RGBToLinear(skyColor);
    vec3 fogColorFinal = GetSkyFogColor(skyColorL, fogColorL, localViewDir.y);

    color.rgb = mix(color.rgb, fogColorFinal, fogF);

    outFinal = color;

    #ifdef LIGHTING_REFLECT_ENABLED
        vec3 viewNormal = mat3(gbufferModelView) * localTexNormal;

        outReflectNormal = packUnorm2x16(OctEncode(viewNormal));

        outReflectSpecular = uvec2(
            packUnorm4x8(vec4(LinearToRGB(albedo), lmcoord.y)),
            packUnorm4x8(specularData));
    #endif
}
