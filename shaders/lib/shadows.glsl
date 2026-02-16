const float Shadow_DistortF = 0.16;
const bool shadowHardwareFiltering = true;


void distort(inout vec2 pos) {
    pos /= length(pos.xy) + Shadow_DistortF;
}
