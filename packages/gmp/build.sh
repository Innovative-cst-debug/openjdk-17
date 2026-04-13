HAS_SOURCE=false
SRC_URL=https://mirrors.kernel.org/gnu/gmp/gmp-6.3.0.tar.xz

configure() { 
    export CFLAGS="-fPIC"
    export LDFLAGS=""
    
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
}
