extends Node
class_name SceneRouter

var current_scene: Node = null

func boot() -> void:
	current_scene = get_tree().current_scene

func go_to(scene_path: String) -> void:
	Gios.event("scene_change_requested", {"scene": scene_path})

	var packed := load(scene_path)
	if packed == null:
		push_error("Scene not found: %s" % scene_path)
		return

	get_tree().change_scene_to_packed(packed)
