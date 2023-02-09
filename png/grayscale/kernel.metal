#include <metal_stdlib>
using namespace metal;

kernel void grayscale(device uint8_t *pixels [[buffer(0)]],
                      constant size_t *dimension [[buffer(1)]],
                      const uint32_t gid [[thread_position_in_grid]]) {
  if (gid < *dimension) {
    uint32_t px = gid * 4;
    // linear luminance from wikipedia
    uint8_t color = pixels[px] * 0.2126 + pixels[px + 1] * 0.7152 + pixels[px + 2] * 0.0722;
    pixels[px] = color;
    pixels[px + 1] = color;
    pixels[px + 2] = color;
  }
}
