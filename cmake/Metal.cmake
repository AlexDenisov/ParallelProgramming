function(_xcrun_find executable output)
  execute_process(COMMAND xcrun -sdk macosx -find ${executable}
    OUTPUT_VARIABLE out
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  set(${output} ${out} PARENT_SCOPE)
endfunction()

_xcrun_find(metal METALC)
_xcrun_find(metallib METALLIBC)

#add_custom_command(OUTPUT ${FOO_FILE}
#  COMMAND ${CMAKE_COMMAND} -E touch ${FOO_FILE}
#  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
#  COMMENT "Creating ${FOO_FILE}"
#  VERBATIM)

#xcrun -sdk macosx metal -c MyLibrary.metal -o MyLibrary.air
#xcrun -sdk macosx metallib MyLibrary.air -o MyLibrary.metallib

function(add_metal_executable name)
  set (cxx_sources)
  set (metal_sources)
  foreach(arg ${ARGN})
    set (source_file "${CMAKE_CURRENT_SOURCE_DIR}/${arg}")
    get_filename_component(ext ${source_file} LAST_EXT)
    if (ext STREQUAL ".metal")
      set (metal_sources ${metal_sources} ${source_file})
    else()
      set (cxx_sources ${cxx_sources} ${source_file})
    endif()
  endforeach()

  set (air_files)
  foreach(metal_file ${metal_sources})
    get_filename_component(name_we ${metal_file} NAME_WE)
    set (air_file ${CMAKE_CURRENT_BINARY_DIR}/${name_we}.air)
    add_custom_command(OUTPUT ${air_file}
      COMMAND ${METALC} -c ${metal_file} -o ${air_file}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      DEPENDS ${metal_file}
      VERBATIM)
    set (air_files ${air_files} ${air_file})
  endforeach()

  set (metal_lib_file ${CMAKE_CURRENT_BINARY_DIR}/${name}.metal.lib)
  add_custom_command(OUTPUT ${metal_lib_file}
    COMMAND ${METALLIBC} ${air_files} -o ${metal_lib_file}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${air_files}
    VERBATIM)
  add_custom_target(${name}.metallib DEPENDS ${metal_lib_file})

  set (metal_helper_h ${CMAKE_CURRENT_BINARY_DIR}/metallib.h)
  set (metal_helper_c ${CMAKE_CURRENT_BINARY_DIR}/metallib.c)

  file(WRITE ${metal_helper_h} "extern \"C\" const char *metallib();\n")
  file(WRITE ${metal_helper_c} "const char *metallib() { return \"${metal_lib_file}\"; }\n")

  add_executable(${name} ${cxx_sources} ${metal_helper_h} ${metal_helper_c})
  add_dependencies(${name} ${name}.metallib)
  target_include_directories(${name} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
  target_link_libraries(${name} PRIVATE "-framework Metal" "-framework Foundation")
endfunction()
