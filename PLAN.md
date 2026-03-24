# NegativeOS — Comprehensive Build Plan

**Created:** 2026-03-24
**Last Updated:** 2026-03-24
**Status:** Active Development — Phase 1 build running, Phases 2-5 code complete

---

## Vision

A lean, purpose-driven Linux distro targeting old and modern hardware alike.
Aesthetic: Windows 95/98 — simple, functional, familiar.
Philosophy: No bloat. Everything has a reason to be there.

---

## Target Hardware

| Tier | Example | Notes |
|------|---------|-------|
| Floor | Pentium 4 (i686, 32-bit) | Oldest supported, BIOS only |
| Mid | Core 2 Duo era | 32 or 64-bit, BIOS or early UEFI |
| Modern | Any x86_64 machine | UEFI, fast hardware |

---

## Architectures

- **i686** — 32-bit, for P4 and older x86 hardware
- **x86_64** — 64-bit, for modern machines
- Two separate ISO builds from one shared source tree
- Shared package recipes, configs, and build logic

### Compiler Flags

```makefile
# i686
ARCH=i686
TARGET=i686-negativeos-linux-gnu
CFLAGS=-march=i686 -mtune=pentium4 -O2 -pipe

# x86_64
ARCH=x86_64
TARGET=x86_64-negativeos-linux-gnu
CFLAGS=-march=x86-64 -mtune=generic -O2 -pipe
```

---

## Full Software Stack

### Core System

