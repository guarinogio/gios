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
        margin.add_theme_constant_override("margin_left", 56)
        margin.add_theme_constant_override("margin_right", 56)
        margin.add_theme_constant_override("margin_top", 72)
        margin.add_theme_constant_override("margin_bottom", 72)
        add_child(margin)

        var root := VBoxContainer.new()
        root.add_theme_constant_override("separation", 28)
        margin.add_child(root)

        var title := Label.new()
        title.text = "Privacy Policy"
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title.add_theme_font_size_override("font_size", 52)
        root.add_child(title)

        var subtitle := Label.new()
        subtitle.text = "GIOS by azunain"
        subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        subtitle.add_theme_font_size_override("font_size", 28)
        root.add_child(subtitle)

        var scroll := ScrollContainer.new()
        scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
        root.add_child(scroll)

        var content := VBoxContainer.new()
        content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        content.add_theme_constant_override("separation", 22)
        scroll.add_child(content)

        _add_section(content, "Effective date", "2026-05-31")

        _add_section(
                content,
                "Overview",
                "GIOS is a reusable Godot-based game engine and framework for Android games. This privacy policy explains how games built with GIOS handle consent, local data, analytics, advertising, and future online services."
        )

        _add_section(
                content,
                "Consent",
                "On first launch, the player can accept or reject optional data usage. If consent is rejected, GIOS blocks optional analytics collection and ad display."
        )

        _add_section(
                content,
                "Local data",
                "GIOS stores save data, settings, session counters, and consent state locally on the device."
        )

        _add_section(
                content,
                "Analytics",
                "Analytics are optional. If the player rejects consent, analytics events are blocked by the engine."
        )

        _add_section(
                content,
                "Advertising",
                "Advertising is optional. If the player rejects consent, rewarded and interstitial ads are blocked by the engine."
        )

        _add_section(
                content,
                "Future services",
                "Future versions may integrate Firebase, Crashlytics, AdMob, Remote Config, and Google Play Games. These services must respect the consent state."
        )

        _add_section(
                content,
                "Contact",
                "Publisher: azunain\nDeveloper: Giovanni Guarino"
        )

        var back := Button.new()
        back.text = "Back"
        back.custom_minimum_size = Vector2(640, 104)
        back.add_theme_font_size_override("font_size", 34)
        back.pressed.connect(func():
                if Gios.services.has("consent") and Gios.services["consent"].is_required():
                        Gios.router.go_to("res://scenes/ui/ConsentScreen.tscn")
                else:
                        Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
        )
        root.add_child(back)

func _add_section(parent: VBoxContainer, heading: String, body: String) -> void:
        var title := Label.new()
        title.text = heading
        title.add_theme_font_size_override("font_size", 34)
        title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        parent.add_child(title)

        var text := Label.new()
        text.text = body
        text.add_theme_font_size_override("font_size", 26)
        text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        parent.add_child(text)
