#!/bin/bash
# NegativeOS — Pale Moon build from source
# Use this when developing/patching Pale Moon
#
# Pale Moon needs specific build deps — run this script to set up
# the build environment and compile.

set -e

PALEMOON_SRC="${HOME}/palemoon-src"
PALEMOON_VERSION="${1:-master}"
ARCH="${2:-$(uname -m)}"  # x86_64 or i686

echo "[NegativeOS] Building Pale Moon from source"
echo "  Source dir : ${PALEMOON_SRC}"
echo "  Version    : ${PALEMOON_VERSION}"
echo "  Arch       : ${ARCH}"

# ── Dependencies ────────────────────────────────────────────────────────────
install_deps() {
    echo "[NegativeOS] Installing Pale Moon build dependencies..."
    # Pale Moon needs autoconf-2.13 specifically
    apk add --no-cache \
        autoconf2.13 \
        python3 \
        rust \
        cargo \
        clang \
        llvm \
        gtk+3.0-dev \
        gtk+2.0-dev \
        dbus-glib-dev \
        libxt-dev \
        libxrender-dev \
        libxcomposite-dev \
        libxdamage-dev \
        pulseaudio-dev \
        alsa-lib-dev \
        nasm \
        yasm \
        zip \
        unzip \
        git
}

# ── Clone / update source ────────────────────────────────────────────────────
fetch_source() {
    if [ -d "${PALEMOON_SRC}/.git" ]; then
        echo "[NegativeOS] Updating existing source tree..."
        cd "${PALEMOON_SRC}"
        git fetch origin
        git checkout "${PALEMOON_VERSION}"
        git pull
    else
        echo "[NegativeOS] Cloning Pale Moon source..."
        git clone --depth=1 \
            https://github.com/MoonchildProductions/Pale-Moon.git \
            "${PALEMOON_SRC}"
        cd "${PALEMOON_SRC}"
        [ "${PALEMOON_VERSION}" != "master" ] && git checkout "${PALEMOON_VERSION}"
    fi
}

# ── Mozconfig ────────────────────────────────────────────────────────────────
write_mozconfig() {
    cat > "${PALEMOON_SRC}/.mozconfig" <<EOF
# NegativeOS Pale Moon mozconfig
# Adjust for your dev environment

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj-${ARCH}
mk_add_options MOZ_MAKE_FLAGS="-j$(nproc)"

ac_add_options --enable-application=browser
ac_add_options --enable-optimize="-O2"
ac_add_options --disable-debug
ac_add_options --disable-tests
ac_add_options --enable-strip
ac_add_options --enable-install-strip

# GTK3 (use --enable-default-toolkit=cairo-gtk2 for GTK2/old hardware)
ac_add_options --enable-default-toolkit=cairo-gtk3

# Audio
ac_add_options --enable-alsa
ac_add_options --disable-pulseaudio

# 32-bit cross-compile (uncomment for i686 build on x86_64 host)
# ac_add_options --target=i686-pc-linux-gnu
# ac_add_options --host=i686-pc-linux-gnu
# export CC="gcc -m32"
# export CXX="g++ -m32"

# Branding — swap in NegativeOS branding later
ac_add_options --enable-official-branding
EOF
    echo "[NegativeOS] Wrote .mozconfig to ${PALEMOON_SRC}/.mozconfig"
}

# ── Build ────────────────────────────────────────────────────────────────────
build() {
    cd "${PALEMOON_SRC}"
    echo "[NegativeOS] Starting Pale Moon build (this takes a while)..."
    ./mach build 2>&1 | tee build.log
    echo "[NegativeOS] Build complete."
    echo "  Binary at: ${PALEMOON_SRC}/obj-${ARCH}/dist/bin/palemoon"
}

# ── Package ──────────────────────────────────────────────────────────────────
package() {
    cd "${PALEMOON_SRC}"
    echo "[NegativeOS] Packaging..."
    ./mach package
    echo "[NegativeOS] Package at: ${PALEMOON_SRC}/obj-${ARCH}/dist/"
    ls "${PALEMOON_SRC}/obj-${ARCH}/dist/"palemoon-*.tar.bz2 2>/dev/null || true
}

# ── Main ─────────────────────────────────────────────────────────────────────
case "${3:-full}" in
    deps)    install_deps ;;
    fetch)   fetch_source ;;
    config)  write_mozconfig ;;
    build)   build ;;
    package) package ;;
    full)
        install_deps
        fetch_source
        write_mozconfig
        build
        package
        ;;
    *)
        echo "Usage: $0 [version] [arch] [deps|fetch|config|build|package|full]"
        exit 1
        ;;
esac
