extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for script_path in [
		"res://tools/capture_main_scene.gd",
		"res://tools/capture_phone_launcher.gd",
		"res://tools/capture_notebook_scene.gd",
		"res://tools/capture_meme_bank_motion.gd",
		"res://tools/capture_publish_scene.gd",
		"res://tools/capture_shop_scene.gd",
		"res://tools/capture_reality_scene.gd",
		"res://tools/capture_reality_district.gd",
		"res://tools/capture_dreamcore_artifacts.gd",
		"res://tools/capture_authored_horror_events.gd",
		"res://tools/capture_dialogue_scene.gd",
		"res://tools/capture_merchant_scene.gd",
		"res://tools/capture_npc_character_scene.gd",
		"res://tools/capture_relic_scene.gd",
		"res://tools/capture_ending_scene.gd",
		"res://tools/capture_day_transition.gd",
		"res://tools/capture_main_menu.gd",
		"res://tools/capture_prologue.gd",
	]:
		_assert_capture_script_guarded(script_path)
	_assert_distinct_capture_sequence([
		"res://tools/current_horror_cover_watcher.png",
		"res://tools/current_horror_cover_watcher_retreat.png",
		"res://tools/current_horror_cover_watcher_gone.png",
	], "cover-watcher appearance, retreat, and disappearance")
	_assert_distinct_capture_sequence([
		"res://tools/current_meme_bank_closed.png",
		"res://tools/current_meme_bank_opening.png",
		"res://tools/current_meme_bank_open.png",
	], "meme-bank closed, opening, and open motion")
	_assert_meme_bank_motion_trace("res://tools/current_meme_bank_motion_trace.json")

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
	_assert_true(load(script_path) is Script, "capture script should compile before any rendered evidence is trusted: %s" % script_path)
	_assert_true(source.contains("DisplayServer.get_name"), "capture script should check the display server before reading viewport textures: %s" % script_path)
	_assert_true(source.contains("headless"), "capture script should explicitly handle headless display mode: %s" % script_path)
	_assert_true(source.contains("HEADLESS_CAPTURE_ERROR"), "capture script should use a clear headless error message: %s" % script_path)
	_assert_true(source.contains("quit(2)"), "capture script should exit with a distinct status for unsupported capture mode: %s" % script_path)
	_assert_true(source.find("if not _ensure_capture_supported()") >= 0 and source.find("if not _ensure_capture_supported()") < source.find("root.get_texture"), "capture script should guard before calling root.get_texture: %s" % script_path)


func _assert_distinct_capture_sequence(paths: Array[String], label: String) -> void:
	var digests: Array[String] = []
	var unique_digests := {}
	for path in paths:
		_assert_true(FileAccess.file_exists(path), "%s evidence should exist: %s" % [label, path])
		if FileAccess.file_exists(path):
			var digest := FileAccess.get_md5(path)
			digests.append(digest)
			unique_digests[digest] = true
	_assert_true(digests.size() == paths.size() and unique_digests.size() == paths.size(), "%s should contain distinct rendered frames" % label)


func _assert_meme_bank_motion_trace(path: String) -> void:
	_assert_true(FileAccess.file_exists(path), "meme-bank motion trace should exist")
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	_assert_true(parsed is Dictionary, "meme-bank motion trace should be valid JSON")
	if not parsed is Dictionary:
		return
	var trace := parsed as Dictionary
	_assert_eq(str(trace.get("timing_basis", "")), "Tween.get_total_elapsed_time", "motion evidence should use the engine tween clock")
	var samples: Array = trace.get("samples", [])
	_assert_eq(samples.size(), 3, "motion evidence should retain closed, opening, and open samples")
	if samples.size() != 3:
		return
	var closed := samples[0] as Dictionary
	var opening := samples[1] as Dictionary
	var opened := samples[2] as Dictionary
	_assert_eq(int(closed.get("motion_elapsed_ms", 0)), -1, "closed evidence should precede the motion clock")
	var opening_ms := int(opening.get("motion_elapsed_ms", -1))
	_assert_true(opening_ms >= 40 and opening_ms <= 150, "opening evidence should be sampled near the requested 70 ms engine time")
	_assert_true(int(opened.get("motion_elapsed_ms", -1)) >= 280, "open evidence should be sampled after the longest tween track")
	_assert_eq(str(opened.get("motion_phase", "")), "open", "open evidence should record the production completion callback")
	_assert_true(int(opening.get("capture_elapsed_ms", -1)) >= opening_ms, "capture wall time may include I/O but must stay separate from motion time")
	if opening_ms >= 0:
		var ratio := clampf(float(opening_ms) / 280.0, 0.0, 1.0)
		var expected_scale := 0.84 + 0.16 * (1.0 - pow(1.0 - ratio, 5.0))
		_assert_true(absf(float(opening.get("scale_x", 0.0)) - expected_scale) <= 0.035, "opening scale should match an easeOutQuint sample on the tween clock")


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
