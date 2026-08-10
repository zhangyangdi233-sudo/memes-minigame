extends SceneTree

var _failures: Array[String] = []
var _state_script: Script = null


func _init() -> void:
	_run()
	if _failures.is_empty():
		print("meme_game_state tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	_state_script = load("res://scripts/meme_game_state.gd") as Script
	_assert_true(_state_script != null, "meme game state script should exist")
	if _state_script == null:
		return
	test_navigation_is_free_and_five_actions_mark_day_end()
	test_social_follow_and_like_toggles_are_free_and_persistent()
	test_pick_token_costs_action_and_adds_notebook_token()
	test_japanese_pickup_preserves_complete_token()
	test_single_character_craft_consumes_doll_frame()
	test_meme_fusion_combines_two_memes_and_increases_pollution()
	test_publish_updates_money_and_pollution_only()
	test_published_memes_make_legacy_rules_on_ascent()
	test_fallback_legacy_rule_is_used_without_published_memes()
	test_reality_dialogue_requires_all_legacy_tiles()
	test_high_pollution_locks_legacy_tiles_and_pollutes_sentence()
	test_reality_phase_moves_from_npc_to_player_to_result()
	test_typed_reality_reveals_one_character_and_never_grants_frames()
	test_first_crossing_sixty_triggers_flashback_and_forces_day_end()
	test_flashback_trigger_is_once_per_run()
	test_gameplay_metrics_are_limited_to_money_and_pollution()


func test_navigation_is_free_and_five_actions_mark_day_end() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.set_phone_open(true)
	game.set_active_app("social")
	_assert_eq(game.actions_remaining, 5, "navigation should not spend actions")
	for index in 5:
		_assert_true(game.spend_action("test-%d" % index), "each available action should be spendable")
	_assert_eq(game.actions_remaining, 0, "five actions should deplete the day")
	_assert_true(game.needs_day_settlement, "depleted actions should request day settlement")
	_assert_true(game.settle_day_if_needed(), "the exhausted day should settle")
	_assert_eq(game.day, 2, "settlement should advance to day two")
	_assert_eq(game.actions_remaining, 5, "settlement should restore five actions")


func test_social_follow_and_like_toggles_are_free_and_persistent() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var actions_before: int = game.actions_remaining
	_assert_true(game.toggle_social_follow("塔下夜巡"), "following should enter run state")
	_assert_true(game.toggle_social_like("missing_window"), "liking should enter run state")
	_assert_eq(game.actions_remaining, actions_before, "social browsing controls should remain free")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_true(game.is_social_following("塔下夜巡"), "follow state should survive day settlement")
	_assert_true(game.is_social_post_liked("missing_window"), "like state should survive day settlement")


func test_pick_token_costs_action_and_adds_notebook_token() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.pick_token("p1", {
		"id": "t1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 2,
	}), "a new Chinese token should be pickable")
	_assert_eq(game.actions_remaining, 4, "picking a token should spend one action")
	_assert_eq(game.notebook_tokens.size(), 1, "picked token should enter the notebook")
	_assert_eq(str(game.notebook_tokens[0].get("text", "")), "哈", "Chinese pickup should keep one visible character")
	_assert_eq(game.pollution, 1, "rarer pickup should increase pollution through the canonical path")


func test_japanese_pickup_preserves_complete_token() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.pick_token("ja-existence", {
		"id": "existence", "text": "  「存在」。 ", "content_locale": "ja", "tags": ["空位"], "rarity": 1,
	}), "Japanese existence token should be pickable")
	_assert_eq(str(game.notebook_tokens[0].get("text", "")), "存在", "Japanese pickup should preserve a complete token")
	_assert_true(game.pick_token("ja-elevator", {
		"id": "elevator", "text": "『エレベーター』", "content_locale": "ja", "tags": ["巴别塔"], "rarity": 1,
	}), "Japanese elevator token should be pickable")
	_assert_eq(str(game.notebook_tokens[1].get("text", "")), "エレベーター", "Japanese kana pickup should remain intact")


func test_single_character_craft_consumes_doll_frame() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.notebook_tokens = [{"id": "n1", "text": "哈", "tags": ["哈吉米"], "rarity": 2}]
	game.owned_meme_frames = 1
	game.owned_meme_frame_ids.append("frame_kept_name")
	_assert_eq(game.get_craft_slots().size(), 1, "the notebook should expose one glyph frame")
	_assert_true(game.place_token_in_slot("glyph", "n1"), "the glyph should enter the doll-granted frame")
	_assert_eq(game.actions_remaining, 5, "arranging the frame should remain free")
	_assert_true(game.confirm_craft(), "one frame plus one glyph should create a meme")
	_assert_eq(game.actions_remaining, 4, "confirming craft should spend one action")
	_assert_eq(str(game.completed_memes[0].get("text", "")), "哈", "basic crafted meme should retain its character")
	_assert_eq(game.owned_meme_frames, 0, "crafting should consume one doll-granted frame")
	_assert_true(game.owned_meme_frame_ids.is_empty(), "consumed frame provenance should leave the inventory")


