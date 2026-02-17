#define FOG_HORIZON_F 0.02

float fogify(const in float x, const in float w) {
    return w / (x * x + w);
}

vec3 GetSkyFogColor(const in vec3 skyColor, const in vec3 fogColor, const in float viewUpF) {
    #ifdef WORLD_NETHER
        return fogColor;
    #else
        float fogF = fogify(max(viewUpF, 0.0), FOG_HORIZON_F);
        return LabMixLinear(skyColor, fogColor, fogF);
    #endif
}
