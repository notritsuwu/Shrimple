#include "/lib/constants.glsl"
#include "/lib/common.glsl"


out VertexData {
    vec4 color;
    vec2 texcoord;
} vOut;

#ifdef TAA_ENABLED
    uniform vec2 taa_offset = vec2(0.0);
#endif


void main() {
    vOut.texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vOut.color = gl_Color;

    vec3 viewPos = mul3(gl_ModelViewMatrix, gl_Vertex.xyz);
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);

    #ifdef TAA_ENABLED
        gl_Position.xy += taa_offset * (2.0 * gl_Position.w);
    #endif
}
