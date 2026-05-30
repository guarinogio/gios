#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

mkdir -p exports/android

echo "== Checking project =="
./scripts/check_project.sh

echo
echo "== Exporting Android Debug APK =="
godot --headless \
  --path godot \
  --export-debug "Android Debug" \
  ../exports/android/gios-debug.apk

echo
echo "APK created:"
ls -lh exports/android/gios-debug.apk
