extends Node
class_name HapticsService

func boot() -> void:
	print("HapticsService boot")

func tap() -> void:
	if not _enabled():
		return
	Input.vibrate_handheld(20)

func success() -> void:
	if not _enabled():
		return
	Input.vibrate_handheld(45)

func failure() -> void:
	if not _enabled():
		return
	Input.vibrate_handheld(90)

func _enabled() -> bool:
	if not Gios.services.has("settings"):
		return true
	return bool(Gios.services["settings"].get_value("haptics_enabled", true))
