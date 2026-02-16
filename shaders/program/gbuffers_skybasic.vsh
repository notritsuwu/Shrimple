#include "/lib/constants.glsl"
#include "/lib/common.glsl"

varying vec4 starData;
out vec3 localPos;

//uniform int renderStage;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#ifdef TAA_ENABLED
    uniform vec2 taa_offset = vec2(0.0);
#endif


void main() {
    gl_Position = ftransform();

    bool is_star = all(greaterThan(gl_Color.rgb, vec3(0.0)));
    starData = vec4(gl_Color.rgb, is_star);

    vec3 viewPos = (gbufferProjectionInverse * gl_Position).xyz;
    localPos = mat3(gbufferModelViewInverse) * viewPos;

    #ifdef TAA_ENABLED
        gl_Position.xy += taa_offset * (2.0 * gl_Position.w);
    #endif
}
