class_name MemeGameState
extends RefCounted

const MAX_TOWER_FLOOR := 5
const TOWER_THRESHOLDS := [0, 36, 64, 94, 120, 150]
const POLLUTION_LOCK_THRESHOLD := 70
const POLLUTION_FLASHBACK_THRESHOLD := 60

const EMOTION_SLOTS := {
	"anxiety": {"id": "anxiety", "label": "焦虑", "price": 5, "default_text": "我不是那个意思", "tags": ["焦虑"], "pollution_bias": 2, "clarity_bias": -4},
	"please": {"id": "please", "label": "讨好", "price": 5, "default_text": "你说得也有道理", "tags": ["讨好"], "pollution_bias": 1, "clarity_bias": -2},
	"counter": {"id": "counter", "label": "反问", "price": 6, "default_text": "难道不是这样吗", "tags": ["反问"], "pollution_bias": 3, "clarity_bias": -5},
	"silence": {"id": "silence", "label": "沉默", "price": 6, "default_text": "我先不说了", "tags": ["沉默", "空位"], "pollution_bias": 3, "clarity_bias": -6},
	"anger": {"id": "anger", "label": "愤怒", "price": 7, "default_text": "别再这样问我", "tags": ["愤怒", "禁问"], "pollution_bias": 4, "clarity_bias": -8},
	"prayer": {"id": "prayer", "label": "祈求", "price": 7, "default_text": "请让我把话说完", "tags": ["祈求", "圣歌"], "pollution_bias": 4, "clarity_bias": -5},
}

const EMOTION_ROTATION := ["anxiety", "please", "counter", "silence", "anger", "prayer"]
const CLEAN_WORDS := ["我", "想", "正常", "说明", "这件事", "不是", "那个意思", "请", "听我", "说完"]
const FALLBACK_LEGACY_TEXTS := {
	1: {"text": "哈吉米，必须补票", "tags": ["哈吉米", "追问"]},
	2: {"text": "在线本身就是发言", "tags": ["沉默", "空位"]},
	3: {"text": "请用更新后的句式进入", "tags": ["巴别塔", "刷新"]},
	4: {"text": "你为什么需要他说话", "tags": ["反问", "禁问"]},
}

var day: int = 1
var heat: int = 18
var pollution: int = 0
var clarity: int = 100
var tower_floor: int = 1
var threshold_discount: int = 0
var next_threshold: int = 36
var ending_unlocked: bool = false
var money: int = 18
var actions_remaining: int = 5
var max_actions_per_day: int = 5
var needs_day_settlement: bool = false
var day_ended_reason: String = ""
var pollution_flashback_seen: bool = false
var pollution_flashback_pending: bool = false

var view_state: String = "phone_down"
var phone_visible: bool = true
var phone_open: bool = true
var active_app: String = "social"
var active_app_window: String = "social"

var notebook_tokens: Array = []
var draft_slots: Dictionary = {}
var completed_memes: Array = []
var dialogue_blanks: Dictionary = {}
var published_memes: Array = []
var event_log: Array[String] = []

var owned_emotion_slots: Array = []
var emotion_slot_texts: Dictionary = {}
var daily_emotion_slot_id: String = "anxiety"

var reality_sentence_slots: Dictionary = {}
var legacy_rules: Array = []
var last_clean_sentence: String = ""
var last_polluted_sentence: String = ""
var npc_understanding: int = 100
var reality_phase: String = "npc_speaking"


func new_run() -> void:
	day = 1
	heat = 18
	pollution = 0
	clarity = 100
	tower_floor = 1
	threshold_discount = 0
	next_threshold = _tower_threshold(tower_floor)
	ending_unlocked = false
	money = 18
	actions_remaining = max_actions_per_day
	needs_day_settlement = false
	day_ended_reason = ""
	pollution_flashback_seen = false
	pollution_flashback_pending = false
	view_state = "phone_down"
	phone_visible = true
	phone_open = true
	active_app = "social"
	active_app_window = "social"
	notebook_tokens = []
	draft_slots = {}
	completed_memes = []
	dialogue_blanks = {}
	published_memes = []
	event_log = []
	owned_emotion_slots = []
	emotion_slot_texts = {}
	daily_emotion_slot_id = _emotion_slot_for_day(day)
	reality_sentence_slots = {}
	legacy_rules = []
	last_clean_sentence = ""
	last_polluted_sentence = ""
	npc_understanding = 100
	reality_phase = "npc_speaking"


