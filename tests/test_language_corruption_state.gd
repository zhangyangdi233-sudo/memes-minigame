extends SceneTree

var _failures: Array[String] = []
var _state_script: Script = null


func _init() -> void:
	_state_script = load("res://scripts/meme_game_state.gd") as Script
	_assert_true(_state_script != null, "meme game state script should exist")
	if _state_script != null:
		test_pollution_alone_controls_first_floor_threshold()
		test_sixty_percent_advances_only_from_a_safe_boundary()
		test_echo_fragments_form_one_hidden_route_without_a_visible_counter()
		test_existing_choice_ids_form_the_alternate_hidden_route()
		test_floor_three_without_hidden_route_enters_normal_ending()
		test_floor_three_with_hidden_route_enters_unregistered_floor_four()
		test_v2_save_round_trip_preserves_hidden_language_state()
		test_v1_floor_five_save_cannot_bypass_the_hidden_route()
		test_random_dialogue_garble_is_capped_and_preserves_punctuation()
		test_hidden_dialogue_key_is_attached_to_an_existing_choice_completion()
		test_floor_transition_request_waits_for_an_explicit_boundary()
		test_effective_pollution_actions_queue_floor_transitions()
	if _failures.is_empty():
		print("language corruption state tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func test_pollution_alone_controls_first_floor_threshold() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 24
	game.heat = 9999
	game.clarity = 0
	game.needs_day_settlement = true
	_assert_true(game.settle_day_if_needed(), "a requested day settlement should run")
	_assert_eq(game.tower_floor, 1, "heat and clarity must not bypass the 25% pollution threshold")

	game.pollution = 25
	game.heat = 0
	game.clarity = 100
	game.needs_day_settlement = true
	_assert_true(game.settle_day_if_needed(), "the next requested day settlement should run")
	_assert_eq(game.tower_floor, 2, "25% pollution should advance floor one at a safe boundary")


func test_sixty_percent_advances_only_from_a_safe_boundary() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.tower_floor = 2
	game.pollution = 59
	_assert_eq(game.tower_floor, 2, "changing pollution during a scene must not move the player immediately")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_eq(game.tower_floor, 2, "59% pollution should remain on floor two")

	game.pollution = 60
	_assert_eq(game.tower_floor, 2, "reaching 60% must wait for a complete-scene boundary")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_eq(game.tower_floor, 3, "60% pollution should advance floor two at day settlement")


func test_echo_fragments_form_one_hidden_route_without_a_visible_counter() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.has_method("get_echo_fragment_ids"), "state should expose the authored echo IDs")
	_assert_true(game.has_method("collect_echo_fragment"), "state should collect echo fragments by stable ID")
	_assert_true(game.has_method("is_hidden_layer_unlocked"), "state should evaluate the hidden route without UI progress")
	if not game.has_method("get_echo_fragment_ids") or not game.has_method("collect_echo_fragment") or not game.has_method("is_hidden_layer_unlocked"):
		return
	var fragment_ids: Array = game.get_echo_fragment_ids()
	_assert_eq(fragment_ids.size(), 3, "the compact hidden route should contain exactly three echo fragments")
	for fragment_id in fragment_ids:
		_assert_true(game.collect_echo_fragment(str(fragment_id)), "each authored fragment should be collectible once")
	_assert_true(not game.collect_echo_fragment(str(fragment_ids[0])), "a fragment cannot be collected twice")
	_assert_true(game.is_hidden_layer_unlocked(), "all three echo fragments should unlock the hidden route")


func test_existing_choice_ids_form_the_alternate_hidden_route() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.has_method("register_dialogue_key_for_choice"), "existing dialogue choices should be able to grant hidden keys")
	if not game.has_method("register_dialogue_key_for_choice"):
		return
	_assert_true(not game.register_dialogue_key_for_choice("unrelated_choice"), "ordinary choices must not create hidden keys")
	for choice_id in ["f1n1_name", "copy_refuse_source", "believer_question"]:
		_assert_true(game.register_dialogue_key_for_choice(choice_id), "each authored existing choice should grant its key once")
	_assert_true(not game.register_dialogue_key_for_choice("f1n1_name"), "the same dialogue key cannot be farmed")
	_assert_true(game.is_hidden_layer_unlocked(), "all required dialogue keys should unlock the same hidden route")


func test_floor_three_without_hidden_route_enters_normal_ending() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.tower_floor = 3
	game.pollution = 80
	_assert_true(game.has_method("complete_floor_three"), "state should expose the formal floor-three ending boundary")
	if not game.has_method("complete_floor_three"):
		return
	_assert_eq(game.complete_floor_three(), "normal-ending", "80% pollution alone must not enter the hidden floor")
	_assert_eq(game.tower_floor, 3, "normal ending should not pretend the hidden floor was entered")
	_assert_true(game.ending_unlocked, "formal floor-three completion should unlock the normal ending")
	_assert_eq(game.ending_route, "normal", "the normal ending route should be explicit in save state")


func test_floor_three_with_hidden_route_enters_unregistered_floor_four() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.tower_floor = 3
	game.pollution = 80
	for fragment_id in game.get_echo_fragment_ids():
		game.collect_echo_fragment(str(fragment_id))
	_assert_eq(game.complete_floor_three(), "hidden-floor", "80% pollution plus either hidden route should enter floor four")
	_assert_eq(game.tower_floor, 4, "the preserved fourth floor should become the hidden unregistered floor")
	_assert_true(not game.ending_unlocked, "entering floor four should not render the normal ending")
	_assert_eq(game.ending_route, "hidden", "the hidden route should survive save and ending routing")


