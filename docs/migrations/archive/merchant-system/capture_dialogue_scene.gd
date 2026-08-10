extends SceneTree

const OUTPUT_PATH := "/Users/zhang/Documents/游戏/babel-meme-game/tools/current_dialogue_view.png"
const VIEW_SIZE := Vector2i(1672, 941)
const HEADLESS_CAPTURE_ERROR := "Screenshot capture requires a rendered display. Run this tool without --headless from a GUI session."


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
	main.set_view_state("npc_up")
	main._phone_art_alpha = 0.0
	if main._phone_down_backdrop_image != null:
		main._phone_down_backdrop_image.visible = false
	main.game.pollution = 72
	main.game.pollution_flashback_seen = true
	main.game.legacy_rules = [{
		"id": "capture-legacy",
		"floor": 1,
		"required_text": "哈吉米，必须补票",
		"tags": ["哈吉米"],
		"strength": 1,
	}]
	var player := main.get_node_or_null("RealityPlayer") as CharacterBody3D
	var merchant := main.get_node_or_null("RealityFloor/Actors/Merchant") as Area3D
	if player != null and merchant != null:
		player.position = merchant.position + Vector3(0.0, 0.0, 1.4)
		main._refresh_nearby_reality_actor()
		main._try_reality_interaction()
		var choice_id := str(main.game.get_typed_reality_choices()[0].get("id", ""))
		main._on_reality_choice_hovered(choice_id)
	for frame in 16:
		await process_frame
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Unable to read root viewport texture")
		quit(1)
		return
	var image := viewport_texture.get_image()
	if image == null:
		push_error("Unable to read root viewport image")
		quit(1)
		return
	var error := image.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("Unable to save screenshot: %s" % error)
		quit(1)
		return
	print("saved screenshot: %s" % OUTPUT_PATH)
	quit(0)


func _ensure_capture_supported() -> bool:
	var display_name := DisplayServer.get_name().to_lower()
	if display_name == "headless":
		push_error(HEADLESS_CAPTURE_ERROR)
		quit(2)
		return false
	return true
