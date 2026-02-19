mat3 BuildTBN(const in vec3 normal, const in vec3 tangent, const in float tangentW) {
    vec3 binormal = normalize(cross(tangent, normal));
    if (tangentW < EPSILON) binormal = -binormal;
    return mat3(tangent, binormal, normal);
}
