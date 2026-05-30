extends Node
class_name EngineState

var current_game_id := ""
var current_game_title := ""
var current_scene_path := ""
var boot_time_ms := 0
var paused := false

func boot() -> void:
	boot_time_ms = Time.get_ticks_msec()
	current_scene_path = str(get_tree().current_scene.scene_file_path) if get_tree().current_scene else ""
	print("[gios][state] boot")

func set_game(game_id: String, title: String) -> void:
	current_game_id = game_id
	current_game_title = title
	Gios.event("engine_game_set", {
		"game_id": game_id,
		"title": title
	})

func set_scene(scene_path: String) -> void:
	current_scene_path = scene_path

func uptime_ms() -> int:
	return Time.get_ticks_msec() - boot_time_ms
