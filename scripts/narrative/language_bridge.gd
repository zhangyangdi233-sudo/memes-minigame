class_name LanguageBridge
extends RefCounted

const SLOT_ORDER := ["subject", "action", "object"]
const SURFACE_FIELDS := {
	"phone": "phone_surface",
	"doctor": "doctor_surface",
	"doll": "doll_surface",
}
const SUPPORTED_WORLDS := ["clean", "phone", "doctor", "doll"]
const SUPPORTED_LOCALE_PREFIXES := ["zh", "ja", "en"]


static func normalized_token(token: Dictionary) -> Dictionary:
	var normalized: Dictionary = token.duplicate(true)
	var token_id := str(token.get("id", "")).strip_edges()
	var lexeme_id := str(token.get("lexeme_id", "")).strip_edges()
	if lexeme_id.is_empty():
		lexeme_id = token_id
	normalized["id"] = token_id
	normalized["text"] = str(token.get("text", ""))
	normalized["lexeme_id"] = lexeme_id
	normalized["grammar_roles"] = _normalized_roles(token.get("grammar_roles", []))
	for field_name in SURFACE_FIELDS.values():
		normalized[field_name] = str(token.get(field_name, ""))
	normalized["pollution_stage"] = maxi(0, int(token.get("pollution_stage", 0)))
	return normalized


static func validate_content(tokens: Array) -> Dictionary:
	var errors: Array[String] = []
	var normalized_tokens: Array = []
	var seen_ids: Dictionary = {}
	for index in tokens.size():
		var token_value: Variant = tokens[index]
		if not token_value is Dictionary:
			errors.append("token[%d].not_dictionary" % index)
			continue
		var token: Dictionary = token_value as Dictionary
		var token_id := str(token.get("id", "")).strip_edges()
		if token_id.is_empty():
			errors.append("token[%d].missing:id" % index)
		elif seen_ids.has(token_id):
			errors.append("token[%d].duplicate_id:%s" % [index, token_id])
		else:
			seen_ids[token_id] = true
		if str(token.get("text", "")).is_empty():
			errors.append("token[%d].missing:text" % index)
		if str(token.get("lexeme_id", "")).strip_edges().is_empty():
			errors.append("token[%d].missing:lexeme_id" % index)
		var raw_roles: Variant = token.get("grammar_roles", null)
		if not raw_roles is Array:
			errors.append("token[%d].invalid:grammar_roles" % index)
		else:
			var roles: Array[String] = _normalized_roles(raw_roles)
			if roles.is_empty():
				errors.append("token[%d].missing:grammar_roles" % index)
			for raw_role in raw_roles as Array:
				var role := str(raw_role).strip_edges().to_lower()
				if role not in SLOT_ORDER:
					errors.append("token[%d].unknown_role:%s" % [index, role])
		var raw_stage: Variant = token.get("pollution_stage", null)
		if typeof(raw_stage) not in [TYPE_INT, TYPE_FLOAT]:
			errors.append("token[%d].invalid:pollution_stage" % index)
		for field_name in SURFACE_FIELDS.values():
			if token.has(field_name) and typeof(token[field_name]) != TYPE_STRING:
				errors.append("token[%d].invalid:%s" % [index, field_name])
		normalized_tokens.append(normalized_token(token))
	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"normalized_tokens": normalized_tokens,
	}


static func validate_recipe(slot_map: Dictionary, tokens: Array) -> Dictionary:
	var errors: Array[String] = []
	var ordered_tokens: Array = []
	var tokens_by_id: Dictionary = {}
	var duplicate_ids: Dictionary = {}
	for token_value in tokens:
		if not token_value is Dictionary:
			continue
		var token := normalized_token(token_value as Dictionary)
		var token_id := str(token.get("id", ""))
		if token_id.is_empty():
			continue
		if tokens_by_id.has(token_id):
			duplicate_ids[token_id] = true
		else:
			tokens_by_id[token_id] = token

	var selected_ids: Dictionary = {}
	for slot_name in SLOT_ORDER:
		var token_id := str(slot_map.get(slot_name, "")).strip_edges()
		if token_id.is_empty():
			errors.append("missing_slot:%s" % slot_name)
			continue
		if duplicate_ids.has(token_id):
			errors.append("ambiguous_token:%s:%s" % [slot_name, token_id])
			continue
		if not tokens_by_id.has(token_id):
			errors.append("unknown_token:%s:%s" % [slot_name, token_id])
			continue
		if selected_ids.has(token_id):
			errors.append("reused_token:%s:%s" % [slot_name, token_id])
			continue
		var token: Dictionary = tokens_by_id[token_id]
		var roles: Array = token.get("grammar_roles", [])
		if slot_name not in roles:
			errors.append("incompatible_role:%s:%s" % [slot_name, token_id])
			continue
		selected_ids[token_id] = true
		ordered_tokens.append(token.duplicate(true))

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"ordered_tokens": ordered_tokens if errors.is_empty() else [],
	}


