#!/bin/bash
set -e

PACKAGE_NAME=com.logicodeum.ide
PREFIX=data/data/$PACKAGE_NAME/files/usr


if [ ! -f ".setup_done" ]; then
    # setup env as well as env variables
    echo "[!] Setup incomplete. Running `./setup.sh setup_env`..."
    source ./scripts/setup.sh setup_env
else
    # Only setup env variables
    source ./scripts/setup.sh setup_env_variables
fi

source ./scripts/download_source.sh
source ./scripts/apply_source_patch.sh
source ./scripts/rsync_source.sh

function unset_variables {
    unset HAS_SOURCE
    unset PACKAGE
    unset PACKAGE_DIRECTORY
    unset BUILD_SCRIPT
    unset ARCH
    unset TARGET
    unset API
    unset SRC_URL
    unset NEED_SOURCE
    unset PACKAGES_DIRECTORY
    unset SOURCE_ALREADY_EXISTS
    unset BUILD_DIR
    unset INSTALL_DIR
    unset FULL_BUILD_DIR
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

  export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
  export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
  export BUILD_DIR="build-$ARCH"
  export INSTALL_DIR="$(pwd)/$BUILD_DIR/install/$PREFIX"
  export FULL_BUILD_DIR="$(pwd)/$BUILD_DIR/build/$PREFIX"
  
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  
  echo "[*] Configuring build for $PACKAGE-$ARCH"
  configure

  echo "[*] Building $PACKAGE-$ARCH"
  build_package
  unset_build_variables
  
  cd ..
}

export PACKAGE=$1
export ARCH=$2
export PACKAGES_DIRECTORY="$(pwd)/packages"
export PACKAGE_DIRECTORY="$PACKAGES_DIRECTORY/$PACKAGE"
export ALL_PACKAGES_BUILD_DIR="$(pwd)/build"
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

if [ -d "$PACKAGE_DIRECTORY/src" ]; then
    SOURCE_ALREADY_EXISTS=true
fi

# Only download if source is not present and source is needed (default true)
if [ "$HAS_SOURCE" = "false" ] && [ "${NEED_SOURCE:-true}" = "true" ] && [ "$SOURCE_ALREADY_EXISTS" != "true" ]; then
    download_and_extract_to_src "$SRC_URL"
fi

# Apply patches when it is sure that source is downloaded
if [ "$SOURCE_ALREADY_EXISTS" != "true" ]; then
    apply_patches
else
    echo "[!] SOURCE_ALREADY_EXISTS is set to true, assuming patches are already applied..."
fi


if [ ! -d "$PACKAGE_DIRECTORY/src" ]; then
    # Initialize empty dir
    mkdir -p "$PACKAGE_DIRECTORY/src"
fi

# Build for all architecture
cd "$PACKAGE_DIRECTORY/src"

configure_and_build $ARCH

cd ../..

unset_variables

echo "[✓] Done: $PACKAGE"
