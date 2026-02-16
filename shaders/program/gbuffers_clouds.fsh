#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 texcoord;
    vec3 localPos;
//    vec3 localNormal;
} vIn;

uniform sampler2D gtexture;

uniform int renderStage;
uniform vec3 skyColor;
uniform vec3 fogColor;

#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
    vec4 color = vec4(1.0);

    color *= vIn.color;

    color.rgb = RGBToLinear(color.rgb);

    outFinal = color;
}
