extends Control

func _ready() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 24)
	add_child(root)

	var title := Label.new()
	title.text = "gios\nby azunain"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var play := Button.new()
	play.text = "Play Sandbox"
	play.pressed.connect(func():
		Gios.router.go_to("res://games/sandbox/SandboxGame.tscn")
	)
	root.add_child(play)

	var ads := Button.new()
	ads.text = "Test Rewarded Ad"
	ads.pressed.connect(func():
		Gios.services.ads.show_rewarded("main_menu_test")
	)
	root.add_child(ads)

	var login := Button.new()
	login.text = "Google Play Login"
	login.pressed.connect(func():
		Gios.services.play_games.sign_in()
	)
	root.add_child(login)
