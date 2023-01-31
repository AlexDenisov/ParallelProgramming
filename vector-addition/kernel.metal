#include <metal_stdlib>
using namespace metal;

kernel void matrixAdd(
    device uint32_t *A [[ buffer(0) ]],
    device uint32_t *B [[ buffer(1) ]],
    device uint32_t *C [[ buffer(2) ]],
    constant uint32_t *dimension [[buffer(3)]],
    const uint32_t gid [[thread_position_in_grid]]) {
  uint32_t dim = *dimension;
  if (gid < dim) {
    C[gid] = A[gid] + B[gid];
  }
}
