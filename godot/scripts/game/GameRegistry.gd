extends Node
class_name GameRegistry

var games: Dictionary = {}

func register_game(game: GiosGame) -> void:
	if game.id.is_empty():
		push_error("Cannot register game without id")
		return

	games[game.id] = game
	Gios.event("game_registered", {"game_id": game.id})

func get_game(game_id: String) -> GiosGame:
	return games.get(game_id)

func has_game(game_id: String) -> bool:
	return games.has(game_id)
