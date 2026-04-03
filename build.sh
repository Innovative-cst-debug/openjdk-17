#!/bin/bash
set -e

PACKAGE_NAME=com.logicodeum.ide
PREFIX=/data/data/$PACKAGE_NAME/files/usr

source ./setup.sh
source ./download_source.sh
source ./apply_source_patch.sh

function unset_variables {
    unset HAS_SOURCE
    unset PACKAGE
    unset PACKAGE_DIRECTORY
    unset BUILD_SCRIPT
    unset ARCH
    unset TARGET
    unset API
    unset NDK
    unset TOOLCHAIN
    unset SRC_URL
    unset NEED_SOURCE
}

function configure_and_build {
  export ARCH=$1

  case $ARCH in
    arm64)
      export TARGET=aarch64-linux-android
      export API=24
      ;;
    arm)
      export TARGET=armv7a-linux-androideabi
      export API=21
      ;;
    x86)
      export TARGET=i686-linux-android
      export API=21
      ;;
    x86_64)
      export TARGET=x86_64-linux-android
      export API=24
      ;;
  esac
  configure
  build_package
}

export PACKAGE=$1
PACKAGE_DIRECTORY="$(pwd)/packages/$PACKAGE"
BUILD_SCRIPT="$PACKAGE_DIRECTORY/build.sh"

if [ -z "$PACKAGE" ]; then
    echo "Usage: ./build.sh <package>"
    unset_variables
    exit 1
fi

if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Package not found: $PACKAGE"
    exit 1
fi

source "$BUILD_SCRIPT"

echo "[*] Reading to build $PACKAGE...."

# Only download if source is not present and source is needed (default true)
if [ "$HAS_SOURCE" = "false" ] && [ "${NEED_SOURCE:-true}" = "true" ]; then
    download_and_extract_to_src "$SRC_URL"
fi

# Apply patches
apply_patches

if [ ! -d "$PACKAGE_DIRECTORY/src" ]; then
    # Initialize empty dir
    mkdir -p "$PACKAGE_DIRECTORY/src"
fi

# Build for all architecture
cd "$PACKAGE_DIRECTORY/src"


for arch in arm64 arm x86 x86_64; do
  configure_and_build $arch
done

cd ../..

unset_variables

echo "[✓] Done: $PACKAGE"
