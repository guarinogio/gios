extends RefCounted
class_name GiosConfig

const CONFIG_PATH := "res://config/gios_config.json"

var data: Dictionary = {}

func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		push_error("Missing config: %s" % CONFIG_PATH)
		data = {}
		return

	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var text := file.get_as_text()
	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON config: %s" % CONFIG_PATH)
		data = {}
		return

	data = parsed

func get_value(path: String, fallback = null):
	var parts := path.split(".")
	var current = data

	for part in parts:
		if typeof(current) != TYPE_DICTIONARY or not current.has(part):
			return fallback
		current = current[part]

	return current
