class_name MemeGameState
extends RefCounted

const MAX_TOWER_FLOOR := 5
const TOWER_THRESHOLDS := [0, 36, 64, 94, 120, 150]
const POLLUTION_LOCK_THRESHOLD := 70
const POLLUTION_FLASHBACK_THRESHOLD := 60
const FLOOR_DEADLINES := {3: 2, 6: 3, 9: 4, 12: 5}
const ACCEPTED_TAG_ROTATION := [
	["哈吉米", "追问", "日常"],
	["空位", "沉默", "哈吉米"],
	["巴别塔", "信徒", "刷新"],
	["反问", "禁问", "哈吉米"],
	["圣歌", "信徒", "巴别塔"],
	["空位", "沉默", "巴别塔"],
]

const SIGNAL_CONTRACTS := [
	{
		"id": "trend_pair",
		"label": "双声回路",
		"description": "命中至少 2 个今日风向",
		"rule": "matching_tags",
		"threshold": 2,
		"base_bonus": 12,
		"multiplier": 1.35,
		"pollution_risk": 2,
	},
	{
		"id": "wideband",
		"label": "杂讯列阵",
		"description": "成品含至少 4 种隐藏标签",
		"rule": "tag_count",
		"threshold": 4,
		"base_bonus": 10,
		"multiplier": 1.45,
		"pollution_risk": 3,
	},
	{
		"id": "emotion_flush",
		"label": "情绪同花",
		"description": "同时装入 2 个情绪槽",
		"rule": "emotion_count",
		"threshold": 2,
		"base_bonus": 8,
		"multiplier": 1.60,
		"pollution_risk": 4,
	},
	{
		"id": "empty_pair",
		"label": "空位对子",
		"description": "同时含有「空位」和「沉默」",
		"rule": "all_tags",
		"required_tags": ["空位", "沉默"],
		"base_bonus": 18,
		"multiplier": 1.45,
		"pollution_risk": 3,
	},
	{
		"id": "babel_straight",
		"label": "巴别直线",
		"description": "集齐「巴别塔」「信徒」「圣歌」",
		"rule": "all_tags",
		"required_tags": ["巴别塔", "信徒", "圣歌"],
		"base_bonus": 22,
		"multiplier": 1.65,
		"pollution_risk": 5,
	},
	{
		"id": "forbidden_loop",
		"label": "禁问回环",
		"description": "复读一次并带有反问或禁问",
		"rule": "repeat_any_tag",
		"threshold": 1,
		"required_tags": ["反问", "禁问"],
		"base_bonus": 26,
		"multiplier": 1.75,
		"pollution_risk": 6,
	},
]

const EMOTION_SLOTS := {
	"anxiety": {"id": "anxiety", "label": "焦虑", "price": 5, "default_text": "我不是那个意思", "tags": ["焦虑"], "pollution_bias": 2, "clarity_bias": -4},
	"please": {"id": "please", "label": "讨好", "price": 5, "default_text": "你说得也有道理", "tags": ["讨好"], "pollution_bias": 1, "clarity_bias": -2},
	"counter": {"id": "counter", "label": "反问", "price": 6, "default_text": "难道不是这样吗", "tags": ["反问"], "pollution_bias": 3, "clarity_bias": -5},
	"silence": {"id": "silence", "label": "沉默", "price": 6, "default_text": "我先不说了", "tags": ["沉默", "空位"], "pollution_bias": 3, "clarity_bias": -6},
	"anger": {"id": "anger", "label": "愤怒", "price": 7, "default_text": "别再这样问我", "tags": ["愤怒", "禁问"], "pollution_bias": 4, "clarity_bias": -8},
	"prayer": {"id": "prayer", "label": "祈求", "price": 7, "default_text": "请让我把话说完", "tags": ["祈求", "圣歌"], "pollution_bias": 4, "clarity_bias": -5},
}

