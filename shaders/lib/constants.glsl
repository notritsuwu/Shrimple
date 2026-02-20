#define PI 3.1415926538
#define EPSILON 1e-6

#define BLOCK_SOLID 1

#define MAT_DEFAULT 0
#define MAT_LABPBR 2
#define MAT_OLDPBR 1

#define PARALLAX_DEFAULT 0
#define PARALLAX_SHARP 1
#define PARALLAX_SMOOTH 2

#define LIGHTING_MODE_VANILLA 0
#define LIGHTING_MODE_ENHANCED 1

#define TEX_FINAL colortex0
#define IMG_FINAL colorimg0
#define TEX_REFLECT_DATA colortex1
#define TEX_BLOOM_TILES colortex5

const vec3 luma_factor = vec3(0.2126, 0.7152, 0.0722);
