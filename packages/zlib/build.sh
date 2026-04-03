HAS_SOURCE=false
SRC_URL=https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.xz

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
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
  
    ../configure \
      --prefix=$(pwd)/build/$PREFIX \
      --shared \
      --uname=Linux
  
    make -j$(nproc)
    make install
    cd ..
    
    # Unset all toolchain and flags
    NDK=$ANDROID_NDK
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
    unset CC
    unset CXX
    unset AR
    unset RANLIB
    unset STRIP
    unset CFLAGS
    unset LDFLAGS
    unset BUILD_DIR
}
