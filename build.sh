#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT_DIR/dist"
OUT_FILE="$OUT_DIR/old-tv-preview.aseprite-extension"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cd "$ROOT_DIR"
zip -r "$OUT_FILE" package.json main.lua old-tv-preview.aseprite-keys

echo "$OUT_FILE"
