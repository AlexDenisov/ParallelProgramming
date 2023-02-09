add_metal_executable(grayscale
  main.mm
  kernel.metal
)
target_link_libraries(grayscale PRIVATE png_helper)
