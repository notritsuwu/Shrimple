//vec3 GetLpvSamplePos(const in vec3 voxelPos, const in vec3 geoNormal, const in vec3 texNormal, const in float offset) {
//    #if MATERIAL_NORMALS != 0
//        vec3 minPos = floor(voxelPos + offset * geoNormal);
//
//        vec3 offsetPos = voxelPos + offset * texNormal;
//
//        offsetPos = clamp(offsetPos, minPos, minPos + 1.0);
//
//        return offsetPos;
//    #else
//        // vec3 samplePos = voxelPos + 0.5 * geoNormal;
//        return voxelPos + offset * geoNormal;
//    #endif
//}

vec3 GetFloodFillSamplePos(const in vec3 voxelPos, const in vec3 geoNormal) {
    return geoNormal * 0.5 + voxelPos;
}

vec3 SampleFloodFill(const in vec3 lpvPos) {
    vec3 texcoord = lpvPos / VoxelBufferSize;

    vec3 lpvSample = (frameCounter % 2) == 0
        ? textureLod(texFloodFillA, texcoord, 0).rgb
        : textureLod(texFloodFillB, texcoord, 0).rgb;

//    vec3 lpvSample = (frameCounter % 2) == 0
//        ? texelFetch(texFloodFillA, ivec3(lpvPos), 0).rgb
//        : texelFetch(texFloodFillB, ivec3(lpvPos), 0).rgb;

    vec3 hsv = RgbToHsv(lpvSample);
    // hsv.z = max(hsv.z, minBlockLight*0.33);
    // hsv.z = _pow2(hsv.z);
    hsv.z = hsv.z * (LpvBlockRange/15.0);
    hsv.z = hsv.z*hsv.z*hsv.z * 3.0;

    vec3 rgb = HsvToRgb(hsv);

    return rgb;
}
