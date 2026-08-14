extends SceneTree

const LocaleScript = preload("res://scripts/localization/game_locale.gd")

var _failures: Array[String] = []


func _init() -> void:
	_test_level_display_names()
	_test_floor_number_clamping()
	_test_dynamic_level_translation()
	if _failures.is_empty():
		print("level display name tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _test_level_display_names() -> void:
	var locale = LocaleScript.new()
	var expected := {
		"zh": ["第一层", "第二层", "第三层", "第四层"],
		"en": ["LEVEL 1", "LEVEL 2", "LEVEL 3", "LEVEL 4"],
		"ja": ["レベル1", "レベル2", "レベル3", "レベル4"],
	}
	for locale_code in ["zh", "en", "ja"]:
		locale.current_locale = locale_code
		for floor_number in range(1, 5):
			_assert_eq(
				locale.level_display_name(floor_number),
				expected[locale_code][floor_number - 1],
				"%s floor %d should use the canonical level name" % [locale_code, floor_number]
			)


func _test_floor_number_clamping() -> void:
	var locale = LocaleScript.new()
	locale.current_locale = "zh"
	_assert_eq(locale.level_display_name(-10), "第一层", "floor numbers below 1 should clamp to level 1")
	_assert_eq(locale.level_display_name(0), "第一层", "floor zero should clamp to level 1")
	locale.current_locale = "en"
	_assert_eq(locale.level_display_name(5), "LEVEL 4", "floor numbers above 4 should clamp to level 4")
	locale.current_locale = "ja"
	_assert_eq(locale.level_display_name(99), "レベル4", "large floor numbers should clamp to level 4")


func _test_dynamic_level_translation() -> void:
	var locale = LocaleScript.new()
	var source_forms := [
		["第 1 层 / 3", 1],
		["FLOOR 2 / 3", 2],
		["第3階 / 3", 3],
		["塔层 4/5", 4],
	]
	var expected := {
		"zh": ["第一层", "第二层", "第三层", "第四层"],
		"en": ["LEVEL 1", "LEVEL 2", "LEVEL 3", "LEVEL 4"],
		"ja": ["レベル1", "レベル2", "レベル3", "レベル4"],
	}
	for locale_code in ["zh", "en", "ja"]:
		locale.current_locale = locale_code
		for index in source_forms.size():
			var translated: String = locale.translate(str(source_forms[index][0]))
			_assert_eq(
				translated,
				expected[locale_code][index],
				"%s should normalize legacy level display %s" % [locale_code, source_forms[index][0]]
			)
			_assert_true(not translated.contains("AREA"), "canonical level displays must never produce AREA")


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
