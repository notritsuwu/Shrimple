#include "/lib/constants.glsl"
#include "/lib/common.glsl"


in VertexData {
    vec4 color;
    vec2 texcoord;
} vIn;

uniform sampler2D gtexture;


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;

void main() {
    vec4 color = texture(gtexture, vIn.texcoord);

    color.rgb = RGBToLinear(color.rgb);

    color *= vIn.color;

    outFinal = color;
}
