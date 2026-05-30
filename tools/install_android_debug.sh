#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

APK="exports/android/gios-debug.apk"

if [ ! -f "$APK" ]; then
  echo "Missing APK: $APK"
  echo "Run ./tools/build_android_debug.sh first"
  exit 1
fi

adb wait-for-device

echo "Waiting for Android boot..."
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  sleep 1
done

echo "Installing $APK"
adb install -r "$APK"
