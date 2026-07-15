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
	test_world_items_are_free_one_shot_publish_modifiers()
	test_pick_token_costs_action_and_adds_notebook_token()
	test_meme_frame_offer_is_infrequent_and_purchase_costs_action()
	test_single_character_craft_consumes_one_frame()
	test_meme_fusion_combines_two_memes_and_boosts_score()
	test_ascent_offers_three_permanent_reward_choices()
	test_star_sun_moon_combo_adds_one_daily_action()
	test_ascent_reward_blocks_actions_and_cannot_be_farmed()
	test_reward_modifier_changes_publish_scoring()
	test_source_card_passive_follows_tokens_into_publish_scoring()
	test_published_memes_make_legacy_rules_on_ascent()
	test_fallback_legacy_rule_is_used_without_published_memes()
	test_reality_dialogue_requires_all_legacy_tiles()
	test_high_pollution_locks_legacy_tiles_and_pollutes_sentence()
	test_reality_phase_moves_from_npc_to_player_to_result()
	test_typed_reality_choices_preview_legacy_without_spending()
	test_typed_reality_reveals_one_character_and_spends_on_completion()
	test_typed_reality_corruption_and_merchant_understanding_checks()
	test_each_floor_npc_has_unique_dialogue_without_understanding_prompt()
	test_communication_item_purchase_costs_action_and_has_limited_charges()
	test_communication_item_only_consumes_to_rescue_failed_understanding()
	test_reality_dialogue_leaves_irreversible_relationship_residue()
	test_first_crossing_sixty_triggers_flashback_and_forces_day_end()
	test_flashback_trigger_is_once_per_run()
	test_place_meme_is_free_and_confirm_dialogue_costs_action()
	test_publish_breakdown_uses_base_times_multiplier_and_repeat_decay()
	test_daily_signal_contract_matches_and_boosts_score()
	test_signal_contract_risk_is_paid_on_publish()
	test_visible_six_day_trends_match_scoring_rotation()
	test_day_settlement_can_raise_tower_and_unlock_ending()
	test_ending_language_choice_is_limited_and_irreversible()
	test_twelve_day_catchup_guarantees_tower_ending()


func test_navigation_is_free_and_five_actions_mark_day_end() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.set_phone_open(true)
	game.set_active_app("social")
	_assert_eq(game.actions_remaining, 5, "navigation should not spend actions")
	for index in 5:
		game.spend_action("test")
	_assert_eq(game.actions_remaining, 0, "five actions should deplete the day")
	_assert_true(game.needs_day_settlement, "depleted actions should request day settlement")
	game.settle_day_if_needed()
	_assert_eq(game.day, 2, "settlement should advance to day 2")
	_assert_eq(game.actions_remaining, 5, "settlement should reset daily actions")


func test_social_follow_and_like_toggles_are_free_and_persistent() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.social_followed_handles.is_empty(), "a new run should begin without followed social accounts")
	_assert_true(game.social_liked_post_ids.is_empty(), "a new run should begin without liked posts")
	var actions_before: int = game.actions_remaining
	_assert_true(game.toggle_social_follow("塔下夜巡"), "following a new account should return the followed state")
	_assert_true(game.is_social_following("塔下夜巡"), "followed account should persist in run state")
	_assert_true(game.toggle_social_like("missing_window"), "liking a new post should return the liked state")
	_assert_true(game.is_social_post_liked("missing_window"), "liked post should persist in run state")
	_assert_eq(game.actions_remaining, actions_before, "following and liking should not spend daily actions")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_true(game.is_social_following("塔下夜巡"), "followed accounts should survive day settlement")
	_assert_true(game.is_social_post_liked("missing_window"), "liked posts should survive day settlement")
	_assert_true(not game.toggle_social_follow("塔下夜巡"), "pressing follow again should unfollow the account")
	_assert_true(not game.toggle_social_like("missing_window"), "pressing like again should remove the like")


func test_world_items_are_free_one_shot_publish_modifiers() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var meme := {
		"id": "world-item-meme",
		"title": "街区测试",
		"text": "信号，仍在回响？",
		"tags": ["日常"],
		"rarity": 1,
		"pollution_bias": 0,
		"clarity_bias": 0,
		"source_passives": [],
	}
	var plain: Dictionary = game.get_publish_breakdown(meme)
	var actions_before: int = game.actions_remaining
	_assert_true(game.collect_world_item({
		"id": "street-chip",
		"label": "信号筹码",
		"effect": "publish_base",
		"value": 8,
		"description": "下一次发布的传播基础 +8。",
	}), "a street chip should be collectable")
	_assert_true(game.collect_world_item({
		"id": "street-lens",
		"label": "回声镜片",
		"effect": "publish_multiplier_bonus",
		"value": 1,
		"description": "下一次发布的整数倍率 +1。",
	}), "an echo lens should stack with the street chip")
	_assert_true(not game.collect_world_item({"id": "street-chip", "effect": "publish_base", "value": 8}), "the same world item id should never be collected twice")
	_assert_eq(game.actions_remaining, actions_before, "exploration pickups should not spend today's actions")
	_assert_true(game.is_world_item_collected("street-chip"), "collected world item ids should persist in the run")
	var boosted: Dictionary = game.get_publish_breakdown(meme)
	_assert_eq(int(boosted.get("world_item_base_bonus", 0)), 8, "street chip should add eight publish base")
	_assert_eq(int(boosted.get("world_item_multiplier_bonus", 0)), 1, "echo lens should add one point to the shared integer multiplier")
	_assert_eq(int(boosted.get("world_item_multiplier", 1)), 2, "legacy world-item multiplier output should remain an integer")
	_assert_true(int(boosted.get("score", 0)) > int(plain.get("score", 0)), "world items should materially improve the propagation preview")
	_assert_eq((boosted.get("active_world_item_labels", []) as Array).size(), 2, "publish preview should name both armed world items")

	game.clarity = 70
	_assert_true(game.collect_world_item({"id": "clear-thread", "label": "清晰线", "effect": "clarity", "value": 7}), "clarity thread should be collectable")
	_assert_eq(game.clarity, 77, "clarity thread should restore clarity immediately")
	_assert_eq((game.pending_world_item_effects.get("labels", []) as Array).size(), 2, "immediate clarity items should not pollute the pending publish labels")

	game.completed_memes = [meme]
	game.place_meme_in_blank("blank_1", "world-item-meme")
	_assert_true(game.confirm_dialogue(), "a world-item-boosted meme should publish normally")
	_assert_true(game.pending_world_item_effects.is_empty(), "successful publication should consume all pending world-item modifiers")
	var consumed: Dictionary = game.get_publish_breakdown(meme)
	_assert_eq(int(consumed.get("world_item_base_bonus", 0)), 0, "consumed street chip should not affect the next preview")
	_assert_eq(int(consumed.get("world_item_multiplier_bonus", 0)), 0, "consumed echo lens should not affect the next preview")


