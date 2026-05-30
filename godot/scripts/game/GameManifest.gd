extends RefCounted
class_name GameManifest

const REQUIRED_FIELDS := [
	"id",
	"class_name",
	"title",
	"version",
	"scene",
	"android_package"
]

var path := ""
var data := {}

static func load_from_path(manifest_path: String) -> GameManifest:
	var manifest := GameManifest.new()
	manifest.path = manifest_path

	if not FileAccess.file_exists(manifest_path):
		push_error("Missing game manifest: %s" % manifest_path)
		return manifest

	var file := FileAccess.open(manifest_path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid game manifest JSON: %s" % manifest_path)
		return manifest

	manifest.data = parsed
	return manifest

func is_valid() -> bool:
	return errors().is_empty()

func errors() -> Array[String]:
	var out: Array[String] = []

	if data.is_empty():
		out.append("empty manifest: %s" % path)
		return out

	for field in REQUIRED_FIELDS:
		if not data.has(field) or str(data[field]).is_empty():
			out.append("missing field '%s' in %s" % [field, path])

	if data.has("id") and not str(data["id"]).is_valid_identifier():
		out.append("id should be snake_case identifier: %s" % data["id"])

	if data.has("scene") and not FileAccess.file_exists(str(data["scene"])):
		out.append("scene not found: %s" % data["scene"])

	return out

func get_value(key: String, fallback = null):
	return data.get(key, fallback)
