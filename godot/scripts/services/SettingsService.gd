extends Node
class_name SettingsService

const SAVE_KEY := "_settings"

var values := {
	"sound_enabled": true,
	"music_enabled": true,
	"haptics_enabled": true,
	"debug_overlay_enabled": false,
	"language": "auto"
}

func boot() -> void:
	var saved = Gios.save.data.get(SAVE_KEY, {})
	if typeof(saved) == TYPE_DICTIONARY:
		for key in saved.keys():
			values[key] = saved[key]
	print("SettingsService boot")

func get_value(key: String, fallback = null):
	return values.get(key, fallback)

func set_value(key: String, value) -> void:
	values[key] = value
	Gios.save.data[SAVE_KEY] = values
	Gios.save.save()
	Gios.event("setting_changed", {"key": key, "value": value})

func toggle_bool(key: String) -> bool:
	var next := not bool(get_value(key, false))
	set_value(key, next)
	return next
