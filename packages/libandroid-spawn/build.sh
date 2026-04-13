HAS_SOURCE=true

configure() { 
    export SYSROOT="$TOOLCHAIN/sysroot"
    export LIBCXX_ROOT="$PACKAGES_DIRECTORY/libc++/src"
    export LIBCXX_LIB="$LIBCXX_ROOT/build-$ARCH/install/$PREFIX/lib"
    export CFLAGS="--sysroot=$SYSROOT -fPIC -DANDROID"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$SYSROOT -L$LIBCXX_LIB -lc++_shared"

    rsync -a --exclude='build-*' "../" "."
}

build_package() { 
    $CXX $CFLAGS -I. -c posix_spawn.cpp -o posix_spawn.o
    $CXX $LDFLAGS -shared posix_spawn.o -o libandroid-spawn.so
    $AR rcu libandroid-spawn.a posix_spawn.o

    mkdir -p "$INSTALL_DIR/include" "$INSTALL_DIR/lib"

    cp posix_spawn.h "$INSTALL_DIR/include/spawn.h"
    cp libandroid-spawn.a "$INSTALL_DIR/lib/"
    cp libandroid-spawn.so "$INSTALL_DIR/lib/"
}

function unset_build_variables {
    unset SYSROOT
    unset LIBCXX_ROOT
    unset LIBCXX_LIB
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
}
