#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#define texSource colortex0

in vec2 texcoord;

uniform sampler2D texSource;

#include "/lib/sampling/bayer.glsl"


void main() {
    vec3 color = texelFetch(texSource, ivec2(gl_FragCoord.xy), 0).rgb;

    color += (GetBayerValue(ivec2(gl_FragCoord.xy)) - 0.5) / 255.0;

    gl_FragData[0] = vec4(color, 1.0);
}
