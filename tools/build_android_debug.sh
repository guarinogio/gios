#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

mkdir -p exports/android

mkdir -p godot/config
python3 - <<'PY_BUILDINFO'
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

def git(args, fallback="unknown"):
    try:
        return subprocess.check_output(["git"] + args, text=True).strip()
    except Exception:
        return fallback

data = {
    "build_time": datetime.now(timezone.utc).isoformat(),
    "git_commit": git(["rev-parse", "--short", "HEAD"]),
    "git_branch": git(["branch", "--show-current"]),
    "profile": "debug"
}
Path("godot/config/build_info.json").write_text(json.dumps(data, indent=2) + "\n")
PY_BUILDINFO

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
