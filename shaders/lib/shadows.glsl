const float shadowAmbientF = SHADOW_AMBIENT * 0.01;
const float Shadow_DistortF = 0.16;


void distort(inout vec2 pos) {
    pos /= length(pos.xy) + Shadow_DistortF;
}
