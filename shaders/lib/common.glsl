/*
const int colortex0Format  = RGBA16F;
*/

const float sunPathRotation = 0; // [-60 -55 -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 1 2 5 10 15 20 25 30 35 40 45 50 55 60]

#define LIGHTING_MODE 0 // [0 1]
#define LIGHTING_COLORED
#define LIGHTING_COLORED_CANDLES
#define LIGHTING_VOXEL_SIZE 128 // [64 128 256]
#define LPV_FRUSTUM_OFFSET 0

#define SHADOWS_ENABLED
const int shadowMapResolution = 1024; // [128 256 512 768 1024 1536 2048 3072 4096 6144 8192]
const float shadowDistance = 100; // [25 50 75 100 125 150 200 250 300 350 400 450 500 600 700 800 900 1000 1200 1400 1600 1800 2000 2200 2400 2600 2800 3000 3200 3400 3600 3800 4000]

#define TAA_ENABLED
#define TAA_SHARPNESS 50 //[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]
//#define TAA_SHARPEN_HISTORY


const bool shadowHardwareFiltering = true;

#ifdef LIGHTING_COLORED
    const float voxelDistance = 64.0;
#endif


//#define _rcp(x) (1.0 / (x))
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

vec3 unproject(const in vec4 pos) {
    return pos.xyz / pos.w;
}

vec3 unproject(const in mat4 matProj, const in vec3 pos) {
    return unproject(matProj * vec4(pos, 1.0));
}
