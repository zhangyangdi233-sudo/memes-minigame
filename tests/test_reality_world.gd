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
	game_root._locale.set_locale("zh")
	game_root.new_game()
	for _line_index in 7:
		game_root._advance_prologue()
	await process_frame

	var player := game_root.get_node_or_null("RealityPlayer") as CharacterBody3D
	var floor_root := game_root.get_node_or_null("RealityFloor") as Node3D
	var camera := game_root.get_node_or_null("Camera3D") as Camera3D
	var top_bar := _find_node_by_name(game_root, "CinematicTopBar") as ColorRect
	var bottom_bar := _find_node_by_name(game_root, "CinematicBottomBar") as ColorRect
	var hud_rail := _find_node_by_name(game_root, "InternationalHUDRail") as PanelContainer
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
	var expected_npc_counts := [4, 3, 2, 1, 0]
	for floor_index in expected_npc_counts.size():
		var floor_number := floor_index + 1
		_assert_eq(game_root._npc_count_for_floor(floor_number), expected_npc_counts[floor_index], "ordinary NPC population should follow the reduced floor sequence")
		if floor_index > 0:
			_assert_true(expected_npc_counts[floor_index] < expected_npc_counts[floor_index - 1], "ordinary NPC population should strictly decrease on every ascent")
	_assert_eq(int(floor_root.get_meta("room_count", 0)), 4, "generated first floor should match the room formula")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 4, "first floor should contain four ordinary NPCs")
	_assert_eq(str(floor_root.get_meta("district_style", "")), "sunlit_brick_street", "first floor should use the sunlit brick-road reference grammar")
	var map_width := float(floor_root.get_meta("map_width", 0.0))
	var map_length := float(floor_root.get_meta("map_length", 0.0))
	_assert_true(_find_node_by_name(floor_root, "BrickWall") != null and _find_node_by_name(floor_root, "Crosswalk00") != null, "sunlit district should include tall brick edge walls and a zebra crossing")
	var first_brick_wall := _find_node_by_name(floor_root, "BrickWall") as Node3D
	if first_brick_wall != null:
		_assert_true(absf(first_brick_wall.position.x) >= map_width * 0.5 - 1.0, "sunlit brick walls should follow the outer terrain edge")
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
	_assert_true(map_width >= 32.0 and map_length >= 230.0, "first floor should be five times longer than the original forty-six-metre street")
	_assert_eq(float(floor_root.get_meta("world_length_scale", 0.0)), 5.0, "generated floors should expose the requested five-times world scale")
	var street_ground := _find_node_by_name(floor_root, "StreetGround") as StaticBody3D
	_assert_true(street_ground != null, "shared street should use one continuous collision ground")
	var crossroad_ground := _find_node_by_name(floor_root, "CrossroadGround") as StaticBody3D
	_assert_true(crossroad_ground != null and bool(crossroad_ground.get_meta("crossroad_extension", false)), "the horizontal branch should have its own continuous collision ground")
	var crossroad := _find_node_by_name(floor_root, "CrossRoad") as Node3D
	_assert_true(crossroad != null and bool(crossroad.get_meta("crossroad_surface", false)), "first corridor district should add a real horizontal road across its center")
	var crossroad_span := float(floor_root.get_meta("crossroad_total_span", 0.0))
	_assert_true(crossroad_span >= map_width + 80.0, "the first crossroad should extend into substantial left and right branches")
	_assert_eq(str(floor_root.get_meta("crossroad_layout", "")), "continuous_four_way", "the crossroad should be a continuous four-way layout")
	var edge_walls: Array[Node3D] = []
	_collect_nodes_with_meta(floor_root, "terrain_edge_wall", edge_walls)
	_assert_eq(edge_walls.size(), 4, "the two long terrain edges should each use two wall segments around the central intersection")
	var crossroad_opening := float(floor_root.get_meta("crossroad_opening_span", 0.0))
	var wall_lengths := {"west": 0.0, "east": 0.0}
	for edge_wall in edge_walls:
		var wall_length := float(edge_wall.get_meta("edge_length", 0.0))
		var edge_side := str(edge_wall.get_meta("edge_side", ""))
		wall_lengths[edge_side] = float(wall_lengths.get(edge_side, 0.0)) + wall_length
		_assert_true(absf(edge_wall.position.z) - wall_length * 0.5 >= crossroad_opening * 0.5 - 0.01, "terrain edge walls should stop before the open center of the crossroad")
	_assert_true(is_equal_approx(float(wall_lengths["west"]), map_length - crossroad_opening) and is_equal_approx(float(wall_lengths["east"]), map_length - crossroad_opening), "each side wall should cover the full map edge except the road opening")
	var boundary_walls: Array[Node3D] = []
	_collect_nodes_with_meta(floor_root, "terrain_boundary_wall", boundary_walls)
	_assert_eq(boundary_walls.size(), 12, "trunk, branch sides, and all four ends should form one continuous visible boundary")
	_assert_eq(int(floor_root.get_meta("crossroad_branch_wall_count", 0)), 6, "left and right branches should each have two side walls and one end wall")
	_assert_true(_find_node_by_name(floor_root, "CrossroadEndWallWest") != null and _find_node_by_name(floor_root, "CrossroadEndWallEast") != null, "both horizontal branches should terminate in real walls")
	_assert_true(_find_node_by_name(floor_root, "StreetEndWallNorth") != null and _find_node_by_name(floor_root, "StreetEndWallSouth") != null, "the long street should close its north and south ends")
	_assert_eq(str(floor_root.get_meta("dreamcore_overlay", "")), "regular_grid_with_controlled_anomalies", "first-floor additions should use controlled dreamcore repetition")
	_assert_eq(int(floor_root.get_meta("dreamcore_light_slot_count", 0)), 18, "both branches should repeat nine threshold light bays")
	_assert_true(int(floor_root.get_meta("dreamcore_false_door_count", 0)) >= 6, "repeated false doors should introduce sparse architectural wrongness")
	_assert_true(_find_node_by_name(floor_root, "DreamcoreThresholdRhythm") != null, "dreamcore atmosphere should be represented by original procedural geometry")
	_assert_eq(int(floor_root.get_meta("air_wall_count", 0)), 12, "the cross-shaped map perimeter should expose twelve joined air-wall segments")
	var air_walls := _find_node_by_name(floor_root, "AirWalls") as Node3D
	_assert_true(air_walls != null and air_walls.get_child_count() == 12, "air-wall container should follow every edge of the cross-shaped floor")
	if air_walls != null:
		for wall in air_walls.get_children():
			_assert_true(wall is StaticBody3D and bool(wall.get_meta("air_wall", false)), "each perimeter edge should be an invisible static air wall")
	if player != null:
		var half_width := map_width * 0.5
		var half_length := map_length * 0.5
		_assert_true(absf(player.position.x) <= half_width - 5.0, "player spawn should have generous horizontal clearance")
		_assert_true(absf(player.position.z) <= half_length - 5.0, "player spawn should have generous longitudinal clearance")
	var branch_position := Vector3(crossroad_span * 0.5 - 2.0, 0.08, 0.0)
	_assert_true(bool(floor_root.call("contains_playable_position", branch_position)), "the player should be allowed to walk down the new right branch")
	var outside_corner := Vector3(crossroad_span * 0.5 - 2.0, 0.08, 24.0)
	_assert_true(not bool(floor_root.call("contains_playable_position", outside_corner)), "the empty diagonal beyond the cross shape should remain outside the map")
	var clamped_corner: Vector3 = floor_root.call("clamp_to_playable_position", outside_corner)
	_assert_true(bool(floor_root.call("contains_playable_position", clamped_corner)), "clamping should choose the nearest valid arm or trunk instead of a bounding rectangle")

	var merchant := _find_actor(floor_root, "merchant")
	var ordinary_npcs := _count_actors(floor_root, "npc")
	_assert_true(merchant != null, "every floor should contain exactly one merchant actor")
	_assert_eq(ordinary_npcs, 4, "first floor should place all four ordinary NPC billboards")
	var npc_z_positions: Array[float] = []
	_collect_actor_z_positions(floor_root, "npc", npc_z_positions)
	npc_z_positions.sort()
	for index in range(1, npc_z_positions.size()):
		_assert_true(npc_z_positions[index] - npc_z_positions[index - 1] >= 25.0, "ordinary NPCs should be spaced across the five-times-long street")
	if merchant != null:
		var merchant_billboard := merchant.get_node_or_null("Billboard") as Sprite3D
		_assert_true(merchant_billboard != null and merchant_billboard.texture != null, "merchant should use generated 2D character artwork")
		if merchant_billboard != null:
			_assert_eq(merchant_billboard.billboard, BaseMaterial3D.BILLBOARD_ENABLED, "2D actors should always face the camera")
	var npc_texture_ids: Dictionary = {}
	_collect_actor_texture_ids(floor_root, "npc", npc_texture_ids)
	_assert_eq(npc_texture_ids.size(), 3, "ordinary NPCs should rotate through all three protagonist-style character artworks")

	for action_name in ["reality_forward", "reality_back", "reality_left", "reality_right", "reality_sprint", "reality_interact"]:
		_assert_true(InputMap.has_action(action_name), "reality movement should register input action %s" % action_name)
	_assert_true(_action_has_key("reality_forward", KEY_W) and _action_has_key("reality_forward", KEY_UP), "forward movement should accept W and Up")
	_assert_true(_action_has_key("reality_back", KEY_S) and _action_has_key("reality_back", KEY_DOWN), "back movement should accept S and Down")
	_assert_true(_action_has_key("reality_left", KEY_A) and _action_has_key("reality_left", KEY_LEFT), "left movement should accept A and Left")
	_assert_true(_action_has_key("reality_right", KEY_D) and _action_has_key("reality_right", KEY_RIGHT), "right movement should accept D and Right")
	_assert_true(_action_has_key("reality_sprint", KEY_SHIFT), "accelerated walking should use Shift")
	_assert_true(_action_has_key("reality_interact", KEY_F), "world interaction should use F")

	game_root.set_view_state("npc_up")
	if top_bar != null and bottom_bar != null:
		_assert_true(top_bar.visible and bottom_bar.visible, "putting the phone down should restore both cinematic bars")
		_assert_true(top_bar.size.y > 24.0 and bottom_bar.size.y > 24.0, "reality walking should retain a visible movie frame")
		_assert_true(top_bar.size.y <= game_root.get_viewport().get_visible_rect().size.y * 0.121, "responsive cinematic bars should never consume more than twelve percent per edge")
		if hud_rail != null:
			var hud_rect := hud_rail.get_global_rect()
			var viewport_height := game_root.get_viewport().get_visible_rect().size.y
			_assert_true(hud_rect.position.y >= top_bar.get_global_rect().end.y + 6.0, "left HUD should begin inside the cinematic picture instead of crossing the top matte")
			_assert_true(hud_rect.end.y <= bottom_bar.get_global_rect().position.y - 6.0, "left HUD should end inside the cinematic picture instead of crossing the bottom matte")
			_assert_true(absf(hud_rect.get_center().y - viewport_height * 0.5) <= 1.0, "left HUD should stay vertically centered on the picture")
	_assert_true(bool(game_root._reality_mouse_look_enabled), "putting the phone down should immediately enable free mouse look")
	var yaw_before_mouse := float(game_root._reality_yaw)
	var mouse_turn := InputEventMouseMotion.new()
	mouse_turn.relative = Vector2(96.0, 0.0)
	game_root._unhandled_input(mouse_turn)
	_assert_true(not is_equal_approx(float(game_root._reality_yaw), yaw_before_mouse), "horizontal mouse movement should rotate the first-person view")
	var yaw_before_touch := float(game_root._reality_yaw)
	var pitch_before_touch := float(game_root._reality_pitch)
	var actions_before_touch := int(game_root.game.actions_remaining)
	var touch_start := InputEventScreenTouch.new()
	touch_start.index = 3
	touch_start.position = Vector2(760.0, 430.0)
	touch_start.pressed = true
	game_root._input(touch_start)
	var touch_turn := InputEventScreenDrag.new()
	touch_turn.index = 3
	touch_turn.position = Vector2(688.0, 468.0)
	touch_turn.screen_relative = Vector2(-72.0, 38.0)
	game_root._input(touch_turn)
	_assert_true(not is_equal_approx(float(game_root._reality_yaw), yaw_before_touch), "horizontal touchscreen drag should rotate the first-person view")
	_assert_true(not is_equal_approx(float(game_root._reality_pitch), pitch_before_touch), "vertical touchscreen drag should tilt the first-person view")
	_assert_eq(game_root.game.actions_remaining, actions_before_touch, "touchscreen free look should not spend an action")
	var yaw_after_primary_touch := float(game_root._reality_yaw)
	var second_touch_turn := InputEventScreenDrag.new()
	second_touch_turn.index = 4
	second_touch_turn.position = Vector2(500.0, 300.0)
	second_touch_turn.screen_relative = Vector2(120.0, 0.0)
	game_root._input(second_touch_turn)
	_assert_true(is_equal_approx(float(game_root._reality_yaw), yaw_after_primary_touch), "a second finger should not steal the active one-finger camera gesture")
	var touch_end := InputEventScreenTouch.new()
	touch_end.index = 3
	touch_end.position = touch_turn.position
	touch_end.pressed = false
	game_root._input(touch_end)
	_assert_eq(int(game_root._reality_touch_look_index), -1, "lifting the active finger should finish the camera gesture")
	game_root._reality_yaw = 0.0
	var trackpad_left := InputEventPanGesture.new()
	# macOS pan deltas report content movement, opposite to finger movement.
	trackpad_left.delta = Vector2(2.0, 0.0)
	game_root._input(trackpad_left)
	_assert_true(float(game_root._reality_yaw) > 0.0, "two-finger trackpad movement to the left should turn the camera left")
	_assert_true(absf(float(game_root._reality_yaw)) <= 4.0, "trackpad look should use the reduced sensitivity")
	game_root._reality_yaw = 0.0
	var trackpad_right := InputEventPanGesture.new()
	trackpad_right.delta = Vector2(-2.0, 0.0)
	game_root._input(trackpad_right)
	_assert_true(float(game_root._reality_yaw) < 0.0, "two-finger trackpad movement to the right should turn the camera right")
	game_root._reality_pitch = 0.0
	var trackpad_up := InputEventPanGesture.new()
	trackpad_up.delta = Vector2(0.0, 2.0)
	game_root._input(trackpad_up)
	_assert_true(float(game_root._reality_pitch) > 0.0, "two-finger trackpad movement upward should tilt the camera upward")
	game_root._reality_pitch = 0.0
	var trackpad_down := InputEventPanGesture.new()
	trackpad_down.delta = Vector2(0.0, -2.0)
	game_root._input(trackpad_down)
	_assert_true(float(game_root._reality_pitch) < 0.0, "two-finger trackpad movement downward should tilt the camera downward")
	_assert_eq(game_root.game.actions_remaining, actions_before_touch, "trackpad free look should not spend an action")
	game_root.set_view_state("phone_down")
	var yaw_while_phone_is_up := float(game_root._reality_yaw)
	game_root._input(touch_start)
	game_root._input(touch_turn)
	_assert_true(is_equal_approx(float(game_root._reality_yaw), yaw_while_phone_is_up), "touchscreen drag should not turn the world while the phone interface is active")
	game_root._input(trackpad_left)
	_assert_true(is_equal_approx(float(game_root._reality_yaw), yaw_while_phone_is_up), "trackpad pan should keep scrolling available instead of turning the world while the phone is active")
	var pitch_while_phone_is_up := float(game_root._reality_pitch)
	game_root._input(trackpad_up)
	_assert_true(is_equal_approx(float(game_root._reality_pitch), pitch_while_phone_is_up), "vertical trackpad pan should remain available to phone UI while the phone is active")
	game_root.set_view_state("npc_up")
	game_root._reality_yaw = 0.0
	game_root._reality_pitch = 0.0
	if player != null:
		var walk_start := player.position
		Input.action_press("reality_forward")
		for frame in 24:
			await physics_frame
		Input.action_release("reality_forward")
		var walk_distance := walk_start.distance_to(player.position)
		_assert_true(walk_distance > 0.25, "holding W should move the first-person body forward through the floor")
		player.position = walk_start
		player.velocity = Vector3.ZERO
		Input.action_press("reality_forward")
		Input.action_press("reality_sprint")
		for frame in 24:
			await physics_frame
		Input.action_release("reality_sprint")
		Input.action_release("reality_forward")
		var sprint_distance := walk_start.distance_to(player.position)
		_assert_true(sprint_distance > walk_distance * 1.35, "holding Shift while walking should cover substantially more distance")
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
		var leave_button := _find_node_by_name(game_root, "RealityConversationContinue") as Button
		var actions_before_leave := int(game_root.game.actions_remaining)
		_assert_true(leave_button != null and leave_button.visible and leave_button.text == "离开", "merchant and NPC conversations should expose an immediate Leave button")
		if leave_button != null:
			leave_button.pressed.emit()
		_assert_true(not game_root._reality_interaction_active, "Leave should close a conversation before the player speaks")
		_assert_eq(game_root.game.actions_remaining, actions_before_leave, "leaving without speaking should not spend an action")
		game_root._refresh_nearby_reality_actor()
		_assert_true(game_root._try_reality_interaction(), "the same actor should remain available after leaving")
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

	game_root.game.tower_floor = 2
	game_root._ensure_reality_floor_current()
	floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
	await physics_frame
	_assert_eq(int(floor_root.get_meta("room_count", 0)), 6, "second floor should retain its six gameplay rooms")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 3, "second floor should reduce ordinary NPCs to three")
	_assert_eq(_count_actors(floor_root, "npc"), 3, "second-floor actor population should match its metadata")
	_assert_eq(str(floor_root.get_meta("district_style", "")), "night_white_blocks", "second floor should use the night white-block district")
	_assert_eq(str(floor_root.get_meta("atmosphere_mode", "")), "slow_burn_suspense", "suspense atmosphere should begin on the second floor")
	_assert_true(float(floor_root.get_meta("fog_density", 0.0)) >= 0.0179, "second-floor fog should be visibly denser than first-floor daylight haze")
	_assert_true(float(floor_root.get_meta("ambient_light_energy", 1.0)) <= 0.20, "second-floor ambient light should leave deliberate shadowed sightlines")
	_assert_eq(str(floor_root.get_meta("suspense_color_temperature", "")), "cold_green", "second-floor global light should use a cold green temperature against warm lamps")
	_assert_true(_find_node_by_name(floor_root, "WarmPool") != null and _find_node_by_name(floor_root, "SuspenseLight00") != null, "second floor should contrast warm street pools with colder suspense lights")
	_assert_true(_find_node_by_name(floor_root, "SuspenseOcclusion") != null, "second floor should add procedural sightline occlusion")
	_assert_true(int(floor_root.get_meta("suspense_occluder_count", 0)) >= 5, "slow-burn atmosphere should repeat several non-blocking sightline screens")
	_assert_true(int(floor_root.get_meta("controlled_repeat_count", 0)) > int(floor_root.get_meta("suspense_occluder_count", 0)), "architectural repetition should include one restrained spatial anomaly")
	_assert_eq(int(floor_root.get_meta("jump_scare_trigger_count", -1)), 0, "suspense geometry should not add jump-scare trigger areas")
	_assert_true(float(floor_root.get_meta("minimum_clear_path_width", 0.0)) >= 5.6, "occluders should preserve a generous continuous walking lane")
	_assert_eq(int(floor_root.get_meta("night_house_segment_count", 0)), 6, "second floor should turn all six rooms into connected terrace segments")
	_assert_true(float(floor_root.get_meta("night_house_coverage_ratio", 0.0)) >= 0.98, "second-floor houses should cover nearly the full inhabited street length")
	_assert_true(float(floor_root.get_meta("night_house_max_gap", 99.0)) <= 1.2, "adjacent house segments should use narrow seams instead of detached-building gaps")
	_assert_true(int(floor_root.get_meta("night_facade_bay_count", 0)) >= 48, "continuous terraces should expose a dense rhythm of repeated house bays")
	var continuous_houses: Array[Node3D] = []
	_collect_nodes_with_meta(floor_root, "continuous_house_segment", continuous_houses)
	_assert_eq(continuous_houses.size(), 6, "every second-floor room should contribute one continuous house segment")
	for house in continuous_houses:
		_assert_true(float(house.get_meta("segment_length", 0.0)) >= 60.0, "second-floor house segments should be elongated rather than isolated cubes")
	var floor_two_spawn: Vector3 = floor_root.call("start_position")
	_assert_true(bool(floor_root.call("contains_playable_position", floor_two_spawn)), "second-floor spawn should remain inside the playable street")
	var floor_two_centerline_hit := _centerline_collision(floor_root, player)
	_assert_true(floor_two_centerline_hit.is_empty(), "second-floor central walking lane should remain collision-free: %s" % str(floor_two_centerline_hit.get("collider", "")))
	var floor_two_fog_density := float(floor_root.get_meta("fog_density", 0.0))

	game_root.game.tower_floor = 5
	game_root._ensure_reality_floor_current()
	floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
	await physics_frame
	_assert_eq(int(floor_root.get_meta("room_count", 0)), 14, "fifth floor should grow to fourteen rooms")
	_assert_true(float(floor_root.get_meta("map_length", 0.0)) > map_length, "higher floors should lengthen the same shared street as lots are added")
	_assert_eq(str(floor_root.get_meta("layout_mode", "")), "shared_street", "higher floors should preserve the shared-street layout")
	_assert_eq(int(floor_root.get_meta("air_wall_count", 0)), 4, "expanded floors should rebuild their four perimeter air walls")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 0, "highest floor should remove ordinary NPCs while retaining the merchant")
	_assert_eq(_count_actors(floor_root, "npc"), 0, "fifth-floor actor population should match its metadata")
	_assert_true(_find_actor(floor_root, "merchant") != null, "merchant should persist on the highest floor")
	_assert_eq(str(floor_root.get_meta("atmosphere_mode", "")), "slow_burn_suspense", "highest floor should preserve the suspense system")
	_assert_true(float(floor_root.get_meta("fog_density", 0.0)) > floor_two_fog_density, "fog should deepen with each ascent after floor two")
	_assert_true(_centerline_collision(floor_root, player).is_empty(), "fifth-floor housing and occluders should preserve the central walking lane")
	_assert_eq(str(floor_root.get_meta("district_style", "")), "night_white_blocks", "fifth floor should rotate back to the night white-block district")
	_assert_true(_find_node_by_name(floor_root, "WhiteHouse") != null and _find_node_by_name(floor_root, "WarmPool") != null, "night district should contain white cubic homes and warm streetlights")
	var night_house := _find_node_by_name(floor_root, "WhiteHouse") as Node3D
	if night_house != null:
		_assert_true(absf(night_house.position.x) <= 7.2, "night houses should crowd the path like the supplied reference instead of leaving a broad empty plaza")

	game_root.game.tower_floor = 3
	game_root._ensure_reality_floor_current()
	floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
	await physics_frame
	_assert_eq(str(floor_root.get_meta("district_style", "")), "overgrown_gallery", "third floor should use the overgrown white-gallery district")
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 2, "third floor should reduce ordinary NPCs to two")
	_assert_eq(_count_actors(floor_root, "npc"), 2, "third-floor actor population should match its metadata")
	_assert_true(_find_node_by_name(floor_root, "GalleryRoof") != null and _find_node_by_name(floor_root, "GalleryCeilingSpan") != null and _find_node_by_name(floor_root, "GrassPatch00") != null, "overgrown district should combine a covered white colonnade with procedural grass")
	_assert_true(bool(floor_root.get_meta("gallery_continuous", false)), "third-floor gallery architecture should be one elongated continuum")
	_assert_true(float(floor_root.get_meta("gallery_span_ratio", 0.0)) >= 0.95, "gallery roofs and outer walls should span nearly the full street")
	_assert_true(float(floor_root.get_meta("gallery_column_spacing", 99.0)) <= 7.2, "third-floor columns should maintain a continuous rhythm without long empty breaks")
	_assert_true(int(floor_root.get_meta("gallery_column_count", 0)) >= 90, "third-floor colonnade should repeat along the full elongated building")
	var gallery_roof := _find_node_by_name(floor_root, "GalleryRoof") as Node3D
	if gallery_roof != null:
		_assert_true(bool(gallery_roof.get_meta("continuous_gallery", false)), "gallery roof should identify itself as a continuous structure")
		_assert_true(float(gallery_roof.get_meta("span_length", 0.0)) >= float(floor_root.get_meta("map_length", 0.0)) - 14.1, "gallery roof should replace short disconnected roof pieces with one long span")
	var gallery_columns: Array[Node3D] = []
	_collect_nodes_with_meta(floor_root, "gallery_column", gallery_columns)
	_assert_eq(gallery_columns.size(), int(floor_root.get_meta("gallery_column_count", 0)), "gallery column metadata should match the generated collision columns")
	var first_gallery_column := _find_node_by_name(floor_root, "GalleryColumnW00") as Node3D
	if first_gallery_column != null:
		_assert_true(absf(first_gallery_column.position.x) - 0.26 >= 2.8, "gallery column collisions should preserve the declared 5.6-metre central lane")
	_assert_eq(str(floor_root.get_meta("atmosphere_mode", "")), "slow_burn_suspense", "third floor should keep the suspense atmosphere under the colonnade")
	_assert_true(float(floor_root.get_meta("fog_density", 0.0)) > floor_two_fog_density, "third-floor fog should deepen beyond floor two")
	_assert_eq(int(floor_root.get_meta("jump_scare_trigger_count", -1)), 0, "third-floor suspense should rely on space and repetition instead of jump-scare areas")
	_assert_true(_centerline_collision(floor_root, player).is_empty(), "third-floor continuous colonnade should keep its centerline walkable")
	var grass_patch := _find_node_by_name(floor_root, "GrassPatch00") as Node3D
	if grass_patch != null:
		_assert_true(grass_patch.get_child_count() >= 30, "gallery grass should read as dense encroachment rather than sparse markers")
		var first_blade := grass_patch.get_child(0) as MeshInstance3D
		_assert_true(first_blade != null and first_blade.mesh is ArrayMesh, "gallery vegetation should use tapered grass blades rather than cone placeholders")
	var gallery_reference_portal := _find_node_by_name(floor_root, "ReferencePortal") as MeshInstance3D
	_assert_true(gallery_reference_portal != null and str(gallery_reference_portal.get_meta("reference_texture", "")).contains("overgrown_gallery"), "gallery district should use the supplied reference as a distant spatial continuation")

	var floor_three_fog_density := float(floor_root.get_meta("fog_density", 0.0))
	game_root.game.tower_floor = 4
	game_root._ensure_reality_floor_current()
	floor_root = game_root.get_node_or_null("RealityFloor") as Node3D
	await physics_frame
	_assert_eq(int(floor_root.get_meta("ordinary_npc_count", 0)), 1, "fourth floor should leave one ordinary NPC")
	_assert_eq(_count_actors(floor_root, "npc"), 1, "fourth-floor actor population should match its metadata")
	_assert_eq(str(floor_root.get_meta("atmosphere_mode", "")), "slow_burn_suspense", "returning district geometry should retain the darker post-floor-two treatment")
	_assert_true(float(floor_root.get_meta("fog_density", 0.0)) > floor_three_fog_density, "fourth-floor fog should continue the floor-by-floor progression")
	_assert_true(int(floor_root.get_meta("suspense_occluder_count", 0)) >= 5, "fourth floor should retain the non-blocking occlusion rhythm")
	_assert_eq(int(floor_root.get_meta("jump_scare_trigger_count", -1)), 0, "fourth-floor suspense should remain free of jump-scare triggers")
	_assert_true(_centerline_collision(floor_root, player).is_empty(), "fourth-floor suspense screens should not block the long street")

	game_root.queue_free()
	await process_frame


