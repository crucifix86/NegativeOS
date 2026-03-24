# NegativeOS

A lean, purpose-driven Linux distro for old and modern x86 hardware.

**Aesthetic:** Windows 95/98 — simple, functional, familiar.
**Philosophy:** No bloat. Everything has a reason to be there.

---

## Target Hardware

| Tier | Example |
|------|---------|
| Floor | Pentium 4 (i686, 32-bit, legacy BIOS) |
| Mid | Core 2 Duo era (32/64-bit, BIOS or UEFI) |
| Modern | Any x86_64 machine (UEFI) |

---

## Stack

| Component | Choice |
|-----------|--------|
| Kernel | Linux 6.12 LTS |
| libc | glibc |
| Init | runit |
| Userspace | BusyBox + selective full packages |
| Package manager | apk |
| Bootloader | GRUB 2 (legacy BIOS + UEFI hybrid) |
| Display | Xorg + IceWM (Win95 theme) |
| Browser | Pale Moon |
| Arches | i686, x86_64 |

---

## Build Phases

- [ ] Phase 1 — Base system (kernel + BusyBox + runit, bootable ISO)
- [ ] Phase 2 — Desktop layer (Xorg + IceWM + core apps)
- [ ] Phase 3 — Networking (NetworkManager + avahi + samba)
- [ ] Phase 4 — Browser (Pale Moon i686 + x86_64)
- [ ] Phase 5 — Driver support (linux-firmware + ndiswrapper + hw detect)
- [ ] Phase 6 — Installer
- [ ] Phase 7 — Polish & release

---

## Building

```bash
# Coming soon — Buildroot-based build system
make negativeos_x86_64_defconfig
make -j$(nproc)
```

---

## Status

Early planning/scaffolding phase.
