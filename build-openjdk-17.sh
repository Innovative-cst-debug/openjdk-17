#!/bin/bash
set -e

source ./build-deps.sh

./build.sh openjdk-17 $ARCH
