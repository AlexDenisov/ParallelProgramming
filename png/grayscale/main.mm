#include "metallib.h"
#include "png_helper.h"
#include <Metal/Metal.h>
#include <filesystem>
#include <iostream>
#include <vector>

using namespace std::string_literals;

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

int main(int argc, char **argv) {
  // Enables Metal API validation
  setenv("METAL_DEVICE_WRAPPER_TYPE", "1", 0);
  assert(argc != 1);
  std::filesystem::path input(argv[1]);
  std::filesystem::path output = input;
  output.replace_extension("output"s + input.extension().string());
  PNG png = loadPNG(input.c_str());

  id<MTLDevice> device = getMetalDevice();
  auto library = getMetalLibrary(device);
  auto function = [library newFunctionWithName:@"grayscale"];
  assert(function);
  NSError *error = nil;
  auto pipeline = [device newComputePipelineStateWithFunction:function error:&error];
  if (error != nil) {
    std::cerr << "Cannot create compute pipeline: " << error.description.UTF8String << "\n";
    abort();
  }
  auto commandQueue = [device newCommandQueue];
  auto commandBuffer = [commandQueue commandBuffer];

  size_t size = png.size.height * png.size.width * 4;
  id<MTLBuffer> buffer = [device newBufferWithBytes:png.pixels
                                             length:size
                                            options:MTLResourceStorageModeShared];

  auto commandEncoder = [commandBuffer computeCommandEncoder];
  [commandEncoder setComputePipelineState:pipeline];
  [commandEncoder setBuffer:buffer offset:0 atIndex:0];
  [commandEncoder setBytes:&size length:sizeof(size) atIndex:1];

  MTLSize threadgroupSize =
      MTLSizeMake(std::min(pipeline.maxTotalThreadsPerThreadgroup, size), 1, 1);
  MTLSize threadsSize = MTLSizeMake(size / 4, 1, 1);

  [commandEncoder dispatchThreads:threadsSize threadsPerThreadgroup:threadgroupSize];

  [commandEncoder endEncoding];
  [commandBuffer commit];
  [commandBuffer waitUntilCompleted];

  savePNG(output.c_str(), png.size, (unsigned char *)[buffer contents]);

  return 0;
}