func test_pick_token_costs_action_and_adds_notebook_token() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var result: bool = game.pick_token("p1", {"id": "t1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1})
	_assert_true(result, "pick_token should return true for a new token")
	_assert_eq(game.actions_remaining, 4, "picking a token should cost one action")
	_assert_eq(game.notebook_tokens.size(), 1, "picked token should enter notebook")
	_assert_eq(game.notebook_tokens[0]["text"], "哈", "every notebook pickup should be normalized to exactly one visible character")


func test_meme_frame_offer_is_infrequent_and_purchase_costs_action() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(not game.get_daily_meme_frame_offer().is_empty(), "day one should offer an onboarding meme frame")
	_assert_true(game.buy_daily_meme_frame(), "the offered meme frame should be purchasable")
	_assert_eq(game.actions_remaining, 4, "buying a meme frame should cost one action")
	_assert_eq(game.owned_meme_frames, 1, "the bought frame should enter inventory")
	_assert_true(not game.buy_daily_meme_frame(), "the same daily frame offer should only be bought once")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_true(game.get_daily_meme_frame_offer().is_empty(), "day two should not offer a frame")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_true(game.get_daily_meme_frame_offer().is_empty(), "day three should not offer a frame")
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_true(not game.get_daily_meme_frame_offer().is_empty(), "the frame should return on day four after two absent days")


func test_single_character_craft_consumes_one_frame() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.notebook_tokens = [{"id": "n1", "text": "哈", "tags": ["哈吉米"], "rarity": 2, "source_passive": {}}]
	game.owned_meme_frames = 1
	_assert_eq(game.get_craft_slots().size(), 1, "the notebook should expose exactly one core slot")
	_assert_eq(str(game.get_craft_slots()[0].get("id", "")), "glyph", "the only core slot should be the one-character glyph frame")
	_assert_true(not game.place_token_in_slot("object", "n1"), "removed object and saying slots should reject tokens")
	_assert_true(game.place_token_in_slot("glyph", "n1"), "the glyph should enter the purchased frame")
	_assert_eq(game.actions_remaining, 5, "placing tokens should be free")
	var crafted: bool = game.confirm_craft()
	_assert_true(crafted, "one frame plus one glyph should create a complete meme")
	_assert_eq(game.actions_remaining, 4, "confirm craft should cost one action")
	_assert_eq(game.completed_memes.size(), 1, "crafted meme should enter meme bank")
	_assert_eq(game.completed_memes[0]["text"], "哈", "a basic crafted meme should remain one character long")
	_assert_eq(game.owned_meme_frames, 0, "crafting should consume exactly one purchased meme frame")


func test_meme_fusion_combines_two_memes_and_boosts_score() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var first := {"id": "m-a", "title": "梗字「哈」", "text": "哈", "tags": ["哈吉米"], "rarity": 1, "pollution_bias": 1, "clarity_bias": -1, "fusion_level": 0, "source_passives": []}
	var second := {"id": "m-b", "title": "梗字「塔」", "text": "塔", "tags": ["巴别塔"], "rarity": 2, "pollution_bias": 2, "clarity_bias": -1, "fusion_level": 0, "source_passives": []}
	game.completed_memes = [first, second]
	var plain_score := int(game.get_publish_breakdown(second).get("score", 0))
	var pollution_before := int(game.pollution)
	_assert_true(game.place_meme_in_fusion_slot("left", "m-a"), "the first complete meme should enter the left fusion slot")
	_assert_true(game.place_meme_in_fusion_slot("right", "m-b"), "a different complete meme should enter the right fusion slot")
	_assert_eq(game.actions_remaining, 5, "arranging fusion slots should be free")
	_assert_true(game.confirm_meme_fusion(), "two different complete memes should fuse")
	_assert_eq(game.actions_remaining, 4, "confirming fusion should cost one action")
	var fused: Dictionary = game.completed_memes[0]
	_assert_eq(str(fused.get("text", "")), "哈塔", "fusion should visibly join the two source memes")
	_assert_eq(int(fused.get("fusion_level", 0)), 1, "the first fusion should record level one")
	_assert_true(int(fused.get("pollution_bias", 0)) > int(first.get("pollution_bias", 0)) + int(second.get("pollution_bias", 0)), "fusion should carry more future pollution than both inputs combined")
	_assert_true(game.pollution > pollution_before, "fusion itself should immediately increase run pollution")
	_assert_true(int(game.get_publish_breakdown(fused).get("score", 0)) > plain_score, "the fused meme should be materially stronger than a basic source meme")
	game.fusion_slots = {"left": "m-a", "right": "m-b"}
	_assert_true(not game.confirm_meme_fusion(), "the same pair should not be fused repeatedly for infinite scaling")


func test_ascent_offers_three_permanent_reward_choices() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.heat = 620
	for index in 5:
		game.spend_action("ascent-%d" % index)
	_assert_true(game.settle_day_if_needed(), "a completed high-progress day should settle")
	_assert_eq(game.tower_floor, 2, "high progress should ascend to floor two")
	var choices: Array = game.get_pending_ascent_reward_choices()
	_assert_eq(choices.size(), 3, "an ascent should present exactly three permanent rewards")
	var ids: Array[String] = []
	for choice in choices:
		ids.append(str(choice.get("id", "")))
		_assert_true(not str(choice.get("tarot_id", "")).is_empty(), "every ascent choice should be a named tarot card")
		_assert_true(not str(choice.get("numeral", "")).is_empty(), "tarot ascent choices should retain their major-arcana numeral")
	_assert_eq(ids.duplicate().size(), 3, "reward choices should expose three identifiers")
	_assert_true(ids[0] != ids[1] and ids[0] != ids[2] and ids[1] != ids[2], "the three reward choices should be unique")
	var actions_before: int = game.actions_remaining
	_assert_true(game.choose_ascent_reward(ids[0]), "one offered reward should be selectable")
	_assert_eq(game.actions_remaining, actions_before, "choosing a permanent reward should be free")
	_assert_eq(game.permanent_modifiers.size(), 1, "chosen reward should persist in the run")
	_assert_true(game.get_pending_ascent_reward_choices().is_empty(), "choosing should clear the current offer")
	_assert_true(not game.choose_ascent_reward(ids[1]), "a reward outside the current offer should not be selectable")


func test_star_sun_moon_combo_adds_one_daily_action() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	for tarot_id in ["star", "sun", "moon"]:
		game.pending_ascent_reward_choices = [{"id": tarot_id, "tarot_id": tarot_id, "numeral": "TEST", "label": tarot_id, "effect": "publish_base", "value": 0.0}]
		_assert_true(game.choose_ascent_reward(tarot_id), "the prepared %s tarot reward should be selectable" % tarot_id)
	_assert_true("star" in game.owned_tarot_ids and "sun" in game.owned_tarot_ids and "moon" in game.owned_tarot_ids, "the run should remember all collected tarot names")
	var combos: Array = game.get_active_tarot_combos()
	_assert_true(not combos.is_empty() and str(combos[0].get("id", "")) == "day_and_night", "star, sun and moon should activate the day-and-night combo")
	_assert_eq(game.max_actions_per_day, 6, "the day-and-night combo should permanently add one daily action")
	game.actions_remaining = 0
	game.needs_day_settlement = true
	game.settle_day_if_needed()
	_assert_eq(game.actions_remaining, 6, "each new day should refill the combo-enhanced action capacity")


func test_ascent_reward_blocks_actions_and_cannot_be_farmed() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game._queue_ascent_reward(1)
	_assert_true(not game.spend_action("blocked-by-reward"), "pending ascent reward should block the next effective action")
	_assert_eq(game.actions_remaining, 5, "a blocked action should not consume today's action budget")
	var reward_id := str(game.get_pending_ascent_reward_choices()[0].get("id", ""))
	_assert_true(game.choose_ascent_reward(reward_id), "the queued ascent reward should be selectable")
	_assert_true(game.spend_action("after-reward"), "effective actions should resume after the reward is chosen")
	game._queue_ascent_reward(1)
	_assert_true(game.get_pending_ascent_reward_choices().is_empty(), "dropping and reascending the same floor must not create another reward")
	_assert_eq(game.permanent_modifiers.size(), 1, "the same departed floor should only grant one permanent modifier")


func test_reward_modifier_changes_publish_scoring() -> void:
	var baseline: RefCounted = _state_script.new()
	baseline.new_run()
	var modified: RefCounted = _state_script.new()
	modified.new_run()
	modified.permanent_modifiers = [{"id": "echo_amplifier", "label": "回声增幅", "effect": "trend_multiplier_bonus", "value": 1.0}]
	var meme := {
		"id": "m-reward",
		"text": "哈吉米，今天必须解释",
		"tags": ["哈吉米", "追问"],
		"rarity": 2,
		"pollution_bias": 0,
	}
	var baseline_score := int(baseline.get_publish_breakdown(meme).get("score", 0))
	var modified_breakdown: Dictionary = modified.get_publish_breakdown(meme)
	var modified_score := int(modified_breakdown.get("score", 0))
	_assert_true(modified_score > baseline_score, "a permanent resonance reward should increase matching publish score")
	_assert_true("回声增幅" in modified_breakdown.get("active_modifier_labels", []), "publish breakdown should name the permanent reward that changed the score")


func test_source_card_passive_follows_tokens_into_publish_scoring() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.notebook_tokens = [
		{
			"id": "card-glyph", "text": "塔", "tags": ["巴别塔", "空位"], "rarity": 2,
			"source_passive": {"id": "floor_draft", "label": "空层底稿", "effect": "base_bonus", "value": 4.0},
		},
	]
	game.owned_meme_frames = 1
	game.place_token_in_slot("glyph", "card-glyph")
	_assert_true(game.confirm_craft(), "a card-sourced glyph should craft normally inside one purchased frame")
	var crafted: Dictionary = game.completed_memes[0]
	_assert_eq(crafted.get("source_passives", []).size(), 1, "crafted meme should keep the source card passive")
	var boosted: Dictionary = game.get_publish_breakdown(crafted)
	var plain_meme: Dictionary = crafted.duplicate(true)
	plain_meme["source_passives"] = []
	var plain: Dictionary = game.get_publish_breakdown(plain_meme)
	_assert_true(int(boosted.get("base_value", 0)) == int(plain.get("base_value", 0)) + 4, "source base passive should change the visible additive score")
	_assert_true("空层底稿" in boosted.get("active_source_passive_labels", []), "publish breakdown should name the active source card passive")


func test_published_memes_make_legacy_rules_on_ascent() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.published_memes = [
		{"id": "low", "text": "普通追问", "tags": ["追问"], "floor": 1, "score": 12},
		{"id": "hot", "text": "哈吉米，必须补票", "tags": ["哈吉米", "追问"], "floor": 1, "score": 44},
	]
	game.register_legacy_rule_for_ascent(1)
	_assert_eq(game.legacy_rules.size(), 1, "ascent should create one legacy rule for previous floor")
	_assert_eq(game.legacy_rules[0]["source_meme_id"], "hot", "legacy rule should use hottest meme on that floor")
	_assert_eq(game.legacy_rules[0]["required_text"], "哈吉米，必须补票", "legacy rule should require hottest meme text")


func test_fallback_legacy_rule_is_used_without_published_memes() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.register_legacy_rule_for_ascent(2)
	_assert_eq(game.legacy_rules.size(), 1, "ascent without published meme should still create a legacy rule")
	_assert_eq(game.legacy_rules[0]["source_meme_id"], "", "fallback legacy should not point to a player meme")
	_assert_true(str(game.legacy_rules[0]["required_text"]).length() > 0, "fallback legacy should have required text")


func test_reality_dialogue_requires_all_legacy_tiles() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.legacy_rules = [{
		"id": "legacy-1",
		"floor": 1,
		"source_meme_id": "m1",
		"required_text": "哈吉米，必须补票",
		"tags": ["哈吉米"],
		"created_day": 2,
		"strength": 1,
	}]
	game.place_reality_tile("clean_1", "clean:我想正常说话")
	_assert_eq(game.actions_remaining, 5, "placing clean reality tiles should be free")
	_assert_true(not game.confirm_reality_dialogue(), "reality dialogue should fail until legacy tile is included")
	_assert_eq(game.actions_remaining, 5, "failed reality dialogue should not spend an action")
	game.place_reality_tile("legacy_1", "legacy:legacy-1")
	var confirmed: bool = game.confirm_reality_dialogue()
	_assert_true(confirmed, "reality dialogue should confirm when all legacy tiles are included")
	_assert_eq(game.actions_remaining, 4, "confirmed reality dialogue should cost one action")
	_assert_true(game.last_clean_sentence.contains("哈吉米，必须补票"), "clean sentence should include required legacy text")
	_assert_true(game.npc_understanding < 100, "legacy burden should reduce NPC understanding")


func test_high_pollution_locks_legacy_tiles_and_pollutes_sentence() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 82
	game.legacy_rules = [{
		"id": "legacy-1",
		"floor": 1,
		"source_meme_id": "m1",
		"required_text": "哈吉米，必须补票",
		"tags": ["哈吉米"],
		"created_day": 2,
		"strength": 2,
	}]
	var tiles: Array = game.get_required_legacy_tiles()
	_assert_eq(tiles.size(), 1, "required legacy tiles should expose one tile")
	_assert_true(bool(tiles[0].get("locked", false)), "high pollution should lock legacy tile placement")
	game.place_reality_tile("clean_1", "clean:我想正常说话")
	var confirmed: bool = game.confirm_reality_dialogue()
	_assert_true(confirmed, "locked legacy tiles should be auto included in reality dialogue")
	_assert_true(game.last_polluted_sentence != game.last_clean_sentence, "high pollution should alter the clean sentence")
	_assert_true(game.last_polluted_sentence.contains("哈吉米") or game.last_polluted_sentence.contains("□"), "polluted sentence should contain pollution markers")


func test_reality_phase_moves_from_npc_to_player_to_result() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.has_method("begin_reality_player_turn"), "state should expose begin_reality_player_turn")
	_assert_true(game.has_method("reset_reality_phase_for_day"), "state should expose reset_reality_phase_for_day")
	if not game.has_method("begin_reality_player_turn") or not game.has_method("reset_reality_phase_for_day"):
		return
	_assert_eq(game.get("reality_phase"), "npc_speaking", "new runs should start reality dialogue in NPC speaking phase")
	game.begin_reality_player_turn()
	_assert_eq(game.get("reality_phase"), "player_composing", "clicking NPC bubble should enter player composing phase")
	game.place_reality_tile("slot_0", "clean:我")
	_assert_true(game.confirm_reality_dialogue(), "reality dialogue should confirm with a clean tile when no legacy rules exist")
	_assert_eq(game.get("reality_phase"), "reality_result", "confirmed reality dialogue should enter result phase")
	game.reset_reality_phase_for_day()
	_assert_eq(game.get("reality_phase"), "npc_speaking", "reset should return to NPC speaking phase")
	game.begin_reality_player_turn()
	game.set_view_state("npc_up")
	_assert_eq(game.get("reality_phase"), "npc_speaking", "entering NPC view should restart at NPC speaking phase")


func test_typed_reality_choices_preview_legacy_without_spending() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.legacy_rules = [{
		"id": "legacy-typed",
		"floor": 1,
		"required_text": "哈吉米，必须补票",
		"tags": ["哈吉米"],
	}]
	var actions_before: int = game.actions_remaining
	_assert_true(game.start_typed_reality_conversation("npc-preview", "npc", "迟到者"), "approaching an NPC should start typed conversation")
	var choices: Array = game.get_typed_reality_choices()
	_assert_eq(choices.size(), 3, "typed reality conversation should expose exactly three choices")
	for choice in choices:
		var summary := str(choice.get("summary", ""))
		_assert_true(summary.length() >= 3 and summary.length() <= 5, "reality choice summaries should stay within three to five Chinese characters")
	var preview: String = game.preview_typed_reality_choice(str(choices[0].get("id", "")))
	_assert_true(preview.contains("哈吉米，必须补票"), "hover preview should automatically carry every legacy phrase")
	_assert_eq(game.actions_remaining, actions_before, "starting and previewing typed dialogue should not spend an action")


func test_typed_reality_reveals_one_character_and_spends_on_completion() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 0
	_assert_true(game.start_typed_reality_conversation("npc-typing", "npc", "抄写员"), "typed dialogue should start with available actions")
	var choice_id := str(game.get_typed_reality_choices()[0].get("id", ""))
	_assert_true(game.select_typed_reality_choice(choice_id), "clicking a response should enter typing")
	var sentence_length: int = game.conversation_clean_sentence.length()
	var first_result: Dictionary = game.advance_typed_reality_character()
	_assert_true(bool(first_result.get("advanced", false)), "one key press should reveal one character")
	_assert_eq(game.conversation_reveal_index, 1, "one key press should advance the reveal cursor exactly once")
	_assert_eq(game.conversation_revealed_units.size(), 1, "one key press should create exactly one revealed unit")
	_assert_eq(game.actions_remaining, 5, "partial typing should not spend an action")
	var final_result: Dictionary = {}
	for index in range(1, sentence_length):
		final_result = game.advance_typed_reality_character()
	_assert_true(bool(final_result.get("completed", false)), "revealing the final character should complete the attempt")
	_assert_true(bool(final_result.get("action_spent", false)), "a completed spoken attempt should spend one action")
	_assert_eq(game.actions_remaining, 4, "typing an entire sentence should cost exactly one action")
	_assert_eq(game.last_clean_sentence, game.last_polluted_sentence, "zero pollution should preserve every clean character")


func test_typed_reality_corruption_and_merchant_understanding_checks() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 100
	game.completed_memes = [{"id": "meme-corrupt", "title": "信号补票", "text": "哈吉米必须进入句子"}]
	_assert_true(game.start_typed_reality_conversation("merchant-corrupt", "merchant", "信号商人"), "merchant should use the same typed conversation surface")
	var choice_id := str(game.get_typed_reality_choices()[0].get("id", ""))
	game.select_typed_reality_choice(choice_id)
	var first_result: Dictionary = game.advance_typed_reality_character()
	_assert_true(bool(first_result.get("advanced", false)), "polluted typing should still advance one character per key")
	_assert_true(bool(game.conversation_revealed_units[0].get("corrupted", false)), "100 pollution should corrupt the first revealed character")
	_assert_true(str(game.conversation_revealed_units[0].get("display", "")) != str(game.conversation_revealed_units[0].get("clean", "")), "corrupted character should become a glyph or meme-bank fragment")
	var final_result: Dictionary = {}
	while game.conversation_phase == "typing":
		final_result = game.advance_typed_reality_character()
	_assert_true(bool(final_result.get("completed", false)), "merchant sentence should resolve after its last key press")
	_assert_eq(game.conversation_understanding_rolls.size(), 3, "merchant understanding should always roll three pollution checks")


func test_each_floor_npc_has_unique_dialogue_without_understanding_prompt() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var floor_counts := {1: 5, 2: 4, 3: 3, 4: 2, 5: 2}
	for floor_number in floor_counts:
		game.tower_floor = int(floor_number)
		var prompts: Array[String] = []
		var response_sentences: Array[String] = []
		for npc_index in int(floor_counts[floor_number]):
			game.reset_typed_reality_conversation()
			_assert_true(game.start_typed_reality_conversation("npc_%d_npc%d" % [floor_number, npc_index], "npc", "NPC %d" % npc_index), "every generated NPC should open a conversation")
			prompts.append(game.conversation_prompt)
			var choices: Array = game.get_typed_reality_choices()
			_assert_eq(choices.size(), 3, "every NPC should expose three authored responses")
			response_sentences.append(str(choices[0].get("sentence", "")))
		_assert_eq(game._unique(prompts).size(), prompts.size(), "all NPC prompts on floor %d should be different" % floor_number)
		_assert_eq(game._unique(response_sentences).size(), response_sentences.size(), "all NPC response copy on floor %d should be different" % floor_number)
	game.new_run()
	game.pollution = 100
	game.start_typed_reality_conversation("npc_1_npc0", "npc", "迟到者")
	game.select_typed_reality_choice(str(game.get_typed_reality_choices()[0].get("id", "")))
	while game.conversation_phase == "typing":
		game.advance_typed_reality_character()
	_assert_eq(game.conversation_phase, "result", "a spoken answer should end in an authored reaction instead of an understanding retry loop")
	_assert_true(not game.conversation_feedback.contains("听懂") and not game.conversation_feedback.contains("理解"), "reality feedback should never tell the player whether the NPC understood")


func test_communication_item_purchase_costs_action_and_has_limited_charges() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var item: Dictionary = game.get_daily_communication_item()
	var money_before: int = game.money
	_assert_true(game.buy_daily_communication_item(), "merchant communication item should be purchasable once per day")
	_assert_eq(game.actions_remaining, 4, "buying a communication item should spend one action")
	_assert_eq(game.money, money_before - int(item.get("price", 0)), "communication item purchase should pay its listed price")
	_assert_true(game.daily_communication_item_bought, "daily merchant inventory should remember the purchase")
	var owned: Dictionary = game.get_active_communication_item()
	_assert_eq(str(owned.get("id", "")), str(item.get("id", "")), "purchased communication item should enter the active inventory")
	_assert_eq(int(owned.get("charges", 0)), int(item.get("charges", 0)), "communication item should begin with its listed limited uses")
	_assert_true(not game.buy_daily_communication_item(), "merchant should not sell the same daily communication item twice")
	_assert_eq(game.actions_remaining, 4, "failed duplicate purchase should not spend an action")
	game.start_typed_reality_conversation("merchant-offer", "merchant", "信号商人")
	game.conversation_selected_choice_id = "trade"
	game.conversation_understood = true
	game.conversation_phase = "result"
	_assert_true(game.should_show_merchant_communication_offer(), "the authored trade response should expose the merchant item offer without an understanding prompt")


func test_communication_item_only_consumes_to_rescue_failed_understanding() -> void:
	var finder: RefCounted = _state_script.new()
	finder.new_run()
	finder.pollution = 80
	var item: Dictionary = finder.get_daily_communication_item()
	var base_chance := 20
	var boosted_chance := base_chance + int(item.get("clarity_bonus", 0))
	var rescued_actor_id := ""
	var clear_actor_id := ""
	for candidate_index in 500:
		var candidate := "aid-roll-%d" % candidate_index
		finder.start_typed_reality_conversation(candidate, "npc", "回声住户")
		var choice_id := str(finder.get_typed_reality_choices()[0].get("id", ""))
		finder.select_typed_reality_choice(choice_id)
		finder.conversation_attempts = 1
		var roll: int = finder._conversation_roll("understanding", 0, 0)
		if clear_actor_id.is_empty() and roll < base_chance:
			clear_actor_id = candidate
		if rescued_actor_id.is_empty() and roll >= base_chance and roll < boosted_chance:
			rescued_actor_id = candidate
		if not rescued_actor_id.is_empty() and not clear_actor_id.is_empty():
			break
	_assert_true(not rescued_actor_id.is_empty() and not clear_actor_id.is_empty(), "test should find deterministic clear and aid-rescued listener rolls")

	var rescued_game: RefCounted = _state_script.new()
	rescued_game.new_run()
	rescued_game.pollution = 80
	rescued_game.owned_communication_items = [item.duplicate(true)]
	rescued_game.start_typed_reality_conversation(rescued_actor_id, "npc", "回声住户")
	rescued_game.select_typed_reality_choice(str(rescued_game.get_typed_reality_choices()[0].get("id", "")))
	while rescued_game.conversation_phase == "typing":
		rescued_game.advance_typed_reality_character()
	_assert_true(rescued_game.conversation_understood, "limited-use communication item should rescue a roll inside its bonus range")
	_assert_eq(int(rescued_game.get_active_communication_item().get("charges", 0)), int(item.get("charges", 0)) - 1, "rescued misunderstanding should consume exactly one charge")
	_assert_eq(rescued_game.last_communication_item_used, str(item.get("label", "")), "dialogue result should identify the consumed communication item")

	var clear_game: RefCounted = _state_script.new()
	clear_game.new_run()
	clear_game.pollution = 80
	clear_game.owned_communication_items = [item.duplicate(true)]
	clear_game.start_typed_reality_conversation(clear_actor_id, "npc", "回声住户")
	clear_game.select_typed_reality_choice(str(clear_game.get_typed_reality_choices()[0].get("id", "")))
	while clear_game.conversation_phase == "typing":
		clear_game.advance_typed_reality_character()
	_assert_true(clear_game.conversation_understood, "base-clear listener should understand without assistance")
	_assert_eq(int(clear_game.get_active_communication_item().get("charges", 0)), int(item.get("charges", 0)), "communication item should not waste a charge on an already successful roll")


func test_reality_dialogue_leaves_irreversible_relationship_residue() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 88
	game.legacy_rules = [{
		"id": "legacy-1",
		"floor": 1,
		"required_text": "哈吉米，必须补票",
		"tags": ["哈吉米"],
		"strength": 2,
	}]
	var money_before: int = game.money
	game.place_reality_tile("slot_0", "clean:我")
	_assert_true(game.confirm_reality_dialogue(), "high-pollution dialogue should resolve with locked legacy text")
	_assert_true(game.relationship_residue > 0, "misunderstanding should leave persistent relationship residue")
	_assert_true(game.last_relationship_residue_gain > 0, "the result should expose this dialogue's residue gain")
	_assert_true(game.money < money_before, "severe misunderstanding should cost money")
	_assert_true(game.last_relationship_money_loss > 0, "the result should expose this dialogue's money loss")
	var residue_before_settlement: int = game.relationship_residue
	for index in 4:
		game.spend_action("finish-day-%d" % index)
	_assert_true(game.settle_day_if_needed(), "the relationship test day should settle")
	_assert_eq(game.relationship_residue, residue_before_settlement, "day settlement must never repair relationship residue")


func test_first_crossing_sixty_triggers_flashback_and_forces_day_end() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.has_method("check_pollution_flashback"), "state should expose check_pollution_flashback")
	_assert_true(game.has_method("consume_pollution_flashback"), "state should expose consume_pollution_flashback")
	if not game.has_method("check_pollution_flashback") or not game.has_method("consume_pollution_flashback"):
		return
	game.pollution = 60
	var triggered: bool = game.check_pollution_flashback(59)
	_assert_true(triggered, "first crossing from 59 to 60 should trigger the pollution flashback")
	_assert_true(bool(game.get("pollution_flashback_pending")), "trigger should mark flashback pending")
	_assert_true(bool(game.get("pollution_flashback_seen")), "trigger should mark flashback seen")
	_assert_eq(game.actions_remaining, 0, "flashback trigger should consume the rest of the day")
	_assert_true(game.needs_day_settlement, "flashback trigger should request day settlement")
	_assert_eq(game.day_ended_reason, "pollution-flashback", "flashback trigger should explain why the day ended")
	_assert_true(game.consume_pollution_flashback(), "pending flashback should be consumable once")
	_assert_true(not bool(game.get("pollution_flashback_pending")), "consuming flashback should clear pending state")
	_assert_true(game.settle_day_if_needed(), "settlement should run after the flashback is consumed")
	_assert_eq(game.day, 2, "flashback settlement should advance to the next day")
	_assert_eq(game.actions_remaining, 5, "new day should restore all five actions")


