#!/bin/bash
set -e

# Function: download_and_extract_to_src
# Usage: download_and_extract_to_src <zip_url>
download_and_extract_to_src() {
    local url="$1"
    local tmp_zip="temp_download.zip"
    local src_dir="$(pwd)/packages/$PACKAGE/src"

    if [ -z "$url" ]; then
        echo "Error: No URL provided"
        return 1
    fi

    echo "[*] Downloading source file for $PACKAGE..."
    curl -sSfL "$url" -o "$tmp_zip"

    echo "[*] Extracting source into src directory..."
    rm -rf "$src_dir"
    mkdir -p "$src_dir"
    unzip -oq "$tmp_zip" -d "$src_dir"

    echo "[*] Cleaning up temporary files..."
    rm -f "$tmp_zip"

    echo "[✓] Source downloaded successfully."
}
