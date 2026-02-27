vec3 GetSkyLightColor(const in float localSunLightDir_y) {
    #ifdef WORLD_NETHER
        const float brightnessF = NETHER_BRIGHTNESS * 0.01;
        return vec3(brightnessF);
    #else
        const vec3 skyLightColor = pow(vec3(0.961, 0.925, 0.843), vec3(2.2));
        const float nightBrightF = OVERWORLD_NIGHT_BRIGHTNESS * 0.01;

        float dayF = smoothstep(-0.15, 0.05, localSunLightDir_y);
        float skyLightBrightness = mix(nightBrightF, 2.00, dayF);

        skyLightBrightness *= mix(1.0, 0.3, rainStrength);

        return skyLightColor * skyLightBrightness;
    #endif
}