const EMOTION_ROTATION := ["anxiety", "please", "counter", "silence", "anger", "prayer"]
const MAX_EQUIPPED_EMOTION_SLOTS := 2
const ASCENT_REWARDS := [
	{"id": "echo_amplifier", "label": "回声增幅", "description": "每个命中风向让共鸣倍率额外 +0.08。", "effect": "synergy_step", "value": 0.08},
	{"id": "pollution_dividend", "label": "污染分红", "description": "污染传播倍率固定额外 +0.15。", "effect": "pollution_bonus", "value": 0.15},
	{"id": "repeat_license", "label": "复读许可", "description": "第一次复用相同表达不触发衰减。", "effect": "repeat_grace", "value": 1.0},
	{"id": "legacy_fold", "label": "遗产折叠", "description": "每条遗产造成的理解惩罚减少 4。", "effect": "legacy_relief", "value": 4.0},
	{"id": "quiet_subsidy", "label": "沉默补贴", "description": "现实沟通造成的资金损失减少 2。", "effect": "relationship_shield", "value": 2.0},
	{"id": "empty_slot_bonus", "label": "空位加码", "description": "带有空位或沉默标签时，传播基础 +8。", "effect": "empty_base", "value": 8.0},
	{"id": "emotion_afterimage", "label": "情绪余像", "description": "每个装备情绪让情绪倍率额外 +0.03。", "effect": "emotion_step", "value": 0.03},
]
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
var last_publish_breakdown: Dictionary = {}
var event_log: Array[String] = []

var owned_emotion_slots: Array = []
var equipped_emotion_slots: Array = []
var emotion_slot_texts: Dictionary = {}
var daily_emotion_slot_id: String = "anxiety"

var permanent_modifiers: Array = []
var pending_ascent_reward_choices: Array = []
var pending_ascent_reward_floor: int = 0
var queued_ascent_reward_floors: Array = []
var rewarded_ascent_floors: Array = []

var reality_sentence_slots: Dictionary = {}
var legacy_rules: Array = []
var last_clean_sentence: String = ""
var last_polluted_sentence: String = ""
var npc_understanding: int = 100
var reality_phase: String = "npc_speaking"
var relationship_residue: int = 0
var last_relationship_residue_gain: int = 0
var last_relationship_money_loss: int = 0
var reality_dialogue_count: int = 0


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
	last_publish_breakdown = {}
	event_log = []
	owned_emotion_slots = []
	equipped_emotion_slots = []
	emotion_slot_texts = {}
	daily_emotion_slot_id = _emotion_slot_for_day(day)
	permanent_modifiers = []
	pending_ascent_reward_choices = []
	pending_ascent_reward_floor = 0
	queued_ascent_reward_floors = []
	rewarded_ascent_floors = []
	reality_sentence_slots = {}
	legacy_rules = []
	last_clean_sentence = ""
	last_polluted_sentence = ""
	npc_understanding = 100
	reality_phase = "npc_speaking"
	relationship_residue = 0
	last_relationship_residue_gain = 0
	last_relationship_money_loss = 0
	reality_dialogue_count = 0


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
	if not pending_ascent_reward_choices.is_empty():
		return false
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


func can_spend_action() -> bool:
	return actions_remaining > 0 and pending_ascent_reward_choices.is_empty()


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
		"source_card_id": str(token.get("source_card_id", "")),
		"source_passive": token.get("source_passive", {}).duplicate(true),
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
	if equipped_emotion_slots.size() < MAX_EQUIPPED_EMOTION_SLOTS:
		equipped_emotion_slots.append(slot_id)
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


func get_equipped_emotion_slot_data() -> Array:
	var result: Array = []
	for slot_id in equipped_emotion_slots:
		if slot_id in owned_emotion_slots and EMOTION_SLOTS.has(slot_id):
			result.append(EMOTION_SLOTS[slot_id])
	return result


func toggle_equipped_emotion_slot(slot_id: String) -> bool:
	if slot_id not in owned_emotion_slots:
		return false
	if slot_id in equipped_emotion_slots:
		equipped_emotion_slots.erase(slot_id)
		return true
	if equipped_emotion_slots.size() >= MAX_EQUIPPED_EMOTION_SLOTS:
		return false
	equipped_emotion_slots.append(slot_id)
	return true


