#!/bin/bash
set -e

# Hard coded for build order
ARCH=$1
for pkg in "zlib" "littlecms" "libiconv" "libc++" "libjpeg-turbo" "libandroid-shmem" "libandroid-spawn" "gmp" "nettle" "gnutls" "openssl" "libcrypt" "cups"; do
  ./build.sh $pkg $ARCH
done

PACKAGES_DIR="./packages"
ROOT_BUILD_DIR="./build"

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

echo "Clearing build..."
rm -rf $ROOT_BUILD_DIR

# Copy include directories
for pkg in "${packages[@]}"; do
    echo "Processing package: $pkg"

    SRC_INCLUDE="$PACKAGES_DIR/$pkg/src/build-$ARCH/install"
    DST_INCLUDE="$ROOT_BUILD_DIR/$ARCH"

    if [ -d "$SRC_INCLUDE" ]; then
        mkdir -p "$DST_INCLUDE"
        cp -r "$SRC_INCLUDE/" "$DST_INCLUDE/"
        echo "Copied include for $pkg [$ARCH] -> $DST_INCLUDE"
    else
        echo "Include folder not found for $pkg [$ARCH], skipping."
    fi

    echo
done

echo "All includes copied."