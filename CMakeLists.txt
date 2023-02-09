cmake_minimum_required(VERSION 3.24)
project(ParallelProgramming C CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)

include(${CMAKE_SOURCE_DIR}/cmake/Metal.cmake)

add_subdirectory(vector-addition)
add_subdirectory(png)
