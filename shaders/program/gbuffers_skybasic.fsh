#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec4 starData;
in vec3 localPos;


uniform int renderStage;
uniform vec3 skyColor;
uniform vec3 fogColor;

#include "/lib/oklab.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
    vec4 color = vec4(0.0);

    if (renderStage == MC_RENDER_STAGE_STARS) {
        color = starData;
        color.rgb = RGBToLinear(color.rgb);
//        color.rgb *= Sky_MoonBrightnessF;
    }
    else {
        vec3 localViewDir = normalize(localPos);
        vec3 skyColorL = GetSkyFogColor(RGBToLinear(skyColor), RGBToLinear(fogColor), localViewDir.y);

        color = vec4(skyColorL, 1.0);
    }

//    color.rgb = RGBToLinear(color.rgb);

    outFinal = color;
}
