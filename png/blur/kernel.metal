#include <metal_stdlib>
using namespace metal;

kernel void blur(device uint8_t *pixels [[buffer(0)]],
                 device uint8_t *pixelsOut [[buffer(1)]],
                 constant size_t *W [[buffer(2)]],
                 constant size_t *H [[buffer(3)]],
                 constant size_t *blurWindow [[buffer(4)]],
                 const uint2 gid [[thread_position_in_grid]]) {
  long window = *blurWindow;
  long width = *W;
  long height = *H;
  long x = gid.x;
  long y = gid.y;

  if (x < width && y < height) {
    float reds = 0;
    float greens = 0;
    float blues = 0;
    size_t count = 0;
    for (int i = -(window / 2); i <= (window / 2); i++) {
      for (int j = -(window / 2); j <= (window / 2); j++) {
        long _x = x + i;
        long _y = y + j;
        if (_x >= 0 && _x < width && _y >= 0 && _y < height) {
          count++;
          size_t pos = (_y * width + _x) * 4;
          reds += pixels[pos];
          greens += pixels[pos + 1];
          blues += pixels[pos + 2];
        }
      }
    }

    size_t px = (y * width + x) * 4;
    pixelsOut[px] = reds / count;
    pixelsOut[px + 1] = greens / count;
    pixelsOut[px + 2] = blues / count;
    pixelsOut[px + 3] = pixels[px + 3];
  }
}
