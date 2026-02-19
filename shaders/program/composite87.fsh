#define RENDER_FRAGMENT

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;

uniform sampler2D TEX_BLOOM_TILES;

uniform vec2 viewSize;

#include "/lib/bloom.glsl"


/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 outFinal;

void main() {
    vec3 color = BloomTileUpsample(TEX_BLOOM_TILES, -1);

    outFinal = color * EffectBloomStrengthF;
}
