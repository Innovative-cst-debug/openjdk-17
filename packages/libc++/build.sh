NEED_SOURCE=false

function configure {
    export SYSROOT="$TOOLCHAIN/sysroot/usr/lib"
    case $ARCH in
        arm64)  TARGET=aarch64-linux-android ;;
        arm)    TARGET=arm-linux-androideabi ;;
        x86)    TARGET=i686-linux-android ;;
        x86_64) TARGET=x86_64-linux-android ;;
        *) echo "Unknown arch $ARCH"; exit 1 ;;
    esac
}

function build_package {
    mkdir -p "$INSTALL_DIR/lib"
    SRC="$SYSROOT/$TARGET"

    # Copy shared + static
    cp "$SRC/libc++_shared.so" "$INSTALL_DIR/lib/"
    cp "$SRC/libc++_static.a" "$INSTALL_DIR/lib/" 2>/dev/null || true

    # Optional: strip to reduce size
    "$TOOLCHAIN/bin/llvm-strip" "$INSTALL_DIR/lib/libc++_shared.so" || true
}

function unset_build_variables {
    unset SYSROOT
    unset SRC
}
