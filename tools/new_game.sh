#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 game_id"
  echo "Example: $0 tap_master"
  exit 1
fi

GAME_ID="$1"

if [[ ! "$GAME_ID" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Invalid game_id: $GAME_ID"
  echo "Use snake_case, starting with a letter. Example: tap_master"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_DIR="$ROOT_DIR/godot"
GAME_DIR="$GODOT_DIR/games/$GAME_ID"

CLASS_NAME="$(python3 - <<PY
game_id = "$GAME_ID"
print("".join(part.capitalize() for part in game_id.split("_")))
PY
)"

if [ -d "$GAME_DIR" ]; then
  echo "Game already exists: $GAME_DIR"
  exit 1
fi

mkdir -p "$GAME_DIR/assets"

cat > "$GAME_DIR/game.json" <<EOFJSON
{
  "id": "$GAME_ID",
  "class_name": "$CLASS_NAME",
  "title": "$CLASS_NAME",
  "version": "0.1.0",
  "scene": "res://games/$GAME_ID/${CLASS_NAME}.tscn",
  "android_package": "com.azunain.$GAME_ID",
  "ads_enabled": true,
  "play_games_enabled": true,
  "leaderboards": {
    "default": "${GAME_ID}_default_leaderboard"
  },
  "achievements": {}
}
EOFJSON

cat > "$GAME_DIR/${CLASS_NAME}.gd" <<EOFGD
extends BaseGame

var score_label: Label

func _ready() -> void:
	game_id = "$GAME_ID"
	game_title = "$CLASS_NAME"
	super._ready()
	_build_ui()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 24)
	add_child(root)

	var title := Label.new()
	title.text = game_title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(score_label)

	var play := Button.new()
	play.text = "+1"
	play.pressed.connect(func():
		add_score(1)
		score_label.text = "Score: %d" % score
	)
	root.add_child(play)

	var finish := Button.new()
	finish.text = "Finish"
	finish.pressed.connect(func():
		finish_game("manual")
		Gios.router.go_to("res://scenes/Main.tscn")
	)
	root.add_child(finish)

	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(func():
		Gios.router.go_to("res://scenes/Main.tscn")
	)
	root.add_child(back)
EOFGD

cat > "$GAME_DIR/${CLASS_NAME}.tscn" <<EOFTSCN
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://games/$GAME_ID/${CLASS_NAME}.gd" id="1"]

[node name="$CLASS_NAME" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")
EOFTSCN

echo "Created game:"
echo "  $GAME_DIR"
echo
echo "Run:"
echo "  ./tools/list_games.sh"
echo "  ./scripts/check_project.sh"
