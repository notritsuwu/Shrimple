#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#include "/lib/sampling/lightmap.glsl"


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void voxy_emitFragment(VoxyFragmentParameters parameters) {
    vec4 color = parameters.sampledColour;
    color.rgb *= parameters.tinting.rgb;

    vec3 localNormal = vec3(
        uint((parameters.face >> 1) == 2),
        uint((parameters.face >> 1) == 0),
        uint((parameters.face >> 1) == 1)
    ) * (float(int(parameters.face) & 1) * 2.0 - 1.0);

    vec3 albedo = RGBToLinear(color.rgb);

    #if LIGHTING_MODE == LIGHTING_MODE_CUSTOM
        // TODO
        color.rgb = albedo.rgb;
    #else
        vec2 lmcoord = parameters.lightMap;

        float sky_lit = dot(localNormal * localNormal, vec3(0.6, 0.25 * localNormal.y + 0.75, 0.8));
        lmcoord.y *= sky_lit;

        lmcoord = LightMapTex(lmcoord);
        vec3 lit = textureLod(lightmap, lmcoord, 0).rgb;
        lit = RGBToLinear(lit);

        color.rgb = albedo.rgb * lit;
    #endif

    outFinal = color;
}
