HAS_SOURCE=false
SRC_URL="https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.1.4/libjpeg-turbo-3.1.4.tar.gz"

configure() {
    export SYSROOT="$TOOLCHAIN/sysroot"
    
    case $ARCH in
      arm64) export ANDROID_ABI=arm64-v8a ;;
      arm)   export ANDROID_ABI=armeabi-v7a ;;
      x86)   export ANDROID_ABI=x86 ;;
      x86_64) export ANDROID_ABI=x86_64 ;;
    esac

    export CFLAGS="--sysroot=$SYSROOT -fPIC"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$SYSROOT"

    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$FULL_BUILD_DIR \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_SYSTEM_VERSION=$API \
        -DCMAKE_ANDROID_ARCH_ABI=$ANDROID_ABI \
        -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
        -DCMAKE_ANDROID_STL_TYPE=c++_shared \
        -DCMAKE_C_COMPILER=$CC \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_FIND_ROOT_PATH=$SYSROOT \
        -DWITH_JPEG8=1 \
        -DENABLE_SHARED=ON \
        -DENABLE_STATIC=OFF
}

# =========================
# Build step (CMake)
# =========================
build_package() {

    make -j$(nproc)
    make install

    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/share/man
    
    cp -rf $FULL_BUILD_DIR/bin $INSTALL_DIR
    cp -rf $FULL_BUILD_DIR/share/man/man1 $INSTALL_DIR/share/man
}

function unset_build_variables {
    unset CFLAGS CXXFLAGS LDFLAGS
}

post_build() {
    echo "[*] Running post-build checks for $ARCH"

    cd "$FULL_BUILD_DIR"

    if ! readelf -d lib/libjpeg.so | grep -q '(SONAME).*\[libjpeg\.so\.'; then
        echo "[!] SONAME for libjpeg.so is not properly set"
        exit 1
    fi

    for f in lib/libjpeg.so.8 lib/libturbojpeg.so.0; do
        if [ ! -e "$f" ]; then
            echo "[!] Missing expected file: $f"
            exit 1
        fi
    done

    cd - > /dev/null

    echo "[✓] Post-build checks passed for $ARCH"
}