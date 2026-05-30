extends Node
class_name GiosSave

const SAVE_PATH := "user://gios_save.json"

var data: Dictionary = {
	"first_launch": true,
	"sessions": 0,
	"games": {}
}

func boot() -> void:
	load_save()
	data["sessions"] = int(data.get("sessions", 0)) + 1
	data["first_launch"] = false
	save()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())

	if typeof(parsed) == TYPE_DICTIONARY:
		data = parsed

func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func get_game_data(game_id: String) -> Dictionary:
	if not data["games"].has(game_id):
		data["games"][game_id] = {}
	return data["games"][game_id]

func set_game_value(game_id: String, key: String, value) -> void:
	var game_data := get_game_data(game_id)
	game_data[key] = value
	save()