func set_phone_open(value: bool) -> void:
	phone_open = value
	phone_visible = value
	if not value:
		active_app_window = ""


func set_view_state(value: String) -> bool:
	if value != "phone_down" and value != "npc_up":
		return false
	view_state = value
	if view_state == "phone_down":
		phone_visible = true
		phone_open = true
		if active_app_window.is_empty():
			active_app_window = active_app
	else:
		phone_visible = false
		phone_open = false
		active_app_window = ""
		reset_reality_phase_for_day()
	return true


func set_active_app(app_id: String) -> void:
	active_app = app_id
	if view_state == "phone_down":
		active_app_window = app_id


func spend_action(action_type: String) -> bool:
	if actions_remaining <= 0:
		actions_remaining = 0
		needs_day_settlement = true
		day_ended_reason = "actions-depleted"
		return false
	actions_remaining = maxi(0, actions_remaining - 1)
	if actions_remaining == 0:
		needs_day_settlement = true
		day_ended_reason = action_type
	return true


func check_pollution_flashback(previous_pollution: int) -> bool:
	if pollution_flashback_seen:
		return false
	if previous_pollution >= POLLUTION_FLASHBACK_THRESHOLD:
		return false
	if pollution < POLLUTION_FLASHBACK_THRESHOLD:
		return false
	pollution_flashback_seen = true
	pollution_flashback_pending = true
	actions_remaining = 0
	needs_day_settlement = true
	day_ended_reason = "pollution-flashback"
	return true


func consume_pollution_flashback() -> bool:
	if not pollution_flashback_pending:
		return false
	pollution_flashback_pending = false
	return true


func begin_reality_player_turn() -> bool:
	if reality_phase == "reality_result":
		return false
	reality_phase = "player_composing"
	return true


func reset_reality_phase_for_day() -> void:
	reality_phase = "npc_speaking"


func settle_day_if_needed() -> bool:
	if not needs_day_settlement:
		return false
	_resolve_tower_step()
	day += 1
	actions_remaining = max_actions_per_day
	needs_day_settlement = false
	day_ended_reason = ""
	pollution_flashback_pending = false
	draft_slots.clear()
	dialogue_blanks.clear()
	reality_sentence_slots.clear()
	reset_reality_phase_for_day()
	daily_emotion_slot_id = _emotion_slot_for_day(day)
	heat = maxi(10, int(round(float(heat) * 0.82)))
	money += 5 + tower_floor * 2
	return true


func pick_token(post_id: String, token: Dictionary) -> bool:
	var note := {
		"id": "%s-%s-%d" % [post_id, token.get("id", "token"), day],
		"text": str(token.get("text", "")),
		"source_post_id": post_id,
		"tags": token.get("tags", []),
		"rarity": int(token.get("rarity", 1)),
		"picked_day": day,
	}
	for existing in notebook_tokens:
		if existing.get("id", "") == note["id"]:
			return false
	if not spend_action("pick-token"):
		return false
	notebook_tokens.append(note)
	var previous_pollution := pollution
	pollution = clampi(pollution + maxi(0, int(note["rarity"]) - 1), 0, 100)
	check_pollution_flashback(previous_pollution)
	return true


func buy_daily_emotion_slot() -> bool:
	var slot_id := daily_emotion_slot_id
	if slot_id in owned_emotion_slots:
		return false
	var slot: Dictionary = EMOTION_SLOTS.get(slot_id, {})
	if slot.is_empty():
		return false
	var price := int(slot.get("price", 5))
	if money < price:
		return false
	if not spend_action("buy-emotion-slot"):
		return false
	money -= price
	owned_emotion_slots.append(slot_id)
	emotion_slot_texts[slot_id] = str(slot.get("default_text", ""))
	return true


func set_emotion_slot_text(slot_id: String, text: String) -> bool:
	if slot_id not in owned_emotion_slots:
		return false
	emotion_slot_texts[slot_id] = text
	return true


func get_daily_emotion_slot() -> Dictionary:
	return EMOTION_SLOTS.get(daily_emotion_slot_id, {})


func get_owned_emotion_slot_data() -> Array:
	var result: Array = []
	for slot_id in owned_emotion_slots:
		if EMOTION_SLOTS.has(slot_id):
			result.append(EMOTION_SLOTS[slot_id])
	return result


