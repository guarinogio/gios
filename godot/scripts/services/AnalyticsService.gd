extends Node
class_name AnalyticsService

func boot() -> void:
	print("AnalyticsService boot")

func event(name: String, params: Dictionary = {}) -> void:
	print("[analytics]", name, params)