static func compose_sentence(slot_map: Dictionary, tokens: Array, world: String, locale: String) -> Dictionary:
	var validation := validate_recipe(slot_map, tokens)
	var world_key := _normalized_world(world)
	if not bool(validation.get("valid", false)) or world_key not in SUPPORTED_WORLDS:
		return _empty_composition()

	var clean_parts: Array[String] = []
	var world_parts: Array[String] = []
	var token_ids: Array[String] = []
	var lexeme_ids: Array[String] = []
	for token_value in validation.get("ordered_tokens", []):
		var token: Dictionary = token_value as Dictionary
		clean_parts.append(str(token.get("text", "")))
		world_parts.append(token_surface(token, world_key))
		token_ids.append(str(token.get("id", "")))
		lexeme_ids.append(str(token.get("lexeme_id", "")))

	return {
		"valid": true,
		"clean_sentence": _join_sentence(clean_parts, locale),
		"world_sentence": _join_sentence(world_parts, locale),
		"token_ids": token_ids,
		"lexeme_ids": lexeme_ids,
	}


static func mark_tokens_used(tokens: Array, token_ids: Array, world: String) -> Array:
	var selected_ids: Dictionary = {}
	for token_id_value in token_ids:
		selected_ids[str(token_id_value)] = true
	var world_key := _normalized_world(world)
	var result: Array = []
	for token_value in tokens:
		if not token_value is Dictionary:
			result.append(token_value)
			continue
		var token_copy: Dictionary = (token_value as Dictionary).duplicate(true)
		if selected_ids.has(str(token_copy.get("id", ""))):
			token_copy["pollution_stage"] = maxi(0, int(token_copy.get("pollution_stage", 0))) + 1
			token_copy["use_count"] = maxi(0, int(token_copy.get("use_count", 0))) + 1
			token_copy["last_used_world"] = world_key
			var used_worlds: Array = []
			var previous_worlds: Variant = token_copy.get("used_worlds", [])
			if previous_worlds is Array:
				used_worlds = (previous_worlds as Array).duplicate(true)
			if not world_key.is_empty() and world_key not in used_worlds:
				used_worlds.append(world_key)
			token_copy["used_worlds"] = used_worlds
		result.append(token_copy)
	return result


static func token_surface(token: Dictionary, world: String) -> String:
	var clean_text := str(token.get("text", ""))
	var world_key := _normalized_world(world)
	if not SURFACE_FIELDS.has(world_key):
		return clean_text
	var surface := str(token.get(str(SURFACE_FIELDS[world_key]), ""))
	return clean_text if surface.strip_edges().is_empty() else surface


static func _normalized_roles(raw_roles: Variant) -> Array[String]:
	var roles: Array[String] = []
	if not raw_roles is Array:
		return roles
	for role_value in raw_roles as Array:
		var role := str(role_value).strip_edges().to_lower()
		if role in SLOT_ORDER and role not in roles:
			roles.append(role)
	return roles


static func _normalized_world(world: String) -> String:
	return world.strip_edges().to_lower()


static func _locale_prefix(locale: String) -> String:
	var normalized := locale.strip_edges().to_lower().replace("_", "-")
	for prefix in SUPPORTED_LOCALE_PREFIXES:
		if normalized == prefix or normalized.begins_with("%s-" % prefix):
			return prefix
	return "zh"


static func _join_sentence(parts: Array[String], locale: String) -> String:
	var separator := " " if _locale_prefix(locale) == "en" else ""
	var sentence := separator.join(parts)
	if sentence.is_empty():
		return sentence
	if sentence.right(1) in ["。", "！", "？", ".", "!", "?"]:
		return sentence
	return sentence + ("." if _locale_prefix(locale) == "en" else "。")


static func _empty_composition() -> Dictionary:
	return {
		"valid": false,
		"clean_sentence": "",
		"world_sentence": "",
		"token_ids": [],
		"lexeme_ids": [],
	}
