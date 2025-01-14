#=============================================================================
# Copyright 2019 BlazingDB, Inc.
#     Copyright 2019 Percy Camilo Triveño Aucahuasi <percy@blazingdb.com>
#=============================================================================

# BEGIN macros

macro(CONFIGURE_RAPIDJSON_EXTERNAL_PROJECT)
    # NOTE percy c.gonzales if you want to pass other RAL CMAKE_CXX_FLAGS into this dependency add it by harcoding
    set(RAPIDJSON_CMAKE_ARGS
        " -DRAPIDJSON_BUILD_TESTS=OFF")

    if(CXX_OLD_ABI)
        # enable old ABI for C/C++
        list(APPEND RAPIDJSON_CMAKE_ARGS " -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0")
        list(APPEND RAPIDJSON_CMAKE_ARGS " -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0")
    endif()

    # Download and unpack rapidjson at configure time
    configure_file(${CMAKE_CURRENT_LIST_DIR}/RapidJSON.CMakeLists.txt.cmake ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/thirdparty/rapidjson-download/CMakeLists.txt)

    execute_process(
        COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
        RESULT_VARIABLE result
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/thirdparty/rapidjson-download/
    )

    if(result)
        message(FATAL_ERROR "CMake step for rapidjson failed: ${result}")
    endif()

    execute_process(
        COMMAND ${CMAKE_COMMAND} --build . -- -j8
        RESULT_VARIABLE result
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/thirdparty/rapidjson-download/
    )

    if(result)
        message(FATAL_ERROR "Build step for rapidjson failed: ${result}")
    endif()
endmacro()

# END macros

# BEGIN MAIN #

if (RAPIDJSON_INSTALL_DIR)
    message(STATUS "RAPIDJSON_INSTALL_DIR defined, it will use vendor version from ${RAPIDJSON_INSTALL_DIR}")
    set(RAPIDJSON_ROOT "${RAPIDJSON_INSTALL_DIR}")
else()
    message(STATUS "RAPIDJSON_INSTALL_DIR not defined, it will be built from sources")
    configure_rapidjson_external_project()
    set(RAPIDJSON_ROOT "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/thirdparty/rapidjson-install/")
endif()

find_package(RapidJSON REQUIRED)
set_package_properties(RapidJSON PROPERTIES TYPE REQUIRED PURPOSE "Fast JSON parser/generator for C++ with both SAX/DOM style API." URL "http://rapidjson.org/")

message(STATUS "rapidjson found in ${RAPIDJSON_ROOT}")

include_directories(${RAPIDJSON_INCLUDEDIR} ${RAPIDJSON_INCLUDE_DIR})

link_directories(${RAPIDJSON_LIBDIR})

# END MAIN #
