#!/bin/bash
set -e

source ./setup.sh
source ./download_source.sh
source ./apply_source_patch.sh

function unset_variables {
    unset HAS_SOURCE
    unset PACKAGE
    unset PACKAGE_DIRECTORY
    unset BUILD_SCRIPT
}

export PACKAGE=$1

if [ -z "$PACKAGE" ]; then
    echo "Usage: ./build.sh <package>"
    unset_variables
    exit 1
fi

PACKAGE_DIRECTORY="$(pwd)/packages/$PACKAGE"
BUILD_SCRIPT="$PACKAGE_DIRECTORY/build.sh"

if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Package not found: $PACKAGE"
    exit 1
fi

source "$BUILD_SCRIPT"

echo "[*] Reading to build $PACKAGE...."

if ! $HAS_SOURCE; then
    download_and_extract_to_src $SRC_URL
fi

apply_patches
build_package

unset_variables

echo "[✓] Done: $PACKAGE"
