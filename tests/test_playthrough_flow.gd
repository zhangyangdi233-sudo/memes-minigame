extends SceneTree

var _failures: Array[String] = []
var _state_script: Script = null


func _init() -> void:
	_run()
	if _failures.is_empty():
		print("playthrough flow tests passed")
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
	test_five_action_phone_day_creates_next_day_legacy_reality_prompt()


func test_five_action_phone_day_creates_next_day_legacy_reality_prompt() -> void:
	var game: RefCounted = _state_script.new()
	game.new_run()

	_assert_true(game.pick_token("d1_a", {"id": "hajimi", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1}), "first action should pick object token")
	_assert_true(game.pick_token("d1_a", {"id": "meaning", "text": "到底是什么意思", "tags": ["追问"], "rarity": 1}), "second action should pick saying token")
	_assert_true(game.buy_daily_emotion_slot(), "third action should buy the daily emotion slot")
	var emotion_slot_id := str(game.daily_emotion_slot_id)
	game.set_emotion_slot_text(emotion_slot_id, "我不是那个意思")
	_assert_eq(game.actions_remaining, 2, "editing emotion slot should not spend an action")

	game.place_token_in_slot("object", "d1_a-hajimi-1")
	game.place_token_in_slot("saying", "d1_a-meaning-1")
	_assert_true(game.confirm_craft_with_emotions(), "fourth action should craft a completed meme")
	_assert_eq(game.completed_memes.size(), 1, "crafted meme should exist before publishing")
	game.place_meme_in_blank("blank_1", str(game.completed_memes[0]["id"]))
	_assert_true(game.confirm_dialogue(), "fifth action should publish the meme")
	_assert_eq(game.actions_remaining, 0, "publishing should deplete all five daily actions")
	_assert_true(game.needs_day_settlement, "fifth action should request automatic day settlement")
	_assert_true(game.settle_day_if_needed(), "settlement should run after the fifth action")

	_assert_eq(game.day, 2, "settlement should advance to day two")
	_assert_eq(game.actions_remaining, 5, "new day should restore five actions")
	_assert_eq(game.tower_floor, 2, "strong first-day post should raise the tower to floor two")
	_assert_eq(game.legacy_rules.size(), 1, "ascent should convert previous floor hot meme into a legacy rule")
	_assert_true(str(game.legacy_rules[0]["required_text"]).contains("哈吉米"), "legacy rule should preserve the published meme language")
	_assert_eq(game.get_pending_ascent_reward_choices().size(), 3, "reaching floor two should pause on a three-choice permanent reward")
	_assert_true(not game.spend_action("blocked-before-reward"), "effective actions should wait until the ascent reward is chosen")
	var reward_id := str(game.get_pending_ascent_reward_choices()[0].get("id", ""))
	_assert_true(game.choose_ascent_reward(reward_id), "the playthrough should choose one ascent reward before continuing")
	_assert_eq(game.actions_remaining, 5, "choosing the reward should not spend an action")

	game.place_reality_tile("slot_0", "clean:我")
	game.place_reality_tile("slot_1", "clean:想")
	_assert_true(not game.confirm_reality_dialogue(), "reality dialogue should reject a sentence missing the legacy tile")
	_assert_eq(game.actions_remaining, 5, "failed reality sentence should not spend an action")
	game.place_reality_tile("slot_2", "legacy:%s" % game.legacy_rules[0]["id"])
	_assert_true(game.confirm_reality_dialogue(), "reality dialogue should accept a sentence containing the legacy tile")
	_assert_eq(game.actions_remaining, 4, "confirmed reality dialogue should spend one action")
	_assert_true(game.last_clean_sentence.contains(str(game.legacy_rules[0]["required_text"])), "accepted clean sentence should include legacy text")


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s. Expected %s, got %s" % [message, str(expected), str(actual)])