func get_craft_slots() -> Array:
	var slots: Array = [
		{"id": "object", "label": "对象", "placeholder": "哈吉米", "required": true},
		{"id": "saying", "label": "说法", "placeholder": "到底是什么意思", "required": true},
	]
	for slot_id in owned_emotion_slots:
		var slot: Dictionary = EMOTION_SLOTS.get(slot_id, {})
		if slot.is_empty():
			continue
		slots.append({
			"id": "emotion:%s" % slot_id,
			"label": str(slot.get("label", "情绪")),
			"placeholder": str(emotion_slot_texts.get(slot_id, slot.get("default_text", ""))),
			"required": false,
			"emotion_slot_id": slot_id,
		})
	return slots


func place_token_in_slot(slot_id: String, token_id: String) -> bool:
	draft_slots[slot_id] = token_id
	return true


func confirm_craft_with_emotions() -> bool:
	var object_text := _find_token_text(str(draft_slots.get("object", "")))
	var saying_text := _find_token_text(str(draft_slots.get("saying", "")))
	if object_text.is_empty() or saying_text.is_empty():
		return false
	if not spend_action("craft-meme"):
		return false

	var tags: Array = []
	tags = _unique(tags + _find_token_tags(str(draft_slots.get("object", ""))))
	tags = _unique(tags + _find_token_tags(str(draft_slots.get("saying", ""))))
	var pollution_bias := 0
	var clarity_bias := 0
	var emotion_parts: Array[String] = []
	for slot_id in owned_emotion_slots:
		var slot: Dictionary = EMOTION_SLOTS.get(slot_id, {})
		if slot.is_empty():
			continue
		var text := str(emotion_slot_texts.get(slot_id, slot.get("default_text", ""))).strip_edges()
		if text.is_empty():
			continue
		emotion_parts.append("%s：%s" % [str(slot.get("label", "情绪")), text])
		tags = _unique(tags + slot.get("tags", []))
		pollution_bias += int(slot.get("pollution_bias", 0))
		clarity_bias += int(slot.get("clarity_bias", 0))

	var text := "%s，%s？" % [object_text, saying_text]
	if not emotion_parts.is_empty():
		text = "%s（%s）" % [text, "；".join(emotion_parts)]
	var meme := {
		"id": "meme-%d-%d" % [day, completed_memes.size() + 1],
		"title": "表达 #%d" % [completed_memes.size() + 1],
		"text": text,
		"tags": tags,
		"rarity": _meme_rarity_from_tags(tags),
		"pollution_bias": pollution_bias,
		"clarity_bias": clarity_bias,
		"created_day": day,
	}
	completed_memes.push_front(meme)
	draft_slots.clear()
	return true


func confirm_craft() -> bool:
	return confirm_craft_with_emotions()


func place_meme_in_blank(blank_id: String, meme_id: String) -> bool:
	dialogue_blanks[blank_id] = meme_id
	return true


func confirm_dialogue() -> bool:
	var meme := _get_first_placed_meme()
	if meme.is_empty():
		return false
	var matching_tags: Array = _intersect(meme.get("tags", []), _current_accepted_tags())
	var score := _score_meme_publish(meme, matching_tags)
	var heat_gain := maxi(6, int(round(float(score) * 0.42)))
	var pollution_gain := 4 + matching_tags.size() * 2 + int(meme.get("pollution_bias", 0))
	if not spend_action("confirm-dialogue"):
		return false
	heat = clampi(heat + heat_gain, 0, 999)
	var previous_pollution := pollution
	pollution = clampi(pollution + pollution_gain, 0, 100)
	check_pollution_flashback(previous_pollution)
	clarity = clampi(clarity - maxi(1, int(round(float(pollution_gain) * 0.35))), 0, 100)
	money += maxi(3, int(floor(float(heat_gain) * 0.22)))
	var record: Dictionary = meme.duplicate(true)
	record["floor"] = tower_floor
	record["score"] = score
	record["heat_gain"] = heat_gain
	record["published_day"] = day
	published_memes.push_front(record)
	dialogue_blanks.clear()
	return true