func test_meme_fusion_combines_two_memes_and_increases_pollution() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var first := {"id": "m-a", "text": "哈", "tags": ["哈吉米"], "rarity": 1, "pollution_bias": 1, "fusion_level": 0}
	var second := {"id": "m-b", "text": "塔", "tags": ["巴别塔"], "rarity": 2, "pollution_bias": 2, "fusion_level": 0}
	game.completed_memes = [first, second]
	var pollution_before: int = game.pollution
	_assert_true(game.place_meme_in_fusion_slot("left", "m-a"), "first meme should enter the left fusion slot")
	_assert_true(game.place_meme_in_fusion_slot("right", "m-b"), "second meme should enter the right fusion slot")
	_assert_true(game.confirm_meme_fusion(), "two different memes should fuse")
	var fused: Dictionary = game.completed_memes[0]
	_assert_eq(str(fused.get("text", "")), "哈塔", "fusion should visibly join both source memes")
	_assert_eq(int(fused.get("fusion_level", 0)), 1, "first fusion should record level one")
	_assert_true(game.pollution > pollution_before, "fusion should immediately raise pollution")
	game.fusion_slots = {"left": "m-a", "right": "m-b"}
	_assert_true(not game.confirm_meme_fusion(), "the same pair should not be farmed repeatedly")


func test_publish_updates_money_and_pollution_only() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var meme := {
		"id": "m-publish", "text": "哈", "tags": ["哈吉米"],
		"rarity": 2, "pollution_bias": 1, "fusion_level": 0,
	}
	game.completed_memes = [meme]
	var expected: Dictionary = game.get_publish_result(meme)
	var money_before: int = game.money
	var pollution_before: int = game.pollution
	_assert_true(game.place_meme_in_blank("blank_1", "m-publish"), "placing a meme should be free")
	_assert_true(game.confirm_dialogue(), "the placed meme should publish")
	_assert_eq(game.money, money_before + int(expected.get("money_gain", 0)), "publishing should add the previewed money")
	_assert_eq(game.pollution, pollution_before + int(expected.get("pollution_gain", 0)), "publishing should add the previewed pollution")
	_assert_eq(game.published_memes.size(), 1, "publication should leave one floor record")
	_assert_eq(int(game.published_memes[0].get("money_gain", 0)), int(expected.get("money_gain", 0)), "record should preserve money gain for legacy ranking")


func test_published_memes_make_legacy_rules_on_ascent() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.published_memes = [
		{"id": "low", "text": "普通追问", "tags": ["追问"], "floor": 1, "money_gain": 4},
		{"id": "hot", "text": "哈吉米，必须补票", "tags": ["哈吉米"], "floor": 1, "money_gain": 9},
	]
	_assert_true(game.register_legacy_rule_for_ascent(1), "ascent should create one legacy rule")
	_assert_eq(str(game.legacy_rules[0].get("source_meme_id", "")), "hot", "legacy should use the floor's highest-earning post")
	_assert_eq(str(game.legacy_rules[0].get("required_text", "")), "哈吉米，必须补票", "legacy should preserve the chosen meme text")


func test_fallback_legacy_rule_is_used_without_published_memes() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.register_legacy_rule_for_ascent(2), "empty floor should still leave an authored legacy")
	_assert_eq(str(game.legacy_rules[0].get("source_meme_id", "missing")), "", "fallback legacy should not claim a player post")
	_assert_true(not str(game.legacy_rules[0].get("required_text", "")).is_empty(), "fallback legacy should contain required text")


func test_reality_dialogue_requires_all_legacy_tiles() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.legacy_rules = [_legacy_rule(1)]
	game.place_reality_tile("slot_0", "clean:我")
	_assert_true(not game.confirm_reality_dialogue(), "an unlocked legacy phrase must be placed explicitly")
	_assert_eq(game.actions_remaining, 5, "invalid sentence should not spend an action")
	game.place_reality_tile("slot_1", "legacy:legacy-1")
	_assert_true(game.confirm_reality_dialogue(), "sentence containing the legacy phrase should resolve")
	_assert_true(game.last_clean_sentence.contains("哈吉米，必须补票"), "spoken sentence should contain inherited language")


