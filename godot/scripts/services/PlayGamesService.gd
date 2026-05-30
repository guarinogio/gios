extends Node
class_name PlayGamesService

var signed_in := false

func boot() -> void:
	print("PlayGamesService boot")

func sign_in() -> void:
	print("[play_games] sign_in requested")

func unlock_achievement(id: String) -> void:
	print("[play_games] unlock achievement:", id)

func submit_score(leaderboard_id: String, score: int) -> void:
	print("[play_games] submit score:", leaderboard_id, score)
