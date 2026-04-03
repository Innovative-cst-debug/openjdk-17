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

    echo "[*] Dowloading source file for $PACKAGE..."

    echo "Creating src directory at: $src_dir"
    mkdir -p "$src_dir"

    echo "Downloading ZIP from: $url"
    curl -L "$url" -o "$tmp_zip"

    echo "Extracting ZIP into src directory"
    unzip -q "$tmp_zip" -d "$src_dir"

    echo "Cleaning up temporary files"
    rm -f "$tmp_zip"

    echo "Done"
}

# Example usage:
# download_and_extract_to_src "https://example.com/code.zip"
