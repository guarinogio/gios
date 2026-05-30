extends Node

const ENGINE_NAME := "gios"
const PUBLISHER := "azunain"
const VERSION := "0.2.0"

const GiosConfigScript := preload("res://scripts/core/GiosConfig.gd")
const GiosSaveScript := preload("res://scripts/core/GiosSave.gd")
const SceneRouterScript := preload("res://scripts/core/SceneRouter.gd")
const EngineStateScript := preload("res://scripts/core/EngineState.gd")
const DebugOverlayScene := preload("res://scenes/ui/DebugOverlay.tscn")

var config
var save
var router
var state
var debug_overlay
var services := {}

func _ready() -> void:
	config = GiosConfigScript.new()
	config.load_config()

	print("%s %s by %s" % [ENGINE_NAME, VERSION, PUBLISHER])

	_boot_save()
	_boot_state()
	_boot_router()
	_boot_services()
	_boot_debug_overlay()

	event("engine_boot", {
		"engine": ENGINE_NAME,
		"version": VERSION,
		"publisher": PUBLISHER
	})

func _boot_save() -> void:
	save = GiosSaveScript.new()
	add_child(save)
	save.boot()

func _boot_state() -> void:
	state = EngineStateScript.new()
	add_child(state)
	state.boot()

func _boot_router() -> void:
	router = SceneRouterScript.new()
	add_child(router)
	router.boot()

func _boot_services() -> void:
	services.settings = preload("res://scripts/services/SettingsService.gd").new()
	services.analytics = preload("res://scripts/services/AnalyticsService.gd").new()
	services.ads = preload("res://scripts/services/AdsService.gd").new()
	services.play_games = preload("res://scripts/services/PlayGamesService.gd").new()
	services.remote_config = preload("res://scripts/services/RemoteConfigService.gd").new()
	services.haptics = preload("res://scripts/services/HapticsService.gd").new()
	services.lifecycle = preload("res://scripts/services/AppLifecycleService.gd").new()

	for service in services.values():
		add_child(service)
		if service.has_method("boot"):
			service.boot()

func _boot_debug_overlay() -> void:
	debug_overlay = DebugOverlayScene.instantiate()
	add_child(debug_overlay)
	debug_overlay.boot()

	if services.has("settings") and bool(services.settings.get_value("debug_overlay_enabled", false)):
		debug_overlay.set_enabled(true)

func event(name: String, params: Dictionary = {}) -> void:
	print("[gios][event] %s %s" % [name, JSON.stringify(params)])
	if services.has("analytics"):
		services.analytics.event(name, params)
