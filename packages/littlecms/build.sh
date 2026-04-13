HAS_SOURCE=false
SRC_URL=https://github.com/mm2/Little-CMS/archive/refs/tags/lcms2.18.tar.gz

configure() {
    export CFLAGS="-fPIC"
    export LDFLAGS=""

    ../configure \
        --prefix=$FULL_BUILD_DIR \
        --host=$TARGET \
        --enable-shared \
        --disable-static
}

build_package() {
    make -j$(nproc)
    make install

    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/share/man

    cp -rf $FULL_BUILD_DIR/bin $INSTALL_DIR
    cp -rf $FULL_BUILD_DIR/share/man/man1 $INSTALL_DIR/share/man
}

function unset_build_variables {
    unset CFLAGS
    unset LDFLAGS
}