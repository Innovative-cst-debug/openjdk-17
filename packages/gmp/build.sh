HAS_SOURCE=false
SRC_URL=https://mirrors.kernel.org/gnu/gmp/gmp-6.3.0.tar.xz

configure() { 
    echo "[*] Configuring build for $PACKAGE-$ARCH"
    NDK=$ANDROID_NDK
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export CFLAGS="-fPIC"
    export LDFLAGS=""
}

build_package() { 
    echo "[*] Building $PACKAGE-$ARCH"

    BUILD_DIR="build-$ARCH"
    INSTALL_DIR="$(pwd)/$BUILD_DIR/install$PREFIX"

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    pushd "$BUILD_DIR"

    ../configure \
        --host=$TARGET \
        --prefix=$INSTALL_DIR

    make -j$(nproc)
    make install
    popd

    # Unset all toolchain and flags
    unset NDK
    unset TOOLCHAIN
    unset CC
    unset CXX
    unset AR
    unset RANLIB
    unset STRIP
    unset CFLAGS
    unset LDFLAGS
    unset BUILD_DIR
    unset INSTALL_DIR
}
