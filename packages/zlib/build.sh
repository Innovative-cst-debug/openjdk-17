HAS_SOURCE=false
SRC_URL=https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.xz

configure() { 
    export CFLAGS="-fPIC"
    export LDFLAGS=""
    
    ../configure \
      --prefix=$INSTALL_DIR \
      --shared \
      --uname=Linux
}

build_package() { 
    make -j$(nproc)
    make install
}

function unset_build_variables {
    unset CFLAGS
    unset LDFLAGS
}