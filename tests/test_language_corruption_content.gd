extends SceneTree

var _failures: Array[String] = []
var _content_script: Script = null


func _init() -> void:
	_content_script = load("res://scripts/narrative/language_corruption_content.gd") as Script
	_assert_true(_content_script != null, "language corruption content script should load")
	if _content_script != null:
		test_reality_dialogue_shape_and_counts()
		test_existing_choice_ids_are_preserved_exactly()
		test_shared_language_persona_lines_are_exact_and_ordered()
		test_authored_corruptions_and_protected_texts()
		test_player_choice_fragments_progress_by_floor()
		test_history_revision_schema_is_view_only_content()
		test_floor_cards_match_required_copy_exactly()
		test_menu_variants_keep_four_stable_functions()
		test_catalog_contains_no_removed_transaction_language()
		test_public_accessors_return_defensive_copies()
	if _failures.is_empty():
		print("language corruption content tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func test_reality_dialogue_shape_and_counts() -> void:
	var expected_counts := {1: 5, 2: 4, 3: 3}
	var line_ids: Array[String] = []
	for floor_number in [1, 2, 3]:
		var entries: Array = _content_script.get_dialogues_for_floor(floor_number)
		_assert_eq(entries.size(), expected_counts[floor_number], "floor %d should preserve its dialogue catalog count" % floor_number)
		for entry: Dictionary in entries:
			var line_id := str(entry.get("line_id", ""))
			_assert_true(not line_id.is_empty(), "every opening dialogue should have a stable line_id")
			_assert_true(not line_id in line_ids, "opening dialogue line_ids should be unique")
			line_ids.append(line_id)
			_assert_true(not str(entry.get("speaker_id", "")).is_empty(), "every opening should identify its voice")
			_assert_true(not str(entry.get("line", "")).is_empty(), "every opening should contain spoken text")
			_assert_true(not str(entry.get("result", "")).is_empty(), "every opening should contain a concrete response beat")
			_assert_true(not str(entry.get("subtext", "")).is_empty(), "every opening should document its subtext")
			_assert_choice_triplet(entry.get("choices", []), "opening %s" % line_id)

	for archetype_index in range(5):
		var followup: Dictionary = _content_script.get_followups_for_archetype(archetype_index)
		_assert_true(not followup.is_empty(), "each of the five existing archetypes should retain follow-ups")
		var turns: Array = followup.get("turns", [])
		_assert_eq(turns.size(), 2, "each archetype should retain exactly two follow-up turns")
		for turn: Dictionary in turns:
			var line_id := str(turn.get("line_id", ""))
			_assert_true(not line_id.is_empty(), "every follow-up should have a stable line_id")
			_assert_true(not line_id in line_ids, "follow-up line_ids should be unique")
			line_ids.append(line_id)
			_assert_choice_triplet(turn.get("choices", []), "follow-up %s" % line_id)


func test_existing_choice_ids_are_preserved_exactly() -> void:
	var expected: Array[String] = [
		"f1n0_wait", "f1n0_time", "f1n0_leave",
		"f1n1_home", "f1n1_pipe", "f1n1_name",
		"f1n2_count", "f1n2_blank", "f1n2_stop",
		"f1n3_sky", "f1n3_receipt", "f1n3_ground",
		"f1n4_yes", "f1n4_no", "f1n4_reply",
		"f2n0_order", "f2n0_reason", "f2n0_refuse",
		"f2n1_lock", "f2n1_follow", "f2n1_return",
		"f2n2_again", "f2n2_record", "f2n2_stamp",
		"f2n3_name", "f2n3_legacy", "f2n3_none",
		"f3n0_submit", "f3n0_copy", "f3n0_window",
		"f3n1_actual", "f3n1_metaphor", "f3n1_nohome",
		"f3n2_self", "f3n2_missing", "f3n2_drawer",
		"late_signal_wait", "late_signal_tower", "late_signal_walk",
		"late_stop_today", "late_stop_silence", "late_stop_own",
		"echo_keep_original", "echo_mark_legacy", "echo_close_pipe",
		"echo_check_reflection", "echo_try_name", "echo_leave_nameless",
		"copy_source_now", "copy_refuse_source", "copy_mark_pollution",
		"copy_no_stamp", "copy_edge_stamp", "copy_rewrite_rule",
		"believer_crowd", "believer_legacy", "believer_static",
		"believer_question", "believer_names", "believer_pause",
		"post_earliest", "post_unsent", "post_close",
		"post_leave_exist", "post_leave_signal", "post_leave_nothing",
	]
	var actual: Array[String] = _content_script.get_all_choice_ids()
	expected.sort()
	actual.sort()
	_assert_eq(actual.size(), 66, "the rewritten catalog should retain all 66 existing choice IDs")
	_assert_eq(actual, expected, "rewriting text must not add, remove, or rename an existing choice ID")


func test_shared_language_persona_lines_are_exact_and_ordered() -> void:
	const SAFE_LINE := "我只是想让你留在安全的地方。"
	const VOICE_LINE := "你不需要再听见那个声音。"
	var scenes: Array = _content_script.get_language_persona_scenes()
	var safe_speakers: Array[String] = []
	var voice_speakers: Array[String] = []
	for scene: Dictionary in scenes:
		var line := str(scene.get("line", ""))
		if line == SAFE_LINE:
			safe_speakers.append(str(scene.get("speaker", "")))
		if line == VOICE_LINE:
			voice_speakers.append(str(scene.get("speaker", "")))
	_assert_true(safe_speakers.size() >= 2, "the safe-place sentence should recur in the mainline")
	_assert_true(voice_speakers.size() >= 2, "the voice sentence should recur in the mainline")
	if safe_speakers.size() >= 2:
		_assert_eq(safe_speakers[0], "玩偶", "the doll must own the safe-place sentence first")
		_assert_eq(safe_speakers[1], "医生", "the doctor must repeat the safe-place sentence second")
	if voice_speakers.size() >= 2:
		_assert_eq(voice_speakers[0], "医生", "the doctor must own the voice sentence first")
		_assert_eq(voice_speakers[1], "玩偶", "the doll must repeat the voice sentence second")


func test_authored_corruptions_and_protected_texts() -> void:
	const SAFE_LINE := "我只是想让你留在安全的地方。"
	const VOICE_LINE := "你不需要再听见那个声音。"
	var protected: Array = _content_script.get_protected_texts()
	_assert_true(SAFE_LINE in protected, "the exact safe-place sentence should be protected from random garble")
	_assert_true(VOICE_LINE in protected, "the exact voice sentence should be protected from random garble")
	for speaker_name in ["玩偶", "医生", "主角"]:
		_assert_true(speaker_name in protected, "%s should be protected from random garble" % speaker_name)

	var corruptions: Array = _content_script.get_authored_critical_corruptions()
	_assert_true(corruptions.size() >= 5, "critical semantic changes should be authored rather than generated")
	for corruption: Dictionary in corruptions:
		_assert_true(not str(corruption.get("corruption_id", "")).is_empty(), "each authored corruption needs a stable ID")
		_assert_true(not str(corruption.get("source_line_id", "")).is_empty(), "each authored corruption needs a source line")
		_assert_true(not str(corruption.get("clean_text", "")).is_empty(), "each authored corruption needs clean text")
		var display_text := str(corruption.get("display_text", ""))
		_assert_true(display_text.contains("{del}") and display_text.contains("{ins}"), "critical revisions should explicitly mark deletion and insertion")
		_assert_eq(display_text.count("{del}"), display_text.count("{/del}"), "deletion markup should be balanced")
		_assert_eq(display_text.count("{ins}"), display_text.count("{/ins}"), "insertion markup should be balanced")


func test_player_choice_fragments_progress_by_floor() -> void:
	for floor_number in [1, 2, 3]:
		var variants: Array = _content_script.get_player_choice_fragments_for_floor(floor_number)
		_assert_eq(variants.size(), 3, "each floor should author approach, check, and refusal displays")
		var intents: Array[String] = []
		for variant: Dictionary in variants:
			intents.append(str(variant.get("intent", "")))
			_assert_eq(int(variant.get("revision_stage", -1)), floor_number - 1, "choice fragmentation should progress one authored stage per floor")
			_assert_true(not str(variant.get("display_text", "")).is_empty(), "fragmented choice display should remain readable")
			_assert_true(not Array(variant.get("tiles", [])).is_empty(), "fragmented choice display should provide puzzle tiles")
		intents.sort()
		_assert_eq(intents, ["approach", "check", "refuse"], "each floor should preserve the three player intentions")
	var floor_one_text := JSON.stringify(_content_script.get_player_choice_fragments_for_floor(1))
	var floor_three_text := JSON.stringify(_content_script.get_player_choice_fragments_for_floor(3))
	_assert_true(not floor_one_text.contains(" / "), "floor one choices should still read as complete speech")
	_assert_true(floor_three_text.contains(" / "), "floor three choices should visibly break into incomplete units")


func test_history_revision_schema_is_view_only_content() -> void:
	var required_fields := [
		"lineId", "originalSpeaker", "currentSpeaker", "originalText",
		"displayText", "revisionStage", "revisionMarkup",
	]
	var revisions: Array = _content_script.get_history_revisions()
	_assert_true(not revisions.is_empty(), "the content catalog should provide authored history revisions")
	for revision: Dictionary in revisions:
		for field_name in required_fields:
			_assert_true(revision.has(field_name), "history revision should include %s" % field_name)
		var display_text := str(revision.get("displayText", ""))
		_assert_true(not display_text.contains("[b]") and not display_text.contains("[color"), "history should use only the two approved revision emphasis tags")
		_assert_true(not revision.has("reward") and not revision.has("unlock"), "history data must not grant progress")


func test_floor_cards_match_required_copy_exactly() -> void:
	var expected := {
		1: {"区域": "被保存的儿童房", "危险": "B", "提示": "《游戏与现实》"},
		2: {"区域": "两次醒来之间", "危险": "A", "提示": "《梦的解析》"},
		3: {"区域": "没有说完的地方", "危险": "A", "提示": "《自我与本我》"},
		4: {"区域": "未记录", "危险": "S", "提示": "《超越快乐原则》"},
	}
	for floor_number in [1, 2, 3, 4]:
		var card: Dictionary = _content_script.get_floor_card(floor_number)
		_assert_eq(card.size(), 3, "floor cards should contain exactly area, danger, and hint")
		_assert_eq(card, expected[floor_number], "floor %d card copy should match the approved text exactly" % floor_number)
		var display_card: Dictionary = _content_script.get_floor_card_display(floor_number)
		_assert_eq(str(display_card.get("危险", "")), str(expected[floor_number]["危险"]), "danger rank must remain readable after corruption")
		_assert_true(str(display_card.get("区域", "")).contains("□") or str(display_card.get("提示", "")).contains("□"), "floor %d display card should contain authored garble" % floor_number)


func test_menu_variants_keep_four_stable_functions() -> void:
	var variants: Dictionary = _content_script.get_menu_label_variants()
	var keys: Array = variants.keys()
	keys.sort()
	_assert_eq(keys, ["autoplay", "history", "save", "settings"], "only the four approved menu labels should receive polluted display variants")
	for function_id in keys:
		var entry: Dictionary = variants[function_id]
		_assert_eq(str(entry.get("function_id", "")), str(function_id), "a display variant must preserve its functional command")
		_assert_eq(Array(entry.get("stages", [])).size(), 3, "each menu function should have three authored display stages")


func test_catalog_contains_no_removed_transaction_language() -> void:
	var serialized := JSON.stringify(_content_script.get_catalog_snapshot()).to_lower()
	for removed_term in ["merchant", "shop", "价格"]:
		_assert_true(not serialized.contains(removed_term), "content catalog should not retain removed transaction term: %s" % removed_term)


func test_public_accessors_return_defensive_copies() -> void:
	var floor_one: Array = _content_script.get_dialogues_for_floor(1)
	var original_line := str(floor_one[0].get("line", ""))
	floor_one[0]["line"] = "被测试修改"
	_assert_eq(str(_content_script.get_dialogues_for_floor(1)[0].get("line", "")), original_line, "callers should not mutate the static dialogue catalog")

	var menu: Dictionary = _content_script.get_menu_label_variants()
	menu["save"]["stages"][0] = "被测试修改"
	_assert_eq(str(_content_script.get_menu_label_variants()["save"]["stages"][0]), "保存", "menu variants should also be returned as defensive copies")


func _assert_choice_triplet(value: Variant, context: String) -> void:
	var choices: Array = value
	_assert_eq(choices.size(), 3, "%s should preserve exactly three choices" % context)
	for choice: Dictionary in choices:
		_assert_true(not str(choice.get("id", "")).is_empty(), "%s choice should retain a stable ID" % context)
		_assert_true(str(choice.get("intent", "")) in ["approach", "check", "refuse"], "%s choice should expose player intent" % context)
		_assert_true(not str(choice.get("sentence", "")).is_empty(), "%s choice should contain authored speech" % context)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
