extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	_run()
	if _failures.is_empty():
		print("main scene tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should exist")
	if scene == null:
		return
	var root := scene.instantiate()
	_assert_true(root is Node3D, "main scene root should be a Node3D")
	_assert_true(root.has_method("new_game"), "main scene script should expose new_game")
	if root.has_method("new_game"):
		root.new_game()
		_assert_true(root.get_node_or_null("Camera3D") is Camera3D, "main scene should contain a Camera3D")
		_assert_true(root.get_node_or_null("CanvasLayer") is CanvasLayer, "main scene should contain a CanvasLayer")
		_assert_true(root.get_node_or_null("Road") is Node3D, "main scene should contain scrolling road node")
		_assert_true(root.get_node_or_null("PhoneRig") is Node3D, "main scene should contain phone rig")
		_assert_true(root.get_node_or_null("NPC") is Node3D, "main scene should contain NPC node")
		_assert_true(root.has_method("_active_palette"), "main scene should expose active palette lookup")
		_assert_true(root.has_method("_theme_color"), "main scene should expose semantic theme colors")
		_assert_true(root.has_method("_play_pollution_flashback"), "main scene should expose pollution flashback playback")
		_assert_true(root.has_method("_finish_pollution_flashback"), "main scene should expose pollution flashback completion")
		_assert_true(root.has_method("begin_reality_player_turn"), "main scene should expose player turn transition")
		_assert_true(root.has_method("_toggle_meme_bank"), "main scene should expose meme bank drawer toggle")
		_assert_true(root.has_method("_move_window_for_test"), "main scene should expose test window movement helper")
		_assert_true(root.has_method("set_view_state"), "main scene should expose set_view_state")
		var phone_tab := root.get_node_or_null("CanvasLayer/UIRoot/PhoneTab") as Button
		var phone_edge := root.get_node_or_null("CanvasLayer/UIRoot/PhoneEdge") as PanelContainer
		var app_window := root.get_node_or_null("CanvasLayer/UIRoot/FloatingAppWindow") as PanelContainer
		var flashback_overlay := root.get_node_or_null("CanvasLayer/UIRoot/PollutionFlashbackOverlay") as Control
		var npc_bubble := root.get_node_or_null("CanvasLayer/UIRoot/NPCChatBubble") as PanelContainer
		var dim_overlay := root.get_node_or_null("CanvasLayer/UIRoot/RealityDimOverlay") as ColorRect
		var player_portrait := root.get_node_or_null("CanvasLayer/UIRoot/PlayerPortrait") as Control
		var thought_layer := root.get_node_or_null("CanvasLayer/UIRoot/ThoughtWordLayer") as Control
		var puzzle_frame := root.get_node_or_null("CanvasLayer/UIRoot/LanguagePuzzleFrame") as PanelContainer
		var meme_bank_tab := root.get_node_or_null("CanvasLayer/UIRoot/MemeBankTab") as Button
		var meme_bank_window := root.get_node_or_null("CanvasLayer/UIRoot/MemeBankWindow") as PanelContainer
		_assert_true(phone_tab != null, "scene should expose a side phone tab")
		_assert_true(phone_edge != null, "scene should expose the phone edge panel")
		_assert_true(app_window != null, "scene should expose the floating app window")
		_assert_true(flashback_overlay != null, "scene should expose a full-screen pollution flashback overlay")
		_assert_true(npc_bubble != null, "scene should expose the NPC chat bubble")
		_assert_true(dim_overlay != null, "scene should expose the reality dim overlay")
		_assert_true(player_portrait != null, "scene should expose the player portrait")
		_assert_true(thought_layer != null, "scene should expose the thought word layer")
		_assert_true(puzzle_frame != null, "scene should expose the Florence-style language puzzle frame")
		_assert_true(meme_bank_tab != null, "scene should expose the meme bank drawer tab")
		_assert_true(meme_bank_window != null, "scene should expose the meme bank drawer window")
		if phone_tab != null and phone_edge != null and app_window != null:
			_assert_true(not phone_tab.visible, "phone tab should be hidden while looking down at the phone")
			_assert_true(phone_edge.visible, "phone panel should be visible while looking down at the phone")
			_assert_true((app_window.offset_right - app_window.offset_left) >= 420.0, "floating app window should be large beside the phone")
		if root.has_method("_active_palette"):
			root.game.pollution = 59
			_assert_eq(root._active_palette().get("name", ""), "palette_1", "pollution below 60 should use Palette 1")
			root.game.pollution = 60
			_assert_eq(root._active_palette().get("name", ""), "pollution_palette_5", "pollution at 60 should use Pollution Palette 5")
		if flashback_overlay != null and root.has_method("_play_pollution_flashback") and root.has_method("_finish_pollution_flashback"):
			_assert_true(not flashback_overlay.visible, "flashback overlay should start hidden")
			root._play_pollution_flashback()
			_assert_true(flashback_overlay.visible, "playing flashback should show the overlay")
			root._finish_pollution_flashback()
			_assert_true(not flashback_overlay.visible, "finishing flashback should hide the overlay")
			root.game.pollution = 60
			root.game.check_pollution_flashback(59)
			root._play_pollution_flashback()
			root._finish_pollution_flashback()
			_assert_eq(root.game.day, 2, "finishing a pending flashback should advance to the next day")
			_assert_eq(root.game.actions_remaining, 5, "flashback settlement should restore next-day actions")
			_assert_true(not flashback_overlay.visible, "flashback overlay should hide after automatic settlement")
		root.game.notebook_tokens = [{"id": "n1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1}]
		root.game.completed_memes = [{"id": "m1", "title": "表达 #1", "text": "哈吉米，到底是什么意思？", "tags": ["哈吉米"], "rarity": 1}]
		root.game.set_active_app("notebook")
		root._render()
		if meme_bank_tab != null and meme_bank_window != null:
			_assert_true(meme_bank_tab.visible, "phone view should show meme bank drawer tab")
			_assert_true(not meme_bank_window.visible, "meme bank window should start collapsed")
			root._toggle_meme_bank()
			_assert_true(meme_bank_window.visible, "toggling meme bank should open the drawer window")
			root._toggle_meme_bank()
			_assert_true(not meme_bank_window.visible, "toggling meme bank again should close the drawer window")
		if app_window != null and root.has_method("_move_window_for_test"):
			var before_pos := app_window.position
			root._move_window_for_test("app", Vector2(36, 28))
			root._render()
			var moved_pos := app_window.position
			_assert_true(moved_pos != before_pos, "dragged app window should move from its initial position")
			root._render()
			_assert_eq(app_window.position, moved_pos, "dragged app window position should survive render")
			_assert_eq(root.game.actions_remaining, 5, "moving a window should not spend an action")
		_assert_true(_has_node_with_method(root, "set_drag_payload"), "notebook and bank items should expose drag payloads")
		_assert_true(_has_node_with_method(root, "configure_drop_target"), "slots and dialogue blank should expose drop targets")
		root._on_slot_token_dropped({"kind": "token", "id": "n1"}, "object")
		_assert_eq(root.game.draft_slots.get("object", ""), "n1", "dropping token should place it in a craft slot")
		_assert_eq(root.game.actions_remaining, 5, "dropping token should not spend an action")
		root._on_dialogue_meme_dropped({"kind": "meme", "id": "m1"}, "blank_1")
		_assert_eq(root.game.dialogue_blanks.get("blank_1", ""), "m1", "dropping meme should place it in dialogue blank")
		_assert_eq(root.game.actions_remaining, 5, "dropping meme should not spend an action")
		root.set_view_state("npc_up")
		_assert_eq(root.game.view_state, "npc_up", "scene should switch to NPC view")
		_assert_true(root.game.active_app_window.is_empty(), "NPC view should hide active app window")
		if phone_tab != null and phone_edge != null:
			_assert_true(phone_tab.visible, "phone tab should be visible after putting the phone away")
			_assert_true(not phone_edge.visible, "phone panel should hide after putting the phone away")
		if npc_bubble != null and dim_overlay != null and player_portrait != null and thought_layer != null and puzzle_frame != null:
			_assert_true(npc_bubble.visible, "NPC view should first show the right-side NPC chat bubble")
			_assert_true(not dim_overlay.visible, "NPC speaking phase should not dim the background yet")
			_assert_true(not player_portrait.visible, "NPC speaking phase should hide player portrait")
			_assert_true(not thought_layer.visible, "NPC speaking phase should hide thought words")
			_assert_true(not puzzle_frame.visible, "NPC speaking phase should hide the language puzzle frame")
		if meme_bank_tab != null and meme_bank_window != null:
			_assert_true(not meme_bank_tab.visible, "NPC view should hide meme bank tab")
			_assert_true(not meme_bank_window.visible, "NPC view should hide meme bank window")
		root.game.legacy_rules = [{
			"id": "legacy-1",
			"floor": 1,
			"source_meme_id": "m1",
			"required_text": "哈吉米，必须补票",
			"tags": ["哈吉米"],
			"created_day": 2,
			"strength": 1,
		}]
		root._render()
		if root.has_method("begin_reality_player_turn") and dim_overlay != null and player_portrait != null and thought_layer != null and puzzle_frame != null:
			root.begin_reality_player_turn()
			_assert_true(dim_overlay.visible, "player composing phase should dim the background")
			_assert_true(player_portrait.visible, "player composing phase should show the player portrait")
			_assert_true(thought_layer.visible, "player composing phase should show thought words")
			_assert_true(puzzle_frame.visible, "player composing phase should show the language puzzle frame")
			_assert_true(npc_bubble.visible, "NPC bubble should remain visible above the dimmed background")
		_assert_true(_has_text(root, "语言组成框"), "player composing phase should show the language puzzle label")
		_assert_true(_has_text(root, "哈吉米，必须补票"), "language puzzle should show required legacy tile")
	root.queue_free()


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s. Expected %s, got %s" % [message, str(expected), str(actual)])


func _has_node_with_method(node: Node, method_name: String) -> bool:
	if node.has_method(method_name):
		return true
	for child in node.get_children():
		if _has_node_with_method(child, method_name):
			return true
	return false


func _has_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text).contains(text):
		return true
	if node is Button and str((node as Button).text).contains(text):
		return true
	if node is LineEdit and str((node as LineEdit).text).contains(text):
		return true
	for child in node.get_children():
		if _has_text(child, text):
			return true
	return false
