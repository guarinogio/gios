extends Control
class_name BaseGame

@export var game_id := "base_game"
@export var game_title := "Base Game"

var score := 0
var started_at_ms := 0

func _ready() -> void:
	started_at_ms = Time.get_ticks_msec()
	Gios.state.set_game(game_id, game_title)
	Gios.event("game_start", {
		"game_id": game_id,
		"title": game_title
	})

func add_score(amount: int) -> void:
	score += amount
	Gios.event("score_changed", {
		"game_id": game_id,
		"score": score
	})

	if Gios.services.has("haptics"):
		Gios.services["haptics"].tap()

func finish_game(reason: String = "completed") -> void:
	var duration_ms := Time.get_ticks_msec() - started_at_ms

	Gios.save.set_game_value(game_id, "last_score", score)

	Gios.event("game_finish", {
		"game_id": game_id,
		"score": score,
		"duration_ms": duration_ms,
		"reason": reason
	})

	if Gios.services.has("haptics"):
		Gios.services["haptics"].success()

	if Gios.services.has("play_games"):
		Gios.services["play_games"].submit_score("%s_default_leaderboard" % game_id, score)