func test_v2_save_round_trip_preserves_hidden_language_state() -> void:
	var source: RefCounted = _state_script.new()
	source.new_run()
	source.pollution = 73
	source.collect_echo_fragment("echo_room_name")
	source.register_dialogue_key_for_choice("f1n1_name")
	var save_data: Dictionary = source.to_save_data()
	_assert_eq(int(save_data.get("version", 0)), 2, "new language-corruption saves should use version two")

	var restored: RefCounted = _state_script.new()
	_assert_true(restored.load_save_data(save_data), "a version-two save should load")
	_assert_eq(restored.pollution, 73, "pollution should survive the version-two round trip")
	_assert_true("echo_room_name" in restored.collected_echo_fragment_ids, "echo fragments should survive save restoration")
	_assert_true("dialogue_key_name" in restored.completed_dialogue_key_ids, "dialogue keys should survive save restoration")


func test_v1_floor_five_save_cannot_bypass_the_hidden_route() -> void:
	var restored: RefCounted = _state_script.new()
	var legacy_save := {
		"version": 1,
		"state": {
			"tower_floor": 5,
			"pollution": 120,
			"owned_meme_frames": 2,
			"owned_communication_items": [{"id": "old_item", "charges": 3}],
		},
	}
	_assert_true(restored.load_save_data(legacy_save), "a version-one save should migrate instead of being rejected")
	_assert_eq(restored.tower_floor, 3, "an old floor-five save must return to floor three without hidden proof")
	_assert_eq(restored.pollution, 100, "migrated pollution should be clamped to the canonical range")
	_assert_eq(restored.owned_meme_frames, 2, "unspent meme frames should survive migration")
	_assert_true(not restored.is_hidden_layer_unlocked(), "old floor number and merchant data must not unlock floor four")
	_assert_true(restored.owned_communication_items.is_empty(), "removed merchant items should not remain active after migration")


func test_random_dialogue_garble_is_capped_and_preserves_punctuation() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 100
	_assert_true(game.start_typed_reality_conversation("floor1npc0", "npc", "迟到者"), "an existing NPC conversation should start")
	var choice_id := str(game.conversation_choices[0].get("id", ""))
	_assert_true(game.select_typed_reality_choice(choice_id), "an existing response should enter typed delivery")
	while game.conversation_phase == "typing":
		game.advance_typed_reality_character()
	for unit in game.conversation_revealed_units:
		var clean_unit := str(unit.get("clean", ""))
		if bool(unit.get("corrupted", false)):
			_assert_true(int(unit.get("roll", 100)) < 65, "random corruption must use a hard 65% probability cap")
		if clean_unit in ["，", "。", "！", "？", ",", ".", "!", "?", "；", ";", "：", ":"]:
			_assert_true(not bool(unit.get("corrupted", false)), "punctuation must remain readable at 100% pollution")


func test_hidden_dialogue_key_is_attached_to_an_existing_choice_completion() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.start_typed_reality_conversation("floor1npc1", "npc", "回声住户"), "the existing echo-tenant conversation should start")
	_assert_true(game.select_typed_reality_choice("f1n1_name"), "the existing name choice should remain available")
	while game.conversation_phase == "typing":
		game.advance_typed_reality_character()
	_assert_true("dialogue_key_name" in game.completed_dialogue_key_ids, "finishing the existing choice should grant its hidden key")
	var key_count: int = game.completed_dialogue_key_ids.size()
	game.register_dialogue_key_for_choice("f1n1_name")
	_assert_eq(game.completed_dialogue_key_ids.size(), key_count, "repeating the same node must not farm hidden progress")


func test_floor_transition_request_waits_for_an_explicit_boundary() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 25
	_assert_true(game.has_method("request_floor_transition_for_pollution"), "state should separate threshold detection from scene changes")
	_assert_true(game.has_method("resolve_floor_transition_at_boundary"), "state should expose an explicit safe-boundary transition")
	if not game.has_method("request_floor_transition_for_pollution") or not game.has_method("resolve_floor_transition_at_boundary"):
		return
	_assert_eq(game.request_floor_transition_for_pollution(), 2, "25% should request floor two")
	_assert_eq(game.tower_floor, 1, "requesting a transition must not interrupt the current line")
	_assert_eq(game.resolve_floor_transition_at_boundary(), 2, "the next explicit boundary should apply the request")
	_assert_eq(game.tower_floor, 2, "the boundary should move the player exactly once")
	_assert_eq(game.pending_floor_transition, 0, "applying a transition should clear its pending target")


func test_effective_pollution_actions_queue_floor_transitions() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 24
	_assert_true(game.pick_token("threshold-post", {
		"id": "threshold-token", "text": "醒", "tags": ["空位"], "rarity": 2,
	}), "an ordinary pickup should still use the existing action flow")
	_assert_eq(game.pollution, 25, "the pickup should raise pollution through the canonical path")
	_assert_eq(game.pending_floor_transition, 2, "crossing 25% during an action should queue floor two")
	_assert_eq(game.tower_floor, 1, "the queued transition must wait for the UI or day boundary")


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
