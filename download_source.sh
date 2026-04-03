#!/bin/bash
set -e

# Function: download_and_extract_to_src
# Usage: download_and_extract_to_src <tar_xz_url>
download_and_extract_to_src() {
    local url="$1"
    local tmp_file="temp_download.tar.xz"
    local src_dir="$(pwd)/packages/$PACKAGE/src"

    if [ -z "$url" ]; then
        echo "Error: No URL provided"
        return 1
    fi

    echo "[*] Downloading source file for $PACKAGE..."
    curl -sSfL "$url" -o "$tmp_file"

    echo "[*] Extracting source into src directory..."
    rm -rf "$src_dir"
    mkdir -p "$src_dir"

    # Extract .tar.xz
    tar -xJf "$tmp_file" -C "$src_dir" --strip-components=1

    echo "[*] Cleaning up temporary files..."
    rm -f "$tmp_file"

    echo "[✓] Source downloaded successfully."
}
