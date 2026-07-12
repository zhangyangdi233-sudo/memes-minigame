extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_async")


func _run_async() -> void:
	await _run()
	if _failures.is_empty():
		print("audio runtime tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should load for audio runtime test")
	if scene == null:
		return
	var game_root := scene.instantiate()
	root.add_child(game_root)
	await process_frame
	game_root.new_game()
	await process_frame

	var phone := game_root.get_node_or_null("PhoneRoadAmbience") as AudioStreamPlayer
	var reality := game_root.get_node_or_null("RealityRoomAmbience") as AudioStreamPlayer
	var flashback := game_root.get_node_or_null("PollutionFlashbackAudio") as AudioStreamPlayer
	var action_tick := game_root.get_node_or_null("ActionTickAudio") as AudioStreamPlayer
	_assert_true(phone != null and phone.playing, "phone ambience should start when gameplay enters the tree")
	_assert_true(reality != null and reality.playing, "reality ambience should stay running underneath the mix")
	if phone != null and reality != null:
		_assert_true(phone.volume_db > reality.volume_db, "phone view should begin with the road layer in front")

	game_root.set_view_state("npc_up")
	await create_timer(0.65).timeout
	if phone != null and reality != null:
		_assert_true(reality.volume_db > phone.volume_db, "raising the camera should crossfade toward room ambience")
		_assert_near(reality.volume_db, -21.0, 0.2, "NPC speaking mix should reach its target volume")

	var player := game_root.get_node_or_null("RealityPlayer") as CharacterBody3D
	var merchant := game_root.get_node_or_null("RealityFloor/Actors/Merchant") as Area3D
	if player != null and merchant != null:
		player.position = merchant.position + Vector3(0.0, 0.0, 1.4)
		game_root._refresh_nearby_reality_actor()
		game_root._try_reality_interaction()
	var first_choice_id := str(game_root.game.get_typed_reality_choices()[0].get("id", ""))
	game_root._on_reality_choice_selected(first_choice_id)
	await create_timer(0.65).timeout
	if reality != null:
		_assert_near(reality.volume_db, -16.0, 0.2, "player composing should make the room tone more intimate")

	game_root._play_pollution_flashback()
	await process_frame
	_assert_true(flashback != null and flashback.playing, "pollution flashback should play its signal burst")
	if phone != null and reality != null:
		_assert_true(bool(phone.get_meta("flashback_ducked", false)), "flashback should duck the phone layer")
		_assert_true(bool(reality.get_meta("flashback_ducked", false)), "flashback should duck the reality layer")
	game_root._finish_pollution_flashback()
	_assert_true(flashback != null and not flashback.playing, "finishing flashback should stop the signal burst")

	game_root._play_action_spend_animation(5, 4)
	await process_frame
	_assert_true(action_tick != null and action_tick.playing, "spending an action should play the short tick")
	game_root._finish_action_spend_animation()
	game_root.queue_free()
	await process_frame


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s (expected %.2f, got %.2f)" % [message, expected, actual])
