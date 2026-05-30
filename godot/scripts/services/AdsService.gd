extends Node
class_name AdsService

func boot() -> void:
	print("AdsService boot")

func show_rewarded(placement: String) -> void:
	print("[ads] rewarded:", placement)

func show_interstitial(placement: String) -> void:
	print("[ads] interstitial:", placement)
