HAS_SOURCE=false
SRC_URL=https://github.com/termux/libandroid-shmem/archive/refs/tags/v0.7.tar.gz

configure() { 
    NDK=$ANDROID_NDK
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
    MAKE_PROCESSES=$(nproc)
    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"
    export CFLAGS="--sysroot=$TOOLCHAIN/sysroot -fPIC -D_PATH_TMP='\"/tmp/\"' -include fcntl.h -include unistd.h -DANDROID"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$TOOLCHAIN/sysroot"
}

build_package() { 
    BUILD_DIR="build-$ARCH"
    INSTALL_DIR="$(pwd)/$BUILD_DIR/install/$PREFIX"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    rsync -a --exclude='android-ndk-*' --exclude='build-*' ../ .

    make -j $MAKE_PROCESSES CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    make -j1 install PREFIX="$INSTALL_DIR"

    cd ..
    
    # Unset all toolchain and flags
    unset BUILD_DIR
    unset INSTALL_DIR
    unset CC
    unset CXX
    unset AR
    unset RANLIB
    unset STRIP
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset MAKE_PROCESSES
    unset TOOLCHAIN
    unset NDK
}
