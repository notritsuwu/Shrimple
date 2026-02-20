#define RENDER_VERTEX

#include "/lib/constants.glsl"
#include "/lib/common.glsl"


#ifdef MATERIAL_PBR_ENABLED
    in vec4 at_tangent;
#endif

#ifdef MATERIAL_PARALLAX_ENABLED
    in vec4 mc_midTexCoord;
    in vec4 mc_Entity;
#endif

out VertexData {
    vec4 color;
    vec2 lmcoord;
    vec2 texcoord;
    vec3 localPos;
    vec3 localNormal;

    #if defined(RENDER_TERRAIN) && defined(IRIS_FEATURE_FADE_VARIABLE)
        float chunkFade;
    #endif

    #ifdef MATERIAL_PBR_ENABLED
        flat vec4 localTangent;
        flat int blockId;
    #endif

    #ifdef MATERIAL_PARALLAX_ENABLED
        vec3 tangentViewPos;
        flat vec2 atlasTilePos;
        flat vec2 atlasTileSize;
    #endif
} vOut;


uniform mat4 gbufferModelViewInverse;

#ifdef TAA_ENABLED
    uniform vec2 taa_offset = vec2(0.0);
#endif


#include "/lib/sampling/lightmap.glsl"
#include "/lib/tbn.glsl"

#ifdef MATERIAL_PARALLAX_ENABLED
    #include "/lib/sampling/atlas.glsl"
#endif


void main() {
    vOut.texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vOut.lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vOut.color = gl_Color;

    vOut.lmcoord = LightMapNorm(vOut.lmcoord);

    vec3 viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    vOut.localNormal = mat3(gbufferModelViewInverse) * viewNormal;

    #if defined(RENDER_TERRAIN) && defined(IRIS_FEATURE_FADE_VARIABLE)
        vOut.chunkFade = saturate(mc_chunkFade);
    #endif

    vec3 viewPos = mul3(gl_ModelViewMatrix, gl_Vertex.xyz);
    vOut.localPos = mul3(gbufferModelViewInverse, viewPos);
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);

    #ifdef TAA_ENABLED
        gl_Position.xy += taa_offset * (2.0 * gl_Position.w);
    #endif

    #ifdef MATERIAL_PBR_ENABLED
        vec3 viewTangent = normalize(gl_NormalMatrix * at_tangent.xyz);
        vOut.localTangent.xyz = mat3(gbufferModelViewInverse) * viewTangent;
        vOut.localTangent.w = at_tangent.w;
    #endif

    #ifdef MATERIAL_PARALLAX_ENABLED
        GetAtlasBounds(vOut.texcoord, vOut.atlasTilePos, vOut.atlasTileSize);

        mat3 matViewTBN = BuildTBN(viewNormal, viewTangent, at_tangent.w);

        vOut.tangentViewPos = viewPos.xyz * matViewTBN;

        vOut.blockId = int(mc_Entity.x + EPSILON);
    #endif
}
