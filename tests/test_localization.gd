extends SceneTree

const LocaleScript = preload("res://scripts/localization/game_locale.gd")
const StateScript = preload("res://scripts/meme_game_state.gd")
const UICatalogScript = preload("res://scripts/localization/ui_catalog.gd")
const StateCatalogScript = preload("res://scripts/localization/state_catalog.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_async")


func _run_async() -> void:
	await _run()
	if _failures.is_empty():
		print("localization tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	_test_catalog_coverage_and_dynamic_templates()
	_test_all_script_literals_have_translations()
	_test_language_specific_pickup_units()
	_test_english_reality_dialogue_uses_words()
	await _test_language_selection_and_settings_ui()


func _test_catalog_coverage_and_dynamic_templates() -> void:
	var ui_catalog = UICatalogScript.new()
	var state_catalog = StateCatalogScript.new()
	var ui_en: Dictionary = ui_catalog.entries("en")
	var ui_ja: Dictionary = ui_catalog.entries("ja")
	var state_en: Dictionary = state_catalog.entries("en")
	var state_ja: Dictionary = state_catalog.entries("ja")
	_assert_true(ui_en.size() >= 300 and ui_en.size() == ui_ja.size(), "UI catalog should contain matching English and Japanese coverage")
	_assert_true(state_en.size() >= 315 and state_en.size() == state_ja.size(), "state catalog should contain matching English and Japanese coverage")

	var locale = LocaleScript.new()
	locale.set_locale("en")
	_assert_eq(locale.translate("继续游戏"), "Continue", "English should translate static menu text")
	_assert_eq(locale.translate("污染 47%"), "CORRUPTION 47%", "English should translate formatted HUD values")
	_assert_eq(locale.translate("关系残留 23 / 100  ·  仍能认出你"), "RELATIONSHIP RESIDUE 23 / 100  ·  They can still recognize you", "dynamic templates should recursively translate nested state labels")
	for value in ui_en.values():
		_assert_true(not locale.has_untranslated_han(str(value)), "English UI catalog values should not retain Han characters: %s" % str(value))
	for value in state_en.values():
		_assert_true(not locale.has_untranslated_han(str(value)), "English state catalog values should not retain Han characters: %s" % str(value))
	locale.set_locale("ja")
	_assert_eq(locale.translate("继续游戏"), "つづきから", "Japanese should translate static menu text naturally")
	locale.set_locale("zh")
	_assert_eq(locale.translate("继续游戏"), "继续游戏", "Chinese should remain the source language")


func _test_all_script_literals_have_translations() -> void:
	var locale = LocaleScript.new()
	locale.set_locale("en")
	var literal_regex := RegEx.new()
	literal_regex.compile("\"((?:\\\\.|[^\"\\\\])*)\"")
	var han_regex := RegEx.new()
	han_regex.compile("[\\x{3400}-\\x{9FFF}]")
	var missing: Array[String] = []
	for path in [
		"res://scripts/babel_meme_game.gd",
		"res://scripts/meme_game_state.gd",
		"res://scripts/reality_floor_generator.gd",
	]:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			missing.append("unable to read %s" % path)
			continue
		var source := file.get_as_text()
		for match_result in literal_regex.search_all(source):
			var literal := match_result.get_string(1).c_unescape()
			if han_regex.search(literal) == null:
				continue
			if locale.translate(literal) == literal and literal not in missing:
				missing.append(literal)
	_assert_true(missing.is_empty(), "every Chinese script literal should have an English catalog entry; missing (%d):\n%s" % [missing.size(), "\n".join(missing)])


func _test_language_specific_pickup_units() -> void:
	var locale = LocaleScript.new()
	locale.set_locale("en")
	_assert_eq(locale.first_pickable_unit("不存在的十三层"), "The", "English pickup should select a word rather than one Latin letter")
	locale.set_locale("ja")
	_assert_eq(locale.first_pickable_unit("不存在的十三层"), "存", "Japanese pickup should select a visible character")

	var game = StateScript.new()
	game.new_run()
	_assert_true(game.pick_token("localized-post", {
		"id": "word",
		"text": "nonexistent floor",
		"source_text": "不存在的十三层",
		"content_locale": "en",
		"tags": ["空位"],
		"rarity": 1,
	}), "English token pickup should succeed")
	_assert_eq(str(game.notebook_tokens[0].get("text", "")), "nonexistent", "English notes should store one semantic word")


func _test_english_reality_dialogue_uses_words() -> void:
	var locale = LocaleScript.new()
	locale.set_locale("en")
	var game = StateScript.new()
	game.new_run()
	game.legacy_rules = [{"required_text": "哈吉米，必须补票", "tags": ["哈吉米"]}]
	_assert_true(game.start_typed_reality_conversation("npc_1_npc0", "npc", "Latecomer"), "English reality conversation should start")
	game.conversation_prompt = locale.translate(game.conversation_prompt)
	game.conversation_result_line = locale.translate(game.conversation_result_line)
	var localized_choices: Array = []
	for choice in game.conversation_choices:
		var localized_choice: Dictionary = (choice as Dictionary).duplicate(true)
		localized_choice["summary"] = locale.translate(str(localized_choice.get("summary", "")))
		localized_choice["sentence"] = locale.translate(str(localized_choice.get("sentence", "")))
		localized_choices.append(localized_choice)
	game.conversation_choices = localized_choices
	game.configure_conversation_locale("en", [locale.translate("哈吉米，必须补票")])
	var choice_id := str(game.conversation_choices[0].get("id", ""))
	_assert_true(game.select_typed_reality_choice(choice_id), "localized English choice should enter typing")
	_assert_true(game.get_typed_reality_unit_count() < game.conversation_clean_sentence.length(), "English typing should reveal words instead of individual letters")
	var first_result: Dictionary = game.advance_typed_reality_character()
	_assert_true(bool(first_result.get("advanced", false)), "one input should reveal one English word unit")
	_assert_true(str(game.conversation_revealed_units[0].get("clean", "")).ends_with(" ") or game.get_typed_reality_unit_count() < 12, "the revealed English unit should be a complete word chunk")
	_assert_true(game.conversation_clean_sentence.contains("Hajimi"), "localized legacy text should be inserted into the English sentence")


func _test_language_selection_and_settings_ui() -> void:
	var scene := load("res://scenes/babel_meme_game.tscn") as PackedScene
	_assert_true(scene != null, "main scene should load for localization UI tests")
	if scene == null:
		return
	var game_root = scene.instantiate()
	root.add_child(game_root)
	await process_frame
	game_root._locale.preferences_path = "user://test_babel_meme_preferences.cfg"
	_assert_true(game_root.has_method("_build_language_selection_overlay"), "main scene should expose the language selection surface")
	game_root._build_language_selection_overlay(true)
	await process_frame
	var overlay := game_root._language_overlay as Control
	_assert_true(overlay != null and is_instance_valid(overlay) and overlay.visible, "first-run language selection should cover the main menu")
	_assert_true(_find_node_by_name(game_root, "LanguageChoiceZH") != null, "language selection should offer Chinese")
	_assert_true(_find_node_by_name(game_root, "LanguageChoiceJA") != null, "language selection should offer Japanese")
	_assert_true(_find_node_by_name(game_root, "LanguageChoiceEN") != null, "language selection should offer English")
	game_root._on_language_selected("en")
	await process_frame
	var continue_button := _find_node_by_name(game_root, "MainMenuContinueButton") as Button
	_assert_true(continue_button != null and continue_button.text == "Continue", "choosing English should rebuild the main menu in English")
	game_root.new_game()
	await process_frame
	var language_option := _find_node_by_name(game_root, "SettingsLanguageOption") as OptionButton
	var manual_save := _find_node_by_name(game_root, "SettingsManualSaveButton") as Button
	_assert_true(language_option != null, "settings should expose an in-game language switcher")
	_assert_true(manual_save != null, "settings should expose manual save")
	game_root.game.pollution = 60
	_assert_eq(game_root._corrupt("I want to speak normally."), "□ want to speak □", "English corruption should replace complete words instead of shredding letters")
	game_root.queue_free()
	await process_frame


func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found := _find_node_by_name(child, target_name)
		if found != null:
			return found
	return null


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
