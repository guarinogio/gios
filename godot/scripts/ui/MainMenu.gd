extends Control

const GAMES_DIR := "res://games"

func _ready() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 18)
	add_child(root)

	var title := Label.new()
	title.text = "gios\nby azunain"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var games := _load_games()

	for game in games:
		var button := Button.new()
		button.text = "Play %s" % game.get("title", game.get("id", "Unknown"))
		button.pressed.connect(func(scene_path = game.get("scene", "")):
			Gios.router.go_to(scene_path)
		)
		root.add_child(button)

	var ads := Button.new()
	ads.text = "Test Rewarded Ad"
	ads.pressed.connect(func():
		Gios.services.ads.show_rewarded("main_menu_test")
	)
	root.add_child(ads)

	var login := Button.new()
	login.text = "Google Play Login"
	login.pressed.connect(func():
		Gios.services.play_games.sign_in()
	)
	root.add_child(login)

func _load_games() -> Array:
	var games: Array = []
	var dir := DirAccess.open(GAMES_DIR)

	if dir == null:
		push_error("Cannot open games directory: %s" % GAMES_DIR)
		return games

	dir.list_dir_begin()
	var name := dir.get_next()

	while name != "":
		if dir.current_is_dir() and not name.begins_with("."):
			var config_path := "%s/%s/game.json" % [GAMES_DIR, name]
			var game := _load_game_config(config_path)
			if not game.is_empty():
				games.append(game)

		name = dir.get_next()

	dir.list_dir_end()

	games.sort_custom(func(a, b):
		return str(a.get("id", "")) < str(b.get("id", ""))
	)

	return games

func _load_game_config(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid game config: %s" % path)
		return {}

	return parsed
