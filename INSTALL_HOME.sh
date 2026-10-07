#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Stopping old Readected..."
pkill -x readected 2>/dev/null || true
pkill -x readected-updater 2>/dev/null || true
sleep 0.3

echo "==> Clean build..."
rm -rf build
mkdir -p build
cd build

echo "==> Configure (prefix=$HOME/.local)..."
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local" ..

echo "==> Build..."
ninja -j"$(nproc 2>/dev/null || echo 4)"

echo "==> Install..."
cmake --install .

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/readected.desktop" << DESK
[Desktop Entry]
Name=Readected
Comment=PDF Reader
Exec=$HOME/.local/bin/readected %f
Icon=application-pdf
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;
DESK

echo ""
echo "=========================================="
echo "  INSTALLED: $HOME/.local/bin/readected"
echo "  Run: $HOME/.local/bin/readected"
echo "=========================================="
ls -la "$HOME/.local/bin/readected" "$HOME/.local/bin/readected-updater" 2>/dev/null || true
