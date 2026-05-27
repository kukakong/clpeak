#!/bin/bash

# Final build script for clpeak Android (32-bit and 64-bit)

set -e

# Configuration
ANDROID_NDK="/opt/android-sdk/ndk/25.2.9519653"
CLPEAK_DIR="/workspace/clpeak"
OUTPUT_DIR="${CLPEAK_DIR}/build-android-output"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Function to build for a specific ABI
build() {
    local ABI=$1
    local BUILD_DIR="${CLPEAK_DIR}/build-${ABI}"
    
    echo "=== Building clpeak for ${ABI} ==="
    
    # Clean build dir
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    # Configure CMake
    cmake -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK}/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="${ABI}" \
        -DANDROID_PLATFORM=android-28 \
        -DCMAKE_BUILD_TYPE=Release \
        "${CLPEAK_DIR}/android-standalone"
    
    # Build
    cmake --build . -j$(nproc)
    
    # Strip debug info
    "${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip" clpeak
    
    # Copy to output
    cp clpeak "${OUTPUT_DIR}/clpeak-${ABI}"
    echo "Successfully built clpeak-${ABI}"
    ls -lh "${OUTPUT_DIR}/clpeak-${ABI}"
    
    cd "${CLPEAK_DIR}"
}

# Build both ABIs
build "armeabi-v7a"
build "arm64-v8a"

# Verify outputs
echo ""
echo "=== Build complete! ==="
echo "Outputs in ${OUTPUT_DIR}:"
ls -lh "${OUTPUT_DIR}"
