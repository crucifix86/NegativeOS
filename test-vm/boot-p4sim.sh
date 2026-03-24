#!/bin/bash
# NegativeOS VM Test — P4-era simulation
# Deliberately weak: 1 core, 512MB RAM, no KVM acceleration, old CPU model
# Use this to verify the i686 ISO works on minimal hardware

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Default to i686 ISO for P4 sim
ISO="${1:-$(ls -t "$REPO_DIR"/output/i686/images/*.iso 2>/dev/null | head -1)}"
# Fall back to x86_64 if no i686 build yet
[ -f "$ISO" ] || ISO="$(ls -t "$REPO_DIR"/output/x86_64/images/*.iso 2>/dev/null | head -1)"

DISK="$SCRIPT_DIR/negativeos-test-p4.qcow2"

[ -f "$ISO" ] || { echo "ERROR: No ISO found."; exit 1; }
echo "[vm] Booting P4 simulation (slow — no KVM): $ISO"
echo "     RAM: 512MB  CPU: 1x pentium4  No hardware acceleration"

if [[ "$*" == *"--install"* ]]; then
    [ -f "$DISK" ] || qemu-img create -f qcow2 "$DISK" 20G
    DISK_ARG="-drive file=$DISK,format=qcow2,if=ide"
else
    DISK_ARG=""
fi

qemu-system-i386 \
    -name "NegativeOS (P4 sim)" \
    -machine type=pc \
    -cpu pentium4 \
    -smp 1 \
    -m 512 \
    -cdrom "$ISO" \
    -boot order=d \
    $DISK_ARG \
    -vga cirrus \
    -display sdl \
    -device ne2k_pci,netdev=net0 \
    -netdev user,id=net0 \
    -rtc base=localtime \
    -usb -device usb-tablet
