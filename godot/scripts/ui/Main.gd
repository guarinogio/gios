extends Control

func _ready() -> void:
	var label := Label.new()
	label.text = "gios engine\nby azunain"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)

	Gios.services["analytics"].event("app_start", {
		"engine": Gios.ENGINE_NAME,
		"version": Gios.VERSION
	})
