/*
const int colortex0Format  = RGBA16F;
const int colortex1Format  = RG32UI;
const int colortex5Format  = RGBA16F;
*/


const float sunPathRotation = 0; // [-60 -55 -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 1 2 5 10 15 20 25 30 35 40 45 50 55 60]

#define MATERIAL_FORMAT 0 // [0 1 2]

#define MATERIAL_PARALLAX_ENABLED
#define MATERIAL_PARALLAX_TYPE 1 // [0 1 2]
#define MATERIAL_PARALLAX_SAMPLES 32 // [8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96]
#define MATERIAL_PARALLAX_DEPTH 25 // [5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]
#define MATERIAL_PARALLAX_MAX_DIST 48.0

#define LIGHTING_MODE 0 // [0 1]
//#define LIGHTING_COLORED
//#define LIGHTING_REFLECT_ENABLED
#define LIGHTING_COLORED_CANDLES
#define LIGHTING_VOXEL_SIZE 128 // [64 128 256]
#define LPV_FRUSTUM_OFFSET 0

//#define SHADOWS_ENABLED
const int shadowMapResolution = 1024; // [128 256 512 768 1024 1536 2048 3072 4096 6144 8192]
const float shadowDistance = 100; // [25 50 75 100 125 150 200 250 300 350 400 450 500 600 700 800 900 1000 1200 1400 1600 1800 2000 2200 2400 2600 2800 3000 3200 3400 3600 3800 4000]

//#define BLOOM_ENABLED
#define BLOOM_STRENGTH 2.0 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0 5.2 5.4 5.6 5.8 6.0 8 10 12 14 16 18 20]

#define TONEMAP_ENABLED

#define TAA_ENABLED
#define TAA_SHARPNESS 50 //[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]
//#define TAA_SHARPEN_HISTORY

//#define DEBUG_WHITEWORLD


const bool shadowHardwareFiltering = true;

#ifdef LIGHTING_COLORED
    const float voxelDistance = 64.0;
#endif

#if MATERIAL_FORMAT == MAT_DEFAULT && defined(MC_TEXTURE_FORMAT_LAB_PBR)
    #undef MATERIAL_FORMAT
    #define MATERIAL_FORMAT MAT_LABPBR
#endif

#if MATERIAL_FORMAT != 0
    #define MATERIAL_PBR_ENABLED
#else
    #undef MATERIAL_PARALLAX_ENABLED
#endif

#ifdef BLOOM_ENABLED
#endif


#define _pow2(x) (x*x)
#define _pow3(x) (x*x*x)
#define _saturate(x) (clamp(x, 0.0, 1.0))

float saturate(const in float x) {return _saturate(x);}
vec2 saturate(const in vec2 x) {return _saturate(x);}
vec3 saturate(const in vec3 x) {return _saturate(x);}
vec4 saturate(const in vec4 x) {return _saturate(x);}

float minOf(const in vec2 vec) {return min(vec[0], vec[1]);}
float minOf(const in vec3 vec) {return min(min(vec[0], vec[1]), vec[2]);}
float minOf(const in vec4 vec) {return min(min(vec[0], vec[1]), min(vec[2], vec[3]));}

float maxOf(const in vec2 vec) {return max(vec[0], vec[1]);}
float maxOf(const in vec3 vec) {return max(max(vec[0], vec[1]), vec[2]);}

int sumOf(ivec2 vec) {return vec.x + vec.y;}
int sumOf(ivec3 vec) {return vec.x + vec.y + vec.z;}
float sumOf(vec3 vec) {return vec.x + vec.y + vec.z;}

float luminance(const in vec3 color) {
    return dot(color, luma_factor);
}

float RGBToLinear(const in float value) {
    return pow(value, 2.2);
}

vec3 RGBToLinear(const in vec3 color) {
    return pow(color, vec3(2.2));
}

vec3 RGBToLinear(const in vec3 color, const in float gamma) {
    return pow(color, vec3(gamma));
}

float LinearToRGB(const in float color) {
    return pow(color, (1.0 / 2.2));
}

vec3 LinearToRGB(const in vec3 color, const in float gamma) {
    return pow(color, vec3(1.0 / gamma));
}

vec3 LinearToRGB(const in vec3 color) {
    return LinearToRGB(color, 2.2);
}

vec3 mul3(const in mat4 matrix, const in vec3 vector) {
    return mat3(matrix) * vector + matrix[3].xyz;
}

vec3 project(const in vec4 pos) {
    return pos.xyz / pos.w;
}

vec3 project(const in mat4 matProj, const in vec3 pos) {
    return project(matProj * vec4(pos, 1.0));
}
