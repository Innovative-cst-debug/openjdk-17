HAS_SOURCE=false
SRC_URL=https://github.com/termux/libandroid-shmem/archive/refs/tags/v0.7.tar.gz

configure() { 
    export MAKE_PROCESSES=$(nproc)
    export CFLAGS="--sysroot=$TOOLCHAIN/sysroot -fPIC -D_PATH_TMP='\"/tmp/\"' -include fcntl.h -include unistd.h -DANDROID"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$TOOLCHAIN/sysroot"

    rsync -a --exclude='build-*' ../ .
}

build_package() { 
    make -j $MAKE_PROCESSES CC="$CC" AR="$AR" RANLIB="$RANLIB" STRIP="$STRIP" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    make -j1 install PREFIX="$INSTALL_DIR"
}

function unset_build_variables {
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset MAKE_PROCESSES
}
