#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
source scripts/env.sh

echo "== gios check =="
echo "godot: $(godot --version)"
echo "java: $("$JAVA_HOME/bin/java" -version 2>&1 | head -n 1)"
echo "sdkmanager: $(sdkmanager --version)"
echo "adb: $(adb version | head -n 1)"

echo
echo "== Godot project parse check =="

LOG_FILE="$(mktemp)"
godot --headless --path godot --quit 2>&1 | tee "$LOG_FILE"

if grep -E "SCRIPT ERROR|ERROR:" "$LOG_FILE" >/dev/null; then
  echo
  echo "FAILED: Godot reported errors."
  exit 1
fi

echo
echo "OK"