func register_legacy_rule_for_ascent(previous_floor: int) -> bool:
	if previous_floor < 1 or previous_floor >= MAX_TOWER_FLOOR:
		return false
	for rule in legacy_rules:
		if int(rule.get("floor", -1)) == previous_floor:
			return false

	var hottest := _hottest_published_meme_for_floor(previous_floor)
	var required_text := ""
	var tags: Array = []
	var source_meme_id := ""
	var strength := previous_floor
	if hottest.is_empty():
		var fallback: Dictionary = FALLBACK_LEGACY_TEXTS.get(previous_floor, FALLBACK_LEGACY_TEXTS[1])
		required_text = str(fallback.get("text", "哈吉米，必须补票"))
		tags = fallback.get("tags", [])
	else:
		required_text = str(hottest.get("text", ""))
		tags = hottest.get("tags", [])
		source_meme_id = str(hottest.get("id", ""))
		strength = maxi(previous_floor, int(ceil(float(hottest.get("score", 0)) / 30.0)))
	if required_text.is_empty():
		required_text = "哈吉米，必须补票"

	legacy_rules.append({
		"id": "legacy-%d" % previous_floor,
		"floor": previous_floor,
		"source_meme_id": source_meme_id,
		"required_text": required_text,
		"tags": tags,
		"created_day": day,
		"strength": strength,
	})
	event_log.push_front("第 %d 层留下遗产规则：%s" % [previous_floor, required_text])
	return true


func get_required_legacy_tiles() -> Array:
	var result: Array = []
	for rule in legacy_rules:
		var rule_id := str(rule.get("id", ""))
		result.append({
			"id": "legacy:%s" % rule_id,
			"rule_id": rule_id,
			"text": str(rule.get("required_text", "")),
			"floor": int(rule.get("floor", 1)),
			"locked": pollution >= POLLUTION_LOCK_THRESHOLD,
			"tags": rule.get("tags", []),
			"strength": int(rule.get("strength", 1)),
		})
	return result


func get_reality_tile_options() -> Array:
	var result: Array = []
	for word in CLEAN_WORDS:
		result.append({"id": "clean:%s" % word, "text": word, "kind": "clean"})
	for slot_id in owned_emotion_slots:
		var slot: Dictionary = EMOTION_SLOTS.get(slot_id, {})
		var text := str(emotion_slot_texts.get(slot_id, slot.get("default_text", ""))).strip_edges()
		if text.is_empty():
			continue
		result.append({"id": "emotion:%s" % slot_id, "text": text, "kind": "emotion"})
	for tile in get_required_legacy_tiles():
		result.append({"id": tile["id"], "text": tile["text"], "kind": "legacy", "locked": tile["locked"]})
	return result


func place_reality_tile(slot_id: String, tile_id: String) -> bool:
	reality_sentence_slots[slot_id] = tile_id
	return true


func confirm_reality_dialogue() -> bool:
	var required_tiles := get_required_legacy_tiles()
	var locked_texts: Array[String] = []
	for tile in required_tiles:
		if bool(tile.get("locked", false)):
			locked_texts.append(str(tile.get("text", "")))
			continue
		if not _reality_slots_include(str(tile.get("id", ""))):
			return false

	var clean_parts: Array[String] = []
	for text in locked_texts:
		if not text.is_empty() and text not in clean_parts:
			clean_parts.append(text)

	var keys := reality_sentence_slots.keys()
	keys.sort()
	for key in keys:
		var text := _reality_tile_text(str(reality_sentence_slots[key]))
		if text.is_empty():
			continue
		if text not in clean_parts:
			clean_parts.append(text)
	if clean_parts.is_empty():
		return false
	if not spend_action("reality-dialogue"):
		return false

	last_clean_sentence = " ".join(clean_parts)
	last_polluted_sentence = pollute_reality_sentence(last_clean_sentence, pollution, legacy_rules)
	var pollution_penalty := int(round(float(pollution) * 0.45))
	var legacy_penalty := legacy_rules.size() * 12
	var distortion_penalty := 8 if last_clean_sentence != last_polluted_sentence else 0
	npc_understanding = clampi(100 - pollution_penalty - legacy_penalty - distortion_penalty, 0, 100)
	clarity = clampi(clarity - maxi(1, int(round(float(legacy_penalty + pollution_penalty) * 0.12))), 0, 100)
	reality_sentence_slots.clear()
	reality_phase = "reality_result"
	return true


func pollute_reality_sentence(sentence: String, pollution_value: int, rules: Array) -> String:
	if pollution_value < 35:
		return sentence
	var markers := ["哈吉米", "□", "刷新", "塔", "禁问", "……"]
	var step := maxi(2, 9 - int(pollution_value / 12))
	var result := ""
	for index in sentence.length():
		var ch := sentence.substr(index, 1)
		if ch == " ":
			result += ch
		elif index % step == 0:
			result += markers[(index + day + rules.size()) % markers.size()]
		else:
			result += ch
	if pollution_value >= POLLUTION_LOCK_THRESHOLD and not result.begins_with("哈吉米"):
		result = "哈吉米 " + result
	return result


