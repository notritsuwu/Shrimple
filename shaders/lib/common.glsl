/*
const int colortex0Format  = RGBA16F;
*/

const float sunPathRotation = 5; // [-60 -55 -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 1 2 5 10 15 20 25 30 35 40 45 50 55 60]

#define TAA_ENABLED
#define TAA_SHARPNESS 50 //[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]
//#define TAA_SHARPEN_HISTORY


//#define _rcp(x) (1.0 / (x))
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
