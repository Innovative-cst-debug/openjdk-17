HAS_SOURCE=true

configure() { 
    NDK=$ANDROID_NDK
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
    SYSROOT="$TOOLCHAIN/sysroot"
    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export AR="$TOOLCHAIN/bin/llvm-ar"

    LIBCXX_ROOT="$PACKAGES_DIRECTORY/libc++/src"
    LIBCXX_LIB="$LIBCXX_ROOT/build-$ARCH/install/$PREFIX/lib"

    export CFLAGS="--sysroot=$SYSROOT -fPIC -DANDROID"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$SYSROOT -L$LIBCXX_LIB -lc++_shared"
}

build_package() { 
    BUILD_DIR="build-$ARCH"
    INSTALL_DIR="$(pwd)/$BUILD_DIR/install/$PREFIX"
    
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    rsync -a --exclude='build-*' "../" "."
    
    $CXX $CFLAGS -I. -c posix_spawn.cpp -o posix_spawn.o
    $CXX $LDFLAGS -shared posix_spawn.o -o libandroid-spawn.so
    $AR rcu libandroid-spawn.a posix_spawn.o

    mkdir -p "$INSTALL_DIR/include" "$INSTALL_DIR/lib"

    cp posix_spawn.h "$INSTALL_DIR/include/spawn.h"
    cp libandroid-spawn.a "$INSTALL_DIR/lib/"
    cp libandroid-spawn.so "$INSTALL_DIR/lib/"

    cd ..
    
    # Unset variables
    unset NDK
    unset TOOLCHAIN
    unset SYSROOT
    unset CC
    unset CXX
    unset AR
    unset LIBCXX_ROOT
    unset LIBCXX_LIB
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset BUILD_DIR
    unset INSTALL_DIR
}
