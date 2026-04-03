HAS_SOURCE=false
SRC_URL="https://mirrors.kernel.org/gnu/libiconv/libiconv-1.18.tar.gz"

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

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    ../configure \
      --prefix=$(pwd)/build/$PREFIX \
      --host=$TARGET \
      --enable-extra-encodings \
      --enable-shared \
      --disable-static


    make -j$(nproc)
    make install
    cd ..

    unset CC CXX AR RANLIB STRIP CFLAGS LDFLAGS BUILD_DIR INSTALL_DIR
}
