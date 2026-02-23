#include "/lib/constants.glsl"
#include "/lib/common.glsl"


in vec2 texcoord;

uniform sampler2D TEX_FINAL;

uniform vec2 viewSize;
uniform int frameCounter;

#include "/lib/sampling/bayer.glsl"

#ifdef DEBUG
    #include "/lib/text.glsl"

    #ifdef PHOTONICS
        #include "/photonics/photonics.glsl"
    #endif
#endif


void main() {
    vec3 color = texelFetch(TEX_FINAL, ivec2(gl_FragCoord.xy), 0).rgb;


    #ifdef DEBUG
        beginText(ivec2(gl_FragCoord.xy * 0.5), ivec2(4, viewSize.y/2 - 24));

        text.bgCol = vec4(0.0, 0.0, 0.0, 0.6);
        text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);

        printString((_L, _i, _g, _h, _t, _s, _colon, _space));
        printUnsignedInt(ph_light_count);
        printLine();

        endText(color);
    #endif


    color += (GetBayerValue(ivec2(gl_FragCoord.xy)) - 0.5) / 255.0;

    gl_FragData[0] = vec4(color, 1.0);
}
