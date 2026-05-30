#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

echo "== gios doctor =="

fail() {
  echo "FAIL: $1"
  exit 1
}

command -v godot >/dev/null || fail "godot not found"
command -v sdkmanager >/dev/null || fail "sdkmanager not found"
command -v adb >/dev/null || fail "adb not found"
command -v python3 >/dev/null || fail "python3 not found"

[ -f godot/project.godot ] || fail "missing godot/project.godot"
[ -f godot/scripts/autoload/Gios.gd ] || fail "missing Gios autoload"
[ -d godot/games ] || fail "missing godot/games"

echo "godot: $(godot --version)"
echo "java: $("$JAVA_HOME/bin/java" -version 2>&1 | head -n 1)"
echo "sdkmanager: $(sdkmanager --version)"
echo "adb: $(adb version | head -n 1)"

echo
echo "== validating manifests =="
python3 - <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path("godot/games")
required = ["id", "class_name", "title", "version", "scene", "android_package"]
ok = True

for manifest in sorted(root.glob("*/game.json")):
    data = json.loads(manifest.read_text())
    print(f"- {manifest}")

    for field in required:
        if not data.get(field):
            print(f"  missing: {field}")
            ok = False

    gid = data.get("id", "")
    if not re.match(r"^[a-z][a-z0-9_]*$", gid):
        print(f"  invalid id: {gid}")
        ok = False

    scene = data.get("scene", "")
    if scene.startswith("res://"):
        scene_path = Path("godot") / scene.removeprefix("res://")
        if not scene_path.exists():
            print(f"  missing scene: {scene}")
            ok = False

    package = data.get("android_package", "")
    if not re.match(r"^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$", package):
        print(f"  invalid package: {package}")
        ok = False

if not ok:
    sys.exit(1)
PY

echo
echo "== project check =="
./scripts/check_project.sh

echo
echo "OK: gios doctor passed"
