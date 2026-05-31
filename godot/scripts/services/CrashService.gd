extends Node
class_name CrashService

const SAVE_KEY := "_crash"
const MAX_REPORTS := 20

var reports: Array = []
var context: Dictionary = {}
var user_id := ""

func boot() -> void:
        var saved = Gios.save.data.get(SAVE_KEY, {})
        if typeof(saved) == TYPE_DICTIONARY:
                var saved_reports = saved.get("reports", [])
                if typeof(saved_reports) == TYPE_ARRAY:
                        reports = saved_reports
                var saved_context = saved.get("context", {})
                if typeof(saved_context) == TYPE_DICTIONARY:
                        context = saved_context
                user_id = str(saved.get("user_id", ""))

        print("[crash] CrashService boot reports=%s enabled=%s" % [reports.size(), can_send_reports()])

func can_send_reports() -> bool:
        if not Gios.services.has("consent"):
                return false
        return Gios.services["consent"].can_send_crash_reports()

func set_user_id(value: String) -> void:
        user_id = value
        _persist()

func set_context(key: String, value) -> void:
        context[key] = value
        _persist()

func clear_context() -> void:
        context = {}
        _persist()

func record_error(message: String, data: Dictionary = {}) -> void:
        _record("error", message, data)

func record_warning(message: String, data: Dictionary = {}) -> void:
        _record("warning", message, data)

func record_info(message: String, data: Dictionary = {}) -> void:
        _record("info", message, data)

func get_reports() -> Array:
        return reports.duplicate(true)

func get_last_report() -> Dictionary:
        if reports.is_empty():
                return {}
        return reports[reports.size() - 1]

func clear_reports() -> void:
        reports = []
        _persist()
        print("[crash] reports cleared")

func summary() -> Dictionary:
        return {
                "enabled": can_send_reports(),
                "stored_reports": reports.size(),
                "user_id": user_id,
                "context_keys": context.keys()
        }

func _record(level: String, message: String, data: Dictionary = {}) -> void:
        var report := {
                "level": level,
                "message": message,
                "data": data,
                "context": context.duplicate(true),
                "user_id": user_id,
                "scene": Gios.state.current_scene_path if Gios.state else "",
                "game_id": Gios.state.current_game_id if Gios.state else "",
                "uptime_ms": Gios.state.uptime_ms() if Gios.state else 0,
                "created_at_unix": Time.get_unix_time_from_system(),
                "can_send": can_send_reports()
        }

        reports.append(report)

        while reports.size() > MAX_REPORTS:
                reports.pop_front()

        _persist()

        if can_send_reports():
                print("[crash][recorded] %s %s %s" % [level, message, JSON.stringify(data)])
        else:
                print("[crash][local_only] %s %s %s" % [level, message, JSON.stringify(data)])

func _persist() -> void:
        Gios.save.data[SAVE_KEY] = {
                "reports": reports,
                "context": context,
                "user_id": user_id
        }
        Gios.save.save()