func test_flashback_trigger_is_once_per_run() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	if not game.has_method("check_pollution_flashback") or not game.has_method("consume_pollution_flashback"):
		_assert_true(false, "state should expose flashback methods before once-per-run behavior can be tested")
		return
	game.pollution = 61
	_assert_true(game.check_pollution_flashback(59), "first threshold crossing should trigger")
	_assert_true(game.consume_pollution_flashback(), "first threshold crossing should be consumed")
	game.needs_day_settlement = false
	game.actions_remaining = 4
	game.day_ended_reason = ""
	game.pollution = 72
	_assert_true(not game.check_pollution_flashback(61), "later pollution growth above 60 should not retrigger")
	_assert_true(not bool(game.get("pollution_flashback_pending")), "later growth should not leave a pending flashback")
	_assert_eq(game.actions_remaining, 4, "later growth should not consume remaining actions")
	_assert_true(not game.needs_day_settlement, "later growth should not force day settlement")


func test_place_meme_is_free_and_confirm_dialogue_costs_action() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.completed_memes = [{
		"id": "m1",
		"title": "普通追问 #1",
		"text": "哈吉米，什么意思？",
		"tags": ["哈吉米", "追问"],
		"rarity": 1,
		"pollution_bias": 0,
	}]
	game.place_meme_in_blank("blank_1", "m1")
	_assert_eq(game.actions_remaining, 5, "placing meme in dialogue should be free")
	var used: bool = game.confirm_dialogue()
	_assert_true(used, "confirm_dialogue should use placed meme")
	_assert_eq(game.actions_remaining, 4, "confirm dialogue should cost one action")
	_assert_eq(game.dialogue_blanks.size(), 0, "dialogue blank should clear after use")
	_assert_true(game.heat > 18, "successful dialogue should increase heat")
	_assert_true(not game.last_publish_breakdown.is_empty(), "confirmed publish should preserve its score breakdown")
	_assert_true(game.published_memes[0].has("score_breakdown"), "published meme record should keep the score breakdown used for legacy ranking")


