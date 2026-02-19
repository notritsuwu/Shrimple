#include "/lib/constants.glsl"
#include "/lib/common.glsl"

out vec2 texcoord;

uniform vec2 viewSize;


void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
