#!/bin/bash
set -e

SETUP_MARKER="$PWD/.setup_done"

NDK_VERSION="r26d"
NDK_ZIP="android-ndk-${NDK_VERSION}-linux.zip"
NDK_DIR="$PWD/android-ndk-${NDK_VERSION}"
NDK_URL="https://dl.google.com/android/repository/${NDK_ZIP}"

BOOTJDK_VERSION="17"
BOOTJDK_DIR="$PWD/bootjdk"

function apply_ndk_patches() {
    echo "[*] Applying NDK patches..."

    local PATCH_DIR="ndk-patches"
    local NDK_SRC="$NDK_DIR"

    if [ ! -d "$PATCH_DIR" ]; then
        echo "[!] No ndk-patches directory found, skipping..."
        return 0
    fi

    cd "$NDK_SRC"

    shopt -s nullglob
    for patch in "../$PATCH_DIR"/*.patch; do
        echo "    Applying $(basename "$patch")"

        patch -p1 --forward --silent < "$patch" || {
            echo "[!] Patch $(basename "$patch") failed, skipping..."
        }
    done
    shopt -u nullglob

    cd - > /dev/null

    echo "[✓] NDK patches applied"
}

function setup_env_variables {
  echo "[*] Setting up environment variables..."
  export ANDROID_NDK="$NDK_DIR"
  export NDK=$ANDROID_NDK
  export TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64"
  export PATH="$TOOLCHAIN/bin:$PATH"

  export AR=$TOOLCHAIN/bin/llvm-ar
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
  export NM=$TOOLCHAIN/bin/llvm-nm
  export OBJCOPY=$TOOLCHAIN/bin/llvm-objcopy
  export OBJDUMP=$TOOLCHAIN/bin/llvm-objdump

  export JAVA_HOME="$BOOTJDK_DIR"
  export PATH="$JAVA_HOME/bin:$PATH"
}

function setup_env {
    echo "[*] Setting up environment packages..."
    PACKAGES=(build-essential gtk-doc-tools autopoint clang llvm make cmake pkg-config autoconf automake libtool unzip curl wget git python3 openjdk-17-jdk)
    
    echo "[*] Updating package list..."
    sudo rm -f /etc/apt/sources.list.d/yarn.list
    sudo apt-get update
    
    echo "[*] Installing required packages..."
    for pkg in "${PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            sudo apt-get install -y "$pkg"
        fi
    done
    
    echo "[*] Setting up Android NDK..."
    export ANDROID_NDK="$NDK_DIR"
    export NDK=$ANDROID_NDK
    export TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64"
    export PATH="$TOOLCHAIN/bin:$PATH"
  
    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export NM=$TOOLCHAIN/bin/llvm-nm
    export OBJCOPY=$TOOLCHAIN/bin/llvm-objcopy
    export OBJDUMP=$TOOLCHAIN/bin/llvm-objdump

    if [ ! -d "$NDK_DIR" ]; then
        if [ ! -f "$NDK_ZIP" ]; then
            wget -q --show-progress "$NDK_URL"
        fi
        unzip -q "$NDK_ZIP"
        
        apply_ndk_patches
    fi
    
    ls "$TOOLCHAIN/bin" | grep -q clang || { echo "Toolchain missing!"; exit 1; }
    
    echo "[✓] NDK setup done"
    echo "    ANDROID_NDK=$ANDROID_NDK"
    echo "    TOOLCHAIN=$TOOLCHAIN"
    
    echo
    echo "[*] Setting up Boot JDK..."
    
    # Detect JAVA_HOME
    JAVA_BIN=$(readlink -f $(which javac))
    JAVA_HOME_DETECTED=$(dirname $(dirname "$JAVA_BIN"))
    
    echo "[*] Detected system JAVA_HOME=$JAVA_HOME_DETECTED"
    
    # Copy to local bootjdk (clean environment)
    rm -rf "$BOOTJDK_DIR"
    mkdir -p "$BOOTJDK_DIR"
    cp -r "$JAVA_HOME_DETECTED"/* "$BOOTJDK_DIR/"
    
    export JAVA_HOME="$BOOTJDK_DIR"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    echo "[✓] Boot JDK ready"
    echo "    JAVA_HOME=$JAVA_HOME"
    touch "$SETUP_MARKER"
}

if [ "$1" = "setup_env_variables" ]; then
    setup_env_variables
elif [ "$1" = "setup_env" ]; then
    setup_env
fi