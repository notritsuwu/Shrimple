#include "/lib/constants.glsl"
#include "/lib/common.glsl"


#ifndef RENDER_SOLID
    out vec2 texcoord;
#endif

#include "/lib/shadows.glsl"


void main() {
    #ifndef RENDER_SOLID
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    #endif

    vec3 viewPos = mul3(gl_ModelViewMatrix, gl_Vertex.xyz);
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);

    distort(gl_Position.xy);
}
