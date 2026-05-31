extends CanvasLayer

var label: Label
var visible_enabled := false

func boot() -> void:
	layer = 999
	visible = false

	label = Label.new()
	label.position = Vector2(16, 16)
	label.add_theme_font_size_override("font_size", 20)
	label.text = "gios debug"
	add_child(label)

	set_process(true)
	print("DebugOverlay boot")

func toggle() -> void:
	set_enabled(not visible_enabled)

func set_enabled(enabled: bool) -> void:
	visible_enabled = enabled
	visible = enabled
	if Gios.services.has("settings"):
		Gios.services["settings"].set_value("debug_overlay_enabled", enabled)

func _process(_delta: float) -> void:
	if not visible_enabled:
		return

	var fps: int = Engine.get_frames_per_second()
	var mem_mb: float = float(OS.get_static_memory_usage()) / 1024.0 / 1024.0
	var scene: String = str(Gios.state.current_scene_path)
	var game: String = str(Gios.state.current_game_id)
	var uptime: float = float(Gios.state.uptime_ms()) / 1000.0

	label.text = "gios %s\nfps: %d\nmem: %.1f MB\nscene: %s\ngame: %s\nuptime: %.1fs" % [
		Gios.VERSION,
		fps,
		mem_mb,
		scene,
		game,
		uptime
	]
