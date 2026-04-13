#!/bin/bash
set -e

function resync_source {
  rsync \
    -a \
    --exclude='build-arm64' \
    --exclude='build-arm' \
    --exclude='build-x86' \
    --exclude='build-x86_64' \
    "../" "."
}
