#include "/lib/constants.glsl"
#include "/lib/common.glsl"

layout (local_size_x = 16, local_size_y = 16) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);


layout(rgba16f) uniform image2D IMG_FINAL;

uniform sampler2D TEX_FINAL;

uniform vec2 viewSize;


void main() {
    if (!all(lessThan(gl_GlobalInvocationID.xy, viewSize))) return;

    vec3 color = texelFetch(TEX_FINAL, ivec2(gl_GlobalInvocationID.xy), 0).rgb;

    #ifdef TONEMAP_ENABLED
        const float wp = 16.0;

        float lum = luminance(color);
//            float tgt = lum * (lum/wp + 1.0) / (lum + 1.0);
        float tgt = lum / (lum + 0.75);
        color *= tgt / lum;
    #endif

    color = LinearToRGB(color);

    imageStore(IMG_FINAL, ivec2(gl_GlobalInvocationID.xy), vec4(color, 1.0));
}
