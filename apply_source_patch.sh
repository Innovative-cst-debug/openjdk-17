#!/bin/bash
set -e

apply_patches() {
    echo "[*] Apply patches for $PACKAGE"
    local PATCH_DIR="$PACKAGE_DIRECTORY/patch"
    local SRC_DIR="$PACKAGE_DIRECTORY/src"

    if [ ! -d "$SRC_DIR" ]; then
        echo "[!] Source directory '$SRC_DIR' does not exist, skipping patches."
        return 0
    fi

    cd "$PACKAGE_DIRECTORY/src"

    shopt -s nullglob
    for patch in "$PATCH_DIR"/*.patch; do
        echo "    Applying $(basename "$patch")"
        test -f "$patch" && sed \
            -e "s%@PACKAGE_DIRECTORY@%$PACKAGE_DIRECTORY%g" \
            -e "s%@SRC_DIR@%$SRC_DIR%g" \
            "$patch" | patch --silent -p1 || {
                echo "Patch $(basename "$patch") failed"
                exit 1
            }
    done
    shopt -u nullglob

    cd ../..
}
