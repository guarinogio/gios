extends Node
class_name AnalyticsService

func boot() -> void:
        print("AnalyticsService boot")

func event(name: String, params: Dictionary = {}) -> void:
        if _should_block(name):
                print("[analytics][blocked]", name)
                return

        print("[analytics]", name, params)

func _should_block(name: String) -> bool:
        if not Gios.services.has("consent"):
                return true

        if name == "consent_changed":
                return false

        return not Gios.services.consent.can_collect_analytics()