func _centerline_collision(floor_root: Node3D, player: CharacterBody3D) -> Dictionary:
	if floor_root == null or floor_root.get_world_3d() == null:
		return {"missing_world": true}
	var half_length := float(floor_root.get_meta("map_length", 0.0)) * 0.5
	var from := floor_root.to_global(Vector3(0.0, 1.1, -half_length + 10.0))
	var to := floor_root.to_global(Vector3(0.0, 1.1, half_length - 10.0))
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.collide_with_areas = false
	if player != null:
		query.exclude = [player.get_rid()]
	return floor_root.get_world_3d().direct_space_state.intersect_ray(query)


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


func _collect_actor_z_positions(node: Node, actor_type: String, result: Array[float]) -> void:
	if node is Area3D and str(node.get_meta("actor_type", "")) == actor_type:
		result.append((node as Area3D).position.z)
	for child in node.get_children():
		_collect_actor_z_positions(child, actor_type, result)


func _collect_actor_texture_ids(node: Node, actor_type: String, result: Dictionary) -> void:
	if node is Area3D and str(node.get_meta("actor_type", "")) == actor_type:
		var billboard := node.get_node_or_null("Billboard") as Sprite3D
		if billboard != null and billboard.texture != null:
			result[billboard.texture.get_instance_id()] = true
	for child in node.get_children():
		_collect_actor_texture_ids(child, actor_type, result)


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


func _collect_nodes_with_meta(node: Node, meta_name: StringName, result: Array[Node3D]) -> void:
	if node is Node3D and bool(node.get_meta(meta_name, false)):
		result.append(node as Node3D)
	for child in node.get_children():
		_collect_nodes_with_meta(child, meta_name, result)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
