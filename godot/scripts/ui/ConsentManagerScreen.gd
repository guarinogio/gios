extends Control

var status_label: Label

func _ready() -> void:
        _build_ui()
        _refresh()

func _build_ui() -> void:
        var bg := ColorRect.new()
        bg.color = Color(0.04, 0.05, 0.09, 1.0)
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
        root.alignment = BoxContainer.ALIGNMENT_CENTER
        root.add_theme_constant_override("separation", 26)
        margin.add_child(root)

        var title := Label.new()
        title.text = "Privacy & Consent"
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title.add_theme_font_size_override("font_size", 52)
        root.add_child(title)

        status_label = Label.new()
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        status_label.add_theme_font_size_override("font_size", 28)
        root.add_child(status_label)

        _add_button(root, "Accept Optional Services", func():
                Gios.services.consent.accept()
                _refresh()
        )

        _add_button(root, "Reject Optional Services", func():
                Gios.services.consent.reject()
                _refresh()
        )

        _add_button(root, "Reset Consent", func():
                Gios.services.consent.reset()
                _refresh()
        )

        _add_button(root, "Read Privacy Policy", func():
                Gios.router.go_to("res://scenes/ui/PrivacyScreen.tscn")
        )

        _add_button(root, "Back", func():
                Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
        )

func _add_button(parent: VBoxContainer, label: String, callback: Callable) -> void:
        var button := Button.new()
        button.text = label
        button.custom_minimum_size = Vector2(720, 96)
        button.add_theme_font_size_override("font_size", 32)
        button.pressed.connect(callback)
        parent.add_child(button)

func _refresh() -> void:
        if not Gios.services.has("consent"):
                status_label.text = "Consent service missing."
                return

        var summary: Dictionary = Gios.services.consent.summary()

        status_label.text = "\n".join([
                "Current state: %s" % summary.get("state", "UNKNOWN"),
                "",
                "Ads: %s" % _enabled_text(bool(summary.get("can_show_ads", false))),
                "Analytics: %s" % _enabled_text(bool(summary.get("can_collect_analytics", false))),
                "Crash reports: %s" % _enabled_text(bool(summary.get("can_send_crash_reports", false))),
                "",
                "Consent required: %s" % str(summary.get("is_required", true))
        ])

func _enabled_text(value: bool) -> String:
        return "enabled" if value else "disabled"
