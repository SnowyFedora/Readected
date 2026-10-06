#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
pkill -x readected 2>/dev/null || true
pkill -x readected-updater 2>/dev/null || true
rm -rf build && mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local" ..
ninja -j"$(nproc 2>/dev/null || echo 4)"
cmake --install .
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/readected.desktop" << DESK
[Desktop Entry]
Name=Readected
Exec=$HOME/.local/bin/readected %f
Icon=application-pdf
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;
DESK
echo "OK: $HOME/.local/bin/readected"
ls -la "$HOME/.local/bin/readected"
