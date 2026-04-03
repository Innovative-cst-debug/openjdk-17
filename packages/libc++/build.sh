NEED_SOURCE=false

function configure {
    NDK="$ANDROID_NDK"
    TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64"
    SYSROOT="$TOOLCHAIN/sysroot/usr/lib"
}

function build_package {
    BUILD_DIR="build-$ARCH"
    INSTALL_DIR="$(pwd)/$BUILD_DIR/install/$PREFIX"

    mkdir -p "$INSTALL_DIR/lib"

    SRC="$SYSROOT/$TARGET"

    # Copy shared + static
    cp "$SRC/libc++_shared.so" "$INSTALL_DIR/lib/"
    cp "$SRC/libc++_static.a" "$INSTALL_DIR/lib/" 2>/dev/null || true

    # Optional: strip to reduce size
    "$TOOLCHAIN/bin/llvm-strip" "$INSTALL_DIR/lib/libc++_shared.so" || true
    
    # Unset
    unset NDK
    unset TOOLCHAIN
    unset SYSROOT
    unset BUILD_DIR
    unset INSTALL_DIR
    unset SRC
}