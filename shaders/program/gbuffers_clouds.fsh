#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 texcoord;
    vec3 localPos;
} vIn;

uniform sampler2D gtexture;

uniform int renderStage;
uniform int isEyeInWater;
uniform vec3 skyColor;
uniform float far;
uniform vec3 fogColor;
uniform float fogDensity;
uniform float fogStart;
uniform float fogEnd;

#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"


#ifdef LIGHTING_REFLECT_ENABLED
    /* RENDERTARGETS: 0,1,2 */
    layout(location = 0) out vec4 outFinal;
    layout(location = 1) out uint outReflectNormal;
    layout(location = 2) out uvec2 outReflectSpecular;
#else
    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 outFinal;
#endif

void main() {
    vec4 color = vec4(1.0);

    color *= vIn.color;

    color.rgb = RGBToLinear(color.rgb);

    float viewDist = length(vIn.localPos);

    float borderFogF = 0.0;//smoothstep(0.94 * far, far, viewDist);
    float envFogF = smoothstep(fogStart, fogEnd, viewDist);
    float fogF = max(borderFogF, envFogF);

    vec3 fogColorL = RGBToLinear(fogColor);
    vec3 skyColorL = RGBToLinear(skyColor);
    vec3 localViewDir = normalize(vIn.localPos);
    vec3 fogColorFinal = GetSkyFogColor(skyColorL, fogColorL, localViewDir.y);

    color.rgb = mix(color.rgb, fogColorFinal, fogF);

    outFinal = color;

    #ifdef LIGHTING_REFLECT_ENABLED
        outReflectNormal = 0u;
        outReflectSpecular = uvec2(0u);
    #endif
}
