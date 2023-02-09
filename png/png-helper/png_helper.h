#pragma once

#import <cstdio>

@class NSBitmapImageRep;

struct PNGSize {
  size_t width;
  size_t height;
};

struct PNG {
  NSBitmapImageRep *rep; // memory owner
  PNGSize size;
  unsigned char *pixels;
};

PNG loadPNG(const char *filename);
void savePNG(const char *filename, PNGSize size, unsigned char *pixels);
