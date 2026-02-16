#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 lmcoord;
    vec2 texcoord;
//    vec3 localPos;
} vIn;


uniform sampler2D gtexture;

#if LIGHTING_MODE == LIGHTING_MODE_VANILLA
    uniform sampler2D lightmap;
#endif

uniform vec4 entityColor;
uniform float alphaTestRef;

#include "/lib/sampling/lightmap.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
	float mip = textureQueryLod(gtexture, vIn.texcoord).y;

	vec4 color = textureLod(gtexture, vIn.texcoord, mip);

//    #if defined(RENDER_OPAQUE)
        if (color.a < alphaTestRef) discard;
//    #endif

	color *= vIn.color;

    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);

    vec3 albedo = RGBToLinear(color.rgb);

    #if LIGHTING_MODE == LIGHTING_MODE_CUSTOM
        // TODO
        color.rgb = albedo.rgb;
    #else
        vec2 lmcoord = LightMapTex(vIn.lmcoord);
        vec3 lit = textureLod(lightmap, lmcoord, 0).rgb;
        lit = RGBToLinear(lit);

        color.rgb = albedo.rgb * lit;
    #endif

    outFinal = color;
}
