#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

./tools/build_android_debug.sh

adb wait-for-device
adb install -r exports/android/gios-debug.apk
adb shell monkey -p com.azunain.gios 1

echo
echo "Deployed and launched gios."
