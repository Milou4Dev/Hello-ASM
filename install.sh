#!/usr/bin/env bash

set -euo pipefail

readonly NASM_VERSION="2.16.03"
readonly NASM_URL="https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz"
readonly TEMP_DIR=$(mktemp -d)

trap 'cleanup' EXIT

cleanup() {
    rm -rf "${TEMP_DIR}"
}

download_nasm() {
    echo "Downloading NASM ${NASM_VERSION}..."
    curl -sSL "${NASM_URL}" -o "${TEMP_DIR}/nasm.tar.gz" || {
        echo "Failed to download NASM. Please check your internet connection and try again." >&2
        exit 1
    }
}

extract_nasm() {
    echo "Extracting archive..."
    tar -xzf "${TEMP_DIR}/nasm.tar.gz" -C "${TEMP_DIR}" || {
        echo "Failed to extract NASM archive." >&2
        exit 1
    }
}

configure_nasm() {
    echo "Configuring NASM..."
    (cd "${TEMP_DIR}/nasm-${NASM_VERSION}" && ./configure) || {
        echo "Failed to configure NASM." >&2
        exit 1
    }
}

build_nasm() {
    echo "Building NASM..."
    (cd "${TEMP_DIR}/nasm-${NASM_VERSION}" && make -j"$(nproc)") || {
        echo "Failed to build NASM." >&2
        exit 1
    }
}

install_nasm() {
    echo "Installing NASM..."
    (cd "${TEMP_DIR}/nasm-${NASM_VERSION}" && sudo make install) || {
        echo "Failed to install NASM. Please check your permissions." >&2
        exit 1
    }
}

verify_installation() {
    echo "Verifying NASM installation..."
    command -v nasm >/dev/null 2>&1 || {
        echo "NASM installation failed. The 'nasm' command is not available." >&2
        exit 1
    }
    installed_version=$(nasm --version | awk '{print $3}')
    [[ "$installed_version" == "$NASM_VERSION" ]] || {
        echo "NASM version mismatch. Expected ${NASM_VERSION}, but got ${installed_version}." >&2
        exit 1
    }
    echo "NASM ${NASM_VERSION} has been successfully installed."
}

main() {
    download_nasm
    extract_nasm
    configure_nasm
    build_nasm
    install_nasm
    verify_installation
}

main
