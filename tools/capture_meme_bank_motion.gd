extends SceneTree

const CLOSED_OUTPUT := "/Users/zhang/Documents/游戏/babel-meme-game/tools/current_meme_bank_closed.png"
const MID_OUTPUT := "/Users/zhang/Documents/游戏/babel-meme-game/tools/current_meme_bank_opening.png"
const OPEN_OUTPUT := "/Users/zhang/Documents/游戏/babel-meme-game/tools/current_meme_bank_open.png"
const TRACE_OUTPUT := "/Users/zhang/Documents/游戏/babel-meme-game/tools/current_meme_bank_motion_trace.json"
const VIEW_SIZE := Vector2i(1672, 941)
const HEADLESS_CAPTURE_ERROR := "Screenshot capture requires a rendered display. Run this tool without --headless from a GUI session."

var _samples: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = VIEW_SIZE
	if not _ensure_capture_supported():
		return
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	if scene == null:
		push_error("Unable to load main scene")
		quit(1)
		return
	var main := scene.instantiate()
	root.add_child(main)
	main._locale.set_locale("zh")
	main.new_game()
	main._skip_prologue()
	main.game.completed_memes = _capture_memes()
	main._on_app_pressed("social")
	main._set_social_screen("publish")
	main._meme_bank_open = false
	main._render()
	for frame in 6:
		await process_frame
	var capture_started_at := Time.get_ticks_msec()
	_record_sample("closed", main, capture_started_at, false)
	if not await _save_viewport(CLOSED_OUTPUT):
		main.queue_free()
		await process_frame
		quit(1)
		return

	main._toggle_meme_bank()
	var motion_tween: Tween = main._meme_bank_tween
	if motion_tween == null:
		push_error("Meme-bank tween was not created")
		main.queue_free()
		await process_frame
		quit(1)
		return
	motion_tween.pause()
	motion_tween.custom_step(0.07)
	await process_frame
	_record_sample("opening", main, capture_started_at, true)
	if not await _save_viewport(MID_OUTPUT):
		main.queue_free()
		await process_frame
		quit(1)
		return

	motion_tween.play()
	if not await _wait_for_motion_phase(main, "open"):
		main.queue_free()
		await process_frame
		quit(1)
		return
	_record_sample("open", main, capture_started_at, true)
	if not await _save_viewport(OPEN_OUTPUT) or not _save_trace(main):
		main.queue_free()
		await process_frame
		quit(1)
		return

	print("saved meme-bank motion evidence: %s" % TRACE_OUTPUT)
	main.queue_free()
	await process_frame
	quit(0)


func _capture_memes() -> Array[Dictionary]:
	return [{
		"id": "capture-ha",
		"title": "梗字「哈」",
		"text": "哈",
		"tags": ["哈吉米"],
		"rarity": 1,
		"pollution_bias": 1,
		"fusion_level": 0,
	}, {
		"id": "capture-tower",
		"title": "梗字「塔」",
		"text": "塔",
		"tags": ["巴别塔"],
		"rarity": 2,
		"pollution_bias": 2,
		"fusion_level": 0,
	}, {
		"id": "capture-empty",
		"title": "复合「空位」",
		"text": "空位",
		"tags": ["空位", "群体"],
		"rarity": 2,
		"pollution_bias": 3,
		"fusion_level": 1,
	}, {
		"id": "capture-signal",
		"title": "复合「失联」",
		"text": "信号失联",
		"tags": ["信号", "失联"],
		"rarity": 3,
		"pollution_bias": 4,
		"fusion_level": 1,
	}]


func _record_sample(phase: String, main: Node, capture_started_at: int, motion_started: bool) -> void:
	var bank := main.find_child("MemeBankPopup", true, false) as Control
	if bank == null:
		return
	var motion_elapsed_ms := -1
	var motion_tween: Tween = main._meme_bank_tween
	if motion_started and motion_tween != null:
		motion_elapsed_ms = roundi(motion_tween.get_total_elapsed_time() * 1000.0)
	_samples.append({
		"phase": phase,
		"capture_elapsed_ms": Time.get_ticks_msec() - capture_started_at,
		"motion_elapsed_ms": motion_elapsed_ms,
		"scale_x": snappedf(bank.scale.x, 0.001),
		"alpha": snappedf(bank.modulate.a, 0.001),
		"visible": bank.visible,
		"motion_phase": str(bank.get_meta("motion_phase", "idle")),
	})


func _wait_for_motion_phase(main: Node, target_phase: String) -> bool:
	for frame_index in 240:
		var bank := main.find_child("MemeBankPopup", true, false) as Control
		if bank != null and str(bank.get_meta("motion_phase", "")) == target_phase:
			return true
		await process_frame
	push_error("Meme-bank tween did not settle into phase: %s" % target_phase)
	return false


func _save_viewport(path: String) -> bool:
	await process_frame
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Unable to read root viewport texture")
		return false
	var image := viewport_texture.get_image()
	if image == null:
		push_error("Unable to read root viewport image")
		return false
	var error := image.save_png(path)
	if error != OK:
		push_error("Unable to save screenshot: %s" % error)
		return false
	print("saved screenshot: %s" % path)
	return true


func _save_trace(main: Node) -> bool:
	var profile: Dictionary = main._meme_bank_motion_profile(true)
	var payload := {
		"implementation": "Godot Tween",
		"timing_basis": "Tween.get_total_elapsed_time",
		"transition": "TRANS_QUINT",
		"ease": "EASE_OUT",
		"scale_duration_seconds": profile.get("scale_duration", 0.0),
		"alpha_duration_seconds": profile.get("alpha_duration", 0.0),
		"samples": _samples,
	}
	var file := FileAccess.open(TRACE_OUTPUT, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write motion trace: %s" % TRACE_OUTPUT)
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true


func _ensure_capture_supported() -> bool:
	var display_name := DisplayServer.get_name().to_lower()
	if display_name == "headless":
		push_error(HEADLESS_CAPTURE_ERROR)
		quit(2)
		return false
	return true
