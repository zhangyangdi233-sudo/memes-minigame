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
		_assert_true(not top_bar.visible and not bottom_bar.visible, "phone view should not be squeezed by the reality-only cinematic bars")
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
	_assert_eq(str(floor_root.get_meta("district_style", "")), "sunlit_brick_street", "first floor should use the sunlit brick-road reference grammar")
	_assert_true(_find_node_by_name(floor_root, "BrickWall") != null and _find_node_by_name(floor_root, "Crosswalk00") != null, "sunlit district should include tall brick walls and a zebra crossing")
	var first_brick_wall := _find_node_by_name(floor_root, "BrickWall") as Node3D
	if first_brick_wall != null:
		_assert_true(absf(first_brick_wall.position.x) >= 9.5 and absf(first_brick_wall.position.x) <= 10.8, "sunlit brick walls should form the reference's narrow road canyon instead of sitting at the map perimeter")
	var first_reference_portal := _find_node_by_name(floor_root, "ReferencePortal") as MeshInstance3D
	_assert_true(first_reference_portal != null and str(first_reference_portal.get_meta("reference_texture", "")).contains("sunlit_brick_street"), "sunlit district should extend its geometry with the supplied reference image")
	if first_reference_portal != null and first_reference_portal.mesh is QuadMesh:
		_assert_true((first_reference_portal.mesh as QuadMesh).size.x >= 12.0, "sunlit reference continuation should fill the road horizon rather than appear as a small poster")
	_assert_true(int(floor_root.get_meta("useful_item_count", 0)) > 0, "some first-floor rooms should contain useful items")
	_assert_true(int(floor_root.get_meta("useful_item_count", 0)) < int(floor_root.get_meta("room_count", 0)), "some rooms should remain empty")
	var useful_item := _find_useful_item(floor_root)
	_assert_true(useful_item != null, "a useful street lot should expose a real pickup Area3D")
	if useful_item != null:
		_assert_true(not str(useful_item.get_meta("item_effect", "")).is_empty(), "world pickup should carry a gameplay effect")
		_assert_true(not str(useful_item.get_meta("item_description", "")).is_empty(), "world pickup should explain its effect in the F prompt")
	_assert_eq(str(floor_root.get_meta("layout_mode", "")), "shared_street", "reality floor should be one shared open street instead of isolated NPC boxes")
	var map_width := float(floor_root.get_meta("map_width", 0.0))
	var map_length := float(floor_root.get_meta("map_length", 0.0))
	_assert_true(map_width >= 32.0 and map_length >= 42.0, "first floor should provide a genuinely broad continuous street")
	var street_ground := _find_node_by_name(floor_root, "StreetGround") as StaticBody3D
	_assert_true(street_ground != null, "shared street should use one continuous collision ground")
	_assert_eq(int(floor_root.get_meta("air_wall_count", 0)), 4, "the map perimeter should expose four air walls")
	var air_walls := _find_node_by_name(floor_root, "AirWalls") as Node3D
	_assert_true(air_walls != null and air_walls.get_child_count() == 4, "air-wall container should surround every map edge")
	if air_walls != null:
		for wall in air_walls.get_children():
			_assert_true(wall is StaticBody3D and bool(wall.get_meta("air_wall", false)), "each perimeter edge should be an invisible static air wall")
	if player != null:
		var half_width := map_width * 0.5
		var half_length := map_length * 0.5
		_assert_true(absf(player.position.x) <= half_width - 5.0, "player spawn should have generous horizontal clearance")
		_assert_true(absf(player.position.z) <= half_length - 5.0, "player spawn should have generous longitudinal clearance")

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
	if top_bar != null and bottom_bar != null:
		_assert_true(top_bar.visible and bottom_bar.visible, "putting the phone down should restore both cinematic bars")
		_assert_true(top_bar.size.y > 24.0 and bottom_bar.size.y > 24.0, "reality walking should retain a visible movie frame")
		_assert_true(top_bar.size.y <= game_root.get_viewport().get_visible_rect().size.y * 0.121, "responsive cinematic bars should never consume more than twelve percent per edge")
	_assert_true(bool(game_root._reality_mouse_look_enabled), "putting the phone down should immediately enable free mouse look")
	var yaw_before_mouse := float(game_root._reality_yaw)
	var mouse_turn := InputEventMouseMotion.new()
	mouse_turn.relative = Vector2(96.0, 0.0)
	game_root._unhandled_input(mouse_turn)
	_assert_true(not is_equal_approx(float(game_root._reality_yaw), yaw_before_mouse), "horizontal mouse movement should rotate the first-person view")
	var yaw_before_touch := float(game_root._reality_yaw)
	var pitch_before_touch := float(game_root._reality_pitch)
	var actions_before_touch := int(game_root.game.actions_remaining)
	var touch_turn := InputEventScreenDrag.new()
	touch_turn.relative = Vector2(-72.0, 38.0)
	game_root._unhandled_input(touch_turn)
	_assert_true(not is_equal_approx(float(game_root._reality_yaw), yaw_before_touch), "horizontal touchscreen drag should rotate the first-person view")
	_assert_true(not is_equal_approx(float(game_root._reality_pitch), pitch_before_touch), "vertical touchscreen drag should tilt the first-person view")
	_assert_eq(game_root.game.actions_remaining, actions_before_touch, "touchscreen free look should not spend an action")
	game_root.set_view_state("phone_down")
	var yaw_while_phone_is_up := float(game_root._reality_yaw)
	game_root._unhandled_input(touch_turn)
	_assert_true(is_equal_approx(float(game_root._reality_yaw), yaw_while_phone_is_up), "touchscreen drag should not turn the world while the phone interface is active")
	game_root.set_view_state("npc_up")
	game_root._reality_yaw = 0.0
	game_root._reality_pitch = 0.0
	if player != null:
		var walk_start := player.position
		Input.action_press("reality_forward")
		for frame in 18:
			await physics_frame
		Input.action_release("reality_forward")
		_assert_true(player.position.z < walk_start.z - 0.25, "holding W should move the first-person body forward through the floor")
		game_root._reality_yaw = 0.0
		player.position = Vector3(0.0, 0.08, map_length * 0.5 - 1.2)
		player.velocity = Vector3.ZERO
		Input.action_press("reality_back")
		for frame in 72:
			await physics_frame
		Input.action_release("reality_back")
		_assert_true(player.position.z < map_length * 0.5, "the south air wall should physically stop sustained backward movement")
		_assert_true(player.position.y > -0.5, "walking against the map edge should keep the player on the continuous ground")
		player.position = Vector3(0.0, -8.0, 0.0)
		player.velocity = Vector3(0.0, -12.0, 0.0)
		game_root._update_reality_player(0.016)
		_assert_true(player.position.y >= 0.0, "falling below the street should recover the player onto a safe spawn")
	if player != null and useful_item != null:
		var item_id := str(useful_item.get_meta("item_id", ""))
		player.global_position = useful_item.global_position + Vector3(0.0, 0.0, 1.2)
		game_root._refresh_nearby_reality_actor()
		_assert_true(game_root._nearby_reality_item == useful_item, "approaching a street relic should select it ahead of distant actors")
		var actions_before_pickup := int(game_root.game.actions_remaining)
		_assert_true(game_root._try_reality_interaction(), "F should collect the nearby street relic")
		_assert_true(game_root.game.is_world_item_collected(item_id), "collected street relic should persist in run state")
		_assert_eq(game_root.game.actions_remaining, actions_before_pickup, "collecting a street relic should not spend an action")
		_assert_true(not useful_item.visible and bool(useful_item.get_meta("collected", false)), "collected street relic should disappear from the current floor")
		game_root._rebuild_reality_floor()
		floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
		var rebuilt_item := _find_item_by_id(floor_root, item_id)
		_assert_true(rebuilt_item != null and not rebuilt_item.visible, "rebuilding a floor should not respawn an already collected relic")
		merchant = _find_actor(floor_root, "merchant")
	if player != null and merchant != null:
		player.position = merchant.position + Vector3(0.0, 0.0, 1.4)
		game_root._refresh_nearby_reality_actor()
		_assert_true(game_root._nearby_reality_actor == merchant, "approaching a merchant should select it as the nearby actor")
		_assert_true(game_root._try_reality_interaction(), "F interaction path should open the nearby actor")
		_assert_true(game_root._reality_interaction_active, "world interaction should enter the dialogue state")
		_assert_true(game_root._active_reality_actor == merchant, "world interaction should remember the selected actor")
		var yaw_during_dialogue := float(game_root._reality_yaw)
		game_root._unhandled_input(touch_turn)
		_assert_true(is_equal_approx(float(game_root._reality_yaw), yaw_during_dialogue), "touchscreen drag should not turn the camera during a reality conversation")
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
	_assert_true(float(floor_root.get_meta("map_length", 0.0)) > map_length, "higher floors should lengthen the same shared street as lots are added")
	_assert_eq(str(floor_root.get_meta("layout_mode", "")), "shared_street", "higher floors should preserve the shared-street layout")
	_assert_eq(int(floor_root.get_meta("air_wall_count", 0)), 4, "expanded floors should rebuild their four perimeter air walls")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 2, "higher floors should thin ordinary NPCs to two")
	_assert_eq(_count_actors(floor_root, "npc"), 2, "fifth-floor actor population should match its metadata")
	_assert_true(_find_actor(floor_root, "merchant") != null, "merchant should persist on the highest floor")
	_assert_eq(str(floor_root.get_meta("district_style", "")), "night_white_blocks", "fifth floor should rotate back to the night white-block district")
	_assert_true(_find_node_by_name(floor_root, "WhiteHouse") != null and _find_node_by_name(floor_root, "WarmPool") != null, "night district should contain white cubic homes and warm streetlights")
	var night_house := _find_node_by_name(floor_root, "WhiteHouse") as Node3D
	if night_house != null:
		_assert_true(absf(night_house.position.x) <= 7.2, "night houses should crowd the path like the supplied reference instead of leaving a broad empty plaza")

	game_root.game.tower_floor = 3
	game_root._ensure_reality_floor_current()
	floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
	_assert_eq(str(floor_root.get_meta("district_style", "")), "overgrown_gallery", "third floor should use the overgrown white-gallery district")
	_assert_true(_find_node_by_name(floor_root, "GalleryRoof") != null and _find_node_by_name(floor_root, "GalleryCeilingSpan") != null and _find_node_by_name(floor_root, "GrassPatch00") != null, "overgrown district should combine a covered white colonnade with procedural grass")
	var grass_patch := _find_node_by_name(floor_root, "GrassPatch00") as Node3D
	if grass_patch != null:
		_assert_true(grass_patch.get_child_count() >= 30, "gallery grass should read as dense encroachment rather than sparse markers")
		var first_blade := grass_patch.get_child(0) as MeshInstance3D
		_assert_true(first_blade != null and first_blade.mesh is ArrayMesh, "gallery vegetation should use tapered grass blades rather than cone placeholders")
	var gallery_reference_portal := _find_node_by_name(floor_root, "ReferencePortal") as MeshInstance3D
	_assert_true(gallery_reference_portal != null and str(gallery_reference_portal.get_meta("reference_texture", "")).contains("overgrown_gallery"), "gallery district should use the supplied reference as a distant spatial continuation")

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


func _find_useful_item(node: Node) -> Area3D:
	if node is Area3D and bool(node.get_meta("useful_item", false)):
		return node as Area3D
	for child in node.get_children():
		var found := _find_useful_item(child)
		if found != null:
			return found
	return null


func _find_item_by_id(node: Node, item_id: String) -> Area3D:
	if node is Area3D and str(node.get_meta("item_id", "")) == item_id:
		return node as Area3D
	for child in node.get_children():
		var found := _find_item_by_id(child, item_id)
		if found != null:
			return found
	return null


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
