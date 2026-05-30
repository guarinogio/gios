extends RefCounted
class_name BuildInfo

const BUILD_INFO_PATH := "res://config/build_info.json"

static func collect() -> Dictionary:
	var data := {
		"build_time": "dev",
		"git_commit": "unknown",
		"git_branch": "unknown",
		"profile": "debug"
	}

	if FileAccess.file_exists(BUILD_INFO_PATH):
		var file := FileAccess.open(BUILD_INFO_PATH, FileAccess.READ)
		var parsed = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			for key in parsed.keys():
				data[key] = parsed[key]

	data["engine_name"] = Gios.ENGINE_NAME
	data["engine_version"] = Gios.VERSION
	data["publisher"] = Gios.PUBLISHER
	data["os"] = OS.get_name()

	return data