func test_publish_breakdown_uses_base_times_multiplier_and_repeat_decay() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 40
	var meme := {
		"id": "m-score",
		"text": "哈吉米，末班车没有终点",
		"tags": ["哈吉米", "追问", "焦虑"],
		"rarity": 2,
		"pollution_bias": 2,
	}
	var first: Dictionary = game.get_publish_breakdown(meme)
	_assert_true(int(first.get("base_value", 0)) > 0, "publish breakdown should expose an additive base value")
	_assert_true(int(first.get("total_multiplier", 0)) > 1, "matching tags and pollution should create a visible integer multiplier")
	_assert_eq(int(first.get("score", 0)), int(first.get("base_value", 0)) * int(first.get("total_multiplier", 0)), "publish score should read as base value times one integer multiplier")
	for key in ["synergy_multiplier", "pollution_multiplier", "repeat_multiplier", "contract_multiplier", "world_item_multiplier", "total_multiplier"]:
		_assert_eq(float(first.get(key, 0)), float(int(first.get(key, 0))), "all exposed multiplier values should be whole numbers: %s" % key)
	game.published_memes = [{"text": meme["text"], "score": first["score"], "floor": 1}]
	var repeated: Dictionary = game.get_publish_breakdown(meme)
	_assert_true(int(repeated.get("repeat_penalty", 0)) > 0, "reusing the same meme should subtract from the shared integer multiplier")
	_assert_true(int(repeated.get("score", 0)) < int(first.get("score", 0)), "repeat decay should lower the final propagation score")


