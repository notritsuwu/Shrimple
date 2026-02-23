float GetOldLighting(const in vec3 localNormal) {
    return saturate(dot(_pow2(localNormal), vec3(0.6, 0.25 * localNormal.y + 0.75, 0.8)));
}
