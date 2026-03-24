# NegativeOS VM Test Scripts

Three boot modes for testing the ISO before putting it on real hardware.

## Scripts

| Script | Mode | RAM | Use for |
|--------|------|-----|---------|
| `boot-uefi.sh` | UEFI + KVM | 2GB | Modern hardware testing |
| `boot-bios.sh` | Legacy BIOS + KVM | 2GB | Old hardware testing |
| `boot-p4sim.sh` | BIOS, no KVM, i386 | 512MB | Worst-case P4 floor test |

## Quick start

```bash
# Live boot (no disk needed)
./boot-uefi.sh
./boot-bios.sh

# Install test (creates a 20GB qcow2 disk)
./boot-uefi.sh --install
./boot-bios.sh --install

# P4 worst-case test (uses i686 ISO if built, falls back to x86_64)
./boot-p4sim.sh
```

## Boot a specific ISO

```bash
./boot-uefi.sh /path/to/negativeos-x86_64.iso
```

## Disk images

`.qcow2` disk images are created in this directory on first `--install` run.
Delete them to start a fresh install test.

```bash
rm test-vm/*.qcow2
```
