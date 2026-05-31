extends Node
class_name AdsService

func boot() -> void:
        print("AdsService boot")

func show_rewarded(placement: String) -> void:
        if not _can_show_ads():
                print("[ads][blocked] rewarded:", placement)
                return

        print("[ads] rewarded:", placement)

func show_interstitial(placement: String) -> void:
        if not _can_show_ads():
                print("[ads][blocked] interstitial:", placement)
                return

        print("[ads] interstitial:", placement)

func _can_show_ads() -> bool:
        if not Gios.services.has("consent"):
                return false

        return Gios.services["consent"].can_show_ads()