func get_craft_slots() -> Array:
	var slots: Array = [
		{"id": "object", "label": "对象", "placeholder": "哈吉米", "required": true},
		{"id": "saying", "label": "说法", "placeholder": "到底是什么意思", "required": true},
	]
	for slot_id in equipped_emotion_slots:
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


func get_draft_source_passives() -> Array:
	var result: Array = []
	for token_id in [str(draft_slots.get("object", "")), str(draft_slots.get("saying", ""))]:
		var passive := _find_token_source_passive(token_id)
		if passive.is_empty():
			continue
		var passive_id := str(passive.get("id", ""))
		var already_added := false
		for existing_passive in result:
			if str(existing_passive.get("id", "")) == passive_id:
				already_added = true
				break
		if not already_added:
			result.append(passive)
	return result


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
	var source_passives: Array = get_draft_source_passives()
	var emotion_parts: Array[String] = []
	for slot_id in equipped_emotion_slots:
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
		"emotion_count": emotion_parts.size(),
		"source_passives": source_passives,
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
	var breakdown := _calculate_publish_breakdown(meme, matching_tags)
	var score := int(breakdown.get("score", 1))
	var heat_gain := maxi(6, int(round(float(score) * 0.42)))
	var pollution_gain := 4 + matching_tags.size() * 2 + int(meme.get("pollution_bias", 0))
	pollution_gain += int(breakdown.get("contract_pollution_risk", 0))
	if not spend_action("confirm-dialogue"):
		return false
	last_publish_breakdown = breakdown.duplicate(true)
	if bool(breakdown.get("contract_matched", false)):
		event_log.push_front("牌型完成：%s，传播倍率 ×%.2f。" % [
			str(breakdown.get("contract_label", "未知牌型")),
			float(breakdown.get("contract_multiplier", 1.0)),
		])
	heat = clampi(heat + heat_gain, 0, 999)
	var previous_pollution := pollution
	pollution = clampi(pollution + pollution_gain, 0, 100)
	check_pollution_flashback(previous_pollution)
	var clarity_loss := maxi(1, int(round(float(pollution_gain) * 0.35))) + maxi(0, -int(meme.get("clarity_bias", 0)))
	clarity = clampi(clarity - clarity_loss, 0, 100)
	money += maxi(3, int(floor(float(heat_gain) * 0.22)))
	var record: Dictionary = meme.duplicate(true)
	record["floor"] = tower_floor
	record["score"] = score
	record["score_breakdown"] = breakdown.duplicate(true)
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
	for slot_id in equipped_emotion_slots:
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
	var legacy_strength := 0
	for rule in legacy_rules:
		legacy_strength += maxi(1, int(rule.get("strength", 1)))
	var legacy_relief := int(round(_modifier_total("legacy_relief")))
	var legacy_penalty_per_rule := maxi(4, 12 - legacy_relief)
	var legacy_penalty := legacy_strength * legacy_penalty_per_rule
	var distortion_penalty := 8 if last_clean_sentence != last_polluted_sentence else 0
	npc_understanding = clampi(100 - pollution_penalty - legacy_penalty - distortion_penalty, 0, 100)
	clarity = clampi(clarity - maxi(1, int(round(float(legacy_penalty + pollution_penalty) * 0.12))), 0, 100)
	reality_dialogue_count += 1
	last_relationship_residue_gain = maxi(0, int(ceil(float(maxi(0, 80 - npc_understanding)) / 12.0)) + legacy_rules.size())
	relationship_residue = clampi(relationship_residue + last_relationship_residue_gain, 0, 100)
	var raw_money_loss := maxi(0, int(ceil(float(maxi(0, 70 - npc_understanding)) / 18.0)))
	var relationship_shield := int(round(_modifier_total("relationship_shield")))
	last_relationship_money_loss = maxi(0, raw_money_loss - relationship_shield)
	money = maxi(0, money - last_relationship_money_loss)
	reality_sentence_slots.clear()
	reality_phase = "reality_result"
	return true


