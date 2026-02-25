#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#define TEX_DEPTH depthtex0

in vec2 texcoord;


uniform sampler2D TEX_FINAL;
uniform sampler2D TEX_GI_COLOR;
uniform usampler2D TEX_REFLECT_SPECULAR;


/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;

void main() {
    ivec2 uv = ivec2(gl_FragCoord.xy);
    vec4 lighting = texelFetch(TEX_GI_COLOR, uv, 0);

    uvec2 reflectData = texelFetch(TEX_REFLECT_SPECULAR, uv, 0).rg;
    vec4 reflectDataR = unpackUnorm4x8(reflectData.r);
    lighting.rgb *= RGBToLinear(reflectDataR.rgb);

    vec3 src = texelFetch(TEX_FINAL, uv, 0).rgb;
    outFinal = vec4(src + lighting.rgb * saturate(lighting.a / 8.0), 1.0);
}
