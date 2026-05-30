#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

source scripts/env.sh

./tools/doctor.sh

echo
echo "== building all release AABs =="

./tools/list_games.sh | cut -f1 | while read -r game_id; do
  [ -n "$game_id" ] || continue
  echo
  echo "== $game_id =="
  ./tools/build_game_release.sh "$game_id"
done

echo
echo "OK: all release AABs built"
ls -lh exports/android/*-release.aab
