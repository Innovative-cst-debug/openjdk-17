#!/bin/bash
set -e

source ./setup.sh
source ./download_source.sh

function unset_variables {
    unset HAS_SOURCE
    unset PACKAGE
}

export PACKAGE=$1

if [ -z "$PACKAGE" ]; then
    echo "Usage: ./build.sh <package>"
    unset_variables
    exit 1
fi

BUILD_SCRIPT="packages/$PACKAGE/build.sh"

if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Package not found: $PACKAGE"
    exit 1
fi

source "$BUILD_SCRIPT"

echo "[*] Building $PACKAGE...."

if ! $HAS_SOURCE; then
    download_and_extract_to_src $SRC_URL
fi

build_package

echo "[✓] Done: $PACKAGE"
