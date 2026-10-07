#!/usr/bin/env bash
# Build (if needed) and run without installing
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
if [[ ! -x build/readected ]]; then
  mkdir -p build && cd build
  cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
  ninja -j"$(nproc 2>/dev/null || echo 4)"
  cd ..
fi
exec "$ROOT/build/readected" "$@"