func get_relationship_state_label() -> String:
	if relationship_residue < 20:
		return "仍能认出你"
	if relationship_residue < 45:
		return "句子留下裂痕"
	if relationship_residue < 70:
		return "只剩熟悉的语气"
	return "彼此已无法确认"


func get_pending_ascent_reward_choices() -> Array:
	return pending_ascent_reward_choices.duplicate(true)


func choose_ascent_reward(reward_id: String) -> bool:
	var selected: Dictionary = {}
	for reward in pending_ascent_reward_choices:
		if str(reward.get("id", "")) == reward_id:
			selected = reward
			break
	if selected.is_empty():
		return false
	permanent_modifiers.append(selected.duplicate(true))
	event_log.push_front("第 %d 层许可：%s" % [pending_ascent_reward_floor, str(selected.get("label", "永久修正"))])
	pending_ascent_reward_choices.clear()
	pending_ascent_reward_floor = 0
	if not queued_ascent_reward_floors.is_empty():
		var next_floor := int(queued_ascent_reward_floors.pop_front())
		_set_pending_ascent_reward(next_floor)
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


func _find_token_source_passive(token_id: String) -> Dictionary:
	for token in notebook_tokens:
		if str(token.get("id", "")) == token_id:
			return (token.get("source_passive", {}) as Dictionary).duplicate(true)
	return {}


func _current_accepted_tags() -> Array:
	return ACCEPTED_TAG_ROTATION[(day - 1) % ACCEPTED_TAG_ROTATION.size()].duplicate()


func get_publish_breakdown(meme: Dictionary) -> Dictionary:
	if meme.is_empty():
		return {}
	var matching_tags := _intersect(meme.get("tags", []), _current_accepted_tags())
	return _calculate_publish_breakdown(meme, matching_tags)


func get_daily_signal_contract() -> Dictionary:
	return SIGNAL_CONTRACTS[(day - 1) % SIGNAL_CONTRACTS.size()].duplicate(true)


func _score_meme_publish(meme: Dictionary, matching_tags: Array) -> int:
	return int(_calculate_publish_breakdown(meme, matching_tags).get("score", 1))


