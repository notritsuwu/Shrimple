#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;

uniform sampler2D depthtex0;
uniform sampler2D TEX_FINAL;
uniform sampler2D TEX_NORMALS;

uniform mat4 gbufferProjectionInverse;


/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 outFinal;

void main() {
    ivec2 uv = ivec2(gl_FragCoord.xy);

    float depth = textureLod(depthtex0, texcoord, 0).r;
    vec3 ndcPos = vec3(texcoord, depth) * 2.0 - 1.0;
    vec3 viewPos = unproject(gbufferProjectionInverse, ndcPos);
    vec3 viewDir = normalize(viewPos);

    vec3 viewNormal = texelFetch(TEX_NORMALS, uv, 0).rgb;
    viewNormal = normalize(viewNormal * 2.0 - 1.0);

    vec3 reflectViewDir = normalize(reflect(viewDir, viewNormal));



    // TODO: trace
    vec3 reflectColor = viewNormal * 0.5 + 0.5;



    float NoVm = max(dot(viewNormal, -viewDir), 0.0);
    reflectColor *= pow(1.0 - NoVm, 5.0);

    vec3 src = texelFetch(TEX_FINAL, uv, 0).rgb;
    outFinal = src + reflectColor;
}
