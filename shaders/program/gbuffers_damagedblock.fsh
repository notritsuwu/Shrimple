#include "/lib/constants.glsl"
#include "/lib/common.glsl"


in VertexData {
    flat uint color;
    vec2 texcoord;
} vIn;

uniform sampler2D gtexture;


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;

void main() {
    vec4 color = texture(gtexture, vIn.texcoord);

    vec4 tint = unpackUnorm4x8(vIn.color);
    color *= tint;

    color.rgb = RGBToLinear(color.rgb) * 0.5;

    outFinal = color;
}