| Component | Choice | Reason |
|-----------|--------|--------|
| Kernel | Linux 6.12 LTS (EOL Dec 2028) | Longest current LTS, full legacy driver support |
| libc | glibc | Best compatibility with old and new software |
| Init | runit | Minimal, fast 3-stage init, no dependencies |
| Userspace | BusyBox + selective full packages | One binary for ~300 tools |
| Package manager | apk (Alpine's) | Fast, lean, easy to build custom repos |
| Bootloader | GRUB 2 (hybrid) | Handles BIOS legacy + UEFI 32/64 from one image |

### Display & Desktop

| Component | Choice | Reason |
|-----------|--------|--------|
| Display server | Xorg | Old GPU support (i915, Radeon 9xxx have no Wayland drivers) |
| Window manager | IceWM | Built-in Win95/98 themes, ~5MB RAM, taskbar + start menu OOB |
| Login manager | SLiM | Minimal, fully themeable to match Win9x aesthetic |
| Desktop theme | Win95 (IceWM built-in) | Ships out of the box, no extra work |

### Default Applications

| App | Package | Purpose |
|-----|---------|---------|
| File manager | PCManFM | Lightweight, tabbed, network share browsing via gvfs |
| Terminal | rxvt-unicode (urxvt) | Fast, minimal, unicode support |
| Text editor | Mousepad | Simple, no bloat |
| Image viewer | gpicview | Single window, instant load |
| Archive manager | xarchiver | GTK, lightweight |
| Browser | Pale Moon | Firefox-based, ships 32-bit builds, handles modern web |
| Network manager | NetworkManager + nm-applet | System tray icon, WiFi/eth management |
| Net discovery | avahi-daemon | mDNS/zeroconf, auto-discovers local devices |
| Windows shares | samba + gvfs-smb | Windows network browsing in PCManFM |
| Audio | PipeWire | Handles old and new hardware, replaces PulseAudio |

### Driver Support

| Package | Purpose |
|---------|---------|
| linux-firmware | Firmware blobs for old WiFi, GPU, etc. |
| ndiswrapper | Run Windows .inf drivers for WiFi cards with no Linux support |
| firmware-linux-nonfree | Non-free blobs (Broadcom, Atheros, Realtek) |
| xserver-xorg-video-vesa | Fallback GPU driver |
| xserver-xorg-video-i740 | Old Intel AGP |
| xserver-xorg-video-savage | Old S3/VIA cards |

---

## Boot & Firmware Support

### Bootloader Strategy

GRUB 2 handles all boot scenarios from a single hybrid ISO:

| Scenario | Method |
|----------|--------|
| Legacy BIOS (P4 era) | GRUB + ISOLINUX/MBR |
| UEFI 64-bit | grub-efi-x86_64 (BOOTX64.EFI) |
| UEFI 32-bit (rare Bay Trail) | grub-efi-ia32 (BOOTIA32.EFI) |
| USB boot any machine | isohybrid |

**No Secure Boot** — complexity not worth it for v1.

### ISO Internal Layout

```
ISO image
├── /boot/grub/           # GRUB BIOS modules
├── /EFI/BOOT/
│   ├── BOOTX64.EFI       # UEFI 64-bit
│   └── BOOTIA32.EFI      # UEFI 32-bit
├── /isolinux/            # Legacy BIOS fallback
└── /live/                # kernel + initrd + squashfs rootfs
```

### Installed System Partition Layout

```
# UEFI
GPT
├── ESP  (FAT32, 512MB)   EFI System Partition
├── /boot (ext4, 512MB)   kernels + GRUB
└── /    (ext4, rest)     root filesystem

# Legacy BIOS
MBR
├── /boot (ext4, 512MB)
└── /    (ext4, rest)
```

### Hybrid ISO Build

```bash
xorriso -as mkisofs \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/efiboot.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  -isohybrid-apm-hfsplus \
  -o negativeos-x86_64.iso ./iso_root/
```

---

## Live Boot + Installer

- ISO boots to live desktop by default
- Installer available from desktop icon / Start menu
- Installer auto-detects firmware (UEFI vs BIOS) and partitions accordingly
- First-boot wizard: locale, user, hostname

---

## Desktop Layout (IceWM Win95 Theme)

```
┌─────────────────────────────────────────────────────────┐
│  Desktop                                                │
│                                                         │
│   [My Computer]  [Network]  [Trash]                     │
│                                                         │
│                                                         │
│                                                         │
├──────────┬──────────────────────────────┬───────────────┤
│ [Start▼] │  [open windows...]           │ 🔊 📶  12:34  │
└──────────┴──────────────────────────────┴───────────────┘
```

IceWM theme config:
```
# ~/.icewm/theme
Theme="Win95/default.theme"
```

---

## Build System

### Approach: Buildroot

- Automated, well-documented, generates i686 and x86_64 images
- Full control over every included package
- Good for getting a working base fast, then customizing

### Directory Structure

```
NegativeOS/
├── PLAN.md                        # this file
├── configs/
│   ├── negativeos_i686_defconfig  # Buildroot config for 32-bit
│   └── negativeos_x86_64_defconfig
├── board/
│   ├── negativeos/
│   │   ├── grub.cfg               # GRUB config (BIOS + UEFI)
│   │   ├── isolinux.cfg           # BIOS fallback
│   │   └── post-build.sh          # ISO assembly script
├── package/
│   └── negativeos-base/           # custom meta-package
├── overlay/
│   ├── etc/
│   │   ├── runit/                 # runit service definitions
│   │   ├── icewm/                 # default IceWM theme config
│   │   └── NetworkManager/
│   └── usr/
│       └── share/
│           └── negativeos/        # branding, wallpapers, icons
└── output/
    ├── i686/
    └── x86_64/
```

### Build Commands

```bash
# Configure
make negativeos_x86_64_defconfig

# Full build
make -j$(nproc)

# Output
ls output/x86_64/images/negativeos-x86_64.iso
```

---

## Build Phases

### Phase 1 — Base System
- [x] Set up Buildroot environment (Buildroot 2024.11, BR2_EXTERNAL wired up)
- [x] Configure i686 + x86_64 toolchains (glibc, configs written)
- [x] Build minimal rootfs: kernel 6.12 LTS + BusyBox + runit (BUILD RUNNING)
- [ ] Bootable console-only ISO (BIOS + UEFI hybrid) — waiting on build output
- [ ] Verify boots on P4 test hardware

### Phase 2 — Desktop Layer
- [x] Add Xorg + IceWM + SLiM (in defconfigs)
- [x] Apply Win95 theme as default (overlay/etc/icewm/theme + preferences)
- [x] Add PCManFM, urxvt, Mousepad, gpicview, xarchiver (in defconfigs)
- [x] Add PipeWire audio (in defconfigs)
- [x] IceWM start menu, toolbar, keybindings, window options (overlay)
- [x] Desktop skel shortcuts: My Computer, Network, Recycle Bin
- [ ] Live desktop boots correctly — pending first successful build

### Phase 3 — Networking
- [x] NetworkManager + nm-applet (in defconfigs)
- [x] avahi-daemon (in defconfigs)
- [x] samba + gvfs-smb (in defconfigs)
- [ ] Verify network tray icon works on live boot

### Phase 4 — Browser
- [x] Pale Moon Buildroot package (package/palemoon/) — binary, arch-aware i686/x86_64
- [x] Pale Moon apk APKBUILD (apk-packages/palemoon/)
- [x] Pale Moon build-from-source.sh for dev/patching work
- [x] Set as default browser via /etc/alternatives symlink
- [ ] Verify Pale Moon launches correctly on live boot

### Phase 5 — Driver Support
- [x] linux-firmware + ndiswrapper in defconfigs
- [x] hw-detect.sh: PCI/USB scan → firmware package install (overlay/usr/share/negativeos/scripts/)
- [x] runit service for hw-detect (runs once on first boot, self-removes)
- [x] Covers: WiFi (Broadcom/Intel/Atheros/Realtek/MediaTek), GPU (Intel/NVIDIA/AMD/VIA/S3), audio, USB
- [ ] Test on varied old hardware

### Phase 6 — Installer ✓ COMPLETE
- [x] Shell installer script (overlay/usr/sbin/negativeos-install)
- [x] Auto-detect UEFI vs BIOS via /sys/firmware/efi
- [x] Partition + format: GPT+ESP for UEFI, MBR for legacy BIOS
- [x] Handles nvme/mmcblk/sda partition naming automatically
- [x] Install rootfs via unsquashfs
- [x] Configures hostname, fstab (UUID-based), timezone, /etc/hosts
- [x] Creates user + sets password via chroot
- [x] Installs GRUB (EFI or i386-pc) + generates grub.cfg
- [x] First-boot wizard (overlay/usr/share/negativeos/scripts/firstboot.sh)
- [x] firstboot: hw-detect, update check, self-removing runit service
- [x] Desktop installer launcher icon (Install NegativeOS on live desktop)

### Phase 7 — Polish & Release ← IN PROGRESS
- [x] SLiM Win95 theme config (overlay/usr/share/slim/themes/negativeos-win95/)
- [x] SLiM theme artwork — programmatically generated (branding/generate-assets.py)
      - panel.png: Win95 dialog box (420x220) with title bar, input fields, OK button
      - background.png: 1920x1080 teal desktop
      - Replace with AI-generated artwork in future release
- [x] Boot splash: bootsplash.png (800x600) — teal, logo, tagline, progress bar outline
- [x] Wallpaper: wallpaper.png (1920x1080) — teal with scanline texture + NegativeOS wordmark
- [x] Logo icon: negativeos-logo.png (128x128) — Win95 raised button style, N on navy
- [x] IceWM wired to wallpaper (DesktopBackgroundImage in preferences)
- [x] SLiM theme wired to panel.png + background.png
- [ ] apk package repo setup (self-hosted)
- [ ] i686 build + test
- [ ] Verify x86_64 build output boots (waiting on running build)
- [ ] Release i686 ISO + x86_64 ISO

---

## Key Notes

- **Pale Moon**: User is considering developing/patching Pale Moon. Keep browser modular and easy to swap builds.
- **No systemd**: runit only. Keep init simple.
- **No Secure Boot**: Intentional, reduces complexity significantly.
- **Xorg not Wayland**: Old GPU drivers (i915, Radeon 9xxx) have no Wayland support — mandatory for P4 tier.
- **apk package manager**: Easy to self-host a repo, very scriptable.
- **Win95/98 aesthetic**: IceWM Win95 theme is the non-negotiable identity of NegativeOS.

---

## Reference Links

- Buildroot docs: https://buildroot.org/downloads/manual/manual.html
- Linux 6.12 LTS: https://kernel.org
- IceWM themes: https://ice-wm.org
- Pale Moon: https://www.palemoon.org
- LFS (reference): https://linuxfromscratch.org
- antiX (study their build): https://antixlinux.com
