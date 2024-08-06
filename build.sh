#!/usr/bin/env bash

set -euo pipefail

readonly BIN_DIR="bin"
readonly SRC_DIR="src"
readonly MAIN_ASM="main.asm"
readonly MAIN_OBJ="main.o"
readonly EXECUTABLE="main"
readonly NASM_REQUIRED="nasm"
readonly LD_REQUIRED="ld"

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is not installed or not in PATH" >&2
        exit 1
    fi
}

build_project() {
    mkdir -p "${BIN_DIR}"
    check_command "${NASM_REQUIRED}"
    check_command "${LD_REQUIRED}"

    if [ ! -f "${SRC_DIR}/${MAIN_ASM}" ]; then
        echo "Error: ${SRC_DIR}/${MAIN_ASM} not found" >&2
        exit 1
    fi

    nasm -f elf64 -w+all -o "${BIN_DIR}/${MAIN_OBJ}" "${SRC_DIR}/${MAIN_ASM}"
    ld -z noexecstack -o "${BIN_DIR}/${EXECUTABLE}" "${BIN_DIR}/${MAIN_OBJ}"

    echo "Build complete. Executable created at ${BIN_DIR}/${EXECUTABLE}"
}

build_project
