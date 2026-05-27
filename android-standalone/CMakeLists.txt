cmake_minimum_required(VERSION 3.20)

# Project setup
project(clpeak-android-standalone)

# Support 16 KB page sizes on Android 15+
set(ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES ON CACHE BOOL "" FORCE)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set the clpeak root directory
set(CLPEAK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
get_filename_component(CLPEAK_GIT_ROOT "${CLPEAK_ROOT}" ABSOLUTE)
include(${CLPEAK_ROOT}/src/common/cmake/version.cmake)

# Build OpenCL stub (provides headers + dlopen-based libOpenCL)
add_subdirectory(${CLPEAK_ROOT}/android/app/src/main/cpp/libopencl-stub ${CMAKE_BINARY_DIR}/libopencl-stub)

# -----------------------------------------------------------------------
# Shared common library
# -----------------------------------------------------------------------
add_subdirectory(${CLPEAK_ROOT}/src/common ${CMAKE_BINARY_DIR}/common)

# -----------------------------------------------------------------------
# OpenCL backend — predefine OpenCL vars so src/opencl/CMakeLists.txt
# skips find_package and uses the stub
# -----------------------------------------------------------------------
set(CLPEAK_ENABLE_OPENCL ON)
set(CLPEAK_OPENCL_PREDEFINED ON)
set(OpenCL_LIBRARIES OpenCL)
set(OpenCL_INCLUDE_DIRS
    ${CLPEAK_ROOT}/android/app/src/main/cpp/libopencl-stub/include
    ${CLPEAK_ROOT}/include
)
# HPP_FOUND is needed by the OpenCL CMakeLists for the opencl.hpp path
set(HPP_FOUND "${CLPEAK_ROOT}/android/app/src/main/cpp/libopencl-stub/include")
add_subdirectory(${CLPEAK_ROOT}/src/opencl ${CMAKE_BINARY_DIR}/opencl)

# -----------------------------------------------------------------------
# Standalone executable
# -----------------------------------------------------------------------
add_executable(clpeak
    ${CLPEAK_ROOT}/src/cli/main.cpp
    ${CLPEAK_ROOT}/src/cli/logger_cli.cpp
)

target_link_libraries(clpeak
    peak_common
    peak_opencl
    log
    atomic
    dl
)

target_include_directories(clpeak PRIVATE
    ${CLPEAK_ROOT}/include
    ${CLPEAK_ROOT}/include/common
)

target_compile_definitions(clpeak PRIVATE CL_TARGET_OPENCL_VERSION=300)
target_compile_options(clpeak PRIVATE -O2 -fexceptions)

# Version
clpeak_setup_version(clpeak GIT_ROOT ${CLPEAK_GIT_ROOT})
