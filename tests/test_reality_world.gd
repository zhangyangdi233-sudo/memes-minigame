extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_async")


func _run_async() -> void:
	await _run()
	if _failures.is_empty():
		print("reality world tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "reality world test should load the main scene")
	if scene == null:
		return
	var game_root := scene.instantiate()
	root.add_child(game_root)
	game_root.new_game()
	await process_frame

	var player := game_root.get_node_or_null("RealityPlayer") as CharacterBody3D
	var floor_root := game_root.get_node_or_null("RealityFloor") as Node3D
	var camera := game_root.get_node_or_null("Camera3D") as Camera3D
	var top_bar := _find_node_by_name(game_root, "CinematicTopBar") as ColorRect
	var bottom_bar := _find_node_by_name(game_root, "CinematicBottomBar") as ColorRect
	var social_window := _find_node_by_name(game_root, "SocialAppWindow") as PanelContainer
	_assert_true(player != null, "reality view should expose a CharacterBody3D player")
	_assert_true(floor_root != null, "reality view should expose a generated floor root")
	_assert_true(camera != null, "reality view should retain the shared 3D camera")
	_assert_true(top_bar != null and bottom_bar != null, "gameplay should expose fixed cinematic bars")
	if top_bar != null and bottom_bar != null:
		_assert_true(top_bar.visible and bottom_bar.visible, "cinematic bars should stay visible during gameplay")
		_assert_true(top_bar.size.y > 24.0 and bottom_bar.size.y > 24.0, "cinematic bars should create a real movie-aspect frame")
		_assert_eq(float(top_bar.get_meta("target_aspect_ratio", 0.0)), 2.35, "cinematic bars should target the selected 2.35 aspect ratio")
	if social_window != null and top_bar != null:
		_assert_true(social_window.z_index > top_bar.z_index, "phone app windows should render above the cinematic bars")

	_assert_eq(game_root._room_count_for_floor(1), 4, "floor one should begin with four rooms")
	_assert_eq(game_root._room_count_for_floor(2), 6, "floor two should add two rooms")
	_assert_eq(game_root._room_count_for_floor(3), 9, "floor three should add three rooms")
	for floor_number in range(2, 6):
		var growth: int = game_root._room_count_for_floor(floor_number) - game_root._room_count_for_floor(floor_number - 1)
		_assert_true(growth == 2 or growth == 3, "each ascent should add two or three rooms")
	_assert_eq(int(floor_root.get_meta("room_count", 0)), 4, "generated first floor should match the room formula")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 5, "first floor should contain five ordinary NPCs")
	_assert_true(int(floor_root.get_meta("useful_item_count", 0)) > 0, "some first-floor rooms should contain useful items")
	_assert_true(int(floor_root.get_meta("useful_item_count", 0)) < int(floor_root.get_meta("room_count", 0)), "some rooms should remain empty")

	var merchant := _find_actor(floor_root, "merchant")
	var ordinary_npcs := _count_actors(floor_root, "npc")
	_assert_true(merchant != null, "every floor should contain exactly one merchant actor")
	_assert_eq(ordinary_npcs, 5, "first floor should place all five ordinary NPC billboards")
	if merchant != null:
		var merchant_billboard := merchant.get_node_or_null("Billboard") as Sprite3D
		_assert_true(merchant_billboard != null and merchant_billboard.texture != null, "merchant should use generated 2D character artwork")
		if merchant_billboard != null:
			_assert_eq(merchant_billboard.billboard, BaseMaterial3D.BILLBOARD_ENABLED, "2D actors should always face the camera")

	for action_name in ["reality_forward", "reality_back", "reality_left", "reality_right", "reality_interact"]:
		_assert_true(InputMap.has_action(action_name), "reality movement should register input action %s" % action_name)
	_assert_true(_action_has_key("reality_forward", KEY_W) and _action_has_key("reality_forward", KEY_UP), "forward movement should accept W and Up")
	_assert_true(_action_has_key("reality_back", KEY_S) and _action_has_key("reality_back", KEY_DOWN), "back movement should accept S and Down")
	_assert_true(_action_has_key("reality_left", KEY_A) and _action_has_key("reality_left", KEY_LEFT), "left movement should accept A and Left")
	_assert_true(_action_has_key("reality_right", KEY_D) and _action_has_key("reality_right", KEY_RIGHT), "right movement should accept D and Right")
	_assert_true(_action_has_key("reality_interact", KEY_F), "world interaction should use F")

	game_root.set_view_state("npc_up")
	if player != null:
		var walk_start := player.position
		Input.action_press("reality_forward")
		for frame in 18:
			await physics_frame
		Input.action_release("reality_forward")
		_assert_true(player.position.z < walk_start.z - 0.25, "holding W should move the first-person body forward through the floor")
	if player != null and merchant != null:
		player.position = merchant.position + Vector3(0.0, 0.0, 1.4)
		game_root._refresh_nearby_reality_actor()
		_assert_true(game_root._nearby_reality_actor == merchant, "approaching a merchant should select it as the nearby actor")
		_assert_true(game_root._try_reality_interaction(), "F interaction path should open the nearby actor")
		_assert_true(game_root._reality_interaction_active, "world interaction should enter the dialogue state")
		_assert_true(game_root._active_reality_actor == merchant, "world interaction should remember the selected actor")
		var choice_id := str(game_root.game.get_typed_reality_choices()[0].get("id", ""))
		game_root._on_reality_choice_selected(choice_id)
		var arbitrary_key := InputEventKey.new()
		arbitrary_key.keycode = KEY_SPACE
		arbitrary_key.pressed = true
		game_root._unhandled_input(arbitrary_key)
		_assert_eq(game_root.game.conversation_reveal_index, 1, "an arbitrary physical key should reveal exactly one spoken character")
		_assert_eq(game_root.game.actions_remaining, 5, "partial typed speech should remain action-free")
		game_root._exit_reality_interaction()
		_assert_true(not game_root._reality_interaction_active, "leaving dialogue should return to free walking")

	game_root.game.tower_floor = 5
	game_root._ensure_reality_floor_current()
	floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
	_assert_eq(int(floor_root.get_meta("room_count", 0)), 14, "fifth floor should grow to fourteen rooms")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 2, "higher floors should thin ordinary NPCs to two")
	_assert_eq(_count_actors(floor_root, "npc"), 2, "fifth-floor actor population should match its metadata")
	_assert_true(_find_actor(floor_root, "merchant") != null, "merchant should persist on the highest floor")

	game_root.queue_free()
	await process_frame


func _action_has_key(action_name: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and (event.physical_keycode == keycode or event.keycode == keycode):
			return true
	return false


func _find_actor(node: Node, actor_type: String) -> Area3D:
	if node is Area3D and str(node.get_meta("actor_type", "")) == actor_type:
		return node as Area3D
	for child in node.get_children():
		var found := _find_actor(child, actor_type)
		if found != null:
			return found
	return null


func _count_actors(node: Node, actor_type: String) -> int:
	var count := 1 if node is Area3D and str(node.get_meta("actor_type", "")) == actor_type else 0
	for child in node.get_children():
		count += _count_actors(child, actor_type)
	return count


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
