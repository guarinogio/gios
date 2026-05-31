extends BaseGame

var score_label: Label

func _ready() -> void:
	game_id = "tap_master"
	game_title = "TapMaster"
	super._ready()
	_build_ui()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 24)
	add_child(root)

	var title := Label.new()
	title.text = game_title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(score_label)

	var play := Button.new()
	play.text = "+1"
	play.pressed.connect(func():
		add_score(1)
		score_label.text = "Score: %d" % score
	)
	root.add_child(play)

	var finish := Button.new()
	finish.text = "Finish"
	finish.pressed.connect(func():
		finish_game("manual")
		Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
	)
	root.add_child(finish)

	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(func():
		Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
	)
	root.add_child(back)
