extends Control

func _ready() -> void:
        _build_ui()

func _build_ui() -> void:
        var bg := ColorRect.new()
        bg.color = Color(0.04, 0.05, 0.09, 1.0)
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
        root.alignment = BoxContainer.ALIGNMENT_CENTER
        root.add_theme_constant_override("separation", 28)
        margin.add_child(root)

        var title := Label.new()
        title.text = "Privacy & Consent"
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title.add_theme_font_size_override("font_size", 52)
        root.add_child(title)

        var body := Label.new()
        body.text = "GIOS can use optional services such as analytics and ads to improve games and support development. You can accept or reject this consent now. You can still play if you reject."
        body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        body.add_theme_font_size_override("font_size", 28)
        root.add_child(body)

        var privacy := Button.new()
        privacy.text = "Read Privacy Policy"
        privacy.custom_minimum_size = Vector2(640, 96)
        privacy.add_theme_font_size_override("font_size", 32)
        privacy.pressed.connect(func():
                Gios.router.go_to("res://scenes/ui/PrivacyScreen.tscn")
        )
        root.add_child(privacy)

        var accept := Button.new()
        accept.text = "Accept"
        accept.custom_minimum_size = Vector2(640, 96)
        accept.add_theme_font_size_override("font_size", 32)
        accept.pressed.connect(func():
                Gios.services["consent"].accept()
                Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
        )
        root.add_child(accept)

        var reject := Button.new()
        reject.text = "Reject"
        reject.custom_minimum_size = Vector2(640, 96)
        reject.add_theme_font_size_override("font_size", 32)
        reject.pressed.connect(func():
                Gios.services["consent"].reject()
                Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
        )
        root.add_child(reject)
