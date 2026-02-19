#if MATERIAL_FORMAT == MAT_DEFAULT && defined(MC_TEXTURE_FORMAT_LAB_PBR)
    #undef MATERIAL_FORMAT
    #define MATERIAL_FORMAT MAT_LABPBR
#endif


const float MATERIAL_EMISSION_POWER = 2.0;
const float MATERIAL_EMISSION_SCALE = 80.0;


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
