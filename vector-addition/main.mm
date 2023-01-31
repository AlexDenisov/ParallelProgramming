#include "metallib.h"
#include <Metal/Metal.h>
#include <iostream>
#include <vector>

id<MTLDevice> getMetalDevice() { return [MTLCopyAllDevices() lastObject]; }

id<MTLLibrary> getMetalLibrary(id<MTLDevice> device) {
  NSError *error = nil;
  auto library = [device newLibraryWithFile:@(metallib()) error:&error];
  if (error != nil) {
    std::cerr << "Cannot create metal library: " << metallib() << ": "
              << error.description.UTF8String << "\n";
    abort();
  }
  return library;
}

id<MTLBuffer> randomBuffer(id<MTLDevice> device, size_t size) {
  std::vector<uint32_t> content(size, 42);
  for (auto &c : content) {
    c = arc4random_uniform(200);
  }
  return [device newBufferWithBytes:content.data() length:size * sizeof(uint32_t) options:MTLResourceStorageModeShared];
}

id<MTLBuffer> emptyBuffer(id<MTLDevice> device, size_t size) {
  std::vector<uint32_t> content(size, 0);
  return [device newBufferWithBytes:content.data() length:size * sizeof(uint32_t) options:MTLResourceStorageModeShared];
}

void dumpBuffer(id<MTLBuffer> buffer) {
  uint32_t *contents = (uint32_t *)[buffer contents];
  for (size_t i = 0; i < [buffer length] / sizeof(uint32_t); i++) {
    std::cout << contents[i] << ' ';
  }
  std::cout << '\n';
}

int main() {
  // Enables Metal API validation
  setenv("METAL_DEVICE_WRAPPER_TYPE", "1", 0);
  id<MTLDevice> device = getMetalDevice();
  auto library = getMetalLibrary(device);
  auto function = [library newFunctionWithName:@"matrixAdd"];
  assert(function);
  NSError *error = nil;
  auto pipeline = [device newComputePipelineStateWithFunction:function error:&error];
  if (error != nil) {
    std::cerr << "Cannot create compute pipeline: " << error.description.UTF8String << "\n";
    abort();
  }
  auto commandQueue = [device newCommandQueue];
  auto commandBuffer = [commandQueue commandBuffer];
  [commandBuffer setLabel:@"Matrix Addition"];

  const size_t size = 10;
  auto A = randomBuffer(device, size);
  auto B = randomBuffer(device, size);
  auto C = emptyBuffer(device, size);

  auto commandEncoder = [commandBuffer computeCommandEncoder];
  [commandEncoder setComputePipelineState:pipeline];
  [commandEncoder setBuffer:A offset:0 atIndex:0];
  [commandEncoder setBuffer:B offset:0 atIndex:1];
  [commandEncoder setBuffer:C offset:0 atIndex:2];
  [commandEncoder setBytes:&size length:sizeof(size) atIndex:3];

  [commandEncoder dispatchThreads:MTLSizeMake(size, 1, 1)
            threadsPerThreadgroup:MTLSizeMake(std::min(pipeline.maxTotalThreadsPerThreadgroup, size), 1, 1)];

  [commandEncoder endEncoding];
  [commandBuffer commit];
  [commandBuffer waitUntilCompleted];

  dumpBuffer(A);
  dumpBuffer(B);
  dumpBuffer(C);

  return 0;
}
