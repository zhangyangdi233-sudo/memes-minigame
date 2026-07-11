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
	test_buy_emotion_slot_costs_action_and_editing_is_free()
	test_craft_uses_two_core_slots_and_optional_emotion_text()
	test_emotion_loadout_limits_crafting_to_two_equipped_slots()
	test_ascent_offers_three_permanent_reward_choices()
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
	test_typed_reality_locks_out_after_three_failed_attempts()
	test_communication_item_purchase_costs_action_and_has_limited_charges()
	test_communication_item_only_consumes_to_rescue_failed_understanding()
	test_reality_dialogue_leaves_irreversible_relationship_residue()
	test_first_crossing_sixty_triggers_flashback_and_forces_day_end()
	test_flashback_trigger_is_once_per_run()
	test_place_meme_is_free_and_confirm_dialogue_costs_action()
	test_publish_breakdown_uses_base_times_multiplier_and_repeat_decay()
	test_daily_signal_contract_matches_and_boosts_score()
	test_signal_contract_risk_is_paid_on_publish()
	test_arcana_purchase_costs_action_and_holding_is_capped()
	test_arcana_use_is_free_and_changes_publish_breakdown()
	test_star_arcana_adds_a_trend_tag_to_target_meme()
	test_judgement_arcana_rerolls_the_daily_signal_hand()
	test_arcana_publish_effects_are_consumed_once_and_pay_their_risk()
	test_tower_hermit_and_hanged_arcana_cover_the_other_build_paths()
	test_visible_six_day_trends_match_scoring_rotation()
	test_day_settlement_can_raise_tower_and_unlock_ending()
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


