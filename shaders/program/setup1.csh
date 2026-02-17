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
#define color_Furnace 196, 159, 114
#define color_RedstoneTorch 239, 78, 42
#define color_RespawnAnchor 99, 17, 165
#define color_SeaPickle 72, 100, 54
#define color_SoulFire 25, 184, 229


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
            color = vec4(color_Furnace, 6);
            break;
        case BLOCK_BREWING_STAND:
            color = vec4(color_Furnace, 2);
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
        case BLOCK_FURNACE_LIT_N:
        case BLOCK_FURNACE_LIT_E:
        case BLOCK_FURNACE_LIT_S:
        case BLOCK_FURNACE_LIT_W:
            color = vec4(color_Furnace, 6);
            break;
        case BLOCK_GLOWSTONE:
            color = vec4(190, 151, 83, 15);
            break;
//        case BLOCK_GLOWSTONE_DUST:
//            color = vec4(190, 151, 83, 6);
//            break;
        case BLOCK_GLOW_LICHEN:
            color = vec4(87, 184, 110, 7);
            break;
        case BLOCK_JACK_O_LANTERN_N:
        case BLOCK_JACK_O_LANTERN_E:
        case BLOCK_JACK_O_LANTERN_S:
        case BLOCK_JACK_O_LANTERN_W:
            color = vec4(196, 179, 83, 15);
            break;
        case BLOCK_LANTERN_CEIL:
        case BLOCK_LANTERN_FLOOR:
            color = vec4(231, 188, 115, 12);
            break;
        case BLOCK_LAVA:
            color = vec4(245, 117, 66, 15);
            break;
        case BLOCK_LIGHTING_ROD_POWERED:
            color = vec4(222, 244, 249, 8);
            break;
        case BLOCK_MAGMA:
            color = vec4(190, 82, 28, 3);
            break;
        case BLOCK_NETHER_PORTAL:
            color = vec4(128, 42, 212, 11);
            break;
        case BLOCK_REDSTONE_LAMP_LIT:
            color = vec4(243, 203, 126, 15);
            break;
        case BLOCK_REDSTONE_ORE_LIT:
            color = vec4(color_RedstoneTorch, 9);
            break;
        case BLOCK_REDSTONE_TORCH_FLOOR_LIT:
        case BLOCK_REDSTONE_TORCH_WALL_N_LIT:
        case BLOCK_REDSTONE_TORCH_WALL_E_LIT:
        case BLOCK_REDSTONE_TORCH_WALL_S_LIT:
        case BLOCK_REDSTONE_TORCH_WALL_W_LIT:
            color = vec4(color_RedstoneTorch, 7);
            break;
        case BLOCK_REDSTONE_WIRE_1:
            color = vec4(color_RedstoneTorch, 1.0);
            break;
        case BLOCK_REDSTONE_WIRE_2:
            color = vec4(color_RedstoneTorch, 1.5);
            break;
        case BLOCK_REDSTONE_WIRE_3:
            color = vec4(color_RedstoneTorch, 2.0);
            break;
        case BLOCK_REDSTONE_WIRE_4:
            color = vec4(color_RedstoneTorch, 2.5);
            break;
        case BLOCK_REDSTONE_WIRE_5:
            color = vec4(color_RedstoneTorch, 3.0);
            break;
        case BLOCK_REDSTONE_WIRE_6:
            color = vec4(color_RedstoneTorch, 3.5);
            break;
        case BLOCK_REDSTONE_WIRE_7:
            color = vec4(color_RedstoneTorch, 4.0);
            break;
        case BLOCK_REDSTONE_WIRE_8:
            color = vec4(color_RedstoneTorch, 4.5);
            break;
        case BLOCK_REDSTONE_WIRE_9:
            color = vec4(color_RedstoneTorch, 5.0);
            break;
        case BLOCK_REDSTONE_WIRE_10:
            color = vec4(color_RedstoneTorch, 5.5);
            break;
        case BLOCK_REDSTONE_WIRE_11:
            color = vec4(color_RedstoneTorch, 6.0);
            break;
        case BLOCK_REDSTONE_WIRE_12:
            color = vec4(color_RedstoneTorch, 6.5);
            break;
        case BLOCK_REDSTONE_WIRE_13:
            color = vec4(color_RedstoneTorch, 7.0);
            break;
        case BLOCK_REDSTONE_WIRE_14:
            color = vec4(color_RedstoneTorch, 7.5);
            break;
        case BLOCK_REDSTONE_WIRE_15:
            color = vec4(color_RedstoneTorch, 8.0);
            break;
        case BLOCK_REPEATER:
            color = vec4(color_RedstoneTorch, 7);
            break;
        case BLOCK_RESPAWN_ANCHOR_1:
            color = vec4(color_RespawnAnchor, 3);
            break;
        case BLOCK_RESPAWN_ANCHOR_2:
            color = vec4(color_RespawnAnchor, 7);
            break;
        case BLOCK_RESPAWN_ANCHOR_3:
            color = vec4(color_RespawnAnchor, 11);
            break;
        case BLOCK_RESPAWN_ANCHOR_4:
            color = vec4(color_RespawnAnchor, 15);
            break;
        case BLOCK_SCULK_CATALYST:
            color = vec4(46, 91, 94, 6);
            break;
        case BLOCK_SEA_LANTERN:
            color = vec4(141, 191, 219, 15);
            break;
        case BLOCK_SEA_PICKLE_WET_1:
            color = vec4(color_SeaPickle, 6);
            break;
        case BLOCK_SEA_PICKLE_WET_2:
            color = vec4(color_SeaPickle, 9);
            break;
        case BLOCK_SEA_PICKLE_WET_3:
            color = vec4(color_SeaPickle, 12);
            break;
        case BLOCK_SEA_PICKLE_WET_4:
            color = vec4(color_SeaPickle, 15);
            break;
        case BLOCK_SHROOMLIGHT:
            color = vec4(216, 120, 52, 15);
            break;
        case BLOCK_SMOKER_LIT_N:
        case BLOCK_SMOKER_LIT_E:
        case BLOCK_SMOKER_LIT_S:
        case BLOCK_SMOKER_LIT_W:
            color = vec4(color_Furnace, 6);
            break;
        case BLOCK_SOUL_CAMPFIRE_LIT_N_S:
        case BLOCK_SOUL_CAMPFIRE_LIT_W_E:
        case BLOCK_SOUL_FIRE:
        case BLOCK_SOUL_LANTERN_CEIL:
        case BLOCK_SOUL_LANTERN_FLOOR:
            color = vec4(color_SoulFire, 12);
            break;
        case BLOCK_SOUL_TORCH_FLOOR:
        case BLOCK_SOUL_TORCH_WALL_N:
        case BLOCK_SOUL_TORCH_WALL_E:
        case BLOCK_SOUL_TORCH_WALL_S:
        case BLOCK_SOUL_TORCH_WALL_W:
            color = vec4(color_SoulFire, 10);
            break;
        case BLOCK_TORCH_FLOOR:
        case BLOCK_TORCH_WALL_N:
        case BLOCK_TORCH_WALL_E:
        case BLOCK_TORCH_WALL_S:
        case BLOCK_TORCH_WALL_W:
            color = vec4(245, 117, 66, 12);
            break;
    }

    color = (color + 0.5) / 255.0;
    imageStore(imgBlockLight, ivec2(gl_GlobalInvocationID.xy), color);
}
