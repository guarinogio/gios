#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 game_id adb_device"
  exit 1
fi

GAME_ID="$1"
DEVICE="$2"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

./tools/build_game_debug.sh "$GAME_ID"

adb connect "$DEVICE" >/dev/null || true
./tools/install_game_debug.sh "$GAME_ID" "$DEVICE"

PACKAGE="$(python3 - <<PY
import json
from pathlib import Path
print(json.loads(Path("godot/games/$GAME_ID/game.json").read_text())["android_package"])
PY
)"

adb -s "$DEVICE" logcat -c
adb -s "$DEVICE" shell am force-stop "$PACKAGE"
adb -s "$DEVICE" shell monkey -p "$PACKAGE" 1 >/dev/null

echo "== gios log attached =="
echo "Press Ctrl+C to detach."
adb -s "$DEVICE" logcat | grep -iE '(\[gios\]|\[analytics\]|\[ads\]|\[play_games\]|\[consent\]|\[remote_config\]|\[crash\]|SCRIPT ERROR|ERROR:|FATAL EXCEPTION|AndroidRuntime)'
