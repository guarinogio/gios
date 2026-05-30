extends RefCounted
class_name DeviceInfo

static func collect() -> Dictionary:
	return {
		"os_name": OS.get_name(),
		"model": OS.get_model_name(),
		"processor": OS.get_processor_name(),
		"locale": OS.get_locale(),
		"screen_size": DisplayServer.screen_get_size(),
		"window_size": DisplayServer.window_get_size(),
		"rendering_driver": RenderingServer.get_rendering_device() != null,
		"unix_time": Time.get_unix_time_from_system()
	}
