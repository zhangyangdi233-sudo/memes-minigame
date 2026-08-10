extends SceneTree

const OUTPUT_PATH := "/Users/zhang/Documents/游戏/babel-meme-game/tools/current_relic_view.png"
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
	var player := main.get_node_or_null("RealityPlayer") as CharacterBody3D
	var items: Array[Area3D] = main._reality_floor.get_interactable_items()
	if player == null or items.is_empty():
		push_error("Unable to find a street relic for capture")
		quit(1)
		return
	var item := items[0]
	player.global_position = item.global_position + Vector3(0.0, 0.0, 2.05)
	var item_direction: Vector3 = item.global_position - player.global_position
	main._reality_yaw = rad_to_deg(atan2(-item_direction.x, -item_direction.z))
	main._reality_pitch = -15.0
	main._refresh_nearby_reality_actor()
	for frame in 48:
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