func test_daily_signal_contract_matches_and_boosts_score() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var contract: Dictionary = game.get_daily_signal_contract()
	_assert_eq(contract.get("id", ""), "trend_pair", "day one should begin with the readable two-trend signal hand")
	var matching_meme := {
		"id": "contract-match",
		"text": "哈吉米，今天还要追问",
		"tags": ["哈吉米", "追问"],
		"rarity": 1,
		"pollution_bias": 0,
	}
	var breakdown: Dictionary = game.get_publish_breakdown(matching_meme)
	_assert_true(bool(breakdown.get("contract_matched", false)), "two day-one trend tags should complete the daily signal hand")
	_assert_eq(breakdown.get("contract_label", ""), "双声回路", "the breakdown should expose the completed hand name")
	_assert_true(int(breakdown.get("contract_base_bonus", 0)) > 0, "a completed hand should add visible propagation base")
	_assert_true(int(breakdown.get("contract_multiplier_bonus", 0)) > 0, "a completed hand should add to the shared integer multiplier")
	_assert_eq(int(breakdown.get("score", 0)), int(breakdown.get("base_value", 0)) * int(breakdown.get("total_multiplier", 0)), "signal hand scoring should remain legible as base times one integer multiplier")


func test_signal_contract_risk_is_paid_on_publish() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var meme := {
		"id": "contract-risk",
		"title": "双声测试",
		"text": "哈吉米，为什么还要追问",
		"tags": ["哈吉米", "追问"],
		"rarity": 1,
		"pollution_bias": 0,
	}
	var preview: Dictionary = game.get_publish_breakdown(meme)
	var risk := int(preview.get("contract_pollution_risk", 0))
	_assert_true(risk > 0, "completed daily hands should reveal their pollution price before publishing")
	game.completed_memes = [meme]
	game.place_meme_in_blank("blank_1", "contract-risk")
	_assert_true(game.confirm_dialogue(), "a matching signal hand should publish normally")
	_assert_eq(game.pollution, 4 + 2 * 2 + risk, "publishing should pay the hand's explicit pollution risk")
	_assert_true(str(game.event_log[0]).contains("双声回路"), "publishing a hand should record the named combo in the event log")


