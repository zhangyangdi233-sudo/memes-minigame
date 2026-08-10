extends SceneTree

const LanguageBridgeScript = preload("res://scripts/narrative/language_bridge.gd")

var _failures: Array[String] = []


func _init() -> void:
	test_uncollected_token_cannot_enter_recipe()
	test_missing_slot_and_incompatible_role_fail()
	test_stable_lexeme_has_authored_world_surfaces()
	test_composition_does_not_mutate_original_text()
	test_missing_world_mapping_falls_back_to_original_text()
	test_three_locale_joining_and_punctuation()
	test_mark_tokens_used_returns_a_deep_copy()
	test_content_validation_reports_bad_note_tokens()
	if _failures.is_empty():
		print("language bridge tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func test_uncollected_token_cannot_enter_recipe() -> void:
	var tokens := _complete_tokens()
	var result: Dictionary = LanguageBridgeScript.validate_recipe({
		"subject": "subject-1",
		"action": "action-1",
		"object": "not-collected",
	}, tokens)
	_assert_true(not bool(result.get("valid", true)), "a token ID outside the collected token array must fail")
	_assert_true("unknown_token:object:not-collected" in result.get("errors", []), "the missing inventory token should have a stable error")


func test_missing_slot_and_incompatible_role_fail() -> void:
	var tokens := _complete_tokens()
	var missing: Dictionary = LanguageBridgeScript.validate_recipe({
		"subject": "subject-1",
		"action": "action-1",
	}, tokens)
	_assert_true(not bool(missing.get("valid", true)), "a three-slot recipe cannot omit its object")
	_assert_true("missing_slot:object" in missing.get("errors", []), "the omitted slot should be named")
	_assert_eq(missing.get("ordered_tokens"), [], "an invalid recipe must not expose a partial sentence payload")

	var incompatible: Dictionary = LanguageBridgeScript.validate_recipe({
		"subject": "object-1",
		"action": "action-1",
		"object": "subject-1",
	}, tokens)
	_assert_true(not bool(incompatible.get("valid", true)), "tokens must match the grammar role of their slot")
	_assert_true("incompatible_role:subject:object-1" in incompatible.get("errors", []), "subject role mismatch should be explicit")


func test_stable_lexeme_has_authored_world_surfaces() -> void:
	var tokens := _complete_tokens()
	var slots := _complete_slots()
	var phone: Dictionary = LanguageBridgeScript.compose_sentence(slots, tokens, "phone", "zh")
	var doctor: Dictionary = LanguageBridgeScript.compose_sentence(slots, tokens, "doctor", "zh")
	var doll: Dictionary = LanguageBridgeScript.compose_sentence(slots, tokens, "doll", "zh")
	_assert_eq(phone.get("clean_sentence"), "我看见塔。", "clean composition should always use the original text")
	_assert_eq(phone.get("world_sentence"), "本账号捕获信号塔。", "phone composition should use only phone_surface fields")
	_assert_eq(doctor.get("world_sentence"), "患者报告病区。", "doctor composition should use only doctor_surface fields")
	_assert_eq(doll.get("world_sentence"), "你记得出口。", "doll composition should use only doll_surface fields")
	_assert_eq(phone.get("lexeme_ids"), ["speaker.self", "perceive.see", "place.tower"], "all worlds should retain the same stable lexeme IDs")


func test_composition_does_not_mutate_original_text() -> void:
	var tokens := _complete_tokens()
	var snapshot: Array = tokens.duplicate(true)
	LanguageBridgeScript.normalized_token(tokens[0])
	LanguageBridgeScript.compose_sentence(_complete_slots(), tokens, "doctor", "ja")
	LanguageBridgeScript.mark_tokens_used(tokens, ["subject-1"], "doctor")
	_assert_eq(tokens, snapshot, "normalizing, composing, and marking must leave the input token array untouched")
	_assert_eq(tokens[0].get("text"), "我", "the authored original text must never be rewritten")


func test_missing_world_mapping_falls_back_to_original_text() -> void:
	var tokens := _complete_tokens()
	tokens[1].erase("doctor_surface")
	tokens[2]["doctor_surface"] = ""
	_assert_eq(LanguageBridgeScript.token_surface(tokens[1], "doctor"), "看见", "a missing doctor mapping should fall back to original text")
	var result: Dictionary = LanguageBridgeScript.compose_sentence(_complete_slots(), tokens, "doctor", "zh-CN")
	_assert_eq(result.get("world_sentence"), "患者看见塔。", "fallback must not invent or randomly append any word")


func test_three_locale_joining_and_punctuation() -> void:
	var tokens := _complete_tokens()
	var slots := _complete_slots()
	_assert_eq(LanguageBridgeScript.compose_sentence(slots, tokens, "clean", "zh-CN").get("clean_sentence"), "我看见塔。", "Chinese should join without spaces and use a full-width period")
	_assert_eq(LanguageBridgeScript.compose_sentence(slots, tokens, "clean", "ja-JP").get("clean_sentence"), "我看见塔。", "Japanese should join without spaces and use a full-width period")
	_assert_eq(LanguageBridgeScript.compose_sentence(slots, tokens, "clean", "en-US").get("clean_sentence"), "我 看见 塔.", "English should join with spaces and use an ASCII period")


func test_mark_tokens_used_returns_a_deep_copy() -> void:
	var tokens := _complete_tokens()
	var marked: Array = LanguageBridgeScript.mark_tokens_used(tokens, ["subject-1", "object-1"], "doctor")
	_assert_true(marked != tokens, "marking should change selected copies")
	_assert_eq(marked[0].get("pollution_stage"), 2, "a selected token should advance one pollution stage")
	_assert_eq(marked[0].get("use_count"), 1, "a selected token should record one use")
	_assert_eq(marked[0].get("last_used_world"), "doctor", "a selected token should remember the authored target world")
	_assert_eq(marked[1].get("pollution_stage"), 0, "an unselected token should retain its pollution stage")
	marked[0]["grammar_roles"].append("object")
	_assert_eq(tokens[0].get("grammar_roles"), ["subject"], "nested arrays must also be deep-copied")
	_assert_true(not tokens[0].has("use_count"), "usage metadata must not leak into the input token")


func test_content_validation_reports_bad_note_tokens() -> void:
	var valid: Dictionary = LanguageBridgeScript.validate_content(_complete_tokens())
	_assert_true(bool(valid.get("valid", false)), "complete authored NoteTokens should pass content validation")
	var malformed := _token("bad", "", "", ["noise"], "", "", "", 0)
	var invalid: Dictionary = LanguageBridgeScript.validate_content([malformed])
	_assert_true(not bool(invalid.get("valid", true)), "missing content and unknown roles should fail validation")
	_assert_true("token[0].missing:text" in invalid.get("errors", []), "content validation should identify missing text")
	_assert_true("token[0].missing:lexeme_id" in invalid.get("errors", []), "content validation should identify a missing stable lexeme")
	_assert_true("token[0].unknown_role:noise" in invalid.get("errors", []), "content validation should reject unknown grammar roles")


func _complete_slots() -> Dictionary:
	return {"subject": "subject-1", "action": "action-1", "object": "object-1"}


func _complete_tokens() -> Array:
	return [
		_token("subject-1", "我", "speaker.self", ["subject"], "本账号", "患者", "你", 1),
		_token("action-1", "看见", "perceive.see", ["action"], "捕获", "报告", "记得", 0),
		_token("object-1", "塔", "place.tower", ["object"], "信号塔", "病区", "出口", 2),
	]


func _token(
	token_id: String,
	text: String,
	lexeme_id: String,
	grammar_roles: Array,
	phone_surface: String,
	doctor_surface: String,
	doll_surface: String,
	pollution_stage: int
) -> Dictionary:
	return {
		"id": token_id,
		"text": text,
		"lexeme_id": lexeme_id,
		"grammar_roles": grammar_roles,
		"phone_surface": phone_surface,
		"doctor_surface": doctor_surface,
		"doll_surface": doll_surface,
		"pollution_stage": pollution_stage,
	}


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
