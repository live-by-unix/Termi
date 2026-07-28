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

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Create build directory
mkdir -p "$BUILD_DIR"

# Build function
build() {
    local os=$1
    local arch=$2
    local ext=$3
    
    local output_name="${REPO_NAME}-${VERSION}-${os}-${arch}"
    local binary_name="termi"
    
    if [ "$os" = "windows" ]; then
        binary_name="termi.exe"
    fi
    
    info "Building for ${os}/${arch}..."
    
    if GOOS=$os GOARCH=$arch go build \
        -ldflags="-s -w -X main.Version=${VERSION}" \
        -o "${BUILD_DIR}/${output_name}/${binary_name}" \
        "${SOURCE_DIR}/main.go" 2>/dev/null; then
        
        # Create archive
        cd "$BUILD_DIR"
        
        if [ "$os" = "windows" ]; then
            zip -r "${output_name}.zip" "${output_name}"
        else
            tar -czf "${output_name}.tar.gz" "${output_name}"
        fi
        
        # Clean up directory
        rm -rf "${output_name}"
        
        cd "$SOURCE_DIR"
        
        info "Created ${output_name}.${ext}"
    else
        warn "Failed to build for ${os}/${arch} (skipping)"
        return 1
    fi
}

# Build for all platforms
info "Starting build process for Termi v${VERSION}"
info "=========================================="

# Linux
build "linux" "amd64" "tar.gz"
build "linux" "arm64" "tar.gz"

# macOS
build "darwin" "amd64" "tar.gz" || true
build "darwin" "arm64" "tar.gz" || true

# Windows
build "windows" "amd64" "zip" || true
build "windows" "arm64" "zip" || true

info "=========================================="
info "Build complete! Artifacts in ${BUILD_DIR}"
