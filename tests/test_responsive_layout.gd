extends SceneTree

const SMALL_VIEW_SIZE := Vector2i(640, 720)

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_async")


func _run_async() -> void:
	await _run()
	if _failures.is_empty():
		print("responsive layout tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	root.size = SMALL_VIEW_SIZE
	root.content_scale_size = SMALL_VIEW_SIZE
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should load for responsive layout test")
	if scene == null:
		return
	var game_root := scene.instantiate()
	root.add_child(game_root)
	if game_root.has_method("new_game"):
		game_root.new_game()
	await process_frame
	await process_frame

	var viewport_rect := Rect2(Vector2.ZERO, root.get_visible_rect().size)
	_assert_true(viewport_rect.size == Vector2(SMALL_VIEW_SIZE), "responsive test should run at the requested small viewport size")
	var hud := _find_node_by_name(game_root, "InternationalHUDRail") as PanelContainer
	var social_window := _find_node_by_name(game_root, "SocialAppWindow") as PanelContainer
	var social_bottom_nav := _find_node_by_name(game_root, "SocialBottomNav") as HBoxContainer
	var social_inline_close := _find_node_by_name(game_root, "SocialAppInlineCloseButton") as Button
	var view_toggle := _find_node_by_name(game_root, "PhoneViewToggleButton") as Button
	var meme_bank := _find_node_by_name(game_root, "MemeBankPopup") as PanelContainer
	var actions_label := _find_node_by_name(game_root, "HUDActionsLabel") as Label
	_assert_true(hud != null, "small view should keep the left HUD rail")
	_assert_true(social_window != null and social_window.visible, "small view should open the social phone")
	if hud != null and social_window != null:
		_assert_true(_inside_rect(social_window, viewport_rect), "small-view social phone should stay inside the viewport")
		_assert_true(social_window.get_global_rect().position.x >= hud.get_global_rect().end.x + 8.0, "small-view social phone should not cover the HUD rail")
	if social_bottom_nav != null:
		_assert_true(_inside_rect(social_bottom_nav, viewport_rect), "small-view social bottom nav should stay reachable")
	if social_inline_close != null:
		_assert_true(_inside_rect(social_inline_close, viewport_rect), "small-view social close button should stay reachable")
		_assert_true(social_inline_close.custom_minimum_size.x >= 44.0, "small-view social close target should meet mobile touch guidance")
	if view_toggle != null:
		_assert_true(_inside_rect(view_toggle, viewport_rect), "small-view put-phone button should stay reachable")
	if meme_bank != null and actions_label != null:
		_assert_true(not meme_bank.get_global_rect().intersects(actions_label.get_global_rect()), "small-view meme bank corner should not cover today's actions")
	if game_root.has_method("_open_social_post"):
		game_root._open_social_post(0)
		await process_frame
		var detail_window := _find_node_by_name(game_root, "SocialDetailWindow") as PanelContainer
		var detail_close := _find_node_by_name(game_root, "SocialDetailWindowCloseButton") as Button
		_assert_true(detail_window != null and detail_window.visible, "small view should open the independent post detail companion")
		if detail_window != null:
			_assert_true(_inside_rect(detail_window, viewport_rect), "small-view detail companion should stay inside the viewport")
		if detail_close != null:
			detail_close.pressed.emit()
			_assert_true(detail_window != null and not detail_window.visible, "small-view detail close should return focus to the phone feed")
		social_inline_close = _find_node_by_name(game_root, "SocialAppInlineCloseButton") as Button

	if social_inline_close != null:
		social_inline_close.pressed.emit()
	await process_frame
	var phone_home := _find_node_by_name(game_root, "PhonePopup") as PanelContainer
	var phone_content := _find_node_by_name(game_root, "PhoneContent") as Control
	var phone_social_icon := _find_node_by_name(game_root, "PhoneAppIconSocial") as Button
	_assert_true(phone_home != null and phone_home.visible, "closing social on small view should reveal the phone home")
	if phone_home != null:
		_assert_true(_inside_rect(phone_home, viewport_rect), "small-view phone home should stay inside the viewport")
		if hud != null:
			_assert_true(phone_home.get_global_rect().position.x >= hud.get_global_rect().end.x + 8.0, "small-view phone home should not cover the HUD rail")
	_assert_true(phone_content != null and phone_content.visible, "small-view phone home should expose app icons")
	if phone_social_icon != null:
		_assert_true(_inside_rect(phone_social_icon, viewport_rect), "small-view phone app icons should stay reachable")
	if game_root.has_method("set_view_state"):
		game_root.set_view_state("npc_up")
	await process_frame
	var npc_bubble := _find_node_by_name(game_root, "NPCChatBubble") as PanelContainer
	var phone_tab := _find_node_by_name(game_root, "PhoneTab") as Button
	_assert_true(npc_bubble != null and not npc_bubble.visible, "small-view walking mode should wait for an F interaction before showing dialogue")
	var reality_player := _find_node_by_name(game_root, "RealityPlayer") as CharacterBody3D
	var reality_merchant := _find_node_by_name(game_root, "Merchant") as Area3D
	if reality_player != null and reality_merchant != null:
		reality_player.position = reality_merchant.position + Vector3(0.0, 0.0, 1.4)
		game_root._refresh_nearby_reality_actor()
		game_root._try_reality_interaction()
	await process_frame
	_assert_true(npc_bubble != null and npc_bubble.visible, "small-view F interaction should show the NPC chat bubble")
	if npc_bubble != null:
		_assert_true(_inside_rect(npc_bubble, viewport_rect), "small-view NPC chat bubble should stay inside the viewport")
	if game_root.has_method("begin_reality_player_turn"):
		game_root.begin_reality_player_turn()
	await process_frame
	var dim_overlay := _find_node_by_name(game_root, "RealityDimOverlay") as ColorRect
	var npc_focus := _find_node_by_name(game_root, "NPCFocusImage") as TextureRect
	var player_portrait := _find_node_by_name(game_root, "PlayerPortrait") as Control
	var thought_layer := _find_node_by_name(game_root, "ThoughtWordLayer") as Control
	var puzzle_frame := _find_node_by_name(game_root, "LanguagePuzzleFrame") as PanelContainer
	_assert_true(dim_overlay != null and dim_overlay.visible, "small-view player turn should show the dim overlay")
	_assert_true(npc_focus != null and npc_focus.visible, "small-view player turn should keep the generated NPC portrait visible")
	_assert_true(player_portrait != null and player_portrait.visible, "small-view player turn should show the player portrait")
	_assert_true(thought_layer != null and thought_layer.visible, "small-view player turn should show thought words")
	_assert_true(puzzle_frame != null and puzzle_frame.visible, "small-view player turn should show the language puzzle")
	for control in [npc_focus, player_portrait, thought_layer, puzzle_frame, phone_tab]:
		if control != null and control.visible:
			_assert_true(_inside_rect(control, viewport_rect), "small-view reality control should stay inside the viewport: %s" % control.name)
	if hud != null and player_portrait != null:
		_assert_true(player_portrait.get_global_rect().position.x >= hud.get_global_rect().end.x + 8.0, "small-view player portrait should not cover the HUD rail")
	if player_portrait != null and puzzle_frame != null:
		_assert_true(not player_portrait.get_global_rect().intersects(puzzle_frame.get_global_rect()), "small-view player portrait should not overlap the language puzzle")
	if player_portrait != null and thought_layer != null:
		_assert_true(not player_portrait.get_global_rect().intersects(thought_layer.get_global_rect()), "small-view player portrait should not overlap thought words")
	game_root.queue_free()


func _inside_rect(control: Control, viewport_rect: Rect2) -> bool:
	if control == null or not control.visible:
		return false
	var rect := control.get_global_rect()
	return rect.position.x >= viewport_rect.position.x and rect.position.y >= viewport_rect.position.y and rect.end.x <= viewport_rect.end.x and rect.end.y <= viewport_rect.end.y


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
