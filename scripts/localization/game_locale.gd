class_name BabelGameLocale
extends RefCounted

const PREFERENCES_PATH := "user://babel_meme_preferences.cfg"
const SUPPORTED_LOCALES := ["zh", "ja", "en"]
const CATALOG_PATHS := [
	"res://scripts/localization/ui_catalog.gd",
	"res://scripts/localization/state_catalog.gd",
]

var current_locale := "zh"
var language_selected := false
var preferences_path := PREFERENCES_PATH
var _entries: Dictionary = {}
var _compiled_templates: Array[Dictionary] = []
var _compiled_patterns: Array[Dictionary] = []


func load_preferences(default_volume: float, default_vhs: bool) -> Dictionary:
	var result := {
		"master_volume": default_volume,
		"vhs_enabled": default_vhs,
	}
	var config := ConfigFile.new()
	if config.load(preferences_path) != OK:
		_set_locale_internal("zh")
		return result
	language_selected = bool(config.get_value("language", "selected", false))
	_set_locale_internal(str(config.get_value("language", "locale", "zh")))
	result["master_volume"] = clampf(float(config.get_value("audio", "master_volume", default_volume)), 0.0, 100.0)
	result["vhs_enabled"] = bool(config.get_value("visual", "vhs_enabled", default_vhs))
	return result


func save_preferences(master_volume: float, vhs_enabled: bool) -> bool:
	var config := ConfigFile.new()
	config.set_value("language", "selected", language_selected)
	config.set_value("language", "locale", current_locale)
	config.set_value("audio", "master_volume", clampf(master_volume, 0.0, 100.0))
	config.set_value("visual", "vhs_enabled", vhs_enabled)
	return config.save(preferences_path) == OK


func select_language(locale_code: String) -> bool:
	var normalized := normalize_locale(locale_code)
	if normalized not in SUPPORTED_LOCALES:
		return false
	language_selected = true
	_set_locale_internal(normalized)
	return true


func set_locale(locale_code: String) -> bool:
	var normalized := normalize_locale(locale_code)
	if normalized not in SUPPORTED_LOCALES:
		return false
	_set_locale_internal(normalized)
	return true


func normalize_locale(locale_code: String) -> String:
	var lowered := locale_code.to_lower().replace("-", "_")
	if lowered.begins_with("ja"):
		return "ja"
	if lowered.begins_with("en"):
		return "en"
	return "zh"


func native_language_name(locale_code: String) -> String:
	match normalize_locale(locale_code):
		"ja":
			return "日本語"
		"en":
			return "English"
		_:
			return "中文"


func translate(source: String) -> String:
	if current_locale == "zh" or source.is_empty():
		return source
	if _entries.has(source):
		return str(_entries[source])
	for template_data in _compiled_templates:
		var template_regex := template_data["regex"] as RegEx
		var template_match := template_regex.search(source)
		if template_match == null:
			continue
		var arguments: Array = []
		var specifiers: Array = template_data["specifiers"]
		for capture_index in specifiers.size():
			var captured := template_match.get_string(capture_index + 1)
			arguments.append(int(captured) if str(specifiers[capture_index]).ends_with("d") else translate(captured))
		return str(template_data["translation"]) % arguments
	for pattern_data in _compiled_patterns:
		var regex := pattern_data["regex"] as RegEx
		if regex.search(source) != null:
			return regex.sub(source, str(pattern_data["replacement"]), true)
	if source.contains("\n"):
		var localized_lines: Array[String] = []
		for line in source.split("\n", true):
			localized_lines.append(translate(line))
		return "\n".join(localized_lines)
	return source


func translate_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(translate(str(value)))
	return result


func first_pickable_unit(source: String) -> String:
	var localized := translate(source).strip_edges()
	if localized.is_empty():
		return ""
	if current_locale == "en":
		var word_regex := RegEx.new()
		word_regex.compile("[A-Za-z0-9']+")
		var match_result := word_regex.search(localized)
		return match_result.get_string() if match_result != null else localized
	for index in localized.length():
		var character := localized.substr(index, 1)
		if not character.strip_edges().is_empty() and character not in ["，", "。", "！", "？", "、", "「", "」", "『", "』"]:
			return character
	return ""


func has_untranslated_han(text: String) -> bool:
	if current_locale != "en":
		return false
	var regex := RegEx.new()
	regex.compile("[\\x{3400}-\\x{9FFF}]")
	return regex.search(text) != null


func _set_locale_internal(locale_code: String) -> void:
	current_locale = normalize_locale(locale_code)
	TranslationServer.set_locale(current_locale)
	_reload_catalog()


func _reload_catalog() -> void:
	_entries.clear()
	for path in CATALOG_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var catalog_script: Variant = load(path)
		if catalog_script == null:
			continue
		var catalog: Variant = catalog_script.new()
		if catalog == null or not catalog.has_method("entries"):
			continue
		var catalog_entries: Variant = catalog.entries(current_locale)
		if catalog_entries is Dictionary:
			_entries.merge(catalog_entries, true)
	_compile_catalog_templates()
	_compile_patterns()


