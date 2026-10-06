#!/usr/bin/env bash
# Readected — build & install script
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT}/build"
PREFIX="${PREFIX:-/usr/local}"

echo "==> Readected installer"
echo "    Prefix: ${PREFIX}"

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: missing dependency: $1"
        exit 1
    fi
}

echo "==> Checking tools..."
need cmake
need ninja
need pkg-config

if ! pkg-config --exists poppler-qt6; then
    echo "ERROR: poppler-qt6 not found (pkg-config)"
    echo "  Arch:    sudo pacman -S poppler-qt6"
    echo "  Debian:  sudo apt install libpoppler-qt6-dev"
    exit 1
fi

if ! pkg-config --exists Qt6Core Qt6Qml Qt6Quick Qt6QuickControls2 Qt6Widgets Qt6Network 2>/dev/null; then
    echo "WARNING: some Qt6 modules may be missing — build will report exact ones"
fi

echo "==> Configuring..."
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    "${ROOT}"

echo "==> Building..."
ninja

echo "==> Installing..."
if [[ -w "${PREFIX}" ]] || [[ -w "${PREFIX}/bin" ]]; then
    ninja install
else
    echo "    (needs sudo for ${PREFIX})"
    sudo ninja install
fi

# Desktop entries
APPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "${APPDIR}"

cat > "${APPDIR}/readected.desktop" << EOF
[Desktop Entry]
Name=Readected
Comment=Material Design PDF Reader
Exec=${PREFIX}/bin/readected %f
Icon=application-pdf
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;
EOF

cat > "${APPDIR}/readected-updater.desktop" << EOF
[Desktop Entry]
Name=Readected Updater
Comment=Update Readected from GitHub
Exec=${PREFIX}/bin/readected-updater
Icon=system-software-update
Terminal=false
Type=Application
Categories=System;
EOF

echo ""
echo "✓ Done. Launch with:  readected  [file.pdf]"
echo "  Updater:             readected-updater"
