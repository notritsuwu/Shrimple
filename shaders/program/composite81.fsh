#define RENDER_FRAGMENT

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;

uniform sampler2D BUFFER_BLOOM_TILES;

uniform vec2 viewSize;

#include "/lib/bloom.glsl"


/* RENDERTARGETS: 15 */
layout(location = 0) out vec3 outFinal;

void main() {
    outFinal = BloomTileUpsample(BUFFER_BLOOM_TILES, 5);
}
