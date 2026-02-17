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
    #include "/lib/floodfill.glsl"
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

	color *= vIn.color;

    #ifdef RENDER_ENTITY
        color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
    #endif

    vec3 albedo = RGBToLinear(color.rgb);
    float viewDist = length(vIn.localPos);
    vec3 localNormal = normalize(vIn.localNormal);

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

        vec3 localSkyLightDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

        float shadow_NoL = dot(localNormal, localSkyLightDir);
        shadow *= pow(saturate(shadow_NoL), 0.2);
    #endif

    #ifdef LIGHTING_COLORED
        vec3 voxelPos = GetVoxelPosition(vIn.localPos);
        float lpvFade = float(IsInVoxelBounds(voxelPos));
    #endif

    #if LIGHTING_MODE == LIGHTING_MODE_CUSTOM
        // TODO
        color.rgb = albedo.rgb;
    #else
        vec2 lmcoord = vIn.lmcoord;

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
            lit += lpvFade * SampleFloodFill(samplePos);
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
