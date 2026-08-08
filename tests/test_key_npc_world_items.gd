extends SceneTree

const RealityFloorGeneratorScript = preload("res://scripts/reality_floor_generator.gd")
const MemeGameStateScript = preload("res://scripts/meme_game_state.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var palette := {
		"bg": "B7D957", "surface": "FFF1C9", "ink": "10140F",
		"accent": "365B2D", "muted": "DDEB8A", "flash_text": "9CFF24",
	}
	var texture := load("res://assets/generated/characters/npc_late_arrival.png") as Texture2D
	for floor_number in [1, 2, 3]:
		var state := MemeGameStateScript.new()
		state.new_run()
		state.tower_floor = floor_number
		var item: Dictionary = state.get_prerequisite_item_for_floor(floor_number)
		var floor_root := RealityFloorGeneratorScript.new()
		root.add_child(floor_root)
		await process_frame
		floor_root.rebuild(floor_number, palette, {
			"key_npc": texture,
			"key_npc_label": "关键住户",
			"npcs": [texture],
		}, 1, false, item)
		var key_npc := _find_actor(floor_root, "key_npc")
		_assert_true(key_npc != null, "floor %d should replace the merchant position with one key NPC" % floor_number)
		_assert_true(_find_actor(floor_root, "merchant") == null, "floor %d should contain no merchant actor" % floor_number)
		if key_npc != null:
			_assert_true(key_npc.position.distance_to(floor_root.start_position()) < 35.0, "floor %d key NPC should remain near the player for testing" % floor_number)
			_assert_true(floor_root.contains_playable_position(key_npc.position, 0.0), "floor %d key NPC must stand inside the playable area" % floor_number)
		var prerequisite := _find_prerequisite_item(floor_root)
		_assert_true(prerequisite != null, "floor %d should build exactly one authored prerequisite" % floor_number)
		if prerequisite != null:
			_assert_eq(str(prerequisite.get_meta("item_id", "")), str(item.get("id", "")), "world item should use the state-owned prerequisite ID")
			_assert_true(floor_root.contains_playable_position(prerequisite.position, 1.0), "floor %d prerequisite must be inside the traversable map" % floor_number)
			_assert_true(not prerequisite.visible, "the item should remain hidden before the key NPC clue")
			floor_root.sync_prerequisite_items([str(item.get("id", ""))], [])
			_assert_true(prerequisite.visible and prerequisite in floor_root.get_interactable_items(), "the clue should reveal the physical world item")
			floor_root.sync_prerequisite_items([str(item.get("id", ""))], [str(item.get("id", ""))])
			_assert_true(not prerequisite.visible, "a collected prerequisite should disappear permanently")
		floor_root.queue_free()
		await process_frame
	_assert_true(_failures.is_empty(), "key NPC world item assertions should pass")
	if _failures.is_empty():
		print("key NPC world item tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _find_actor(node: Node, actor_type: String) -> Area3D:
	if node is Area3D and str(node.get_meta("actor_type", "")) == actor_type:
		return node as Area3D
	for child in node.get_children():
		var found := _find_actor(child, actor_type)
		if found != null:
			return found
	return null


func _find_prerequisite_item(node: Node) -> Area3D:
	if node is Area3D and bool(node.get_meta("prerequisite_item", false)):
		return node as Area3D
	for child in node.get_children():
		var found := _find_prerequisite_item(child)
		if found != null:
			return found
	return null


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