func test_visible_six_day_trends_match_scoring_rotation() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.day = 5
	_assert_true("圣歌" in game._current_accepted_tags() and "巴别塔" in game._current_accepted_tags(), "day five scoring should match the visible hymn and Babel trend")
	game.day = 6
	_assert_true("空位" in game._current_accepted_tags() and "沉默" in game._current_accepted_tags(), "day six scoring should match the visible empty-seat and silence trend")


func test_day_settlement_can_raise_tower_and_unlock_ending() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.heat = 620
	game.pollution = 90
	game.tower_floor = 4
	game.published_memes = [{"id": "m4", "text": "塔顶直播没有画面", "tags": ["空位"], "floor": 4, "score": 80}]
	game.spend_action("one")
	game.spend_action("two")
	game.spend_action("three")
	game.spend_action("four")
	game.spend_action("five")
	game.settle_day_if_needed()
	_assert_eq(game.tower_floor, 5, "high progress should raise the tower floor")
	_assert_true(game.get("ending_unlocked"), "floor 5 should unlock ending")
	_assert_true(game.legacy_rules.size() >= 1, "raising tower should preserve previous floor as legacy")


func test_ending_language_choice_is_limited_and_irreversible() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_eq(game.get_ending_language_choices().size(), 4, "tower ending should compress language to exactly four residual choices")
	_assert_true(not game.choose_ending_language("hajimi"), "final language should remain unavailable before reaching the tower top")
	game.ending_unlocked = true
	_assert_true(not game.choose_ending_language("ordinary_sentence"), "tower ending should reject language outside the four residual choices")
	_assert_true(game.choose_ending_language("blocks"), "player should be able to commit one residual final language")
	_assert_eq(game.get_ending_language_output(), "■ ■ ■ ■", "block choice should resolve to the final block utterance")
	_assert_true(not game.choose_ending_language("hajimi"), "the last utterance should be irreversible once selected")


func test_twelve_day_catchup_guarantees_tower_ending() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	for _day_index in 12:
		while not game.get_pending_ascent_reward_choices().is_empty():
			var reward_id := str(game.get_pending_ascent_reward_choices()[0].get("id", ""))
			_assert_true(game.choose_ascent_reward(reward_id), "catchup rewards should be consumed before the next day")
		for action_index in 5:
			_assert_true(game.spend_action("no-progress-%d" % action_index), "five empty progress actions should still be valid daily actions")
		_assert_true(game.settle_day_if_needed(), "forced no-progress day should still settle")
	_assert_eq(game.tower_floor, 5, "narrative catchup should guarantee reaching the top by the end of day twelve")
	_assert_true(game.ending_unlocked, "day twelve catchup should unlock the tower ending")
	_assert_eq(game.legacy_rules.size(), 4, "guaranteed ascent should still create one permanent legacy rule for every departed floor")


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s. Expected %s, got %s" % [message, str(expected), str(actual)])
