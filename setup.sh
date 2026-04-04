#!/bin/bash
set -e

NDK_VERSION="r26d"
NDK_ZIP="android-ndk-${NDK_VERSION}-linux.zip"
NDK_DIR="$PWD/android-ndk-${NDK_VERSION}"
NDK_URL="https://dl.google.com/android/repository/${NDK_ZIP}"

BOOTJDK_VERSION="17"
BOOTJDK_DIR="$PWD/bootjdk"

PACKAGES=(build-essential clang llvm make cmake pkg-config autoconf automake libtool unzip curl wget git python3 openjdk-17-jdk)

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
if [ ! -d "$NDK_DIR" ]; then
    if [ ! -f "$NDK_ZIP" ]; then
        wget -q --show-progress "$NDK_URL"
    fi
    unzip -q "$NDK_ZIP"
fi

export ANDROID_NDK="$NDK_DIR"
export TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64"
export PATH="$TOOLCHAIN/bin:$PATH"

ls "$TOOLCHAIN/bin" | grep -q clang || { echo "Toolchain missing!"; exit 1; }

echo "[✓] NDK setup done"
echo "ANDROID_NDK=$ANDROID_NDK"
echo "TOOLCHAIN=$TOOLCHAIN"

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
echo "JAVA_HOME=$JAVA_HOME"
