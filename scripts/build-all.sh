#!/bin/bash
set -e

# Termi Build Script
# Builds release binaries for all platforms
# Author: LIVE-BY-UNIX
# Year: 2026

VERSION="1.0.0"
REPO_NAME="termi"
BUILD_DIR="$(pwd)/releases"
SOURCE_DIR="$(pwd)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info(){ echo -e "${GREEN}[INFO]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }

mkdir -p "$BUILD_DIR"

build(){
    local os=$1 arch=$2 ext=$3
    local output_name="${REPO_NAME}-${VERSION}-${os}-${arch}"
    local binary_name="termi"
    [ "$os" = "windows" ] && binary_name="termi.exe"

    info "Building for ${os}/${arch}..."
    mkdir -p "${BUILD_DIR}/${output_name}"

    if GOOS=$os GOARCH=$arch go build \
        -ldflags="-s -w -X main.Version=${VERSION}" \
        -o "${BUILD_DIR}/${output_name}/${binary_name}" \
        "${SOURCE_DIR}/main.go"; then

        if [ "$os" = "windows" ]; then
            zip -r "${BUILD_DIR}/${output_name}.zip" -j "${BUILD_DIR}/${output_name}"
            sha256sum "${BUILD_DIR}/${output_name}.zip" > "${BUILD_DIR}/${output_name}.zip.sha256"
        else
            tar -czf "${BUILD_DIR}/${output_name}.tar.gz" -C "${BUILD_DIR}" "${output_name}"
            sha256sum "${BUILD_DIR}/${output_name}.tar.gz" > "${BUILD_DIR}/${output_name}.tar.gz.sha256"
        fi

        rm -rf "${BUILD_DIR:?}/${output_name}"
        info "Created ${output_name}.${ext} with checksum"
    else
        warn "Failed to build for ${os}/${arch}"
    fi
}

info "Starting build process for Termi v${VERSION}"
info "=========================================="

build "linux" "amd64" "tar.gz"
build "linux" "arm64" "tar.gz"
build "darwin" "amd64" "tar.gz"
build "darwin" "arm64" "tar.gz"
build "windows" "amd64" "zip