func test_high_pollution_locks_legacy_tiles_and_pollutes_sentence() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 82
	game.legacy_rules = [_legacy_rule(2)]
	var tiles: Array = game.get_required_legacy_tiles()
	_assert_true(bool(tiles[0].get("locked", false)), "high pollution should lock the legacy phrase into place")
	game.place_reality_tile("slot_0", "clean:我")
	_assert_true(game.confirm_reality_dialogue(), "locked legacy phrase should be inserted automatically")
	_assert_true(game.last_polluted_sentence != game.last_clean_sentence, "high pollution should alter the spoken sentence")
	_assert_true(game.relationship_residue > 0, "damaged communication should leave relationship residue")


func test_reality_phase_moves_from_npc_to_player_to_result() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_eq(game.reality_phase, "npc_speaking", "new day should begin with the NPC speaking")
	_assert_true(game.begin_reality_player_turn(), "clicking the NPC line should begin composition")
	_assert_eq(game.reality_phase, "player_composing", "player turn should expose the language puzzle")
	game.place_reality_tile("slot_0", "clean:我")
	_assert_true(game.confirm_reality_dialogue(), "clean sentence should resolve without legacy rules")
	_assert_eq(game.reality_phase, "reality_result", "confirmed sentence should show its result")
	game.reset_reality_phase_for_day()
	_assert_eq(game.reality_phase, "npc_speaking", "day reset should restore the NPC phase")


func test_typed_reality_reveals_one_character_and_never_grants_frames() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.start_typed_reality_conversation("floor1npc0", "npc", "迟到者"), "ordinary NPC dialogue should start")
	var choice_id := str(game.get_typed_reality_choices()[0].get("id", ""))
	_assert_true(game.select_typed_reality_choice(choice_id), "response should enter per-character delivery")
	var first_result: Dictionary = game.advance_typed_reality_character()
	_assert_true(bool(first_result.get("advanced", false)), "one key should reveal one character")
	_assert_eq(game.actions_remaining, 5, "partial delivery should remain free")
	while game.conversation_phase == "typing":
		game.advance_typed_reality_character()
	_assert_eq(game.actions_remaining, 4, "completing the spoken turn should spend one action")
	_assert_eq(game.owned_meme_frames, 0, "ordinary NPC dialogue must never grant a meme frame")
	_assert_true(game.conversation_reward.is_empty(), "ordinary NPC result should have no reward payload")


func test_first_crossing_sixty_triggers_flashback_and_forces_day_end() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 59
	game.change_pollution(1)
	_assert_true(game.pollution_flashback_pending, "first 60% crossing should queue the flashback")
	_assert_true(game.pollution_flashback_seen, "first crossing should be remembered for the run")
	_assert_eq(game.actions_remaining, 0, "flashback should consume the rest of the day")
	_assert_true(game.needs_day_settlement, "flashback should request day settlement")
	_assert_eq(game.day_ended_reason, "pollution-flashback", "forced settlement should preserve its cause")
	_assert_true(game.consume_pollution_flashback(), "pending flashback should be consumable once")
	_assert_true(game.settle_day_if_needed(), "flashback day should settle after the sequence")
	_assert_eq(game.day, 2, "flashback should advance to the next day")


func test_flashback_trigger_is_once_per_run() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 60
	_assert_true(game.check_pollution_flashback(59), "first threshold crossing should trigger")
	_assert_true(game.consume_pollution_flashback(), "first trigger should be consumable")
	game.actions_remaining = 4
	game.needs_day_settlement = false
	game.pollution = 72
	_assert_true(not game.check_pollution_flashback(61), "later growth above 60 should not retrigger")
	_assert_eq(game.actions_remaining, 4, "later pollution growth should not erase remaining actions")


func test_gameplay_metrics_are_limited_to_money_and_pollution() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var metrics: Dictionary = game.get_gameplay_metrics()
	_assert_eq(metrics.size(), 2, "core gameplay should expose only two numeric metrics")
	_assert_true(metrics.has("money") and metrics.has("pollution"), "the two metrics should be money and pollution")


func _legacy_rule(strength: int) -> Dictionary:
	return {
		"id": "legacy-1",
		"floor": 1,
		"source_meme_id": "m1",
		"required_text": "哈吉米，必须补票",
		"tags": ["哈吉米"],
		"created_day": 2,
		"strength": strength,
	}


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s. Expected %s, got %s" % [message, str(expected), str(actual)])
