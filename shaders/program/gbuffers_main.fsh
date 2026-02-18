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
} vIn;


uniform sampler2D gtexture;

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
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 cameraPosition;
uniform int frameCounter;

#include "/lib/oklab.glsl"
#include "/lib/hsv.glsl"
#include "/lib/fog.glsl"
#include "/lib/sampling/lightmap.glsl"

#ifdef LIGHTING_COLORED
    #include "/lib/voxel.glsl"
    #include "/lib/floodfill-render.glsl"
#endif

#ifdef SHADOWS_ENABLED
    #include "/lib/shadows.glsl"
#endif

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
	float mip = textureQueryLod(gtexture, vIn.texcoord).y;

	vec4 color = textureLod(gtexture, vIn.texcoord, mip);

    // opaque is a fallback for cutout not being supported
    // #if defined(RENDER_CUTOUT) || defined(RENDER_OPAQUE)
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

    vec3 albedo = RGBToLinear(color.rgb);
    float viewDist = length(vIn.localPos);
    vec3 localNormal = normalize(vIn.localNormal);

    vec3 localSkyLightDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    float shadow = 1.0;
    #ifdef SHADOWS_ENABLED
        vec3 shadowPos = mul3(shadowModelView, vIn.localPos);
        shadowPos.z += 0.016 * viewDist;
        shadowPos = (shadowProjection * vec4(shadowPos, 1.0)).xyz;

        distort(shadowPos.xy);
        shadowPos = shadowPos * 0.5 + 0.5;

        #ifdef IRIS_FEATURE_SEPARATE_HARDWARE_SAMPLERS
            shadow = texture(shadowtex1HW, shadowPos).r;
        #else
            float shadowDepth = textureLod(shadowtex1, shadowPos.xy, 0).r;
            shadow = step(shadowPos.z, shadowDepth);
        #endif

        float shadow_NoL = dot(localNormal, localSkyLightDir);
        shadow *= pow(saturate(shadow_NoL), 0.2);
    #endif

    #ifdef LIGHTING_COLORED
        vec3 voxelPos = GetVoxelPosition(vIn.localPos);
        float lpvFade = GetVoxelFade(voxelPos);// float(IsInVoxelBounds(voxelPos));
    #endif

    vec2 lmcoord = vIn.lmcoord;
    #if LIGHTING_MODE == LIGHTING_MODE_ENHANCED
        lmcoord = pow(lmcoord, vec2(3.0));

        const vec3 blockLightColor = pow(vec3(0.922, 0.871, 0.686), vec3(2.2));
        vec3 blockLight = lmcoord.x * blockLightColor;

        #ifdef LIGHTING_COLORED
            vec3 samplePos = GetFloodFillSamplePos(voxelPos, localNormal);
            vec3 lpvSample = SampleFloodFill(samplePos);
            blockLight = mix(blockLight, lpvSample, lpvFade);
        #endif

        const vec3 skyLightColor = pow(vec3(0.961, 0.925, 0.843), vec3(2.2));

        float skyLight_NoLm = max(dot(localSkyLightDir, localNormal), 0.0);

        vec3 localSunLightDir = normalize(mat3(gbufferModelViewInverse) * sunPosition);
        float dayF = smoothstep(-0.15, 0.05, localSunLightDir.y);
        float skyLightBrightness = mix(0.04, 1.00, dayF);
        vec3 skyLight = lmcoord.y * ((skyLight_NoLm * shadow)*0.7 + 0.3) * skyLightBrightness * skyLightColor;

        color.rgb = albedo.rgb * (blockLight + skyLight);

        #ifdef RENDER_TERRAIN
            color.rgb *= _pow2(vIn.color.a);
        #endif
    #else
        lmcoord.y = min(lmcoord.y, shadow * 0.5 + 0.5);

        #ifdef RENDER_ENTITY
            float sky_lit = dot(localNormal * localNormal, vec3(0.6, 0.25 * localNormal.y + 0.75, 0.8));
            lmcoord.y *= sky_lit;
        #endif

        #ifdef LIGHTING_COLORED
            lmcoord.x *= 1.0 - lpvFade;
        #endif

        lmcoord = LightMapTex(lmcoord);
        vec3 lit = textureLod(lightmap, lmcoord, 0).rgb;
        lit = RGBToLinear(lit);

        #ifdef LIGHTING_COLORED
            vec3 samplePos = GetFloodFillSamplePos(voxelPos, localNormal);
            vec3 lpvSample = SampleFloodFill(samplePos, pow(vIn.lmcoord.x, 2.2));
            lit += lpvFade * lpvSample;
        #endif

        color.rgb = albedo.rgb * lit;
    #endif

    float borderFogF = smoothstep(0.94 * far, far, viewDist);
    float envFogF = smoothstep(fogStart, fogEnd, viewDist);// * fogDensity;
//    float envFogF = exp(-5.0 * (1.0 - saturate(viewDist/far)));
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
    vec3 localViewDir = normalize(vIn.localPos);
    vec3 fogColorFinal = GetSkyFogColor(skyColorL, fogColorL, localViewDir.y);

    color.rgb = mix(color.rgb, fogColorFinal, fogF);

    outFinal = color;
}
