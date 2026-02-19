#define RENDER_FRAGMENT

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;

uniform sampler2D BUFFER_BLOOM_TILES;

uniform vec2 viewSize;
//uniform int isEyeInWater;
//uniform float nightVision;

#include "/lib/bloom.glsl"


/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 outFinal;

void main() {
    vec3 color = BloomTileUpsample(BUFFER_BLOOM_TILES, -1);

//    if (isEyeInWater == 1) {
//        color *= 3.0;
//    }

    outFinal = color * EffectBloomStrengthF;
}