func test_pick_token_costs_action_and_adds_notebook_token() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var result: bool = game.pick_token("p1", {"id": "t1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1})
	_assert_true(result, "pick_token should return true for a new token")
	_assert_eq(game.actions_remaining, 4, "picking a token should cost one action")
	_assert_eq(game.notebook_tokens.size(), 1, "picked token should enter notebook")
	_assert_eq(game.notebook_tokens[0]["text"], "哈吉米", "notebook token text should match")


func test_buy_emotion_slot_costs_action_and_editing_is_free() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	_assert_true(game.has_method("buy_daily_emotion_slot"), "state should expose buy_daily_emotion_slot")
	if not game.has_method("buy_daily_emotion_slot"):
		return
	var slot_id := str(game.get("daily_emotion_slot_id"))
	var bought: bool = game.buy_daily_emotion_slot()
	_assert_true(bought, "buy_daily_emotion_slot should buy today's emotion")
	_assert_eq(game.actions_remaining, 4, "buying an emotion slot should cost one action")
	_assert_true(slot_id in game.owned_emotion_slots, "bought emotion slot should be owned")
	_assert_true(slot_id in game.equipped_emotion_slots, "the first purchased emotion should auto equip")
	game.set_emotion_slot_text(slot_id, "我不是那个意思")
	_assert_eq(game.actions_remaining, 4, "editing emotion text should be free")
	_assert_eq(game.emotion_slot_texts.get(slot_id, ""), "我不是那个意思", "emotion slot text should save player wording")


func test_craft_uses_two_core_slots_and_optional_emotion_text() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.notebook_tokens = [
		{"id": "n1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1},
		{"id": "n2", "text": "到底是什么意思", "tags": ["追问"], "rarity": 1},
	]
	game.owned_emotion_slots = ["anxiety"]
	game.equipped_emotion_slots = ["anxiety"]
	game.set_emotion_slot_text("anxiety", "我不是那个意思")
	game.place_token_in_slot("object", "n1")
	game.place_token_in_slot("saying", "n2")
	_assert_eq(game.actions_remaining, 5, "placing tokens should be free")
	var crafted: bool = game.confirm_craft_with_emotions()
	_assert_true(crafted, "confirm_craft_with_emotions should create a meme when core slots are filled")
	_assert_eq(game.actions_remaining, 4, "confirm craft should cost one action")
	_assert_eq(game.completed_memes.size(), 1, "crafted meme should enter meme bank")
	_assert_true(game.completed_memes[0]["text"].contains("哈吉米"), "crafted meme should include slot text")
	_assert_true(game.completed_memes[0]["text"].contains("我不是那个意思"), "crafted meme should include edited emotion text")
	_assert_true("焦虑" in game.completed_memes[0]["tags"], "emotion hidden tag should enter crafted meme")


func test_emotion_loadout_limits_crafting_to_two_equipped_slots() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.owned_emotion_slots = ["anxiety", "please", "counter"]
	game.equipped_emotion_slots = ["anxiety", "please"]
	game.emotion_slot_texts = {
		"anxiety": "我不是那个意思",
		"please": "你说得也有道理",
		"counter": "难道不是这样吗",
	}
	_assert_true(not game.toggle_equipped_emotion_slot("counter"), "a third emotion should not equip while two slots are occupied")
	_assert_eq(game.equipped_emotion_slots.size(), 2, "failed third equip should preserve the two-slot loadout")
	_assert_true(game.toggle_equipped_emotion_slot("please"), "an equipped emotion should be removable for free")
	_assert_true(game.toggle_equipped_emotion_slot("counter"), "a different emotion should equip after a slot is freed")
	_assert_eq(game.actions_remaining, 5, "changing the emotion loadout should not cost an action")
	game.notebook_tokens = [
		{"id": "n1", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1},
		{"id": "n2", "text": "到底是什么意思", "tags": ["追问"], "rarity": 1},
	]
	game.place_token_in_slot("object", "n1")
	game.place_token_in_slot("saying", "n2")
	_assert_true(game.confirm_craft_with_emotions(), "the selected two-slot loadout should craft normally")
	var crafted: Dictionary = game.completed_memes[0]
	_assert_true(str(crafted["text"]).contains("我不是那个意思"), "equipped anxiety text should enter the crafted meme")
	_assert_true(str(crafted["text"]).contains("难道不是这样吗"), "equipped counter text should enter the crafted meme")
	_assert_true(not str(crafted["text"]).contains("你说得也有道理"), "unequipped emotion text should stay out of the crafted meme")
	_assert_eq(int(crafted.get("emotion_count", 0)), 2, "crafted meme should record exactly two equipped emotions")


func test_ascent_offers_three_permanent_reward_choices() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.heat = 220
	for index in 5:
		game.spend_action("ascent-%d" % index)
	_assert_true(game.settle_day_if_needed(), "a completed high-progress day should settle")
	_assert_eq(game.tower_floor, 2, "high progress should ascend to floor two")
	var choices: Array = game.get_pending_ascent_reward_choices()
	_assert_eq(choices.size(), 3, "an ascent should present exactly three permanent rewards")
	var ids: Array[String] = []
	for choice in choices:
		ids.append(str(choice.get("id", "")))
	_assert_eq(ids.duplicate().size(), 3, "reward choices should expose three identifiers")
	_assert_true(ids[0] != ids[1] and ids[0] != ids[2] and ids[1] != ids[2], "the three reward choices should be unique")
	var actions_before: int = game.actions_remaining
	_assert_true(game.choose_ascent_reward(ids[0]), "one offered reward should be selectable")
	_assert_eq(game.actions_remaining, actions_before, "choosing a permanent reward should be free")
	_assert_eq(game.permanent_modifiers.size(), 1, "chosen reward should persist in the run")
	_assert_true(game.get_pending_ascent_reward_choices().is_empty(), "choosing should clear the current offer")
	_assert_true(not game.choose_ascent_reward(ids[1]), "a reward outside the current offer should not be selectable")


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
	modified.permanent_modifiers = [{"id": "echo_amplifier", "label": "回声增幅", "effect": "synergy_step", "value": 0.08}]
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
			"id": "card-object", "text": "不存在的十三层", "tags": ["巴别塔", "空位"], "rarity": 2,
			"source_passive": {"id": "floor_draft", "label": "空层底稿", "effect": "base_bonus", "value": 4.0},
		},
		{"id": "card-saying", "text": "还在施工", "tags": ["刷新"], "rarity": 1, "source_passive": {}},
	]
	game.place_token_in_slot("object", "card-object")
	game.place_token_in_slot("saying", "card-saying")
	_assert_true(game.confirm_craft_with_emotions(), "card-sourced tokens should craft normally")
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


func test_typed_reality_locks_out_after_three_failed_attempts() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.pollution = 100
	var actor_id := ""
	for candidate_index in 200:
		var candidate := "lockout-%d" % candidate_index
		game.start_typed_reality_conversation(candidate, "npc", "无名信徒")
		var candidate_choice := str(game.get_typed_reality_choices()[0].get("id", ""))
		game.select_typed_reality_choice(candidate_choice)
		var all_fail := true
		for attempt_index in 3:
			game.conversation_attempts = attempt_index
			if game._conversation_roll("understanding", game.conversation_clean_sentence.length(), 0) < 5:
				all_fail = false
				break
		if all_fail:
			actor_id = candidate
			break
	_assert_true(not actor_id.is_empty(), "test should find a deterministic actor id that fails three maximum-pollution checks")
	game.new_run()
	game.pollution = 100
	game.start_typed_reality_conversation(actor_id, "npc", "无名信徒")
	for attempt_index in 3:
		var choice_id := str(game.get_typed_reality_choices()[0].get("id", ""))
		_assert_true(game.select_typed_reality_choice(choice_id), "each failed attempt should return to the three response choices")
		while game.conversation_phase == "typing":
			game.advance_typed_reality_character()
	_assert_eq(game.conversation_phase, "locked_out", "three failed spoken attempts should lock the conversation until F is pressed again")
	_assert_eq(game.conversation_attempts, 3, "lockout should happen on the third failed attempt")
	_assert_eq(game.actions_remaining, 2, "each complete retry should spend one daily action")


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
	game.conversation_selected_choice_id = "ask_goods"
	game.conversation_understood = true
	game.conversation_phase = "result"
	_assert_true(game.should_show_merchant_communication_offer(), "understood ask-goods response should expose the merchant item offer")


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
		var roll: int = finder._conversation_roll("understanding", finder.conversation_clean_sentence.length(), 0)
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
	_assert_true(float(first.get("total_multiplier", 0.0)) > 1.0, "matching tags and pollution should create a visible resonance multiplier")
	_assert_eq(int(first.get("score", 0)), int(round(float(first.get("base_value", 0)) * float(first.get("total_multiplier", 0.0)))), "publish score should read as base value times resonance multiplier")
	game.published_memes = [{"text": meme["text"], "score": first["score"], "floor": 1}]
	var repeated: Dictionary = game.get_publish_breakdown(meme)
	_assert_true(float(repeated.get("repeat_multiplier", 1.0)) < 1.0, "reusing the same meme should expose a repeat decay multiplier")
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
	_assert_true(float(breakdown.get("contract_multiplier", 1.0)) > 1.0, "a completed hand should add a visible multiplier")
	_assert_eq(int(breakdown.get("score", 0)), int(round(float(breakdown.get("base_value", 0)) * float(breakdown.get("total_multiplier", 0.0)))), "signal hand scoring should remain legible as base times total multiplier")


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


func test_arcana_purchase_costs_action_and_holding_is_capped() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.money = 100
	game.daily_arcana_card_id = "moon"
	_assert_true(game.buy_daily_arcana_card(), "the daily arcana card should be purchasable")
	_assert_eq(game.actions_remaining, 4, "buying an arcana card should cost one action")
	_assert_eq(game.owned_arcana_cards.size(), 1, "purchased arcana should enter the held-card area")
	game.daily_arcana_bought = false
	game.daily_arcana_card_id = "hermit"
	_assert_true(game.buy_daily_arcana_card(), "a second arcana should fit in the held-card area")
	_assert_eq(game.owned_arcana_cards.size(), 2, "two held arcana should fill the inventory")
	game.daily_arcana_bought = false
	game.daily_arcana_card_id = "star"
	_assert_true(not game.buy_daily_arcana_card(), "a third arcana should be rejected while both held slots are full")
	_assert_eq(game.actions_remaining, 3, "a rejected full-inventory purchase should not spend an action")


func test_arcana_use_is_free_and_changes_publish_breakdown() -> void:
	var baseline: RefCounted = _state_script.new()
	baseline.new_run()
	var game: RefCounted = _state_script.new()
	game.new_run()
	var meme := {
		"id": "arcana-preview",
		"text": "哈吉米，今天还要追问",
		"tags": ["哈吉米", "追问"],
		"rarity": 1,
		"pollution_bias": 0,
	}
	game.owned_arcana_cards = [{"uid": "held-moon", "id": "moon", "bought_day": 1}]
	var actions_before: int = game.actions_remaining
	_assert_true(game.use_arcana_card("held-moon"), "moon arcana should arm its next-publish effect")
	_assert_eq(game.actions_remaining, actions_before, "using an already purchased arcana should be free")
	_assert_eq(game.owned_arcana_cards.size(), 0, "used arcana should be consumed from the held-card area")
	var plain: Dictionary = baseline.get_publish_breakdown(meme)
	var boosted: Dictionary = game.get_publish_breakdown(meme)
	_assert_true(float(boosted.get("arcana_multiplier", 1.0)) > 1.0, "moon arcana should expose a separate multiplier")
	_assert_true(int(boosted.get("arcana_pollution_risk", 0)) > 0, "moon arcana should reveal its pollution price in preview")
	_assert_true(int(boosted.get("score", 0)) > int(plain.get("score", 0)), "moon arcana should increase the predicted propagation score")
	_assert_true("月亮" in boosted.get("active_arcana_labels", []), "publish preview should name the armed arcana")


func test_star_arcana_adds_a_trend_tag_to_target_meme() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	game.completed_memes = [{
		"id": "star-target",
		"title": "未对齐表达",
		"text": "今天的路没有尽头",
		"tags": ["日常"],
		"rarity": 1,
		"pollution_bias": 0,
	}]
	game.owned_arcana_cards = [{"uid": "held-star", "id": "star", "bought_day": 1}]
	var actions_before: int = game.actions_remaining
	_assert_true(game.use_arcana_card("held-star", "star-target"), "star arcana should modify a selected completed meme")
	_assert_eq(game.actions_remaining, actions_before, "targeted arcana modification should not spend another action")
	_assert_true("哈吉米" in game.completed_memes[0]["tags"], "star arcana should add the first missing current-trend tag")
	_assert_eq(int(game.completed_memes[0].get("pollution_bias", 0)), 1, "star-marked memes should carry a small permanent pollution bias")


func test_judgement_arcana_rerolls_the_daily_signal_hand() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var before_id := str(game.get_daily_signal_contract().get("id", ""))
	game.owned_arcana_cards = [{"uid": "held-judgement", "id": "judgement", "bought_day": 1}]
	_assert_true(game.use_arcana_card("held-judgement"), "judgement arcana should reroll the current signal hand")
	var after_id := str(game.get_daily_signal_contract().get("id", ""))
	_assert_true(after_id != before_id, "judgement should replace the visible daily hand with a different one")
	_assert_eq(game.actions_remaining, 5, "rerolling with a held arcana should not spend an action")


func test_arcana_publish_effects_are_consumed_once_and_pay_their_risk() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()
	var meme := {
		"id": "arcana-publish",
		"title": "月面回声",
		"text": "哈吉米，为什么还要追问",
		"tags": ["哈吉米", "追问"],
		"rarity": 1,
		"pollution_bias": 0,
	}
	game.owned_arcana_cards = [{"uid": "held-moon", "id": "moon", "bought_day": 1}]
	_assert_true(game.use_arcana_card("held-moon"), "moon arcana should arm before publishing")
	var preview: Dictionary = game.get_publish_breakdown(meme)
	var contract_risk := int(preview.get("contract_pollution_risk", 0))
	var arcana_risk := int(preview.get("arcana_pollution_risk", 0))
	game.completed_memes = [meme]
	game.place_meme_in_blank("blank_1", "arcana-publish")
	_assert_true(game.confirm_dialogue(), "an arcana-armed meme should publish normally")
	_assert_eq(game.pollution, 4 + 2 * 2 + contract_risk + arcana_risk, "publishing should pay both signal-hand and arcana pollution risks")
	_assert_true(game.pending_arcana_effects.is_empty(), "successful publish should clear one-shot arcana effects")
	var next_preview: Dictionary = game.get_publish_breakdown(meme)
	_assert_eq(float(next_preview.get("arcana_multiplier", 1.0)), 1.0, "consumed arcana multiplier should not leak into later publishes")


func test_tower_hermit_and_hanged_arcana_cover_the_other_build_paths() -> void:
	var meme := {
		"id": "arcana-paths",
		"title": "未成立样本",
		"text": "路面一直向后移动",
		"tags": ["沉默"],
		"rarity": 1,
		"pollution_bias": 0,
	}

	var tower_game: RefCounted = _state_script.new()
	tower_game.new_run()
	tower_game.owned_arcana_cards = [{"uid": "held-tower", "id": "tower", "bought_day": 1}]
	_assert_true(tower_game.use_arcana_card("held-tower"), "tower arcana should arm without a target meme")
	var tower_preview: Dictionary = tower_game.get_publish_breakdown(meme)
	_assert_true(bool(tower_preview.get("contract_matched", false)), "tower arcana should force an otherwise incomplete signal hand")
	_assert_true(bool(tower_preview.get("arcana_force_contract", false)), "forced hand preview should identify the tower override")

	var hermit_game: RefCounted = _state_script.new()
	hermit_game.new_run()
	hermit_game.published_memes = [{"text": meme["text"], "score": 20, "floor": 1}]
	var repeated_preview: Dictionary = hermit_game.get_publish_breakdown(meme)
	hermit_game.owned_arcana_cards = [{"uid": "held-hermit", "id": "hermit", "bought_day": 1}]
	_assert_true(hermit_game.use_arcana_card("held-hermit"), "hermit arcana should arm repeat relief")
	var relieved_preview: Dictionary = hermit_game.get_publish_breakdown(meme)
	_assert_true(float(relieved_preview.get("repeat_multiplier", 0.0)) > float(repeated_preview.get("repeat_multiplier", 0.0)), "hermit arcana should reduce repeat decay")
	_assert_eq(int(relieved_preview.get("effective_repeat_count", -1)), 0, "one hermit should forgive one previous use")

	var hanged_game: RefCounted = _state_script.new()
	hanged_game.new_run()
	var plain_preview: Dictionary = hanged_game.get_publish_breakdown(meme)
	hanged_game.owned_arcana_cards = [{"uid": "held-hanged", "id": "hanged", "bought_day": 1}]
	_assert_true(hanged_game.use_arcana_card("held-hanged"), "hanged arcana should trade clarity for propagation base")
	var sacrificed_preview: Dictionary = hanged_game.get_publish_breakdown(meme)
	_assert_eq(hanged_game.clarity, 92, "hanged arcana should immediately remove eight clarity")
	_assert_eq(int(sacrificed_preview.get("base_value", 0)), int(plain_preview.get("base_value", 0)) + 24, "hanged arcana should add exactly twenty-four propagation base")


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
	game.heat = 220
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
