#!/bin/bash
# NegativeOS ISO assembly script
# Called by Buildroot after rootfs is built

set -e

BOARD_DIR="$(dirname "$0")"
BINARIES_DIR="${1}"
BUILD_DIR="${2}"
ARCH="${3:-x86_64}"

ISO_ROOT="${BINARIES_DIR}/iso_root"
OUTPUT_ISO="${BINARIES_DIR}/negativeos-${ARCH}.iso"

echo "[NegativeOS] Assembling ISO for ${ARCH}..."

# Create ISO directory structure
mkdir -p "${ISO_ROOT}"/{live,boot/grub,EFI/BOOT,isolinux}

# Copy kernel and initrd
cp "${BINARIES_DIR}/bzImage"    "${ISO_ROOT}/live/vmlinuz"
cp "${BINARIES_DIR}/rootfs.cpio.gz" "${ISO_ROOT}/live/initrd.img"

# Copy squashfs rootfs if present
[ -f "${BINARIES_DIR}/rootfs.squashfs" ] && \
    cp "${BINARIES_DIR}/rootfs.squashfs" "${ISO_ROOT}/live/filesystem.squashfs"

# Copy bootloader configs
cp "${BOARD_DIR}/grub.cfg"     "${ISO_ROOT}/boot/grub/grub.cfg"
cp "${BOARD_DIR}/isolinux.cfg" "${ISO_ROOT}/isolinux/isolinux.cfg"

# Build hybrid ISO (BIOS + UEFI)
xorriso -as mkisofs \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e EFI/boot/efiboot.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -V "NegativeOS" \
    -o "${OUTPUT_ISO}" \
    "${ISO_ROOT}/"

echo "[NegativeOS] ISO built: ${OUTPUT_ISO}"
