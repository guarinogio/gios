extends Control

const DeviceInfoScript := preload("res://scripts/core/DeviceInfo.gd")
const BuildInfoScript := preload("res://scripts/core/BuildInfo.gd")

func _ready() -> void:
	print("DIAGNOSTICS SCREEN READY")
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.04, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 64)
	margin.add_theme_constant_override("margin_bottom", 64)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_child(scroll)

	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(900, 0)
	root.add_theme_constant_override("separation", 24)
	scroll.add_child(root)

	var title := Label.new()
	title.text = "gios diagnostics"
	title.add_theme_font_size_override("font_size", 48)
	root.add_child(title)

	var text := Label.new()
	text.add_theme_font_size_override("font_size", 24)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.text = _diagnostics_text()
	root.add_child(text)

	var debug := Button.new()
	debug.text = "Toggle Debug Overlay"
	debug.custom_minimum_size = Vector2(640, 96)
	debug.add_theme_font_size_override("font_size", 32)
	debug.pressed.connect(func():
		Gios.debug_overlay.toggle()
	)
	root.add_child(debug)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(640, 96)
	back.add_theme_font_size_override("font_size", 32)
	back.pressed.connect(func():
		Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
	)
	root.add_child(back)

func _diagnostics_text() -> String:
	var lines: Array[String] = []

	lines.append("engine: %s %s" % [Gios.ENGINE_NAME, Gios.VERSION])
	lines.append("publisher: %s" % Gios.PUBLISHER)
	lines.append("sessions: %s" % Gios.save.data.get("sessions", 0))
	lines.append("current_game: %s" % Gios.state.current_game_id)
	lines.append("current_scene: %s" % Gios.state.current_scene_path)
	lines.append("uptime_ms: %s" % Gios.state.uptime_ms())

	lines.append("")
	lines.append("services:")
	for key in Gios.services.keys():
		lines.append("  - %s: loaded" % key)

	lines.append("")
	lines.append("settings:")
	for key in Gios.services.settings.values.keys():
		lines.append("  - %s: %s" % [key, str(Gios.services.settings.values[key])])

	lines.append("")
	lines.append("build:")
	var build := BuildInfoScript.collect()
	for key in build.keys():
		lines.append("  - %s: %s" % [key, str(build[key])])

	lines.append("")
	lines.append("device:")
	var info := DeviceInfoScript.collect()
	for key in info.keys():
		lines.append("  - %s: %s" % [key, str(info[key])])

	return "\n".join(lines)
