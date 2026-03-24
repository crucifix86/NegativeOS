#!/bin/sh
# NegativeOS First Boot Wizard
# Runs once after installation — handles anything the installer deferred
# Triggered by runit service, removes itself after completion

set -e

DIALOG="dialog"
DONE_MARK="/var/lib/negativeos/.firstboot-done"

[ -f "$DONE_MARK" ] && exit 0

# ── Welcome ───────────────────────────────────────────────────────────────────

$DIALOG --title "Welcome to NegativeOS" \
    --msgbox "\nWelcome!\n\nThis wizard will finish setting up your system.\nIt only runs once.\n" \
    10 50

# ── Hardware detection ────────────────────────────────────────────────────────

$DIALOG --title "Hardware Setup" \
    --infobox "\nDetecting hardware and installing drivers...\n" 7 50

/usr/share/negativeos/scripts/hw-detect.sh >> /var/log/negativeos-firstboot.log 2>&1 || true

# ── Update check ──────────────────────────────────────────────────────────────

$DIALOG --title "System Update" \
    --yesno "\nCheck for NegativeOS updates now?\n(Requires internet connection)\n" \
    9 50 && {
        $DIALOG --title "Updating" \
            --infobox "\nUpdating package lists...\n" 6 40
        apk update >> /var/log/negativeos-firstboot.log 2>&1 || true
        apk upgrade >> /var/log/negativeos-firstboot.log 2>&1 || true
    }

# ── Done ──────────────────────────────────────────────────────────────────────

mkdir -p /var/lib/negativeos
touch "$DONE_MARK"

$DIALOG --title "Setup Complete" \
    --msgbox "\nYour system is ready.\n\nEnjoy NegativeOS.\n" \
    9 40

# Remove the autostart entry so this never runs again
rm -f /etc/runit/runsvdir/default/firstboot
