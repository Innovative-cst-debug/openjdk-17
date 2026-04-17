HAS_SOURCE=false
SRC_URL=https://github.com/OpenPrinting/cups/releases/download/v2.4.16/cups-2.4.16-source.tar.gz

configure() { 
    export CFLAGS="-fPIC"
    export LDFLAGS=""
    export CHOWNPROG=true CHGRPPROG=true

    local REL_LIB_DIR="src/$BUILD_DIR/install/$PREFIX/lib"
    local REL_INCLUDE_DIR="src/$BUILD_DIR/install/$PREFIX/include"
    local REL_PC_DIR="$REL_LIB_DIR/pkgconfig"

    export PKG_CONFIG_LIBDIR="$(realpath ../../../"gnutls/$REL_PC_DIR")"
    PKG_CONFIG_LIBDIR+=":$(realpath ../../../"nettle/$REL_PC_DIR")"
    PKG_CONFIG_LIBDIR+=":$(realpath ../../../"gmp/$REL_PC_DIR")"
    PKG_CONFIG_LIBDIR+=":$(realpath ../../../"libcrypt/$REL_PC_DIR")"
    CFLAGS+=" -isystem$(realpath ../../../"gnutls/$REL_INCLUDE_DIR")"
    CFLAGS+=" -isystem$(realpath ../../../"nettle/$REL_INCLUDE_DIR")"
    CFLAGS+=" -isystem$(realpath ../../../"gmp/$REL_INCLUDE_DIR")"
    CFLAGS+=" -isystem$(realpath ../../../"libcrypt/$REL_INCLUDE_DIR")"
    LDFLAGS+=" -L$(realpath ../../../"gnutls/$REL_LIB_DIR")"
    LDFLAGS+=" -L$(realpath ../../../"nettle/$REL_LIB_DIR")"
    LDFLAGS+=" -L$(realpath ../../../"gmp/$REL_LIB_DIR")"
    LDFLAGS+=" -L$(realpath ../../../"libcrypt/$REL_LIB_DIR")"

    rsync -a --exclude='build-*' "../" "."

    ./configure \
        --host=$TARGET \
        --prefix=$INSTALL_DIR \
        --with-tls=gnutls \
        --disable-pam
}

build_package() { 
    make -j$(nproc)
    make install
}

function unset_build_variables {
    unset CFLAGS
    unset LDFLAGS
    unset PKG_CONFIG_LIBDIR
    unset CHOWNPROG CHGRPPROG
}
