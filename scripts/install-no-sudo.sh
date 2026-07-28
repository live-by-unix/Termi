#!/bin/bash
set -e

# Termi Installer (No Sudo)
# Installs Termi to ~/.local/bin without requiring sudo privileges
# Author: LIVE-BY-UNIX
# Year: 2026

INSTALL_DIR="${HOME}/.local/bin"
BASE_URL="https://github.com/live-by-unix/Termi/releases/download/v1.0.0-stable-tested"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info(){ echo -e "${GREEN}[INFO]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
error(){ echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Uninstall
if [[ "$1" == "--remove" || "$1" == "uninstall" ]]; then
    info "Uninstalling Termi..."
    rm -f "${INSTALL_DIR}/termi" && info "Removed binary"
    rm -f "${HOME}/.shelloptions.termioptions" && info "Removed config"
    rm -rf "${HOME}/.term-plugins" && info "Removed plugins"
    info "Termi uninstalled successfully"; exit 0
fi

# Detect platform
detect_platform(){
    case "$(uname -s)-$(uname -m)" in
        Linux-x86_64)   echo "linux-amd64" ;;
        Linux-aarch64)  echo "linux-arm64" ;;
        Darwin-x86_64)  echo "darwin-amd64" ;;
        Darwin-arm64)   echo "darwin-arm64" ;;
        MINGW*|CYGWIN*) echo "windows-amd64" ;;
        *) error "Unsupported platform: $(uname -s)-$(uname -m)" ;;
    esac
}

main(){
    info "Termi Installer (No Sudo)"
    info "========================="

    local platform=$(detect_platform)
    local filename="termi-${VERSION}-${platform}"
    [[ "$platform" == windows* ]] && filename="${filename}.zip" || filename="${filename}.tar.gz"
    local url="${BASE_URL}/${filename}"

    info "Detected platform: $platform"
    info "Download URL: $url"

    local tmp_dir=$(mktemp -d); trap "rm -rf $tmp_dir" EXIT
    local filepath="${tmp_dir}/${filename}"

    info "Downloading ${filename}..."
    curl -fsSL "$url" -o "$filepath" || error "Download failed"

    info "Extracting archive..."
    cd "$tmp_dir"
    [[ "$filename" == *.zip ]] && unzip -q "$filename" || tar -xzf "$filename"

    local binary=$(find "$tmp_dir" -type f -name "termi" -o -name "termi.exe" | head -n 1)
    [ -z "$binary" ] && error "Binary not found"

    mkdir -p "$INSTALL_DIR"
    cp "$binary" "${INSTALL_DIR}/termi"
    chmod +x "${INSTALL_DIR}/termi"

    info "Installation successful!"
    info "Termi installed at: ${INSTALL_DIR}/termi"
    info "Ensure ${INSTALL_DIR} is in your PATH"
    info "Run 'termi --version' to verify"
    info "To uninstall, run: $0 --remove"
}

main "$@"
