
configure() {
    export CFLAGS="-fPIC"
    export LDFLAGS=""
    export CPPFLAGS=""
    mkdir -p $INSTALL_DIR/lib/
    mkdir -p $INSTALL_DIR/include/
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
