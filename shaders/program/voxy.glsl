#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#include "/lib/sampling/lightmap.glsl"
#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void voxy_emitFragment(VoxyFragmentParameters parameters) {
    vec4 color = parameters.sampledColour;
    color.rgb *= parameters.tinting.rgb;

    vec3 ndcPos = gl_FragCoord.xyz;
    ndcPos.xy /= viewSize;
    ndcPos = ndcPos * 2.0 - 1.0;

    vec3 viewPos = unproject(vxProjInv, ndcPos);
    vec3 localPos = mul3(vxModelViewInv, viewPos);

    vec3 localNormal = vec3(
        uint((parameters.face >> 1) == 2),
        uint((parameters.face >> 1) == 0),
        uint((parameters.face >> 1) == 1)
    ) * (float(int(parameters.face) & 1) * 2.0 - 1.0);

    // TODO: if vanilla lighting, make foliage have "up" normals

    vec3 albedo = RGBToLinear(color.rgb);
    float viewDist = length(localPos);

    vec2 lmcoord = parameters.lightMap;
    #if LIGHTING_MODE == LIGHTING_MODE_ENHANCED
        // TODO
        color.rgb = albedo.rgb;
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
}
