extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for script_path in [
		"res://tools/capture_main_scene.gd",
		"res://tools/capture_publish_scene.gd",
		"res://tools/capture_shop_scene.gd",
		"res://tools/capture_reality_scene.gd",
		"res://tools/capture_dialogue_scene.gd",
		"res://tools/capture_merchant_scene.gd",
		"res://tools/capture_relic_scene.gd",
		"res://tools/capture_day_transition.gd",
		"res://tools/capture_main_menu.gd",
	]:
		_assert_capture_script_guarded(script_path)

	if _failures.is_empty():
		print("capture tool tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _assert_capture_script_guarded(script_path: String) -> void:
	var source := FileAccess.get_file_as_string(script_path)
	_assert_true(not source.is_empty(), "capture script should be readable: %s" % script_path)
	_assert_true(source.contains("DisplayServer.get_name"), "capture script should check the display server before reading viewport textures: %s" % script_path)
	_assert_true(source.contains("headless"), "capture script should explicitly handle headless display mode: %s" % script_path)
	_assert_true(source.contains("HEADLESS_CAPTURE_ERROR"), "capture script should use a clear headless error message: %s" % script_path)
	_assert_true(source.contains("quit(2)"), "capture script should exit with a distinct status for unsupported capture mode: %s" % script_path)
	_assert_true(source.find("if not _ensure_capture_supported()") >= 0 and source.find("if not _ensure_capture_supported()") < source.find("root.get_texture"), "capture script should guard before calling root.get_texture: %s" % script_path)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)
