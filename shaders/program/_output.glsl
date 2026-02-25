#if defined(LIGHTING_REFLECT_ENABLED) || defined(PHOTONICS_LIGHT_ENABLED)
    layout(location = 0) out vec4 outFinal;
    layout(location = 1) out uint outTexNormal;
    layout(location = 2) out uvec2 outReflectSpecular;

    #ifdef PHOTONICS_LIGHT_ENABLED
        /* RENDERTARGETS: 0,2,3,4 */
        layout(location = 3) out uint outGeoNormal;
    #else
        /* RENDERTARGETS: 0,2,3 */
    #endif
#else
    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 outFinal;
#endif
