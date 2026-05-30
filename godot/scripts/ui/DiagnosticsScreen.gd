extends Control

func _ready() -> void:
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

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 24)
	margin.add_child(root)

	var title := Label.new()
	title.text = "gios diagnostics"
	title.add_theme_font_size_override("font_size", 48)
	root.add_child(title)

	var text := Label.new()
	text.add_theme_font_size_override("font_size", 24)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.text = _diagnostics_text()
	root.add_child(text)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(640, 96)
	back.add_theme_font_size_override("font_size", 32)
	back.pressed.connect(func():
		Gios.router.go_to("res://scenes/Main.tscn")
	)
	root.add_child(back)

func _diagnostics_text() -> String:
	var lines: Array[String] = []

	lines.append("engine: %s %s" % [Gios.ENGINE_NAME, Gios.VERSION])
	lines.append("publisher: %s" % Gios.PUBLISHER)
	lines.append("sessions: %s" % Gios.save.data.get("sessions", 0))
	lines.append("services:")

	for key in Gios.services.keys():
		lines.append("  - %s: loaded" % key)

	lines.append("")
	lines.append("device:")

	var info := DeviceInfo.collect()
	for key in info.keys():
		lines.append("  - %s: %s" % [key, str(info[key])])

	return "\n".join(lines)
