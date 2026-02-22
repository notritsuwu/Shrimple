#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec4 starData;
in vec3 localPos;


uniform float far;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform int renderStage;
uniform int isEyeInWater;
uniform int vxRenderDistance;

#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
    vec4 color = vec4(0.0);

    if (renderStage == MC_RENDER_STAGE_STARS) {
        color = starData;
        color.rgb = RGBToLinear(color.rgb);
    }
    else {
        vec3 localViewDir = normalize(localPos);
        color.rgb = GetSkyFogColor(RGBToLinear(skyColor), RGBToLinear(fogColor), localViewDir.y);
        color.a = 1.0;
    }

    outFinal = color;
}
