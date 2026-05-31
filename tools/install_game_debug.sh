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
APK="$ROOT_DIR/exports/android/${GAME_ID}-debug.apk"

if [ ! -f "$APK" ]; then
  echo "APK not found: $APK"
  echo "Run: ./tools/build_game_debug.sh $GAME_ID"
  exit 1
fi

ADB=(adb)

if [ -n "$DEVICE" ]; then
  if [[ "$DEVICE" == *:* ]]; then
    adb connect "$DEVICE" >/dev/null || true
  fi
  ADB=(adb -s "$DEVICE")
fi

echo "== Installing =="
echo "apk: $APK"
if [ -n "$DEVICE" ]; then
  echo "device: $DEVICE"
fi

"${ADB[@]}" install -r "$APK"
