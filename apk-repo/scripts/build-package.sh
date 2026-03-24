#!/bin/sh
# NegativeOS Package Builder
# Builds a package from its APKBUILD and drops the .apk into the repo
#
# Usage:
#   ./build-package.sh palemoon
#   ./build-package.sh all

set -e

REPO_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
PKG_ROOT="${REPO_ROOT}/apk-packages"
REPO_DIR="${REPO_ROOT}/apk-repo"

build_pkg() {
    PKG="$1"
    PKG_DIR="${PKG_ROOT}/${PKG}"

    [ -d "${PKG_DIR}" ] || { echo "ERROR: Package '${PKG}' not found in ${PKG_ROOT}"; exit 1; }
    [ -f "${PKG_DIR}/APKBUILD" ] || { echo "ERROR: No APKBUILD in ${PKG_DIR}"; exit 1; }

    echo "[build] Building ${PKG}..."
    cd "${PKG_DIR}"

    # Build with abuild
    abuild -r 2>&1 | tee "/tmp/negativeos-build-${PKG}.log"

    # Copy output to repo
    ARCH=$(abuild -A 2>/dev/null || uname -m)
    PKGS_DIR="${HOME}/packages/${PKG}/${ARCH}"

    if [ -d "${PKGS_DIR}" ]; then
        mkdir -p "${REPO_DIR}/${ARCH}"
        cp "${PKGS_DIR}"/*.apk "${REPO_DIR}/${ARCH}/" 2>/dev/null && \
            echo "[build] ${PKG}: copied to ${REPO_DIR}/${ARCH}/" || \
            echo "[build] WARNING: no .apk found in ${PKGS_DIR}"
    fi

    echo "[build] ${PKG} done."
}

if [ "$1" = "all" ]; then
    for pkg_dir in "${PKG_ROOT}"/*/; do
        pkg=$(basename "${pkg_dir}")
        [ -f "${pkg_dir}/APKBUILD" ] && build_pkg "${pkg}" || true
    done
else
    [ -z "$1" ] && { echo "Usage: $0 <package-name|all>"; exit 1; }
    build_pkg "$1"
fi

# Re-index after build
echo "[build] Re-indexing repository..."
"${REPO_DIR}/scripts/index-repo.sh"

echo "[build] All done."
