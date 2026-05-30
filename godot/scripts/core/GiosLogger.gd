extends RefCounted
class_name GiosLogger

static func info(message: String, data: Dictionary = {}) -> void:
	print("[gios][info] ", message, " ", data)

static func warn(message: String, data: Dictionary = {}) -> void:
	push_warning("[gios][warn] %s %s" % [message, data])

static func error(message: String, data: Dictionary = {}) -> void:
	push_error("[gios][error] %s %s" % [message, data])
