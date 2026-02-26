layout(location = 0) out vec4 outFinal;

#ifdef DEFERRED_NORMAL_ENABLED // defined(LIGHTING_REFLECT_ENABLED) || defined(PHOTONICS_LIGHT_ENABLED)
    layout(location = 1) out uint outGeoNormal;
    layout(location = 2) out uint outTexNormal;

    #ifdef DEFERRED_SPECULAR_ENABLED
        /* RENDERTARGETS: 0,4,2,3 */
        layout(location = 3) out uvec2 outReflectSpecular;
    #else
        /* RENDERTARGETS: 0,4,2 */
    #endif
#else
    /* RENDERTARGETS: 0 */
#endif