func _calculate_publish_breakdown(meme: Dictionary, matching_tags: Array) -> Dictionary:
	var rarity := int(meme.get("rarity", 1))
	var repeat_count := 0
	for record in published_memes:
		if str(record.get("text", "")) == str(meme.get("text", "")):
			repeat_count += 1
	var tags: Array = meme.get("tags", [])
	var contract_result := _evaluate_signal_contract(meme, matching_tags, repeat_count)
	var source_base_bonus := 0.0
	var source_synergy_step := 0.0
	var source_pollution_bonus := 0.0
	var source_repeat_relief := 0.0
	var active_source_passive_labels: Array[String] = []
	for passive in meme.get("source_passives", []):
		var effect_id := str(passive.get("effect", ""))
		var value := float(passive.get("value", 0.0))
		match effect_id:
			"base_bonus":
				source_base_bonus += value
			"synergy_step":
				source_synergy_step += value
			"pollution_bonus":
				source_pollution_bonus += value
			"repeat_relief":
				source_repeat_relief += value
		if effect_id != "synergy_step" or not matching_tags.is_empty():
			active_source_passive_labels.append(str(passive.get("label", "来源被动")))
	var empty_base_bonus := int(round(_modifier_total("empty_base"))) if ("空位" in tags or "沉默" in tags) else 0
	var contract_base_bonus := int(contract_result.get("base_bonus", 0)) if bool(contract_result.get("matched", false)) else 0
	var base_value := 12 + rarity * 6 + matching_tags.size() * 8 + empty_base_bonus + int(round(source_base_bonus)) + contract_base_bonus
	var synergy_step := 0.25 + _modifier_total("synergy_step") + source_synergy_step
	var synergy_multiplier := 1.0 + matching_tags.size() * synergy_step
	var pollution_multiplier := 1.0 + float(pollution) / 100.0 * 0.65 + _modifier_total("pollution_bonus") + source_pollution_bonus
	var emotion_bonus := minf(0.60, float(maxi(0, int(meme.get("pollution_bias", 0)))) * 0.04)
	emotion_bonus += float(maxi(0, int(meme.get("emotion_count", 0)))) * _modifier_total("emotion_step")
	var emotion_multiplier := 1.0 + emotion_bonus
	var effective_repeat_count := maxi(0, repeat_count - int(round(_modifier_total("repeat_grace"))))
	var repeat_multiplier := minf(1.0, maxf(0.28, 1.0 - effective_repeat_count * 0.18 + source_repeat_relief))
	var contract_multiplier := float(contract_result.get("multiplier", 1.0)) if bool(contract_result.get("matched", false)) else 1.0
	var total_multiplier := snappedf(synergy_multiplier * pollution_multiplier * emotion_multiplier * repeat_multiplier * contract_multiplier, 0.01)
	var score := maxi(1, int(round(base_value * total_multiplier)))
	var active_modifier_labels: Array[String] = []
	for modifier in permanent_modifiers:
		var effect_id := str(modifier.get("effect", ""))
		var is_active := effect_id == "pollution_bonus"
		is_active = is_active or (effect_id == "synergy_step" and not matching_tags.is_empty())
		is_active = is_active or (effect_id == "repeat_grace" and repeat_count > 0)
		is_active = is_active or (effect_id == "empty_base" and empty_base_bonus > 0)
		is_active = is_active or (effect_id == "emotion_step" and int(meme.get("emotion_count", 0)) > 0)
		if is_active:
			active_modifier_labels.append(str(modifier.get("label", "永久许可")))
	return {
		"base_value": base_value,
		"matching_tags": matching_tags.duplicate(),
		"synergy_multiplier": snappedf(synergy_multiplier, 0.01),
		"pollution_multiplier": snappedf(pollution_multiplier, 0.01),
		"emotion_multiplier": snappedf(emotion_multiplier, 0.01),
		"repeat_multiplier": snappedf(repeat_multiplier, 0.01),
		"contract_id": str(contract_result.get("id", "")),
		"contract_label": str(contract_result.get("label", "未命名牌型")),
		"contract_description": str(contract_result.get("description", "")),
		"contract_progress": str(contract_result.get("progress", "")),
		"contract_matched": bool(contract_result.get("matched", false)),
		"contract_base_bonus": contract_base_bonus,
		"contract_multiplier": snappedf(contract_multiplier, 0.01),
		"contract_pollution_risk": int(contract_result.get("pollution_risk", 0)) if bool(contract_result.get("matched", false)) else 0,
		"total_multiplier": total_multiplier,
		"repeat_count": repeat_count,
		"effective_repeat_count": effective_repeat_count,
		"modifier_base_bonus": empty_base_bonus,
		"active_modifier_labels": active_modifier_labels,
		"active_source_passive_labels": active_source_passive_labels,
		"score": score,
	}


