#!/bin/bash
set -e

# Termi Installer (With Sudo)
# Installs Termi system-wide to /usr/local/bin using sudo
# Author: LIVE-BY-UNIX
# Year: 2026

REPO="live-by-unix/termi"
GITHUB_API="https://api.github.com/repos/${REPO}/releases/latest"
INSTALL_DIR="/usr/local/bin"
VERSION="${1:-latest}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check for uninstall flag
if [ "$1" = "--remove" ] || [ "$1" = "uninstall" ]; then
    info "Uninstalling Termi (system-wide)..."
    
    if [ -f "${INSTALL_DIR}/termi" ]; then
        sudo rm -f "${INSTALL_DIR}/termi"
        info "Removed binary from ${INSTALL_DIR}/termi"
    else
        warn "Termi binary not found in ${INSTALL_DIR}/termi"
    fi
    
    if [ -f "${HOME}/.shelloptions.termioptions" ]; then
        rm -f "${HOME}/.shelloptions.termioptions"
        info "Removed configuration file"
    fi
    
    if [ -d "${HOME}/.term-plugins" ]; then
        rm -rf "${HOME}/.term-plugins"
        info "Removed plugins directory"
    fi
    
    info "Termi uninstalled successfully"
    exit 0
fi

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    if ! command -v sudo &> /dev/null; then
        error "This script requires sudo privileges, but sudo is not available"
    fi
    info "This script requires sudo privileges for system-wide installation"
fi

# Detect OS and architecture
detect_platform() {
    local os=""
    local arch=""
    
    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="darwin" ;;
        CYGWIN*) os="windows" ;;
        MINGW*)  os="windows" ;;
        *)       error "Unsupported operating system: $(uname -s)" ;;
    esac
    
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        arm64)   arch="arm64" ;;
        i386)    arch="386" ;;
        *)       error "Unsupported architecture: $(uname -m)" ;;
    esac
    
    echo "${os}-${arch}"
}

# Get download URL for a specific version
get_download_url() {
    local version="$1"
    local platform="$2"
    local ext=""
    
    if [[ "$platform" == *"windows"* ]]; then
        ext="zip"
    else
        ext="tar.gz"
    fi
    
    if [ "$version" = "latest" ]; then
        local api_url="${GITHUB_API}"
    else
        local api_url="https://api.github.com/repos/${REPO}/releases/tags/${version}"
    fi
    
    info "Fetching release information from GitHub..."
    local response=$(curl -s "$api_url")
    
    if [ -z "$response" ]; then
        error "Failed to fetch release information from GitHub"
    fi
    
    # Extract download URL
    local download_url=$(echo "$response" | grep -o "\"browser_download_url\": \"[^\"]*termi-${version}-${platform}.${ext}\"" | cut -d'"' -f4)
    
    if [ -z "$download_url" ]; then
        # Try without version prefix in filename
        download_url=$(echo "$response" | grep -o "\"browser_download_url\": \"[^\"]*${platform}.${ext}\"" | cut -d'"' -f4)
    fi
    
    if [ -z "$download_url" ]; then
        error "Could not find download URL for ${platform} with version ${version}"
    fi
    
    echo "$download_url"
}

# Get checksum URL
get_checksum_url() {
    local version="$1"
    
    if [ "$version" = "latest" ]; then
        local api_url="${GITHUB_API}"
    else
        local api_url="https://api.github.com/repos/${REPO}/releases/tags/${version}"
    fi
    
    local response=$(curl -s "$api_url")
    local checksum_url=$(echo "$response" | grep -o "\"browser_download_url\": \"[^\"]*SHA256SUMS\"" | cut -d'"' -f4)
    
    echo "$checksum_url"
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local checksum_file="$2"
    
    info "Verifying SHA256 checksum..."
    
    if [ ! -f "$checksum_file" ]; then
        error "Checksum file not found: $checksum_file"
    fi
    
    local computed_checksum=$(sha256sum "$file" | awk '{print $1}')
    local expected_checksum=$(grep "$(basename "$file")" "$checksum_file" | awk '{print $1}')
    
    if [ -z "$expected_checksum" ]; then
        warn "Could not find checksum for $(basename "$file") in checksum file"
        return 0
    fi
    
    if [ "$computed_checksum" = "$expected_checksum" ]; then
        info "Checksum verification passed"
        return 0
    else
        error "Checksum verification failed"
        echo "Expected: $expected_checksum"
        echo "Computed: $computed_checksum"
        return 1
    fi
}

# Main installation
main() {
    info "Termi Installer (System-Wide with Sudo)"
    info "======================================="
    
    # Check for required commands
    for cmd in curl sha256sum; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Required command not found: $cmd"
        fi
    done
    
    # Detect platform
    local platform=$(detect_platform)
    info "Detected platform: $platform"
    
    # Get download URL
    local download_url=$(get_download_url "$VERSION" "$platform")
    info "Download URL: $download_url"
    
    # Create temp directory
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    # Download file
    local filename=$(basename "$download_url")
    local filepath="${tmp_dir}/${filename}"
    
    info "Downloading ${filename}..."
    curl -fsSL "$download_url" -o "$filepath"
    
    if [ ! -f "$filepath" ]; then
        error "Failed to download file"
    fi
    
    # Download checksum
    local checksum_url=$(get_checksum_url "$VERSION")
    if [ -n "$checksum_url" ]; then
        local checksum_file="${tmp_dir}/SHA256SUMS"
        info "Downloading checksums..."
        curl -fsSL "$checksum_url" -o "$checksum_file"
        
        if [ -f "$checksum_file" ]; then
            verify_checksum "$filepath" "$checksum_file"
        fi
    else
        warn "Checksum file not found, skipping verification"
    fi
    
    # Extract file
    info "Extracting archive..."
    cd "$tmp_dir"
    
    if [[ "$filename" == *.zip ]]; then
        unzip -q "$filename"
    else
        tar -xzf "$filename"
    fi
    
    # Find the binary
    local binary=$(find "$tmp_dir" -type f -name "termi" -o -name "termi.exe" | head -n 1)
    
    if [ -z "$binary" ]; then
        error "Could not find termi binary in archive"
    fi
    
    # Install binary with sudo
    info "Installing Termi to ${INSTALL_DIR} (requires sudo)..."
    sudo cp "$binary" "${INSTALL_DIR}/termi"
    sudo chmod +x "${INSTALL_DIR}/termi"
    
    # Verify installation
    if [ ! -f "${INSTALL_DIR}/termi" ]; then
        error "Installation failed"
    fi
    
    info "Installation successful!"
    info ""
    info "Termi has been installed to: ${INSTALL_DIR}/termi"
    info ""
    info "The binary is now available system-wide for all users."
    info ""
    info "Run 'termi --version' to verify the installation."
    info ""
    info "To uninstall, run: sudo $0 --remove"
}

main "$@"
