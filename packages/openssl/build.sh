HAS_SOURCE=false
SRC_URL=https://github.com/openjdk/jdk17u/archive/refs/tags/jdk-17.0.18-ga.tar.gzTERMUX_PKG_VERSION=1:3.6.1
TERMUX_PKG_VERSION=1:3.6.1
SRC_URL=https://github.com/openssl/openssl/releases/download/openssl-${TERMUX_PKG_VERSION:2}/openssl-${TERMUX_PKG_VERSION:2}.tar.gz

configure() {
    export MAKE_PROCESSES=$(nproc)

    export CFLAGS="--sysroot=$TOOLCHAIN/sysroot -fPIC -DANDROID -DNO_SYSLOG"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$TOOLCHAIN/sysroot"

    resync_source

    # Select OpenSSL platform
    case "$ARCH" in
        arm)
            OPENSSL_PLATFORM="android-arm"
            ;;
        arm64)
            OPENSSL_PLATFORM="android-arm64"
            ;;
        x86)
            OPENSSL_PLATFORM="android-x86"
            ;;
        x86_64)
            OPENSSL_PLATFORM="android-x86_64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    # Configure OpenSSL
    ./Configure "$OPENSSL_PLATFORM" \
        --prefix="$INSTALL_DIR" \
        --openssldir="$INSTALL_DIR/etc/tls" \
        shared \
        zlib-dynamic \
        no-ssl \
        no-hw \
        no-srp \
        no-tests \
        enable-tls1_3
}

build_package() {
    make depend

    make -j$MAKE_PROCESSES \
        CC="$CC" \
        AR="$AR" \
        RANLIB="$RANLIB" \
        STRIP="$STRIP" \
        CFLAGS="$CFLAGS" \
        LDFLAGS="$LDFLAGS"

    # install_sw = no man pages
    make -j1 install_sw

    mkdir -p "$INSTALL_DIR/etc/tls"

    # Install config file
    cp apps/openssl.cnf "$INSTALL_DIR/etc/tls/openssl.cnf"

    sed "s|@INSTALL_DIR@|$INSTALL_DIR|g" \
  		"../../add-trusted-certificate" \
  		> "$INSTALL_DIR/bin/add-trusted-certificate"
  	chmod 700 "$INSTALL_DIR/bin/add-trusted-certificate"
}

unset_build_variables() {
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset MAKE_PROCESSES
}
