extends Node

const ENGINE_NAME := "gios"
const PUBLISHER := "azunain"
const VERSION := "0.1.0"

const GiosConfigScript := preload("res://scripts/core/GiosConfig.gd")
const GiosSaveScript := preload("res://scripts/core/GiosSave.gd")

var config
var save
var services := {}

func _ready() -> void:
	config = GiosConfigScript.new()
	config.load_config()

	print("%s %s by %s" % [ENGINE_NAME, VERSION, PUBLISHER])

	_boot_save()
	_boot_services()

func _boot_save() -> void:
	save = GiosSaveScript.new()
	add_child(save)
	save.boot()

func _boot_services() -> void:
	services.analytics = preload("res://scripts/services/AnalyticsService.gd").new()
	services.ads = preload("res://scripts/services/AdsService.gd").new()
	services.play_games = preload("res://scripts/services/PlayGamesService.gd").new()
	services.remote_config = preload("res://scripts/services/RemoteConfigService.gd").new()

	for service in services.values():
		add_child(service)
		if service.has_method("boot"):
			service.boot()

func event(name: String, params: Dictionary = {}) -> void:
	if services.has("analytics"):
		services.analytics.event(name, params)
