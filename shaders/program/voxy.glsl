#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#include "/lib/blocks.glsl"
#include "/lib/sampling/lightmap.glsl"
#include "/lib/octohedral.glsl"
#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"


#include "_output.glsl"

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    vec4 color = parameters.sampledColour;
    color.rgb *= parameters.tinting.rgb;

    vec3 ndcPos = gl_FragCoord.xyz;
    ndcPos.xy /= viewSize;
    ndcPos = ndcPos * 2.0 - 1.0;

    vec3 viewPos = project(vxProjInv, ndcPos);
    vec3 localPos = mul3(vxModelViewInv, viewPos);

    vec3 localNormal = vec3(
        uint((parameters.face >> 1) == 2),
        uint((parameters.face >> 1) == 0),
        uint((parameters.face >> 1) == 1)
    ) * (float(int(parameters.face) & 1) * 2.0 - 1.0);

    // TODO: if vanilla lighting, make foliage have "up" normals
    #if LIGHTING_MODE == LIGHTING_MODE_VANILLA
        bool isGrass = parameters.customId == BLOCK_GRASS
            || parameters.customId == BLOCK_TALL_GRASS_LOWER
            || parameters.customId == BLOCK_TALL_GRASS_UPPER;

        if (isGrass) localNormal = vec3(0,1,0);
    #endif

    vec3 albedo = RGBToLinear(color.rgb);

    #ifdef DEBUG_WHITEWORLD
        albedo = vec3(0.86);
    #endif

    vec4 specularData = vec4(0.0, 0.04, 0.0, 0.0);

    #if defined(MATERIAL_PBR_ENABLED) || defined(LIGHTING_REFLECT_ENABLED)
        if (parameters.customId == BLOCK_WATER) {
            // TODO: add option to make clear?
            // albedo = vec3(0.0);
            specularData = vec4(0.98, 0.02, 0.0, 0.0);
        }
    #endif

    float viewDist = length(localPos);
    vec2 lmcoord = parameters.lightMap;

    #if LIGHTING_MODE == LIGHTING_MODE_ENHANCED
        lmcoord = _pow3(lmcoord);

        const vec3 blockLightColor = pow(vec3(0.922, 0.871, 0.686), vec3(2.2));
        vec3 blockLight = lmcoord.x * blockLightColor;

        const vec3 skyLightColor = pow(vec3(0.961, 0.925, 0.843), vec3(2.2));

        vec3 localSkyLightDir = normalize(mat3(vxModelViewInv) * shadowLightPosition);
        float skyLight_NoLm = max(dot(localSkyLightDir, localNormal), 0.0);

        vec3 localSunLightDir = normalize(mat3(vxModelViewInv) * sunPosition);
        float dayF = smoothstep(-0.15, 0.05, localSunLightDir.y);
        float skyLightBrightness = mix(0.02, 1.00, dayF);
        vec3 skyLight = lmcoord.y * (skyLight_NoLm*0.7 + 0.3) * skyLightBrightness * skyLightColor;

        color.rgb = albedo.rgb * (blockLight + skyLight);

        // TODO: AO
        // color.rgb *= _pow2(vIn.color.a);
    #else
        float sky_lit = dot(localNormal * localNormal, vec3(0.6, 0.25 * localNormal.y + 0.75, 0.8));
        lmcoord.y *= sky_lit;

        lmcoord = LightMapTex(lmcoord);
        vec3 lit = textureLod(lightmap, lmcoord, 0).rgb;
        lit = RGBToLinear(lit);

        color.rgb = albedo.rgb * lit;
    #endif

    #define _far (vxRenderDistance * 16.0)
    float borderFogF = smoothstep(0.94 * _far, _far, viewDist);
    float envFogF = smoothstep(fogStart, fogEnd, viewDist);
    float fogF = max(borderFogF, envFogF);

    vec3 fogColorL = RGBToLinear(fogColor);
    vec3 skyColorL = RGBToLinear(skyColor);
    vec3 localViewDir = normalize(localPos);
    vec3 fogColorFinal = GetSkyFogColor(skyColorL, fogColorL, localViewDir.y);

    color.rgb = mix(color.rgb, fogColorFinal, fogF);

    outFinal = color;

    #ifdef PHOTONICS_LIGHT_ENABLED
        outGeoNormal = packUnorm2x16(OctEncode(localNormal));
    #endif

    #if defined(LIGHTING_REFLECT_ENABLED) || defined(PHOTONICS_LIGHT_ENABLED)
        vec3 viewNormal = mat3(gbufferModelView) * localNormal;
        outTexNormal = packUnorm2x16(OctEncode(viewNormal));

        outReflectSpecular = uvec2(
            packUnorm4x8(vec4(LinearToRGB(albedo), lmcoord.y)),
            packUnorm4x8(specularData));
    #endif
}
