#!/bin/bash
set -e

# Function: download_and_extract_to_src
# Usage: download_and_extract_to_src <archive_url>
download_and_extract_to_src() {
    local url="$1"
    local tmp_file
    local src_dir="$(pwd)/packages/$PACKAGE/src"

    if [ -z "$url" ]; then
        echo "Error: No URL provided"
        return 1
    fi

    # Determine temporary file name and type
    if [[ "$url" == *.tar.xz ]]; then
        tmp_file="temp_download.tar.xz"
        tar_flags="-xJf"
    elif [[ "$url" == *.tar.gz ]] || [[ "$url" == *.tgz ]]; then
        tmp_file="temp_download.tar.gz"
        tar_flags="-xzf"
    else
        echo "Error: Unsupported archive format. Only .tar.xz and .tar.gz are supported."
        return 1
    fi

    echo "[*] Downloading source file for $PACKAGE..."
    curl -sSfL "$url" -o "$tmp_file"

    echo "[*] Extracting source into src directory..."
    rm -rf "$src_dir"
    mkdir -p "$src_dir"

    tar "$tar_flags" "$tmp_file" -C "$src_dir" --strip-components=1

    echo "[*] Cleaning up temporary files..."
    rm -f "$tmp_file"

    echo "[✓] Source downloaded successfully."
}