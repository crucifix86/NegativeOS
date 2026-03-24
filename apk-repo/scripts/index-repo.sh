#!/bin/sh
# NegativeOS APK Repo Indexer
# Signs and indexes all .apk files in the repo
# Run after adding or updating any package

set -e

REPO_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
KEY_DIR="${REPO_DIR}/keys"
KEY_NAME="negativeos-packages"
PRIVKEY="${KEY_DIR}/${KEY_NAME}.rsa"

[ -f "${PRIVKEY}" ] || {
    echo "ERROR: Signing key not found at ${PRIVKEY}"
    echo "Run setup-repo.sh first."
    exit 1
}

echo "[apk-repo] Indexing NegativeOS package repository..."

for arch in x86_64 x86 noarch; do
    ARCH_DIR="${REPO_DIR}/${arch}"
    [ -d "${ARCH_DIR}" ] || continue

    APKS=$(ls "${ARCH_DIR}"/*.apk 2>/dev/null | wc -l)
    [ "$APKS" -eq 0 ] && echo "  ${arch}: no packages, skipping" && continue

    echo "  Indexing ${arch} (${APKS} packages)..."

    apk index \
        --rewrite-arch "${arch}" \
        -o "${ARCH_DIR}/APKINDEX.tar.gz" \
        "${ARCH_DIR}"/*.apk

    # Sign the index
    abuild-sign \
        -k "${PRIVKEY}" \
        "${ARCH_DIR}/APKINDEX.tar.gz"

    echo "  ${arch}: index signed and written."
done

echo "[apk-repo] Done. Repository ready to serve."
