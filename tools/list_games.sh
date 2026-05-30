#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GAMES_DIR="$ROOT_DIR/godot/games"

find "$GAMES_DIR" -mindepth 2 -maxdepth 2 -name game.json -print | sort | while read -r file; do
  python3 - <<PY
import json
from pathlib import Path

p = Path("$file")
data = json.loads(p.read_text())
print(f"{data['id']}\t{data['title']}\t{data['scene']}")
PY
done
