#include "png_helper.h"
#include <Cocoa/Cocoa.h>

PNG loadPNG(const char *filename) {
  auto picture = (NSBitmapImageRep *)[NSImageRep imageRepWithContentsOfFile:@(filename)];
  PNGSize size = {size_t(picture.size.width), size_t(picture.size.height)};
  unsigned char *data = [picture bitmapData];
  return PNG{.rep = picture, .size = size, .pixels = data};
}

void savePNG(const char *filename, PNGSize size, unsigned char *pixels) {
  NSBitmapImageRep *rep =
      [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels
                                              pixelsWide:(NSInteger)size.width
                                              pixelsHigh:(NSInteger)size.height
                                           bitsPerSample:8
                                         samplesPerPixel:4
                                                hasAlpha:YES
                                                isPlanar:NO
                                          colorSpaceName:NSCalibratedRGBColorSpace
                                             bytesPerRow:4 * (NSInteger)size.width
                                            bitsPerPixel:32];
  NSData *data = [rep representationUsingType:NSPNGFileType
                                   properties:@{
                                     NSImageCompressionFactor : @1
                                   }];
  [data writeToFile:@(filename) atomically:NO];
}
