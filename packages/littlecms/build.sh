HAS_SOURCE=false
SRC_URL=https://github.com/mm2/Little-CMS/archive/refs/tags/lcms2.18.tar.gz

configure() {
    echo "[*] Configuring build for $PACKAGE-$ARCH"

    NDK=$ANDROID_NDK
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang --sysroot=$TOOLCHAIN/sysroot"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++ --sysroot=$TOOLCHAIN/sysroot"
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip

    export CFLAGS="-fPIC"
    export LDFLAGS=""
}

build_package() {
    echo "[*] Building $PACKAGE-$ARCH"

    BUILD_DIR="build-$ARCH"
    INSTALL_DIR="$(pwd)/$BUILD_DIR/install/$PREFIX"
    FULL_BUILD_DIR="$(pwd)/$BUILD_DIR/build/$PREFIX"

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    ../configure \
        --prefix=$FULL_BUILD_DIR \
        --host=$TARGET \
        --enable-shared \
        --disable-static

    make -j$(nproc)
    make install
    
    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/share/man
    
    cp -rf $FULL_BUILD_DIR/bin $INSTALL_DIR
    cp -rf $FULL_BUILD_DIR/share/man/man1 $INSTALL_DIR/share/man

    cd ..

    # Cleanup env
    unset CC CXX AR RANLIB STRIP CFLAGS LDFLAGS BUILD_DIR INSTALL_DIR FULL_BUILD_DIR
}

