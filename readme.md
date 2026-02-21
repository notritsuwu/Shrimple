# Shrimple [shader]

A Minecraft Java shader that attempts to maintain a minimal "vanilla" aesthetic, while adding some optional features:
- TAA +CAS. Temporal AntiAliasing reduces jagged edges, and improves subpixel details. Filtered using a modified version of AMD's Contrast-Aware Sharpening.
- Colored Lighting. Uses custom floodfill implementation to replace nearby lighting with a similar RGB variant.
- PBR Materials. Both "OldPbr" and "LabPbr" packs are supported, with a very minimal "PBR" implementation.
- Reflections. Screen-space by default; use Photonics for world-space reflections.
- Parallax/"POM". Also support "smooth" and "sharp" methods.



A Minecraft Java shader that attempts to maintain a minimal "vanilla" aesthetic, while adding some optional features:
 - Waving Plants.
 - Rain puddles & ripples.
 - Volumetric fog lighting.
 - TAA / FXAA (anti-aliasing).
 - Normal / Specular Mapping (PBR).
 - POM (Parallax Occlusion Mapping).
 - Dynamic Soft Shadows / +Cascaded Shadow Mapping.
 - Dynamic Colored Lighting / +Ray-Traced block-light shadows.


## Mod Support

### Photonics
The [Photonics](https://modrinth.com/mod/photonics) mod can be used to replace screen-space reflection with fully world-space reflections. RT lighting is not currently supported.

### Other
 - Applied Energistics 2
 - [Big Globe](https://modrinth.com/mod/big-globe)
 - [Colorwheel](https://modrinth.com/mod/colorwheel)
 - Create (+Deco, +Steam 'N Rails)
 - [Distant Horizons](https://modrinth.com/mod/distanthorizons)
 - [Fractal Lightning](https://modrinth.com/mod/fractal-lightning)
 - Loot Urns
 - Maccaws Lights
 - Modern Industrialization
 - [Physics Mod](https://www.patreon.com/c/Haubna/posts)
 - Redstone Lamps Plus
 - Saro´s Road Blocks
 - Supplementaries
 - [Voxy](https://modrinth.com/mod/voxy)


## FAQ
- **Q:** What happened to the "RTX" profile /ray-traced lighting?  
**A:** I removed it, never should have added to Shrimple

- **Q:** How do I make colored/dynamic/traced shadows work further from player/camera?  
**A:** You can increase the Block Lighting > Advanced > Horizontal/Vertical Bin Counts. Increasing the Bin Size option will also help, but it will reduce the maximum "density" of light sources per area.

- **Q:** How do I make colored/dynamic/traced shadows faster?  
**A:** There are several options under Block Lighting > Advanced settings:
  - Reduce the Horizontal/Vertical Bin Counts to reduce the size of the light volume.
  - Reduce the Block Lighting > Advanced > Bin Size to use smaller bins (less blocks per bin).
  - Reduce the maximum number of lights per-bin.
  - Reduce the Range multiplier for lights.


## Special Thanks
- Fayer: _very_ extensive help with QA, support, repairs, and motivation.
- Builderb0y: help with optimized bit-magic supporting the core of voxelization.
- Bálint: Created the fancy Iris warning, as well as DDA tracing & bit-shifting madness.
- Gri: Supplying texture for, and helping implement, Blue-Noise for smoother RT lighting.
- Tech: Helped implement improved soft shadow filtering & dithering.
