#!/bin/bash
# NegativeOS VM Test — Legacy BIOS boot
# Simulates old hardware (P4-era BIOS, no UEFI)
#
# Usage:
#   ./boot-bios.sh                        # boot latest ISO
#   ./boot-bios.sh path/to/custom.iso     # boot specific ISO
#   ./boot-bios.sh --install              # boot with virtual disk

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
ISO="${1:-$(ls -t "$REPO_DIR"/output/x86_64/images/*.iso 2>/dev/null | head -1)}"
DISK="$SCRIPT_DIR/negativeos-test-bios.qcow2"

[ -f "$ISO" ] || { echo "ERROR: No ISO found. Build first or pass ISO path as arg."; exit 1; }
echo "[vm] Booting (Legacy BIOS): $ISO"

if [[ "$*" == *"--install"* ]]; then
    if [ ! -f "$DISK" ]; then
        echo "[vm] Creating 20GB virtual disk..."
        qemu-img create -f qcow2 "$DISK" 20G
    fi
    DISK_ARG="-drive file=$DISK,format=qcow2,if=ide"
else
    DISK_ARG=""
fi

qemu-system-x86_64 \
    -name "NegativeOS (BIOS)" \
    -machine type=pc,accel=kvm \
    -cpu host \
    -smp 4 \
    -m 2048 \
    -cdrom "$ISO" \
    -boot order=d,menu=on \
    $DISK_ARG \
    -vga std \
    -display sdl \
    -device e1000,netdev=net0 \
    -netdev user,id=net0 \
    -rtc base=localtime \
    -usb -device usb-tablet
