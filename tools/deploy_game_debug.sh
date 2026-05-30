#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 game_id"
  echo "Example: $0 tap_master"
  exit 1
fi

GAME_ID="$1"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

GAME_JSON="godot/games/$GAME_ID/game.json"

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

APK="exports/android/${GAME_ID}-debug.apk"

./tools/build_game_debug.sh "$GAME_ID"

adb wait-for-device
adb install -r "$APK"
adb shell monkey -p "$PACKAGE" 1

echo
echo "Deployed and launched $GAME_ID ($PACKAGE)."
