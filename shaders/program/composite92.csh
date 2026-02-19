#include "/lib/constants.glsl"
#include "/lib/common.glsl"


layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);

layout(rgba16f) uniform image2D IMG_FINAL;

shared vec3 sharedBuffer[18*18];

uniform sampler2D TEX_FINAL;

uniform vec2 viewSize;


ivec2 getSharedUV(const in uint z) {
    return ivec2(z % 18, z / 18);
}

int getSharedIndex(const in ivec2 uv) {
    return uv.y * 18 + uv.x;
}


void main() {
    uint i_base = gl_LocalInvocationIndex * 2u;

    if (i_base < (18*18)) {
        // preload shared memory
        ivec2 uv_base = ivec2(gl_WorkGroupID.xy) * 16 - 1;

        for (uint i = 0u; i < 2u; i++) {
            uint i_shared = i_base + i;

            if (i_shared < (18*18)) {
                ivec2 uv_i = getSharedUV(i_shared);
                vec3 color = texelFetch(TEX_FINAL, uv_base + uv_i, 0).rgb;
                sharedBuffer[i_shared] = color;
            }
        }
    }

    barrier();

    if (all(lessThan(gl_WorkGroupID.xy, viewSize))) {
        // Simplified version of "slow" CAS without upscaling or better diagonals
        // https://github.com/GPUOpen-Effects/FidelityFX-CAS/blob/master/ffx-cas/ffx_cas.h#L423

        const float peak = -1.0 / mix(8.0, 5.0, TAA_SHARPNESS * 0.01);

        ivec2 uv = ivec2(gl_LocalInvocationID.xy) + 1;
        vec3 b = sharedBuffer[getSharedIndex(uv + ivec2( 0,-1))];
        vec3 d = sharedBuffer[getSharedIndex(uv + ivec2(-1, 0))];
        vec3 e = sharedBuffer[getSharedIndex(uv)];
        vec3 f = sharedBuffer[getSharedIndex(uv + ivec2( 1, 0))];
        vec3 h = sharedBuffer[getSharedIndex(uv + ivec2( 0, 1))];

        vec3 area_min = min(min(min(min(d, e), f), b), h);
        vec3 area_max = max(max(max(max(d, e), f), b), h);

        vec3 amp = min(area_min, 1.0 - area_max) / area_max;
        vec3 weight = sqrt(saturate(amp)) * peak;

        vec3 weight_inv = 1.0 / (4.0*weight + 1.0);
        vec3 color = ((b + d + f + h) * weight + e) * weight_inv;
        color = saturate(color);

        imageStore(IMG_FINAL, ivec2(gl_GlobalInvocationID.xy), vec4(color, 1.0));
    }
}