func _get_first_placed_meme() -> Dictionary:
	for meme_id in dialogue_blanks.values():
		for meme in completed_memes:
			if str(meme.get("id", "")) == str(meme_id):
				return meme
	return {}


func _find_token_text(token_id: String) -> String:
	for token in notebook_tokens:
		if str(token.get("id", "")) == token_id:
			return str(token.get("text", ""))
	return ""


func _find_token_tags(token_id: String) -> Array:
	for token in notebook_tokens:
		if str(token.get("id", "")) == token_id:
			return token.get("tags", [])
	return []


func _current_accepted_tags() -> Array:
	match ((day - 1) % 4) + 1:
		1:
			return ["哈吉米", "追问", "日常"]
		2:
			return ["沉默", "空位", "圣歌", "追问"]
		3:
			return ["巴别塔", "信徒", "刷新"]
		_:
			return ["反问", "禁问", "清晰"]


func _score_meme_publish(meme: Dictionary, matching_tags: Array) -> int:
	var rarity := int(meme.get("rarity", 1))
	var repeat_penalty := 0
	for record in published_memes:
		if str(record.get("text", "")) == str(meme.get("text", "")):
			repeat_penalty += 10
	return maxi(1, 18 + matching_tags.size() * 20 + rarity * 8 + int(floor(float(pollution) * 0.28)) + int(meme.get("pollution_bias", 0)) * 4 - repeat_penalty)


func _hottest_published_meme_for_floor(floor: int) -> Dictionary:
	var best: Dictionary = {}
	var best_score := -999999
	for record in published_memes:
		if int(record.get("floor", -1)) != floor:
			continue
		var score := int(record.get("score", 0))
		if score > best_score:
			best = record
			best_score = score
	return best


func _reality_slots_include(tile_id: String) -> bool:
	for value in reality_sentence_slots.values():
		if str(value) == tile_id:
			return true
	return false


func _reality_tile_text(tile_id: String) -> String:
	if tile_id.begins_with("clean:"):
		return tile_id.substr(6)
	if tile_id.begins_with("emotion:"):
		var slot_id := tile_id.substr(8)
		return str(emotion_slot_texts.get(slot_id, ""))
	if tile_id.begins_with("legacy:"):
		var rule_id := tile_id.substr(7)
		for rule in legacy_rules:
			if str(rule.get("id", "")) == rule_id:
				return str(rule.get("required_text", ""))
	return ""


func _resolve_tower_step() -> void:
	var previous_floor := tower_floor
	var threshold := _tower_threshold(tower_floor)
	var progress := _progress_score()
	if progress >= threshold:
		tower_floor = clampi(tower_floor + 1, 1, MAX_TOWER_FLOOR)
		if tower_floor > previous_floor:
			register_legacy_rule_for_ascent(previous_floor)
		threshold_discount = maxi(0, threshold_discount - 8)
		event_log.push_front("第二天，巴别塔把你标记到第 %d 层。" % tower_floor)
	elif tower_floor > 1 and progress < int(float(threshold) * 0.62):
		tower_floor = clampi(tower_floor - 1, 1, MAX_TOWER_FLOOR)
		threshold_discount = clampi(threshold_discount + 16, 0, 70)
		event_log.push_front("第二天，楼层退回第 %d 层，但遗产规则没有消失。" % tower_floor)
	else:
		threshold_discount = clampi(threshold_discount + 6, 0, 70)
		event_log.push_front("第二天，塔没有移动，只是把门槛悄悄放低。")
	next_threshold = _tower_threshold(tower_floor)
	if tower_floor >= MAX_TOWER_FLOOR:
		ending_unlocked = true


func _tower_threshold(floor: int) -> int:
	var index := clampi(floor, 1, MAX_TOWER_FLOOR)
	return maxi(18, int(TOWER_THRESHOLDS[index]) - threshold_discount)


func _progress_score() -> int:
	return int(round(float(heat) + float(pollution) * 0.55 + float(100 - clarity) * 0.18))


func _emotion_slot_for_day(value: int) -> String:
	return EMOTION_ROTATION[(value - 1) % EMOTION_ROTATION.size()]


func _meme_rarity_from_tags(tags: Array) -> int:
	return clampi(1 + int(floor(float(tags.size()) / 2.0)), 1, 5)


func _intersect(left: Array, right: Array) -> Array:
	var result: Array = []
	for value in left:
		if value in right and value not in result:
			result.append(value)
	return result


func _unique(values: Array) -> Array:
	var result: Array = []
	for value in values:
		if value not in result:
			result.append(value)
	return result
