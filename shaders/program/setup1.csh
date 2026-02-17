#include "/lib/constants.glsl"
#include "/lib/common.glsl"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const ivec3 workGroups = ivec3(32, 32, 1);

layout(rgba8) uniform writeonly image2D imgBlockLight;

#include "/lib/blocks.glsl"


#define color_White 255, 255, 255
#define color_Amethyst 118, 58, 201
#define color_Candle 230, 144, 76
#define color_CopperBulb 230, 204, 128
#define color_Fire 220, 152, 89


void main() {
    uint blockId = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * 256u;
    vec4 color = vec4(0.0); // [RGB][range]

    switch (blockId) {
        case BLOCK_LIGHT_1:
            color = vec4(color_White, 1);
            break;
        case BLOCK_LIGHT_2:
            color = vec4(color_White, 2);
            break;
        case BLOCK_LIGHT_3:
            color = vec4(color_White, 3);
            break;
        case BLOCK_LIGHT_4:
            color = vec4(color_White, 4);
            break;
        case BLOCK_LIGHT_5:
            color = vec4(color_White, 5);
            break;
        case BLOCK_LIGHT_6:
            color = vec4(color_White, 6);
            break;
        case BLOCK_LIGHT_7:
            color = vec4(color_White, 7);
            break;
        case BLOCK_LIGHT_8:
            color = vec4(color_White, 8);
            break;
        case BLOCK_LIGHT_9:
            color = vec4(color_White, 9);
            break;
        case BLOCK_LIGHT_10:
            color = vec4(color_White, 10);
            break;
        case BLOCK_LIGHT_11:
            color = vec4(color_White, 11);
            break;
        case BLOCK_LIGHT_12:
            color = vec4(color_White, 12);
            break;
        case BLOCK_LIGHT_13:
            color = vec4(color_White, 13);
            break;
        case BLOCK_LIGHT_14:
            color = vec4(color_White, 14);
            break;
        case BLOCK_LIGHT_15:
            color = vec4(color_White, 15);
            break;
        case BLOCK_AMETHYST_BUD_LARGE:
            color = vec4(color_Amethyst, 4);
            break;
        case BLOCK_AMETHYST_BUD_MEDIUM:
            color = vec4(color_Amethyst, 2);
            break;
        case BLOCK_AMETHYST_CLUSTER:
            color = vec4(color_Amethyst, 5);
            break;
        case BLOCK_BEACON:
            color = vec4(color_White, 15);
            break;
        case BLOCK_BLAST_FURNACE_LIT_N:
        case BLOCK_BLAST_FURNACE_LIT_E:
        case BLOCK_BLAST_FURNACE_LIT_S:
        case BLOCK_BLAST_FURNACE_LIT_W:
            color = vec4(196, 159, 114, 6);
            break;
        case BLOCK_BREWING_STAND:
            color = vec4(196, 159, 114, 2);
            break;
        case BLOCK_CANDLE_CAKE:
            color = vec4(color_Candle, 3);
            break;
        case BLOCK_CAVEVINE_BERRIES:
            color = vec4(230, 120, 30, 14);
            break;
        case BLOCK_COPPER_BULB_LIT:
            color = vec4(color_CopperBulb, 15);
            break;
        case BLOCK_COPPER_BULB_EXPOSED_LIT:
            color = vec4(color_CopperBulb, 12);
            break;
        case BLOCK_COPPER_BULB_OXIDIZED_LIT:
            color = vec4(color_CopperBulb, 4);
            break;
        case BLOCK_COPPER_BULB_WEATHERED_LIT:
            color = vec4(color_CopperBulb, 8);
            break;
        case BLOCK_COPPER_TORCH_FLOOR:
        case BLOCK_COPPER_TORCH_WALL_N:
        case BLOCK_COPPER_TORCH_WALL_E:
        case BLOCK_COPPER_TORCH_WALL_S:
        case BLOCK_COPPER_TORCH_WALL_W:
            color = vec4(126, 230, 25, 14);
            break;
        case BLOCK_CREAKING_HEART:
            color = vec4(230, 128, 47, 8);
            break;
        case BLOCK_EYEBLOSSOM_OPEN:
            color = vec4(230, 128, 47, 2);
            break;
        case BLOCK_CRYING_OBSIDIAN:
            color = vec4(99, 17, 165, 10);
            break;
        case BLOCK_END_ROD:
            color = vec4(244, 237, 223, 14);
            break;
        case BLOCK_CAMPFIRE_N_S:
        case BLOCK_CAMPFIRE_W_E:
        case BLOCK_FIRE:
            color = vec4(color_Fire, 15);
            break;
        case BLOCK_FROGLIGHT_OCHRE:
            color = vec4(196, 165, 28, 15);
            break;
        case BLOCK_FROGLIGHT_PEARLESCENT:
            color = vec4(188, 111, 168, 15);
            break;
        case BLOCK_FROGLIGHT_VERDANT:
            color = vec4(118, 195, 104, 15);
            break;


//        case LIGHT_FURNACE_N:
//        case LIGHT_FURNACE_E:
//        case LIGHT_FURNACE_S:
//        case LIGHT_FURNACE_W:
//            lightRange = 6.0;
//            break;
//        case LIGHT_GLOWSTONE:
//            lightRange = 15.0;
//            break;
//        case LIGHT_GLOWSTONE_DUST:
//            lightRange = 6.0;
//            break;
//        case LIGHT_GLOW_LICHEN:
//            lightRange = 7.0;
//            break;
//        case LIGHT_JACK_O_LANTERN_N:
//        case LIGHT_JACK_O_LANTERN_E:
//        case LIGHT_JACK_O_LANTERN_S:
//        case LIGHT_JACK_O_LANTERN_W:
//            lightRange = 15.0;
//            break;
//        case LIGHT_LANTERN:
//            lightRange = 12.0;
//            break;


        case BLOCK_TORCH_FLOOR:
        case BLOCK_TORCH_WALL_N:
        case BLOCK_TORCH_WALL_E:
        case BLOCK_TORCH_WALL_S:
        case BLOCK_TORCH_WALL_W:
            color = vec4(245, 117,  66, 15);
            break;
        case BLOCK_LAVA:
            color = vec4(245, 117,  66, 15);
            break;
    }

    color = (color + 0.5) / 255.0;
    imageStore(imgBlockLight, ivec2(gl_GlobalInvocationID.xy), color);
}
