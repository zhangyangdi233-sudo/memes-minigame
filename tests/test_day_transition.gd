extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_async")


func _run_async() -> void:
	await _run()
	if _failures.is_empty():
		print("day transition tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "day transition test should load the main scene")
	if scene == null:
		return
	var game_root := scene.instantiate()
	root.add_child(game_root)
	game_root.new_game()
	await process_frame

	var day_overlay := _find_node_by_name(game_root, "DayTransitionOverlay") as Control
	var day_label := _find_node_by_name(game_root, "DayTransitionDayLabel") as Label
	var action_overlay := _find_node_by_name(game_root, "ActionSpendOverlay") as Control
	var flashback_overlay := _find_node_by_name(game_root, "PollutionFlashbackOverlay") as Control
	_assert_true(day_overlay != null and day_label != null, "scene should expose a dedicated next-day overlay")
	if day_overlay != null:
		var duration := float(day_overlay.get_meta("duration_seconds", 0.0))
		_assert_true(duration >= 3.0 and duration <= 5.0, "next-day overlay should last between three and five seconds")
		_assert_true(not day_overlay.visible, "next-day overlay should start hidden")
	if day_overlay != null and action_overlay != null and flashback_overlay != null:
		_assert_true(day_overlay.z_index > action_overlay.z_index, "next-day overlay should cover the action pulse")
		_assert_true(day_overlay.z_index < flashback_overlay.z_index, "pollution flashback should retain highest visual priority")

	game_root.game.actions_remaining = 1
	_assert_true(game_root.game.spend_action("transition-test"), "last daily action should be spendable")
	game_root._play_action_spend_animation(1, 0)
	game_root._finish_action_spend_animation()
	_assert_true(day_overlay != null and day_overlay.visible, "last action should start the next-day overlay after its inline pulse")
	_assert_true(game_root._input_locked, "next-day overlay should lock gameplay input")
	_assert_eq(game_root.game.day, 1, "day settlement should wait until the transition reaches its midpoint")
	_assert_true(day_label != null and str(day_label.text).contains("01"), "transition should begin on the departing day")
	game_root._commit_day_transition_settlement()
	_assert_eq(game_root.game.day, 2, "transition midpoint should commit the next day")
	_assert_eq(game_root.game.actions_remaining, 5, "committed next day should restore all five actions")
	_assert_true(day_label != null and str(day_label.text).contains("02"), "transition should reveal the newly acquired day")
	game_root._finish_day_transition()
	_assert_true(day_overlay != null and not day_overlay.visible, "finished next-day transition should hide its overlay")
	_assert_true(not game_root._input_locked, "finished next-day transition should restore input")

	game_root.new_game()
	await process_frame
	var meme_bank := _find_node_by_name(game_root, "MemeBankPopup") as Control
	var meme_bank_content := _find_node_by_name(game_root, "MemeBankContent") as Control
	_assert_true(meme_bank != null and not meme_bank.visible, "meme bank should be hidden on the normal social feed")
	_assert_true(not game_root._should_peek_meme_bank(), "meme bank should no longer expose a global corner peek")
	game_root._social_screen = "publish"
	game_root._open_app_windows["social"] = true
	game_root._render()
	_assert_true(meme_bank != null and meme_bank.visible, "meme bank should appear as a small attached window only on social publish")
	var actions_before_bank_motion: int = game_root.game.actions_remaining
	var opening_profile: Dictionary = game_root._meme_bank_motion_profile(true)
	var closing_profile: Dictionary = game_root._meme_bank_motion_profile(false)
	_assert_eq(opening_profile.get("transition"), Tween.TRANS_QUINT, "meme bank opening should use a quint transition")
	_assert_eq(opening_profile.get("ease"), Tween.EASE_OUT, "meme bank opening should ease out")
	_assert_eq(closing_profile.get("transition"), Tween.TRANS_QUINT, "meme bank closing should use a quint transition")
	_assert_eq(closing_profile.get("ease"), Tween.EASE_OUT, "meme bank closing should ease out")
	_assert_true(float(opening_profile.get("scale_duration", 0.0)) > 0.0, "meme bank scale motion should have a visible duration")
	_assert_true(float(opening_profile.get("alpha_duration", 0.0)) > 0.0, "meme bank alpha motion should have a visible duration")
	_assert_true(Array(opening_profile.get("properties", [])).has("scale"), "meme bank motion should animate scale")
	_assert_true(Array(opening_profile.get("properties", [])).has("modulate:a"), "meme bank motion should animate alpha")
	_assert_true(bool(opening_profile.get("interrupts_previous", false)), "meme bank motion should interrupt stale tweens")
	game_root._toggle_meme_bank()
	_assert_true(meme_bank_content != null and meme_bank_content.visible, "publish-only meme bank should still expand on demand")
	_assert_eq(str(meme_bank.get_meta("motion_easing", "")), "easeOutQuint", "meme bank open and close motion should use easeOutQuint")
	_assert_eq(str(meme_bank.get_meta("motion_phase", "")), "opening", "opening motion should expose its phase for regression checks")
	_assert_eq(meme_bank.get_meta("motion_transition"), Tween.TRANS_QUINT, "opening window tween should expose quint transition metadata")
	_assert_eq(meme_bank.get_meta("motion_ease"), Tween.EASE_OUT, "opening window tween should expose ease-out metadata")
	var opening_tween: Tween = game_root._meme_bank_tween
	game_root._toggle_meme_bank()
	_assert_eq(str(meme_bank.get_meta("motion_phase", "")), "closing", "closing motion should use the same explicit profile")
	_assert_true(opening_tween != null and not opening_tween.is_valid(), "closing the bank should cancel an unfinished opening tween")
	_assert_true(game_root._meme_bank_tween != opening_tween, "closing the bank should create a fresh tween")
	_assert_eq(game_root.game.actions_remaining, actions_before_bank_motion, "opening and closing the meme bank should not spend an action")
	game_root._toggle_meme_bank()
	await create_timer(float(opening_profile.get("scale_duration", 0.28)) + 0.08).timeout
	_assert_eq(str(meme_bank.get_meta("motion_phase", "")), "open", "a completed opening tween should expose its settled phase")
	_assert_true(meme_bank.scale.is_equal_approx(Vector2.ONE), "a completed meme-bank tween should settle at its exact authored scale")
	_assert_true(is_equal_approx(meme_bank.modulate.a, 1.0), "a completed meme-bank tween should settle at full authored alpha")
	game_root.game.set_active_app("notebook")
	game_root._open_app_windows["social"] = false
	game_root._render()
	_assert_true(meme_bank != null and meme_bank.visible, "switching to notebook should keep the contextual radial meme bank available")
	_assert_true(meme_bank_content != null and meme_bank_content.visible, "notebook should open the radial meme bank for frame and fusion work")
	game_root.set_view_state("npc_up")
	_assert_true(meme_bank != null and not meme_bank.visible, "reality walking should never show the meme bank")

	game_root.new_game()
	await process_frame
	game_root.game.pollution = 60
	game_root.game.check_pollution_flashback(59)
	game_root._play_pollution_flashback()
	game_root._finish_pollution_flashback()
	day_overlay = _find_node_by_name(game_root, "DayTransitionOverlay") as Control
	_assert_eq(game_root.game.day, 2, "pollution flashback should still settle directly into the next day")
	_assert_true(day_overlay != null and not day_overlay.visible, "pollution flashback should not stack the normal three-second day overlay")

	game_root.queue_free()
	await process_frame


func _find_node_by_name(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
