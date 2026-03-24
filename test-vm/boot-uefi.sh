#!/bin/bash
# NegativeOS VM Test — UEFI boot
# Tests the x86_64 ISO in UEFI mode (modern hardware simulation)
#
# Usage:
#   ./boot-uefi.sh                        # boot latest ISO
#   ./boot-uefi.sh path/to/custom.iso     # boot specific ISO
#   ./boot-uefi.sh --install              # boot with a virtual disk (for install testing)

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
ISO="${1:-$(ls -t "$REPO_DIR"/output/x86_64/images/*.iso 2>/dev/null | head -1)}"
OVMF_CODE="/usr/share/OVMF/OVMF_CODE_4M.fd"
OVMF_VARS_SRC="/usr/share/OVMF/OVMF_VARS_4M.fd"
OVMF_VARS="$SCRIPT_DIR/OVMF_VARS_uefi.fd"   # writable copy per-VM
DISK="$SCRIPT_DIR/negativeos-test-uefi.qcow2"

[ -f "$ISO" ] || { echo "ERROR: No ISO found. Build first or pass ISO path as arg."; exit 1; }
echo "[vm] Booting (UEFI): $ISO"

# Copy OVMF vars if not present (stores EFI boot entries between runs)
[ -f "$OVMF_VARS" ] || cp "$OVMF_VARS_SRC" "$OVMF_VARS"

# Create test disk for install testing
if [[ "$*" == *"--install"* ]]; then
    if [ ! -f "$DISK" ]; then
        echo "[vm] Creating 20GB virtual disk for install test..."
        qemu-img create -f qcow2 "$DISK" 20G
    fi
    DISK_ARG="-drive file=$DISK,format=qcow2,if=virtio"
else
    DISK_ARG=""
fi

qemu-system-x86_64 \
    -name "NegativeOS (UEFI)" \
    -machine type=q35,accel=kvm \
    -cpu host \
    -smp 4 \
    -m 2048 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -cdrom "$ISO" \
    -boot order=d,menu=on \
    $DISK_ARG \
    -device virtio-vga \
    -display sdl,gl=on \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0 \
    -device virtio-rng-pci \
    -rtc base=localtime \
    -usb -device usb-tablet
