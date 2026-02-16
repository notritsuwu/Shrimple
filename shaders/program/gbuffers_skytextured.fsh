#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 texcoord;
} vIn;

uniform sampler2D gtexture;

uniform int renderStage;


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
    vec4 color = textureLod(gtexture, vIn.texcoord, 0);

    color.rgb *= vIn.color.rgb;

    color.rgb = RGBToLinear(color.rgb);

    outFinal = color;
}
