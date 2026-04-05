HAS_SOURCE=false
SRC_URL=https://github.com/openjdk/jdk17u/archive/refs/tags/jdk-17.0.18-ga.tar.gz

configure() {
    echo "[*] Configuring $PACKAGE-$ARCH"

    export NDK=$ANDROID_NDK
    export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
    export INSTALL_DIR="$(pwd)/$BUILD_DIR/install/$PREFIX/lib/jvm/java-17"

    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export NM=$TOOLCHAIN/bin/llvm-nm
    export OBJCOPY=$TOOLCHAIN/bin/llvm-objcopy
    export OBJDUMP=$TOOLCHAIN/bin/llvm-objdump

    # Your built dependency root (VERY IMPORTANT)
    export SYSROOT_PREFIX="$ALL_PACKAGES_BUILD_DIR/$ARCH/install/data/data/com.logicodeum.ide/files/usr"

    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export CFLAGS="-fPIC -isystem$SYSROOT_PREFIX/include"
    export CXXFLAGS="-fPIC -isystem$SYSROOT_PREFIX/include"
    export LDFLAGS="-L$SYSROOT_PREFIX/lib -Wl,-rpath=/data/data/com.logicodeum.ide/files/usr/lib"
    export HOST_LLVM_BASE_DIR=/usr/lib/llvm/21 #THIS CHANGES DEPENDING ON WHAT GNU/LINUX DISTRO IS BUILDING OPENJDK. CHANGES IN GITHUB ACTIONS. another possible other location: /usr/lib/llvm-21

    case "$ARCH" in
        arm64) export TARGET_TRIPLE="aarch64-linux-gnu" ;;
        arm)   export TARGET_TRIPLE="arm-linux-gnueabi" ;;
        x86)   export TARGET_TRIPLE="i686-linux-gnu" ;;
        x86_64) export TARGET_TRIPLE="x86_64-linux-gnu" ;;
        *) echo "Unsupported ARCH: $ARCH"; exit 1 ;;
    esac


    # Boot JDK REQUIRED
    export JAVA_HOME=${JAVA_HOME:?Set JAVA_HOME to host JDK}
    export PATH=$JAVA_HOME/bin:$PATH
}

build_package() {
    echo "[*] Building $PACKAGE-$ARCH"

    rm -rf "$INSTALL_DIR"

    export BUILD_DIR="build-$ARCH"

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    rsync -a --exclude='build-$ARCH' ".." "."
    bash ./configure \
        --openjdk-target=$TARGET_TRIPLE \
        --with-toolchain-type=clang \
        --with-debug-level=release \
        --with-jvm-variants=server \
        --disable-warnings-as-errors \
        --disable-precompiled-headers \
        --with-extra-cflags="$CFLAGS -D__ANDROID__=1 -D__TERMUX__=1" \
        --with-extra-cxxflags="$CXXFLAGS -D__ANDROID__=1 -D__TERMUX__=1" \
        --with-extra-ldflags="$LDFLAGS -landroid-shmem -landroid-spawn -liconv" \
        --with-zlib=system \
        --with-libjpeg=system \
        --with-lcms=system \
        --with-vendor-name="Logicodium" \
        --enable-headless-only \
        AR="$AR" \
        NM="$NM" \
        OBJCOPY="$OBJCOPY" \
        OBJDUMP="$OBJDUMP" \
        STRIP="$STRIP" \
        CXXFILT="llvm-cxxfilt" \
        BUILD_CC="$HOST_LLVM_BASE_DIR/bin/clang" \
        BUILD_CXX="$HOST_LLVM_BASE_DIR/bin/clang++" \
        BUILD_NM="$HOST_LLVM_BASE_DIR/bin/llvm-nm" \
        BUILD_AR="$HOST_LLVM_BASE_DIR/bin/llvm-ar" \
        BUILD_OBJCOPY="$HOST_LLVM_BASE_DIR/bin/llvm-objcopy" \
        BUILD_STRIP="$HOST_LLVM_BASE_DIR/bin/llvm-strip" \
        --with-jobs=$(nproc)

    make images -j$(nproc)

    # OpenJDK output directory
    BUILD_DIR=$(find build -type d -name "*-server-release" | head -n 1)

    if [ -z "$BUILD_DIR" ]; then
        echo "Build output not found!"
        exit 1
    fi

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    cp -r "$BUILD_DIR/images/jdk/"* "$INSTALL_DIR/"

    echo "[✓] Installed JDK -> $INSTALL_DIR"

    # Cleanup env (important for next arch)
    unset CC CXX AR RANLIB STRIP NM OBJCOPY OBJDUMP
    unset CFLAGS CXXFLAGS LDFLAGS
    unset SYSROOT_PREFIX
}
