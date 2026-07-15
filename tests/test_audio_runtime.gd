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
	var pollution_music := game_root.get_node_or_null("PollutionMusicLayer") as AudioStreamPlayer
	var flashback := game_root.get_node_or_null("PollutionFlashbackAudio") as AudioStreamPlayer
	var action_tick := game_root.get_node_or_null("ActionTickAudio") as AudioStreamPlayer
	_assert_true(phone != null and phone.playing, "phone ambience should start when gameplay enters the tree")
	_assert_true(reality != null and reality.playing, "reality ambience should stay running underneath the mix")
	_assert_true(pollution_music != null and pollution_music.playing, "phase-aligned pollution music should run silently until needed")
	if phone != null and reality != null:
		_assert_true(phone.volume_db > reality.volume_db, "phone view should begin with the road layer in front")
		_assert_true(str(phone.get_meta("generated_audio_path", "")).contains("babel_phone_signal"), "phone view should use the new original signal score")
		_assert_true(str(reality.get_meta("generated_audio_path", "")).contains("babel_reality_liminal"), "reality view should use the new original liminal score")
	if pollution_music != null:
		_assert_true(str(pollution_music.get_meta("generated_audio_path", "")).contains("babel_pollution_rot"), "pollution should use its own original synchronized stem")
		_assert_near(pollution_music.volume_db, -60.0, 0.1, "low pollution should keep the corruption stem inaudible")
	if phone != null and reality != null and pollution_music != null:
		var phone_stream := phone.stream as AudioStreamWAV
		var reality_stream := reality.stream as AudioStreamWAV
		var pollution_stream := pollution_music.stream as AudioStreamWAV
		_assert_true(phone_stream != null and reality_stream != null and pollution_stream != null, "all adaptive score stems should load as loopable WAV streams")
		if phone_stream != null and reality_stream != null and pollution_stream != null:
			_assert_eq(phone_stream.loop_end, reality_stream.loop_end, "phone and reality stems should share an exact loop frame count")
			_assert_eq(reality_stream.loop_end, pollution_stream.loop_end, "pollution should remain phase-aligned with the base score")
			_assert_true(phone_stream.loop_end == 2_116_800, "the original score should render an exact 96-second loop")
		_assert_true(absf(phone.get_playback_position() - reality.get_playback_position()) < 0.05, "phone and reality score stems should begin in sync")
		_assert_true(absf(reality.get_playback_position() - pollution_music.get_playback_position()) < 0.05, "pollution score stem should begin in sync with reality")

	game_root.game.pollution = 50
	game_root._sync_audio_state(true)
	if pollution_music != null:
		_assert_near(pollution_music.volume_db, game_root._pollution_music_target(50), 0.1, "mid pollution should fade the corruption score into the mix")
	_assert_near(game_root._pollution_music_target(60), -24.0, 0.1, "the 60 percent threshold should expose the pollution stem")
	_assert_near(game_root._pollution_music_target(100), -3.0, 0.1, "maximum pollution should bring the corruption stem near the foreground")
	game_root.game.pollution = 0
	game_root._sync_audio_state(true)

	game_root.set_view_state("npc_up")
	await create_timer(0.65).timeout
	if phone != null and reality != null:
		_assert_true(reality.volume_db > phone.volume_db, "raising the camera should crossfade toward room ambience")
		_assert_near(reality.volume_db, -10.0, 0.2, "NPC speaking mix should reach its audible liminal-score target")

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
		_assert_near(reality.volume_db, -7.0, 0.2, "player composing should make the room score more intimate")

	game_root._play_pollution_flashback()
	await process_frame
	_assert_true(flashback != null and flashback.playing, "pollution flashback should play its signal burst")
	if phone != null and reality != null:
		_assert_true(bool(phone.get_meta("flashback_ducked", false)), "flashback should duck the phone layer")
		_assert_true(bool(reality.get_meta("flashback_ducked", false)), "flashback should duck the reality layer")
	if pollution_music != null:
		_assert_true(bool(pollution_music.get_meta("flashback_ducked", false)), "flashback should duck the pollution music layer")
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


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, expected, actual])
