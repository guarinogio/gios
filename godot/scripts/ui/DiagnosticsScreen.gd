extends Control

const DeviceInfoScript := preload("res://scripts/core/DeviceInfo.gd")
const BuildInfoScript := preload("res://scripts/core/BuildInfo.gd")

func _ready() -> void:
        print("[gios][ui][diagnostics] ready")
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

        _add_button(root, "Record Test Warning", func():
                print("[gios][ui][diagnostics] record warning pressed")
                Gios.services["crash"].record_warning("diagnostics_test_warning", {"source": "DiagnosticsScreen"})
                Gios.router.go_to("res://scenes/ui/DiagnosticsScreen.tscn")
        )

        _add_button(root, "Record Test Error", func():
                print("[gios][ui][diagnostics] record error pressed")
                Gios.services["crash"].record_error("diagnostics_test_error", {"source": "DiagnosticsScreen"})
                Gios.router.go_to("res://scenes/ui/DiagnosticsScreen.tscn")
        )

        _add_button(root, "Clear Crash Reports", func():
                print("[gios][ui][diagnostics] clear crash pressed")
                Gios.services["crash"].clear_reports()
                Gios.router.go_to("res://scenes/ui/DiagnosticsScreen.tscn")
        )

        _add_button(root, "Privacy & Consent", func():
                Gios.router.go_to("res://scenes/ui/ConsentManagerScreen.tscn")
        )

        _add_button(root, "Toggle Debug Overlay", func():
                Gios.debug_overlay.toggle()
        )

        _add_button(root, "Back", func():
                Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
        )

func _add_button(parent: VBoxContainer, label: String, callback: Callable) -> void:
        var button := Button.new()
        button.text = label
        button.custom_minimum_size = Vector2(640, 96)
        button.add_theme_font_size_override("font_size", 32)
        button.pressed.connect(callback)
        parent.add_child(button)

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
        lines.append("consent:")
        if Gios.services.has("consent"):
                for key in Gios.services["consent"].summary().keys():
                        lines.append("  - %s: %s" % [key, str(Gios.services["consent"].summary()[key])])

        lines.append("")
        lines.append("crash:")
        if Gios.services.has("crash"):
                var crash: Dictionary = Gios.services["crash"].summary()
                for key in crash.keys():
                        lines.append("  - %s: %s" % [key, str(crash[key])])
                var last: Dictionary = Gios.services["crash"].get_last_report()
                if not last.is_empty():
                        lines.append("  - last_level: %s" % last.get("level", ""))
                        lines.append("  - last_message: %s" % last.get("message", ""))

        lines.append("")
        lines.append("settings:")
        for key in Gios.services["settings"].values.keys():
                lines.append("  - %s: %s" % [key, str(Gios.services["settings"].values[key])])

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
