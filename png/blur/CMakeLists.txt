add_metal_executable(blur
  main.mm
  kernel.metal
)
target_link_libraries(blur PRIVATE png_helper)
