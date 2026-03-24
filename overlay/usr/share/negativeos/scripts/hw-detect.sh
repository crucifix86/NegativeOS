#!/bin/sh
# NegativeOS Hardware Detection & Driver Install
# Runs on first boot and from live environment
# Maps PCI/USB IDs to firmware/driver packages and installs them

set -e

LOG="/var/log/negativeos-hwdetect.log"
INSTALLED_MARK="/var/lib/negativeos/.hw-detect-done"

log() { echo "[hw-detect] $*" | tee -a "$LOG"; }

# ── Already ran? ─────────────────────────────────────────────────────────────
if [ -f "$INSTALLED_MARK" ] && [ "$1" != "--force" ]; then
    log "Already ran. Use --force to re-run."
    exit 0
fi

mkdir -p /var/lib/negativeos
log "NegativeOS hardware detection starting..."

PKGS_TO_INSTALL=""

add_pkg() {
    for p in "$@"; do
        echo "$PKGS_TO_INSTALL" | grep -q "$p" || PKGS_TO_INSTALL="$PKGS_TO_INSTALL $p"
    done
}

# ── WiFi / Network ────────────────────────────────────────────────────────────
detect_wifi() {
    log "Scanning WiFi hardware..."

    # Broadcom (b43 / brcmfmac / wl)
    if lspci -n 2>/dev/null | grep -qi "14e4:"; then
        log "  Broadcom WiFi detected"
        add_pkg firmware-brcm80211 broadcom-sta-dkms
    fi

    # Intel WiFi (iwlwifi)
    if lspci -n 2>/dev/null | grep -qi "8086:.*network\|8086:4229\|8086:422b\|8086:4236\|8086:08b1\|8086:24fb\|8086:2526"; then
        log "  Intel WiFi detected"
        add_pkg linux-firmware-iwlwifi
    fi

    # Atheros (ath9k / ath10k)
    if lspci -n 2>/dev/null | grep -qi "168c:"; then
        log "  Atheros WiFi detected"
        add_pkg linux-firmware-ath9k linux-firmware-ath10k
    fi

    # Realtek (rtlwifi / r8188eu)
    if lspci -n 2>/dev/null | grep -qi "10ec:.*[89][0-9][0-9][0-9]" || \
       lsusb 2>/dev/null | grep -qi "0bda:"; then
        log "  Realtek WiFi detected"
        add_pkg linux-firmware-rtl_nic linux-firmware-rtlwifi
    fi

    # MediaTek / Ralink
    if lspci -n 2>/dev/null | grep -qi "1814:\|14c3:"; then
        log "  MediaTek/Ralink WiFi detected"
        add_pkg linux-firmware-mediatek
    fi

    # Old cards with no Linux driver — try ndiswrapper
    if ! ip link 2>/dev/null | grep -q "wl"; then
        log "  No WiFi interface found — ndiswrapper available as fallback"
        add_pkg ndiswrapper
    fi
}

# ── GPU ───────────────────────────────────────────────────────────────────────
detect_gpu() {
    log "Scanning GPU hardware..."

    # Intel integrated (i915)
    if lspci -n 2>/dev/null | grep -qi "8086:.*display\|8086:.*vga"; then
        log "  Intel GPU detected"
        add_pkg linux-firmware-i915 xf86-video-intel
    fi

    # NVIDIA (nouveau / legacy)
    if lspci -n 2>/dev/null | grep -qi "10de:.*vga\|10de:.*3d"; then
        log "  NVIDIA GPU detected"
        add_pkg linux-firmware-nvidia xf86-video-nouveau
    fi

    # AMD / ATI (radeon / amdgpu)
    if lspci -n 2>/dev/null | grep -qi "1002:.*vga\|1002:.*display"; then
        log "  AMD/ATI GPU detected"
        add_pkg linux-firmware-amdgpu linux-firmware-radeon xf86-video-ati
    fi

    # VIA (old P4-era systems)
    if lspci -n 2>/dev/null | grep -qi "1106:.*vga"; then
        log "  VIA GPU detected"
        add_pkg xf86-video-openchrome
    fi

    # S3 / Savage
    if lspci -n 2>/dev/null | grep -qi "5333:.*vga"; then
        log "  S3/Savage GPU detected"
        add_pkg xf86-video-savage
    fi

    # Fallback: VESA (works on anything)
    add_pkg xf86-video-vesa
}

# ── Sound ─────────────────────────────────────────────────────────────────────
detect_audio() {
    log "Scanning audio hardware..."

    # Intel HDA (most common since Core 2 era)
    if lspci -n 2>/dev/null | grep -qi "8086:.*audio\|8086:.*hda\|8086:2668\|8086:27d8"; then
        log "  Intel HDA audio detected"
        add_pkg alsa-firmware
    fi

    # Creative / SoundBlaster (old P4 era)
    if lspci -n 2>/dev/null | grep -qi "1102:"; then
        log "  Creative audio detected"
        add_pkg alsa-firmware
    fi

    # Realtek HD audio
    if lspci -n 2>/dev/null | grep -qi "10ec:.*audio"; then
        log "  Realtek audio detected"
        add_pkg alsa-firmware
    fi
}

# ── USB Devices ───────────────────────────────────────────────────────────────
detect_usb() {
    log "Scanning USB devices..."

    # USB WiFi — Ralink
    if lsusb 2>/dev/null | grep -qi "148f:"; then
        log "  Ralink USB WiFi detected"
        add_pkg linux-firmware-mediatek
    fi

    # USB WiFi — ASUS/Realtek
    if lsusb 2>/dev/null | grep -qi "0b05:.*wlan\|0bda:8176\|0bda:8178\|0bda:817f"; then
        log "  Realtek USB WiFi detected"
        add_pkg linux-firmware-rtlwifi
    fi
}

# ── Touchpad / Input ──────────────────────────────────────────────────────────
detect_input() {
    log "Scanning input devices..."

    if lspci -n 2>/dev/null | grep -qi "synaptics\|elantech"; then
        add_pkg xf86-input-synaptics
    fi

    # Generic evdev for everything else
    add_pkg xf86-input-evdev xf86-input-libinput
}

# ── Run detections ────────────────────────────────────────────────────────────
detect_wifi
detect_gpu
detect_audio
detect_usb
detect_input

# ── Install ───────────────────────────────────────────────────────────────────
if [ -n "$PKGS_TO_INSTALL" ]; then
    log "Packages to install:${PKGS_TO_INSTALL}"
    if [ "$1" = "--dry-run" ]; then
        log "Dry run — not installing."
    else
        apk add --no-cache $PKGS_TO_INSTALL 2>&1 | tee -a "$LOG"
        log "Done installing drivers."
    fi
else
    log "No additional driver packages needed."
fi

# ── Mark done ─────────────────────────────────────────────────────────────────
touch "$INSTALLED_MARK"
log "Hardware detection complete."
