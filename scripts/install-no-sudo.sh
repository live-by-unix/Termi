#!/bin/bash
set -e

# Termi Installer (No Sudo)
# Installs Termi to ~/.local/bin without requiring sudo privileges
# Author: LIVE-BY-UNIX
# Year: 2026

REPO="live-by-unix/termi"
GITHUB_API="https://api.github.com/repos/${REPO}/releases/latest"
INSTALL_DIR="${HOME}/.local/bin"
VERSION="${1:-latest}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Uninstall
if [ "$1" = "--remove" ] || [ "$1" = "uninstall" ]; then
    info "Uninstalling Termi..."
    [ -f "${INSTALL_DIR}/termi" ] && rm -f "${INSTALL_DIR}/termi" && info "Removed binary"
    [ -f "${HOME}/.shelloptions.termioptions" ] && rm -f "${HOME}/.shelloptions.termioptions" && info "Removed config"
    [ -d "${HOME}/.term-plugins" ] && rm -rf "${HOME}/.term-plugins" && info "Removed plugins"
    info "Termi uninstalled successfully"
    exit 0
fi

# Detect platform
detect_platform() {
    local os arch
    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="darwin" ;;
        CYGWIN*|MINGW*) os="windows" ;;
        *) error "Unsupported OS: $(uname -s)" ;;
    esac
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        i386) arch="386" ;;
        *) error "Unsupported arch: $(uname -m)" ;;
    esac
    echo "${os}-${arch}"
}

# Get download URL
get_download_url() {
    local version="$1" platform="$2" ext="tar.gz"
    [[ "$platform" == *"windows"* ]] && ext="zip"

    local api_url
    if [ "$version" = "latest" ]; then
        api_url="${GITHUB_API}"
    else
        api_url="https://api.github.com/repos/${REPO}/releases/tags/${version}"
    fi

    info "Fetching release info from GitHub..."
    local response=$(curl -s "$api_url")
    [ -z "$response" ] && error "Failed to fetch release info"

    local tag=$(echo "$response" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

    local download_url=$(echo "$response" | grep -o "\"browser_download_url\": \"[^\"]*termi-${tag}-${platform}.${ext}\"" | cut -d'"' -f4)
    if [ -z "$download_url" ]; then
        download_url=$(echo "$response" | grep -o "\"browser_download_url\": \"[^\"]*${platform}.${ext}\"" | cut -d'"' -f4)
    fi
    [ -z "$download_url" ] && error "No download URL found for ${platform} (${version})"
    echo "$download_url"
}

# Get checksum URL
get_checksum_url() {
    local version="$1" api_url
    if [ "$version" = "latest" ]; then
        api_url="${GITHUB_API}"
    else
        api_url="https://api.github.com/repos/${REPO}/releases/tags/${version}"
    fi
    local response=$(curl -s "$api_url")
    echo "$response" | grep -o "\"browser_download_url\": \"[^\"]*SHA256SUMS\"" | cut -d'"' -f4
}

# Verify checksum
verify_checksum() {
    local file="$1" checksum_file="$2"
    info "Verifying SHA256 checksum..."
    [ ! -f "$checksum_file" ] && error "Checksum file not found"
    local computed=$(sha256sum "$file" | awk '{print $1}')
    local expected=$(grep "$(basename "$file")" "$checksum_file" | awk '{print $1}')
    if [ -z "$expected" ]; then
        warn "No checksum entry for $(basename "$file")"
        return 0
    fi
    if [ "$computed" = "$expected" ]; then
        info "Checksum passed"
    else
        error "Checksum failed (expected $expected, got $computed)"
    fi
}

# Main
main() {
    info "Termi Installer (No Sudo)"
    info "========================="

    for cmd in curl sha256sum; do
        command -v "$cmd" &> /dev/null || error "Required command not found: $cmd"
    done

    local platform=$(detect_platform)
    info "Detected platform: $platform"

    local download_url=$(get_download_url "$VERSION" "$platform")
    info "Download URL: $download_url"

    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT

    local filename=$(basename "$download_url")
    local filepath="${tmp_dir}/${filename}"

    info "Downloading ${filename}..."
    curl -fsSL "$download_url" -o "$filepath"
    [ ! -f "$filepath" ] && error "Download failed"

    local checksum_url=$(get_checksum_url "$VERSION")
    if [ -n "$checksum_url" ]; then
        local checksum_file="${tmp_dir}/SHA256SUMS"
        info "Downloading checksums..."
        curl -fsSL "$checksum_url" -o "$checksum_file"
        [ -f "$checksum_file" ] && verify_checksum "$filepath" "$checksum_file"
    else
        warn "No checksum file found, skipping verification"
    fi

    info "Extracting archive..."
    cd "$tmp_dir"
    if [[ "$filename" == *.zip ]]; then
        unzip -q "$filename"
    else
        tar -xzf "$filename"
    fi

    local binary=$(find "$tmp_dir" -type f -name "termi" -o -name "termi.exe" | head -n 1)
    [ -z "$binary" ] && error "Binary not found in archive"

    mkdir -p "$INSTALL_DIR"
    info "Installing Termi to ${INSTALL_DIR}..."
    cp "$binary" "${INSTALL_DIR}/termi"
    chmod +x "${INSTALL_DIR}/termi"

    [ ! -f "${INSTALL_DIR}/termi" ] && error "Installation failed"

    info "Installation successful!"
    info "Termi installed at: ${INSTALL_DIR}/termi"
    info "Ensure ${INSTALL_DIR} is in your PATH:"
    info "  export PATH=\"\$PATH:${INSTALL_DIR}\""
    info "Add this to ~/.bashrc or ~/.zshrc for permanence."
    info "Run 'termi --version' to verify."
    info "To uninstall, run: $0 --remove"
}

main "$@"
