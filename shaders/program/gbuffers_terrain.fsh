#define RENDER_TERRAIN

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 lmcoord;
    vec2 texcoord;
//    vec3 localPos;
} vIn;


uniform sampler2D gtexture;

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
	float mip = textureQueryLod(gtexture, vIn.texcoord).y;

	vec4 color = textureLod(gtexture, vIn.texcoord, mip);

    #ifndef RENDER_SOLID
        if (color.a < alphaTestRef) discard;
    #endif

	color.rgb *= vIn.color.rgb;
    vec3 albedo = RGBToLinear(color.rgb);

    outFinal = color;
}
