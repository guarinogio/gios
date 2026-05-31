#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 game_id [adb_device]"
  echo "Example: $0 sandbox 192.168.8.116:33375"
  exit 1
fi

GAME_ID="$1"
DEVICE="${2:-}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GAME_JSON="$ROOT_DIR/godot/games/$GAME_ID/game.json"

if [ ! -f "$GAME_JSON" ]; then
  echo "Game not found: $GAME_JSON"
  exit 1
fi

PACKAGE="$(python3 - <<PY
import json
from pathlib import Path
print(json.loads(Path("$GAME_JSON").read_text())["android_package"])
PY
)"

ADB=(adb)

if [ -n "$DEVICE" ]; then
  if [[ "$DEVICE" == *:* ]]; then
    adb connect "$DEVICE" >/dev/null || true
  fi
  ADB=(adb -s "$DEVICE")
fi

echo "== Launching =="
echo "package: $PACKAGE"
if [ -n "$DEVICE" ]; then
  echo "device: $DEVICE"
fi

"${ADB[@]}" shell monkey -p "$PACKAGE" 1
