layout(rgba16f) uniform writeonly image2D imgPhotonicsIndirect;


void write_indirect(vec3 color) {
    imageStore(imgPhotonicsIndirect, ivec2(gl_FragCoord.xy), vec4(color, 1.0));
}
