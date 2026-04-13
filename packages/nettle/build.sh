HAS_SOURCE=false
SRC_URL=https://mirrors.kernel.org/gnu/nettle/nettle-3.10.2.tar.gz

configure() {
    local REL_LIB_DIR="src/$BUILD_DIR/install/$PREFIX/lib"
    local REL_INCLUDE_DIR="src/$BUILD_DIR/install/$PREFIX/include"
    local REL_PC_DIR="$REL_LIB_DIR/pkgconfig"
    export PKG_CONFIG_LIBDIR="$(realpath ../../../"gmp/$REL_PC_DIR")"
    export CFLAGS="-fPIC -isystem$(realpath ../../../"gmp/$REL_INCLUDE_DIR")"
    export LDFLAGS=" -L$(realpath ../../../"gmp/$REL_LIB_DIR")"

    ../configure \
        --host=$TARGET \
        --prefix=$INSTALL_DIR
}

build_package() { 
    make -j$(nproc)
    make install
}

function unset_build_variables {
    unset CFLAGS
    unset LDFLAGS
    unset PKG_CONFIG_LIBDIR
}
