HAS_SOURCE=false
SRC_URL=https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.11.tar.xz

configure() { 
    local REL_LIB_DIR="src/$BUILD_DIR/install/$PREFIX/lib"
    local REL_INCLUDE_DIR="src/$BUILD_DIR/install/$PREFIX/include"
    local REL_PC_DIR="$REL_LIB_DIR/pkgconfig"

    export PKG_CONFIG_LIBDIR="$(realpath ../../../"gmp/$REL_PC_DIR")"
    PKG_CONFIG_LIBDIR+=":$(realpath ../../../"nettle/$REL_PC_DIR")"
    export CFLAGS="-fPIC -isystem$(realpath ../../../"gmp/$REL_INCLUDE_DIR")"
    export LDFLAGS=" -L$(realpath ../../../"gmp/$REL_LIB_DIR")"

    resync_source

    autoreconf -fi

    ./configure \
        --host=$TARGET \
        --prefix=$INSTALL_DIR \
        --with-included-unistring \
        --with-included-libtasn1 \
        --disable-hardware-acceleration \
        --enable-local-libopts \
        --without-p11-kit \
        --disable-doc \
        --disable-examples
}

build_package() { 
    make -j$(nproc)
    make install
}

function unset_build_variables {
    unset PKG_CONFIG_LIBDIR
    unset CFLAGS
    unset LDFLAGS
}
