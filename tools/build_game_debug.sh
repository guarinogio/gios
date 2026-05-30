#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 game_id"
  echo "Example: $0 tap_master"
  exit 1
fi

GAME_ID="$1"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_DIR="$ROOT_DIR/godot"
GAME_JSON="$GODOT_DIR/games/$GAME_ID/game.json"

cd "$ROOT_DIR"
source scripts/env.sh

if [ ! -f "$GAME_JSON" ]; then
  echo "Game not found: $GAME_JSON"
  exit 1
fi

readarray -t META < <(python3 - <<PY
import json
from pathlib import Path

data = json.loads(Path("$GAME_JSON").read_text())
print(data["id"])
print(data["title"])
print(data["scene"])
print(data["android_package"])
print(data.get("version", "0.1.0"))
PY
)

ID="${META[0]}"
TITLE="${META[1]}"
SCENE="${META[2]}"
PACKAGE="${META[3]}"
VERSION="${META[4]}"
APK_PATH="../exports/android/${ID}-debug.apk"

echo "== Building game =="
echo "id:      $ID"
echo "title:   $TITLE"
echo "scene:   $SCENE"
echo "package: $PACKAGE"
echo "version: $VERSION"

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

PROJECT_FILE="$GODOT_DIR/project.godot"
PROJECT_BACKUP="$(mktemp)"
PRESET_FILE="$GODOT_DIR/export_presets.cfg"
PRESET_BACKUP=""

cp "$PROJECT_FILE" "$PROJECT_BACKUP"

if [ -f "$PRESET_FILE" ]; then
  PRESET_BACKUP="$(mktemp)"
  cp "$PRESET_FILE" "$PRESET_BACKUP"
fi

cleanup() {
  cp "$PROJECT_BACKUP" "$PROJECT_FILE"
  rm -f "$PROJECT_BACKUP"

  if [ -n "$PRESET_BACKUP" ] && [ -f "$PRESET_BACKUP" ]; then
    cp "$PRESET_BACKUP" "$PRESET_FILE"
    rm -f "$PRESET_BACKUP"
  else
    rm -f "$PRESET_FILE"
  fi
}
trap cleanup EXIT

python3 - <<PY
from pathlib import Path

project = Path("$PROJECT_FILE")
s = project.read_text()

def replace_line(prefix, new_line):
    global s
    lines = s.splitlines()
    for i, line in enumerate(lines):
        if line.startswith(prefix):
            lines[i] = new_line
            s = "\n".join(lines) + "\n"
            return
    marker = "[application]\n\n"
    s = s.replace(marker, marker + new_line + "\n")

replace_line("config/name=", 'config/name="$TITLE"')
replace_line("run/main_scene=", 'run/main_scene="$SCENE"')
replace_line("config/version=", 'config/version="$VERSION"')

project.write_text(s)
PY

cat > "$PRESET_FILE" <<EOF_PRESET
[preset.0]

name="Android Debug"
platform="Android"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="$APK_PATH"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.0.options]

custom_template/debug=""
custom_template/release=""
gradle_build/use_gradle_build=false
gradle_build/gradle_build_directory=""
gradle_build/android_source_template=""
gradle_build/compress_native_libraries=false
gradle_build/export_format=0
gradle_build/min_sdk=""
gradle_build/target_sdk=""
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
version/code=1
version/name="$VERSION"
package/unique_name="$PACKAGE"
package/name="$TITLE"
package/signed=true
package/app_category=2
package/retain_data_on_uninstall=false
package/exclude_from_recents=false
package/show_in_android_tv=false
package/show_in_app_library=true
package/show_as_launcher_app=true
launcher_icons/main_192x192="res://assets/icons/icon.svg"
launcher_icons/adaptive_foreground_432x432="res://assets/icons/icon.svg"
launcher_icons/adaptive_background_432x432=""
graphics/opengl_debug=false
xr_features/xr_mode=0
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
command_line/extra_args=""
apk_expansion/enable=false
EOF_PRESET

echo
echo "== Checking project =="
./scripts/check_project.sh

echo
echo "== Exporting APK =="
godot --headless \
  --path godot \
  --export-debug "Android Debug" \
  "$APK_PATH"

echo
echo "APK created:"
ls -lh "exports/android/${ID}-debug.apk"
