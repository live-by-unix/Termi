#!/bin/bash
set -e

# Termi Installer (No Sudo)
# Installs Termi to ~/.local/bin without requiring sudo privileges

INSTALL_DIR="${HOME}/.local/bin"
VERSION="1.0.0"
BASE_URL="https://github.com/live-by-unix/Termi/releases/download/v1.0.0-stable-tested"

info(){ echo "[INFO] $1"; }
error(){ echo "[ERROR] $1"; exit 1; }

# Uninstall
if [[ "$1" == "--remove" || "$1" == "uninstall" ]]; then
    rm -f "${INSTALL_DIR}/termi"
    rm -f "${HOME}/.shelloptions.termioptions"
    rm -rf "${HOME}/.term-plugins"
    echo "[INFO] Termi uninstalled successfully"
    exit 0
fi

detect_url(){
    case "$(uname -s)-$(uname -m)" in
        Linux-x86_64)   echo "${BASE_URL}/termi-${VERSION}-linux-amd64.tar.gz" ;;
        Linux-aarch64)  echo "${BASE_URL}/termi-${VERSION}-linux-arm64.tar.gz" ;;
        Darwin-x86_64)  echo "${BASE_URL}/termi-${VERSION}-darwin-amd64.tar.gz" ;;
        Darwin-arm64)   echo "${BASE_URL}/termi-${VERSION}-darwin-arm64.tar.gz" ;;
        MINGW*|CYGWIN*) echo "${BASE_URL}/termi-${VERSION}-windows-amd64.zip" ;;
        *) error "Unsupported platform: $(uname -s)-$(uname -m)" ;;
    esac
}

main(){
    local url=$(detect_url)
    local filename=$(basename "$url")
    local tmp_dir=$(mktemp -d); trap "rm -rf $tmp_dir" EXIT
    local filepath="${tmp_dir}/${filename}"

    info "Downloading ${filename}..."
    curl -fsSL "$url" -o "$filepath" || error "Download failed"

    info "Extracting..."
    cd "$tmp_dir"
    [[ "$filename" == *.zip ]] && unzip -q "$filename" || tar -xzf "$filename"

    local binary=$(find "$tmp_dir" -type f -name "termi" -o -name "termi.exe" | head -n 1)
    [ -z "$binary" ] && error "Binary not found"

    mkdir -p "$INSTALL_DIR"
    cp "$binary" "${INSTALL_DIR}/termi"
    chmod +x "${INSTALL_DIR}/termi"

    info "Installation successful at ${INSTALL_DIR}/termi"
}

main "$@"
