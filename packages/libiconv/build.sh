HAS_SOURCE=false
SRC_URL="https://mirrors.kernel.org/gnu/libiconv/libiconv-1.18.tar.gz"

configure() { 
    export CFLAGS="-fPIC"
    export LDFLAGS=""

    ../configure \
      --prefix=$FULL_BUILD_DIR \
      --host=$TARGET \
      --enable-extra-encodings \
      --enable-shared \
      --disable-static
}

build_package() { 
    make -j$(nproc)
    make install

    mkdir -p $INSTALL_DIR
    cp -rf $FULL_BUILD_DIR/bin $INSTALL_DIR
    cp -rf $FULL_BUILD_DIR/lib $INSTALL_DIR/lib
}

function unset_build_variables {
    unset CFLAGS
    unset LDFLAGS
}