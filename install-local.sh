#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASEPRITE_BIN="${ASEPRITE_BIN:-/Applications/Aseprite.app/Contents/MacOS/aseprite}"
PACKAGE="$("$ROOT_DIR/build.sh")"

if [[ ! -x "$ASEPRITE_BIN" ]]; then
  echo "Aseprite binary not found: $ASEPRITE_BIN" >&2
  exit 1
fi

open "$PACKAGE"
echo "Opened $PACKAGE. Finish installation in Aseprite, then restart Aseprite."
