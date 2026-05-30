extends Node
class_name AppLifecycleService

func boot() -> void:
	print("AppLifecycleService boot")
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Gios.state.paused = false
			Gios.event("app_focus_in")
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			Gios.state.paused = true
			Gios.event("app_focus_out")
		NOTIFICATION_WM_CLOSE_REQUEST:
			Gios.event("app_close_requested")
			get_tree().quit()
