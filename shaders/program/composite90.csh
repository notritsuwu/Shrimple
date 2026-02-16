#include "/lib/constants.glsl"
#include "/lib/common.glsl"

#define texSource colortex0
#define imgFinal colorimg0

layout (local_size_x = 16, local_size_y = 16) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);


layout(rgba16f) uniform image2D imgFinal;

uniform sampler2D texSource;

uniform vec2 viewSize;


void main() {
    if (all(lessThan(gl_GlobalInvocationID.xy, viewSize))) {
        vec3 color = texelFetch(texSource, ivec2(gl_GlobalInvocationID.xy), 0).rgb;

        // TODO: tonemap

        color = LinearToRGB(color);

        imageStore(imgFinal, ivec2(gl_GlobalInvocationID.xy), vec4(color, 1.0));
    }
}
