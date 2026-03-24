#!/bin/sh
# NegativeOS APK Repository Setup
# Run once on the machine that will host/sign packages
# Generates a signing keypair and initializes the repo structure

set -e

REPO_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
KEY_DIR="${REPO_DIR}/keys"
KEY_NAME="negativeos-packages"

echo "[apk-repo] Setting up NegativeOS package repository..."
echo "  Repo dir : ${REPO_DIR}"

# ── Install abuild if needed ──────────────────────────────────────────────────
if ! command -v abuild-keygen >/dev/null 2>&1; then
    echo "[apk-repo] Installing abuild..."
    apk add --no-cache abuild || {
        echo "ERROR: abuild not found. Install Alpine SDK or run on Alpine/NegativeOS."
        exit 1
    }
fi

# ── Generate signing key ──────────────────────────────────────────────────────
mkdir -p "${KEY_DIR}"

if [ -f "${KEY_DIR}/${KEY_NAME}.rsa" ]; then
    echo "[apk-repo] Signing key already exists — skipping keygen."
else
    echo "[apk-repo] Generating RSA signing keypair..."
    abuild-keygen -a -i -n \
        --keysize 4096 \
        --pubkey "${KEY_DIR}/${KEY_NAME}.rsa.pub" \
        --privkey "${KEY_DIR}/${KEY_NAME}.rsa"
    echo "[apk-repo] Key generated:"
    echo "  Private : ${KEY_DIR}/${KEY_NAME}.rsa   (KEEP SECRET — do not commit)"
    echo "  Public  : ${KEY_DIR}/${KEY_NAME}.rsa.pub (bundled in OS image)"
fi

# ── Create repo directories ───────────────────────────────────────────────────
for arch in x86_64 x86 noarch; do
    mkdir -p "${REPO_DIR}/${arch}"
done

echo "[apk-repo] Repository initialized."
echo ""
echo "Next steps:"
echo "  1. Build packages:  cd apk-packages/<pkg> && abuild -r"
echo "  2. Index repo:      ${REPO_DIR}/scripts/index-repo.sh"
echo "  3. Serve repo:      ${REPO_DIR}/scripts/serve-repo.sh"
echo "  4. On clients:      apk add --repository http://your-server/apk-repo <package>"
