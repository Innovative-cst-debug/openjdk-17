HAS_SOURCE=true

configure() {
    export CFLAGS="-fPIC"
    export LDFLAGS=""
    export CPPFLAGS=""
    mkdir -p $INSTALL_DIR/lib/
    mkdir -p $INSTALL_DIR/include/

    local REL_LIB_DIR="src/$BUILD_DIR/install/$PREFIX/lib"
    local REL_INCLUDE_DIR="src/$BUILD_DIR/install/$PREFIX/include"
    local REL_PC_DIR="$REL_LIB_DIR/pkgconfig"

    export PKG_CONFIG_LIBDIR="$(realpath ../../../"openssl/$REL_PC_DIR")"
    CFLAGS+=" -isystem$(realpath ../../../"openssl/$REL_INCLUDE_DIR")"
    LDFLAGS+=" -L$(realpath ../../../"openssl/$REL_LIB_DIR")"

    resync_source
}

build_package() {
    $CC $CFLAGS $CPPFLAGS $LDFLAGS -Wall -Wextra -fPIC -shared crypt3.c -lcrypto -o $INSTALL_DIR/lib/libcrypt.so
    cp crypt.h $INSTALL_DIR/include/
    # cp LICENSE $TERMUX_PKG_SRCDIR/
}

function unset_build_variables {
    unset CFLAGS
    unset LDFLAGS
    unset CPPFLAGS
}