func _compile_catalog_templates() -> void:
	_compiled_templates.clear()
	var source_templates: Array = []
	for source in _entries.keys():
		var source_text := str(source)
		if source_text.contains("%s") or source_text.contains("%d") or source_text.contains("%02d"):
			source_templates.append(source_text)
	source_templates.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
	for source_text in source_templates:
		var compiled := _compile_format_template(source_text)
		if compiled.is_empty():
			continue
		compiled["translation"] = str(_entries[source_text])
		_compiled_templates.append(compiled)


func _compile_format_template(template: String) -> Dictionary:
	var pattern := "^"
	var specifiers: Array[String] = []
	var index := 0
	while index < template.length():
		if template.substr(index, 4) == "%02d":
			pattern += "(-?[0-9]+)"
			specifiers.append("%02d")
			index += 4
			continue
		if template.substr(index, 2) == "%d":
			pattern += "(-?[0-9]+)"
			specifiers.append("%d")
			index += 2
			continue
		if template.substr(index, 2) == "%s":
			pattern += "(.+?)"
			specifiers.append("%s")
			index += 2
			continue
		if template.substr(index, 2) == "%%":
			pattern += "%"
			index += 2
			continue
		pattern += _escape_regex_character(template.substr(index, 1))
		index += 1
	pattern += "$"
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return {}
	return {"regex": regex, "specifiers": specifiers}


func _escape_regex_character(character: String) -> String:
	if character in ["\\", ".", "^", "$", "|", "?", "*", "+", "(", ")", "[", "]", "{", "}"]:
		return "\\" + character
	return character


func _compile_patterns() -> void:
	_compiled_patterns.clear()
	var patterns: Array = _dynamic_patterns().get(current_locale, [])
	for pattern_data in patterns:
		var regex := RegEx.new()
		if regex.compile(str(pattern_data.get("pattern", ""))) != OK:
			continue
		_compiled_patterns.append({
			"regex": regex,
			"replacement": str(pattern_data.get("replacement", "")),
		})


func _dynamic_patterns() -> Dictionary:
	return {
		"ja": [
			{"pattern": "^DAY ([0-9]+)$", "replacement": "DAY $1"},
			{"pattern": "^污染 ([0-9]+)%$", "replacement": "汚染度 $1%"},
			{"pattern": "^资金 ([0-9]+)$", "replacement": "資金 $1"},
			{"pattern": "^第 ([0-9]+) 层 / ([0-9]+)$", "replacement": "$1階 / $2"},
			{"pattern": "^塔层 ([0-9]+)/([0-9]+)$", "replacement": "階層 $1/$2"},
			{"pattern": "^下一门槛：([0-9]+)$", "replacement": "次の閾値：$1"},
			{"pattern": "^持有 ([0-9]+)$", "replacement": "所持数 $1"},
			{"pattern": "^已合成梗：([0-9]+)$", "replacement": "作成済みミーム：$1"},
			{"pattern": "^污染：([0-9]+)%$", "replacement": "汚染度：$1%"},
			{"pattern": "^任意键  ([0-9]+) / ([0-9]+)$", "replacement": "いずれかのキー  $1 / $2"},
			{"pattern": "^([0-9]+) 资金$", "replacement": "$1 資金"},
			{"pattern": "^梗库\\n([0-9]+)$", "replacement": "ミーム庫\\n$1"},
			{"pattern": "^梗字「(.+)」$", "replacement": "ミーム文字「$1」"},
			{"pattern": "^复合「(.+)」$", "replacement": "融合「$1」"},
		],
		"en": [
			{"pattern": "^DAY ([0-9]+)$", "replacement": "DAY $1"},
			{"pattern": "^污染 ([0-9]+)%$", "replacement": "CORRUPTION $1%"},
			{"pattern": "^资金 ([0-9]+)$", "replacement": "FUNDS $1"},
			{"pattern": "^第 ([0-9]+) 层 / ([0-9]+)$", "replacement": "FLOOR $1 / $2"},
			{"pattern": "^塔层 ([0-9]+)/([0-9]+)$", "replacement": "FLOOR $1/$2"},
			{"pattern": "^下一门槛：([0-9]+)$", "replacement": "NEXT THRESHOLD: $1"},
			{"pattern": "^持有 ([0-9]+)$", "replacement": "OWNED $1"},
			{"pattern": "^已合成梗：([0-9]+)$", "replacement": "CRAFTED MEMES: $1"},
			{"pattern": "^污染：([0-9]+)%$", "replacement": "CORRUPTION: $1%"},
			{"pattern": "^任意键  ([0-9]+) / ([0-9]+)$", "replacement": "ANY KEY  $1 / $2"},
			{"pattern": "^([0-9]+) 资金$", "replacement": "$1 FUNDS"},
			{"pattern": "^梗库\\n([0-9]+)$", "replacement": "MEME BANK\\n$1"},
			{"pattern": "^梗字「(.+)」$", "replacement": "GLYPH MEME \"$1\""},
			{"pattern": "^复合「(.+)」$", "replacement": "FUSION \"$1\""},
		],
	}
