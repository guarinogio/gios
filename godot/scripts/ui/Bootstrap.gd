extends Control

func _ready() -> void:
        call_deferred("_route_initial_scene")

func _route_initial_scene() -> void:
        if Gios.services.has("consent") and Gios.services.consent.is_required():
                Gios.router.go_to("res://scenes/ui/ConsentScreen.tscn")
                return

        Gios.router.go_to("res://scenes/ui/MainMenu.tscn")
