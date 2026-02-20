const float MATERIAL_EMISSION_POWER = 2.0;
const float MATERIAL_EMISSION_SCALE = 16.0;


vec3 mat_normal_lab(const in vec2 normalData) {
    vec2 normal_xy = fma(normalData.xy, vec2(2.0), vec2(-254.0/255.0));
    float normal_z = sqrt(max(1.0 - dot(normal_xy, normal_xy), 0.0));
    return vec3(normal_xy, normal_z);
}

vec3 mat_normal_old(const in vec3 normalData) {
    return normalize(fma(normalData, vec3(2.0), vec3(-1.0)));
}

vec3 mat_normal(const in vec3 normalData) {
    #if MATERIAL_FORMAT == MAT_LABPBR
        return mat_normal_lab(normalData.xy);
    #elif MATERIAL_FORMAT == MAT_OLDPBR
        return mat_normal_old(normalData);
    #else
        return vec3(0.0);
    #endif
}

float mat_occlusion_lab(const in float normal_a) {
    return normal_a;
}

float mat_occlusion_old() {
    return 1.0;
}

float mat_occlusion(const in float normal_a) {
    #if MATERIAL_FORMAT == MAT_LABPBR
        return mat_occlusion_lab(normal_a);
    #else
        return 1.0;
    #endif
}

float mat_roughness(const in float specular_r) {
    #if MATERIAL_FORMAT != MAT_DEFAULT
        return 1.0 - specular_r;
    #else
        return 1.0;
    #endif
}

float mat_metalness_lab(const in float specular_g) {
    return step((229.5/255.0), specular_g);
}

float mat_metalness_old(const in float specular_g) {
    return specular_g;
}

float mat_metalness(const in float specular_g) {
    #if MATERIAL_FORMAT == MAT_LABPBR
        return mat_metalness_lab(specular_g);
    #elif MATERIAL_FORMAT == MAT_OLDPBR
        return mat_metalness_old(specular_g);
    #else
        return 0.0;
    #endif
}

float mat_emission_lab(const in float specular_a) {
    return fract(specular_a);
}

float mat_emission_old(const in float specular_b) {
    return specular_b;
}

float mat_emission(const in vec4 specularData) {
    #if MATERIAL_FORMAT == MAT_LABPBR
        float emission = mat_emission_lab(specularData.a);
    #elif MATERIAL_FORMAT == MAT_OLDPBR
        float emission = mat_emission_old(specularData.b);
    #else
        const float emission = 0.0;
        return 0.0;
    #endif

    return pow(emission, MATERIAL_EMISSION_POWER) * MATERIAL_EMISSION_SCALE;
}
