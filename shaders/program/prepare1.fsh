#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;


uniform vec3 fogColor;


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
    outFinal = vec4(RGBToLinear(fogColor), 1.0);
}
