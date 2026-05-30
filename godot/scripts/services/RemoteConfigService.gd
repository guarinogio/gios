extends Node
class_name RemoteConfigService

var values := {
	"ads_enabled": true,
	"interstitial_frequency": 3,
	"daily_challenge_enabled": true
}

func boot() -> void:
	print("RemoteConfigService boot")

func get_value(key: String, fallback = null):
	return values.get(key, fallback)
