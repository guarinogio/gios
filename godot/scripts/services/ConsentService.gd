extends Node
class_name ConsentService

const SAVE_KEY := "_consent"

enum ConsentState {
        UNKNOWN,
        ACCEPTED,
        REJECTED
}

var state: int = ConsentState.UNKNOWN
var updated_at_unix: float = 0.0

func boot() -> void:
        var saved = Gios.save.data.get(SAVE_KEY, {})
        if typeof(saved) == TYPE_DICTIONARY:
                state = int(saved.get("state", ConsentState.UNKNOWN))
                updated_at_unix = float(saved.get("updated_at_unix", 0.0))
        print("ConsentService boot state=%s" % get_state())

func accept() -> void:
        _set_state(ConsentState.ACCEPTED)

func reject() -> void:
        _set_state(ConsentState.REJECTED)

func reset() -> void:
        _set_state(ConsentState.UNKNOWN)

func get_state() -> String:
        match state:
                ConsentState.ACCEPTED:
                        return "ACCEPTED"
                ConsentState.REJECTED:
                        return "REJECTED"
                _:
                        return "UNKNOWN"

func get_updated_at_unix() -> float:
        return updated_at_unix

func is_required() -> bool:
        return state == ConsentState.UNKNOWN

func can_show_ads() -> bool:
        return state == ConsentState.ACCEPTED

func can_collect_analytics() -> bool:
        return state == ConsentState.ACCEPTED

func can_send_crash_reports() -> bool:
        return state == ConsentState.ACCEPTED

func summary() -> Dictionary:
        return {
                "state": get_state(),
                "updated_at_unix": updated_at_unix,
                "is_required": is_required(),
                "can_show_ads": can_show_ads(),
                "can_collect_analytics": can_collect_analytics(),
                "can_send_crash_reports": can_send_crash_reports()
        }

func _set_state(next_state: int) -> void:
        state = next_state
        updated_at_unix = Time.get_unix_time_from_system()

        Gios.save.data[SAVE_KEY] = {
                "state": state,
                "state_name": get_state(),
                "updated_at_unix": updated_at_unix
        }
        Gios.save.save()

        Gios.event("consent_changed", summary())