func _evaluate_signal_contract(meme: Dictionary, matching_tags: Array, repeat_count: int) -> Dictionary:
	var contract := get_daily_signal_contract()
	var tags: Array = meme.get("tags", [])
	var rule := str(contract.get("rule", ""))
	var threshold := int(contract.get("threshold", 0))
	var current := 0
	var matched := false
	var progress := ""
	match rule:
		"matching_tags":
			current = matching_tags.size()
			matched = current >= threshold
			progress = "%d/%d 今日风向" % [mini(current, threshold), threshold]
		"tag_count":
			current = tags.size()
			matched = current >= threshold
			progress = "%d/%d 隐藏标签" % [mini(current, threshold), threshold]
		"emotion_count":
			current = int(meme.get("emotion_count", 0))
			matched = current >= threshold
			progress = "%d/%d 情绪槽" % [mini(current, threshold), threshold]
		"all_tags":
			var required_tags: Array = contract.get("required_tags", [])
			for required_tag in required_tags:
				if required_tag in tags:
					current += 1
			matched = current >= required_tags.size()
			progress = "%d/%d 必要标签" % [current, required_tags.size()]
		"repeat_any_tag":
			var required_tags: Array = contract.get("required_tags", [])
			var has_required_tag := false
			for required_tag in required_tags:
				if required_tag in tags:
					has_required_tag = true
					break
			current = repeat_count
			matched = repeat_count >= threshold and has_required_tag
			progress = "%d/%d 复读 · %s" % [mini(repeat_count, threshold), threshold, "标签命中" if has_required_tag else "缺反问/禁问"]
	contract["matched"] = matched
	contract["progress"] = progress
	return contract


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
			_queue_ascent_reward(previous_floor)
		threshold_discount = maxi(0, threshold_discount - 8)
		event_log.push_front("第二天，巴别塔把你标记到第 %d 层。" % tower_floor)
	elif tower_floor > 1 and progress < int(float(threshold) * 0.62):
		tower_floor = clampi(tower_floor - 1, 1, MAX_TOWER_FLOOR)
		threshold_discount = clampi(threshold_discount + 16, 0, 70)
		event_log.push_front("第二天，楼层退回第 %d 层，但遗产规则没有消失。" % tower_floor)
	else:
		threshold_discount = clampi(threshold_discount + 6, 0, 70)
		event_log.push_front("第二天，塔没有移动，只是把门槛悄悄放低。")
	var guaranteed_floor := _minimum_floor_for_day(day)
	while tower_floor < guaranteed_floor:
		var catchup_floor := tower_floor
		tower_floor += 1
		register_legacy_rule_for_ascent(catchup_floor)
		_queue_ascent_reward(catchup_floor)
		event_log.push_front("第 %d 天，塔强制收录你到第 %d 层。" % [day, tower_floor])
	next_threshold = _tower_threshold(tower_floor)
	if tower_floor >= MAX_TOWER_FLOOR:
		ending_unlocked = true


func _queue_ascent_reward(previous_floor: int) -> void:
	# The final ascent immediately enters the ending, so rewards live on floors 2-4.
	if previous_floor < 1 or previous_floor >= MAX_TOWER_FLOOR - 1:
		return
	if previous_floor in rewarded_ascent_floors:
		return
	rewarded_ascent_floors.append(previous_floor)
	if pending_ascent_reward_choices.is_empty():
		_set_pending_ascent_reward(previous_floor)
	elif previous_floor not in queued_ascent_reward_floors:
		queued_ascent_reward_floors.append(previous_floor)


func _set_pending_ascent_reward(previous_floor: int) -> void:
	pending_ascent_reward_floor = previous_floor + 1
	pending_ascent_reward_choices.clear()
	var owned_ids: Array[String] = []
	for modifier in permanent_modifiers:
		owned_ids.append(str(modifier.get("id", "")))
	var start_index := (previous_floor * 2 + day) % ASCENT_REWARDS.size()
	for offset in ASCENT_REWARDS.size():
		var reward: Dictionary = ASCENT_REWARDS[(start_index + offset) % ASCENT_REWARDS.size()]
		var reward_id := str(reward.get("id", ""))
		if reward_id in owned_ids:
			continue
		pending_ascent_reward_choices.append(reward.duplicate(true))
		if pending_ascent_reward_choices.size() == 3:
			break
	if not pending_ascent_reward_choices.is_empty():
		event_log.push_front("第 %d 层开放三项许可，必须保留其中一项。" % pending_ascent_reward_floor)


func _modifier_total(effect_id: String) -> float:
	var total := 0.0
	for modifier in permanent_modifiers:
		if str(modifier.get("effect", "")) == effect_id:
			total += float(modifier.get("value", 0.0))
	return total


func _tower_threshold(floor: int) -> int:
	var index := clampi(floor, 1, MAX_TOWER_FLOOR)
	return maxi(18, int(TOWER_THRESHOLDS[index]) - threshold_discount)


func _progress_score() -> int:
	return int(round(float(heat) + float(pollution) * 0.55 + float(100 - clarity) * 0.18))


func _minimum_floor_for_day(current_day: int) -> int:
	var result := 1
	for deadline in FLOOR_DEADLINES.keys():
		if current_day >= int(deadline):
			result = maxi(result, int(FLOOR_DEADLINES[deadline]))
	return result


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
