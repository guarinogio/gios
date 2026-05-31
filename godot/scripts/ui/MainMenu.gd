extends Control

const GAMES_DIR := "res://games"
const BuildInfoScript := preload("res://scripts/core/BuildInfo.gd")

func _ready() -> void:
        print("[gios][ui][main_menu] ready")
        _build_ui()

func _build_ui() -> void:
        print("[gios][ui][main_menu] build_ui start")

        var bg := ColorRect.new()
        bg.color = Color(0.05, 0.07, 0.12, 1.0)
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
        scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
        margin.add_child(scroll)

        var root := VBoxContainer.new()
        root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        root.size_flags_vertical = Control.SIZE_EXPAND_FILL
        root.alignment = BoxContainer.ALIGNMENT_CENTER
        root.add_theme_constant_override("separation", 22)
        scroll.add_child(root)

        var title := Label.new()
        title.text = "gios\nby azunain"
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title.add_theme_font_size_override("font_size", 64)
        root.add_child(title)

        for game in _load_games():
                _add_button(root, "Play %s" % game.get("title", game.get("id", "Unknown")), func(scene_path = game.get("scene", "")):
                        print("[gios][ui][main_menu] play ", scene_path)
                        Gios.router.go_to(scene_path)
                )

        _add_button(root, "Privacy & Consent", func():
                print("[gios][ui][main_menu] open consent manager")
                Gios.router.go_to("res://scenes/ui/ConsentManagerScreen.tscn")
        )

        _add_button(root, "Privacy Policy", func():
                print("[gios][ui][main_menu] open privacy policy")
                Gios.router.go_to("res://scenes/ui/PrivacyScreen.tscn")
        )

        _add_button(root, "Test Rewarded Ad", func():
                print("[gios][ui][main_menu] test rewarded")
                Gios.services["ads"].show_rewarded("main_menu_test")
        )

        _add_button(root, "Google Play Login", func():
                print("[gios][ui][main_menu] play games login")
                Gios.services["play_games"].sign_in()
        )

        _add_button(root, "Diagnostics", func():
                print("[gios][ui][main_menu] diagnostics")
                Gios.router.go_to("res://scenes/ui/DiagnosticsScreen.tscn")
        )

        _add_button(root, "Toggle Debug Overlay", func():
                print("[gios][ui][main_menu] toggle debug overlay")
                Gios.debug_overlay.toggle()
        )

        print("[gios][ui][main_menu] build_ui done")

func _add_button(parent: VBoxContainer, label: String, callback: Callable) -> void:
        var button := Button.new()
        button.text = label
        button.custom_minimum_size = Vector2(640, 88)
        button.add_theme_font_size_override("font_size", 30)
        button.pressed.connect(callback)
        parent.add_child(button)

func _load_games() -> Array:
        var games: Array = []
        var selected_game_id := BuildInfoScript.selected_game_id()

        var dir := DirAccess.open(GAMES_DIR)

        if dir == null:
                push_error("Cannot open games directory: %s" % GAMES_DIR)
                return games

        dir.list_dir_begin()
        var name := dir.get_next()

        while name != "":
                if dir.current_is_dir() and not name.begins_with("."):
                        var config_path := "%s/%s/game.json" % [GAMES_DIR, name]
                        var game := _load_game_config(config_path)
                        if not game.is_empty():
                                if selected_game_id.is_empty() or str(game.get("id", "")) == selected_game_id:
                                        games.append(game)
                name = dir.get_next()

        dir.list_dir_end()

        games.sort_custom(func(a, b):
                return str(a.get("id", "")) < str(b.get("id", ""))
        )

        print("[gios][ui][main_menu] selected_game_id: ", selected_game_id)
        print("[gios][ui][main_menu] games loaded: ", games.size())
        return games

func _load_game_config(path: String) -> Dictionary:
        if not FileAccess.file_exists(path):
                return {}

        var file := FileAccess.open(path, FileAccess.READ)
        var parsed = JSON.parse_string(file.get_as_text())

        if typeof(parsed) != TYPE_DICTIONARY:
                push_error("Invalid game config: %s" % path)
                return {}

        return parsed
