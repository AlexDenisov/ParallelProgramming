add_library(png_helper png_helper.h png_helper.mm)
target_include_directories(png_helper PUBLIC ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(png_helper PRIVATE "-framework Cocoa")
