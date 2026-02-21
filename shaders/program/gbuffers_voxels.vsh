#include "/lib/constants.glsl"
#include "/lib/common.glsl"


out VertexData {
//    vec4 color;
    vec2 lmcoord;
    vec3 localPos;
    vec3 localNormal;
} vOut;


//uniform int heldBlockLightValue;
//uniform int heldBlockLightValue2;
uniform mat4 gbufferModelViewInverse;

uniform vec2 taa_offset = vec2(0.0);


#include "/lib/sampling/lightmap.glsl"


void main() {
    vOut.lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
//    vOut.color = gl_Color;

    vOut.lmcoord = LightMapNorm(vOut.lmcoord);

    vec3 viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    vOut.localNormal = mat3(gbufferModelViewInverse) * viewNormal;

    vec3 viewPos = mul3(gl_ModelViewMatrix, gl_Vertex.xyz);
    vOut.localPos = mul3(gbufferModelViewInverse, viewPos);
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);

//    #if defined(LIGHTING_HAND) && LIGHTING_MODE == LIGHTING_MODE_VANILLA && !defined(LIGHTING_COLORED)
//        float dist = length(viewPos);
//
//        float handLightLevel = max(heldBlockLightValue, heldBlockLightValue2);
//        float handLightF = 1.0 - saturate(dist / handLightLevel);
//        vOut.lmcoord.x = max(vOut.lmcoord.x, handLightF);
//    #endif

    #ifdef TAA_ENABLED
        gl_Position.xy += taa_offset * (2.0 * gl_Position.w);
    #endif
}
