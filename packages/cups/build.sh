HAS_SOURCE=false
SRC_URL=https://github.com/OpenPrinting/cups/releases/download/v2.4.16/cups-2.4.16-source.tar.gz

configure() { 
    echo "[*] Configuring build for $PACKAGE-$ARCH"
    NDK=$ANDROID_NDK
    TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export CFLAGS="-fPIC"
    export LDFLAGS=""
    export CHOWNPROG=true CHGRPPROG=true
}

build_package() { 
    echo "[*] Building $PACKAGE-$ARCH"

    BUILD_DIR="build-$ARCH"
    INSTALL_DIR="$(pwd)/$BUILD_DIR/install$PREFIX"
    local REL_LIB_DIR="src/$BUILD_DIR/install$PREFIX/lib"
    local REL_INCLUDE_DIR="src/$BUILD_DIR/install$PREFIX/include"
    local REL_PC_DIR="$REL_LIB_DIR/pkgconfig"
    export PKG_CONFIG_LIBDIR="$(realpath ../../"gnutls/$REL_PC_DIR")"
    PKG_CONFIG_LIBDIR+=":$(realpath ../../"nettle/$REL_PC_DIR")"
    PKG_CONFIG_LIBDIR+=":$(realpath ../../"gmp/$REL_PC_DIR")"
    CFLAGS+=" -isystem$(realpath ../../"gnutls/$REL_INCLUDE_DIR")"
    CFLAGS+=" -isystem$(realpath ../../"nettle/$REL_INCLUDE_DIR")"
    CFLAGS+=" -isystem$(realpath ../../"gmp/$REL_INCLUDE_DIR")"
    LDFLAGS+=" -L$(realpath ../../"gnutls/$REL_LIB_DIR")"
    LDFLAGS+=" -L$(realpath ../../"nettle/$REL_LIB_DIR")"
    LDFLAGS+=" -L$(realpath ../../"gmp/$REL_LIB_DIR")"

    rm -rf "$BUILD_DIR"
    local tmpdir="$(mktemp -d)"
    cp -r . "$tmpdir/$BUILD_DIR"
    mv "$tmpdir/$BUILD_DIR" ./
    pushd "$BUILD_DIR"

    ./configure \
        --host=$TARGET \
        --prefix=$INSTALL_DIR \
        --with-tls=gnutls

    make -j$(nproc)
    make install
    popd

    # Unset all toolchain and flags
    unset NDK
    unset TOOLCHAIN
    unset CC
    unset CXX
    unset AR
    unset RANLIB
    unset STRIP
    unset CFLAGS
    unset LDFLAGS
    unset BUILD_DIR
    unset INSTALL_DIR
}
