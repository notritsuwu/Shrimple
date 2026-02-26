float SSAO_GetFade(const in float viewDist) {
    return smoothstep(0.9 * far, far, viewDist);
}
