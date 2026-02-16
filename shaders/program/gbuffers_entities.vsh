#include "/lib/constants.glsl"
#include "/lib/common.glsl"

out VertexData {
    vec4 color;
    vec2 lmcoord;
    vec2 texcoord;
//    vec3 localPos;
} vOut;


//uniform mat4 gbufferModelViewInverse;
//uniform vec4 entityColor;

#ifdef TAA_ENABLED
    uniform vec2 taa_offset = vec2(0.0);
#endif


#include "/lib/sampling/lightmap.glsl"


void main() {
    vOut.texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vOut.lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vOut.color = gl_Color;

    vOut.lmcoord = LightMapNorm(vOut.lmcoord);

    vec3 viewPos = mul3(gl_ModelViewMatrix, gl_Vertex.xyz);
//    vOut.localPos = mul3(gbufferModelViewInverse, viewPos);
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);

    #ifdef TAA_ENABLED
        gl_Position.xy += taa_offset * (2.0 * gl_Position.w);
    #endif
}
