#!/bin/bash
set -e

# Hard coded for build order
for pkg in "zlib" "libiconv" "libc++" "libandroid-shmem" "libandroid-spawn"; do
  ./build.sh $pkg
done

PACKAGES_DIR="./packages"
ROOT_BUILD_DIR="./build"
ARCHS=(arm64 arm x86 x86_64)

mkdir -p "$ROOT_BUILD_DIR"

# List all packages
packages=()
for pkg in "$PACKAGES_DIR"/*; do
    if [ -d "$pkg" ]; then
        packages+=("$(basename "$pkg")")
    fi
done

echo "Found packages: ${packages[*]}"
echo

# Copy include directories
for pkg in "${packages[@]}"; do
    echo "Processing package: $pkg"

    for arch in "${ARCHS[@]}"; do
        SRC_INCLUDE="$PACKAGES_DIR/$pkg/src/build-$arch/include"
        DST_INCLUDE="$ROOT_BUILD_DIR/$arch"

        if [ -d "$SRC_INCLUDE" ]; then
            mkdir -p "$DST_INCLUDE"
            cp -r "$SRC_INCLUDE/"* "$DST_INCLUDE/"
            echo "Copied include for $pkg [$arch] -> $DST_INCLUDE"
        else
            echo "Include folder not found for $pkg [$arch], skipping."
        fi
    done

    echo
done

echo "All includes copied."
