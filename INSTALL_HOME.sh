#!/usr/bin/env bash
# Readected home install — puts real binary at ~/.local/bin/readected
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
BINDIR="$PREFIX/bin"
VERSION="1.5.5"

echo "=============================================="
echo "  Readected $VERSION  →  $BINDIR/readected"
echo "=============================================="

pkill -x readected 2>/dev/null || true
pkill -x readected-bin 2>/dev/null || true
pkill -x readected-updater 2>/dev/null || true
sleep 0.2

rm_old() {
  local f="$1"
  [[ -e "$f" || -L "$f" ]] || return 0
  if rm -f "$f" 2>/dev/null; then
    echo "  - removed $f"
  elif command -v sudo >/dev/null 2>&1; then
    sudo rm -f "$f" && echo "  - removed (sudo) $f" || echo "  ! cannot remove $f"
  else
    echo "  ! cannot remove $f"
  fi
}

echo "==> Cleaning old binaries..."
for d in "$HOME/.local/bin" /usr/local/bin /usr/bin "$HOME/bin"; do
  rm_old "$d/readected"
  rm_old "$d/readected-bin"
  rm_old "$d/readected-updater"
done

if ! pkg-config --exists poppler-qt6 2>/dev/null || ! command -v cmake >/dev/null || ! command -v ninja >/dev/null; then
  echo "==> Installing dependencies..."
  if [[ -x "$ROOT/install.sh" ]]; then
    bash "$ROOT/install.sh" deps || true
  fi
  if ! pkg-config --exists poppler-qt6 2>/dev/null; then
    echo "ERROR: poppler-qt6 not found. Install it, then re-run."
    echo "  Arch:   sudo pacman -S qt6-base qt6-declarative qt6-quickcontrols2 poppler-qt6 cmake ninja"
    echo "  Debian: sudo apt install qt6-base-dev qt6-declarative-dev libpoppler-qt6-dev cmake ninja-build"
    exit 1
  fi
fi

echo "==> Building from $ROOT ..."
cd "$ROOT"
rm -rf build
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
ninja -j"$(nproc 2>/dev/null || echo 4)"

BUILT=""
for cand in readected readected-bin; do
  if [[ -x "$ROOT/build/$cand" ]]; then
    BUILT="$ROOT/build/$cand"
    break
  fi
done
if [[ -z "$BUILT" ]]; then
  BUILT="$(find "$ROOT/build" -maxdepth 3 -type f -executable -name 'readected*' | head -1 || true)"
fi
if [[ -z "$BUILT" || ! -x "$BUILT" ]]; then
  echo "ERROR: build failed — no executable in build/"
  ls -la "$ROOT/build" || true
  exit 1
fi
echo "  built: $BUILT ($(du -h "$BUILT" | awk '{print $1}'))"

echo "==> Installing..."
mkdir -p "$BINDIR" "$PREFIX/share/applications" "$PREFIX/share/readected" \
         "${XDG_CONFIG_HOME:-$HOME/.config}/Readected/marks"

cp -f "$BUILT" "$BINDIR/readected"
chmod 755 "$BINDIR/readected"

echo "$VERSION" > "$PREFIX/share/readected/VERSION"

cat > "$PREFIX/share/applications/readected.desktop" << DESK
[Desktop Entry]
Name=Readected
Comment=PDF Reader
Exec=$BINDIR/readected %f
Icon=application-pdf
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;
DESK

echo ""
echo "=============================================="
echo "  OK: $BINDIR/readected"
ls -la "$BINDIR/readected"
echo "  version: $VERSION"
echo "=============================================="

EXPORT_LINE='export PATH="$HOME/.local/bin:$PATH"'
if ! echo ":$PATH:" | grep -q ":$BINDIR:"; then
  echo "!!! $BINDIR is NOT on PATH"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [[ -f "$rc" ]] && ! grep -qF '.local/bin' "$rc" 2>/dev/null; then
      echo "$EXPORT_LINE" >> "$rc"
      echo "  (added PATH line to $rc)"
    fi
  done
else
  echo "PATH already contains $BINDIR"
fi
hash -r 2>/dev/null || true
echo "Test: $BINDIR/readected"
