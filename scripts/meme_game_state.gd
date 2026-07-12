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
		"multiplier_bonus": 1,
		"pollution_risk": 2,
	},
	{
		"id": "wideband",
		"label": "杂讯列阵",
		"description": "成品含至少 4 种隐藏标签",
		"rule": "tag_count",
		"threshold": 4,
		"base_bonus": 10,
		"multiplier_bonus": 1,
		"pollution_risk": 3,
	},
	{
		"id": "emotion_flush",
		"label": "情绪同花",
		"description": "同时装入 2 个情绪槽",
		"rule": "emotion_count",
		"threshold": 2,
		"base_bonus": 8,
		"multiplier_bonus": 2,
		"pollution_risk": 4,
	},
	{
		"id": "empty_pair",
		"label": "空位对子",
		"description": "同时含有「空位」和「沉默」",
		"rule": "all_tags",
		"required_tags": ["空位", "沉默"],
		"base_bonus": 18,
		"multiplier_bonus": 1,
		"pollution_risk": 3,
	},
	{
		"id": "babel_straight",
		"label": "巴别直线",
		"description": "集齐「巴别塔」「信徒」「圣歌」",
		"rule": "all_tags",
		"required_tags": ["巴别塔", "信徒", "圣歌"],
		"base_bonus": 22,
		"multiplier_bonus": 2,
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
		"multiplier_bonus": 2,
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
const MAX_HELD_ARCANA_CARDS := 2
const ARCANA_CARDS := {
	"moon": {
		"id": "moon", "numeral": "XVIII", "label": "月亮", "price": 8,
		"effect": "next_multiplier_bonus", "value": 1, "pollution_risk": 4,
		"description": "下一次传播的整数倍率 +1，同时追加 4 污染。",
	},
	"tower": {
		"id": "tower", "numeral": "XVI", "label": "高塔", "price": 10,
		"effect": "force_contract", "pollution_risk": 7,
		"description": "下一次发布强制成立今日牌型，同时追加 7 污染。",
	},
	"hermit": {
		"id": "hermit", "numeral": "IX", "label": "隐者", "price": 7,
		"effect": "repeat_grace", "value": 1, "pollution_risk": 0,
		"description": "下一次发布忽略 1 次复读衰减。",
	},
	"hanged": {
		"id": "hanged", "numeral": "XII", "label": "倒吊人", "price": 6,
		"effect": "clarity_for_base", "value": 24, "clarity_cost": 8, "pollution_risk": 0,
		"description": "立即失去 8 清晰，下一次传播基础 +24。",
	},
	"star": {
		"id": "star", "numeral": "XVII", "label": "星星", "price": 8,
		"effect": "add_trend_tag", "requires_meme": true, "pollution_risk": 0,
		"description": "为选中的完整梗永久写入 1 个缺失的今日风向。",
	},
	"judgement": {
		"id": "judgement", "numeral": "XX", "label": "审判", "price": 7,
		"effect": "reroll_contract", "pollution_risk": 0,
		"description": "立刻改写今日牌型；本次使用不消耗行动。",
	},
}
const ARCANA_ROTATION := ["moon", "star", "hermit", "tower", "hanged", "judgement"]
const ASCENT_REWARDS := [
	{"id": "echo_amplifier", "label": "回声增幅", "description": "命中至少 2 个风向时，整数倍率额外 +1。", "effect": "trend_multiplier_bonus", "value": 1.0},
	{"id": "pollution_dividend", "label": "污染分红", "description": "污染达到 40% 时，传播基础 +10。", "effect": "pollution_base", "value": 10.0},
	{"id": "repeat_license", "label": "复读许可", "description": "第一次复用相同表达不触发衰减。", "effect": "repeat_grace", "value": 1.0},
	{"id": "legacy_fold", "label": "遗产折叠", "description": "每条遗产造成的理解惩罚减少 4。", "effect": "legacy_relief", "value": 4.0},
	{"id": "quiet_subsidy", "label": "沉默补贴", "description": "现实沟通造成的资金损失减少 2。", "effect": "relationship_shield", "value": 2.0},
	{"id": "empty_slot_bonus", "label": "空位加码", "description": "带有空位或沉默标签时，传播基础 +8。", "effect": "empty_base", "value": 8.0},
	{"id": "emotion_afterimage", "label": "情绪余像", "description": "每个装备情绪让传播基础 +4。", "effect": "emotion_base", "value": 4.0},
]
const CLEAN_WORDS := ["我", "想", "正常", "说明", "这件事", "不是", "那个意思", "请", "听我", "说完"]
const FALLBACK_LEGACY_TEXTS := {
	1: {"text": "哈吉米，必须补票", "tags": ["哈吉米", "追问"]},
	2: {"text": "在线本身就是发言", "tags": ["沉默", "空位"]},
	3: {"text": "请用更新后的句式进入", "tags": ["巴别塔", "刷新"]},
	4: {"text": "你为什么需要他说话", "tags": ["反问", "禁问"]},
}
const REALITY_RESPONSE_SETS := {
	"npc": [
		{"id": "explain", "summary": "直接说明", "sentence": "我只是想把刚才的事情说清楚。"},
		{"id": "apologize", "summary": "先道歉", "sentence": "对不起，我没有想让你觉得被忽视。"},
		{"id": "listen", "summary": "请你再说", "sentence": "请你再说一遍，我想认真听完。"},
	],
	"merchant": [
		{"id": "ask_goods", "summary": "询问商品", "sentence": "我想看看能帮助沟通的东西。"},
		{"id": "state_need", "summary": "说明来意", "sentence": "我需要让别人更容易听懂我。"},
		{"id": "test_price", "summary": "试探价格", "sentence": "这些东西分别需要多少钱？"},
	],
}
const REALITY_CORRUPTION_GLYPHS := ["■", "▦", "∴", "//", "哈", "吉", "米", "空位"]
const COMMUNICATION_ITEMS := {
	"silence_patch": {
		"id": "silence_patch", "label": "静音贴", "price": 6, "charges": 2, "clarity_bonus": 18,
		"description": "原本听不懂时，自动把理解机会提高 18%。",
	},
	"semantic_anchor": {
		"id": "semantic_anchor", "label": "语义锚", "price": 9, "charges": 3, "clarity_bonus": 14,
		"description": "原本听不懂时，自动把理解机会提高 14%。",
	},
	"dictionary_leaf": {
		"id": "dictionary_leaf", "label": "旧词典页", "price": 12, "charges": 1, "clarity_bonus": 32,
		"description": "仅能使用一次，但把理解机会提高 32%。",
	},
}
const COMMUNICATION_ITEM_ROTATION := ["silence_patch", "semantic_anchor", "dictionary_leaf"]
const ENDING_LANGUAGE_CHOICES := [
	{"id": "blank", "label": "空白", "output": "（空白）"},
	{"id": "blocks", "label": "■■■■", "output": "■ ■ ■ ■"},
	{"id": "hajimi", "label": "哈吉米", "output": "哈吉米"},
	{"id": "silence", "label": "沉默", "output": "……"},
]

var day: int = 1
var heat: int = 18
var pollution: int = 0
var clarity: int = 100
var tower_floor: int = 1
var threshold_discount: int = 0
var next_threshold: int = 36
var ending_unlocked: bool = false
var ending_language_choice: String = ""
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
var social_followed_handles: Array[String] = []
var social_liked_post_ids: Array[String] = []

var owned_emotion_slots: Array = []
var equipped_emotion_slots: Array = []
var emotion_slot_texts: Dictionary = {}
var daily_emotion_slot_id: String = "anxiety"

var owned_arcana_cards: Array = []
var daily_arcana_card_id: String = "moon"
var daily_arcana_bought: bool = false
var pending_arcana_effects: Dictionary = {}
var signal_contract_offset: int = 0
var arcana_sequence: int = 0
var collected_world_item_ids: Array[String] = []
var pending_world_item_effects: Dictionary = {}

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
var conversation_phase: String = "idle"
var conversation_actor_id: String = ""
var conversation_actor_type: String = "npc"
var conversation_actor_label: String = ""
var conversation_choices: Array = []
var conversation_selected_choice_id: String = ""
var conversation_clean_sentence: String = ""
var conversation_revealed_units: Array = []
var conversation_reveal_index: int = 0
var conversation_attempts: int = 0
var conversation_understood: bool = false
var conversation_understanding_rolls: Array[int] = []
var conversation_feedback: String = ""
var owned_communication_items: Array = []
var daily_communication_item_bought: bool = false
var last_communication_item_used: String = ""
var last_communication_item_remaining: int = 0


func new_run() -> void:
	day = 1
	heat = 18
	pollution = 0
	clarity = 100
	tower_floor = 1
	threshold_discount = 0
	next_threshold = _tower_threshold(tower_floor)
	ending_unlocked = false
	ending_language_choice = ""
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
	social_followed_handles = []
	social_liked_post_ids = []
	owned_emotion_slots = []
	equipped_emotion_slots = []
	emotion_slot_texts = {}
	daily_emotion_slot_id = _emotion_slot_for_day(day)
	owned_arcana_cards = []
	daily_arcana_card_id = _arcana_for_day(day)
	daily_arcana_bought = false
	pending_arcana_effects = {}
	signal_contract_offset = 0
	arcana_sequence = 0
	collected_world_item_ids = []
	pending_world_item_effects = {}
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
	owned_communication_items = []
	daily_communication_item_bought = false
	last_communication_item_used = ""
	last_communication_item_remaining = 0
	reset_typed_reality_conversation()


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


func is_world_item_collected(item_id: String) -> bool:
	return item_id in collected_world_item_ids


func collect_world_item(item_data: Dictionary) -> bool:
	var item_id := str(item_data.get("id", "")).strip_edges()
	var effect := str(item_data.get("effect", "")).strip_edges()
	var label := str(item_data.get("label", "街区遗物")).strip_edges()
	if item_id.is_empty() or item_id in collected_world_item_ids:
		return false
	match effect:
		"publish_base":
			pending_world_item_effects["base_bonus"] = int(pending_world_item_effects.get("base_bonus", 0)) + int(item_data.get("value", 0))
		"publish_multiplier_bonus":
			pending_world_item_effects["multiplier_bonus"] = int(pending_world_item_effects.get("multiplier_bonus", 0)) + int(item_data.get("value", 0))
		"clarity":
			clarity = clampi(clarity + int(item_data.get("value", 0)), 0, 100)
		_:
			return false
	collected_world_item_ids.append(item_id)
	if effect != "clarity":
		var labels: Array = pending_world_item_effects.get("labels", []).duplicate()
		if label not in labels:
			labels.append(label)
		pending_world_item_effects["labels"] = labels
	event_log.push_front("拾取街区遗物：%s。%s" % [label, str(item_data.get("description", "信号已经写入。"))])
	return true


func get_ending_language_choices() -> Array:
	return ENDING_LANGUAGE_CHOICES.duplicate(true)


func choose_ending_language(choice_id: String) -> bool:
	if not ending_unlocked or not ending_language_choice.is_empty():
		return false
	for choice in ENDING_LANGUAGE_CHOICES:
		if str(choice.get("id", "")) == choice_id:
			ending_language_choice = choice_id
			return true
	return false


func get_ending_language_output() -> String:
	for choice in ENDING_LANGUAGE_CHOICES:
		if str(choice.get("id", "")) == ending_language_choice:
			return str(choice.get("output", ""))
	return ""


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


func is_social_following(handle: String) -> bool:
	return handle in social_followed_handles


func toggle_social_follow(handle: String) -> bool:
	var normalized := handle.strip_edges()
	if normalized.is_empty():
		return false
	if normalized in social_followed_handles:
		social_followed_handles.erase(normalized)
		return false
	social_followed_handles.append(normalized)
	return true


func is_social_post_liked(post_id: String) -> bool:
	return post_id in social_liked_post_ids


func toggle_social_like(post_id: String) -> bool:
	var normalized := post_id.strip_edges()
	if normalized.is_empty():
		return false
	if normalized in social_liked_post_ids:
		social_liked_post_ids.erase(normalized)
		return false
	social_liked_post_ids.append(normalized)
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


func start_typed_reality_conversation(actor_id: String, actor_type: String, actor_label: String) -> bool:
	if not can_spend_action():
		return false
	conversation_actor_id = actor_id
	conversation_actor_type = "merchant" if actor_type == "merchant" else "npc"
	conversation_actor_label = actor_label
	conversation_choices = (REALITY_RESPONSE_SETS.get(conversation_actor_type, REALITY_RESPONSE_SETS["npc"]) as Array).duplicate(true)
	conversation_selected_choice_id = ""
	conversation_clean_sentence = ""
	conversation_revealed_units = []
	conversation_reveal_index = 0
	conversation_attempts = 0
	conversation_understood = false
	conversation_understanding_rolls = []
	conversation_feedback = ""
	last_communication_item_used = ""
	last_communication_item_remaining = 0
	conversation_phase = "choosing"
	return true


func reset_typed_reality_conversation() -> void:
	conversation_phase = "idle"
	conversation_actor_id = ""
	conversation_actor_type = "npc"
	conversation_actor_label = ""
	conversation_choices = []
	conversation_selected_choice_id = ""
	conversation_clean_sentence = ""
	conversation_revealed_units = []
	conversation_reveal_index = 0
	conversation_attempts = 0
	conversation_understood = false
	conversation_understanding_rolls = []
	conversation_feedback = ""
	last_communication_item_used = ""
	last_communication_item_remaining = 0


func get_typed_reality_choices() -> Array:
	return conversation_choices.duplicate(true)


func get_daily_communication_item() -> Dictionary:
	var index := posmod(day + tower_floor - 2, COMMUNICATION_ITEM_ROTATION.size())
	var item_id := str(COMMUNICATION_ITEM_ROTATION[index])
	return (COMMUNICATION_ITEMS.get(item_id, {}) as Dictionary).duplicate(true)


func buy_daily_communication_item() -> bool:
	if daily_communication_item_bought:
		return false
	var item := get_daily_communication_item()
	if item.is_empty():
		return false
	var price := int(item.get("price", 0))
	if money < price or not spend_action("buy-communication-item"):
		return false
	money -= price
	daily_communication_item_bought = true
	var item_id := str(item.get("id", ""))
	var stacked := false
	for index in owned_communication_items.size():
		var owned: Dictionary = owned_communication_items[index]
		if str(owned.get("id", "")) != item_id:
			continue
		owned["charges"] = int(owned.get("charges", 0)) + int(item.get("charges", 0))
		owned_communication_items[index] = owned
		stacked = true
		break
	if not stacked:
		owned_communication_items.append(item.duplicate(true))
	event_log.push_front("你从信号商人那里买到%s，可用 %d 次。" % [str(item.get("label", "沟通辅助")), int(item.get("charges", 0))])
	return true


func get_active_communication_item() -> Dictionary:
	var best: Dictionary = {}
	for item in owned_communication_items:
		if int(item.get("charges", 0)) <= 0:
			continue
		if best.is_empty() or int(item.get("clarity_bonus", 0)) > int(best.get("clarity_bonus", 0)):
			best = item
	return best.duplicate(true)


func get_communication_item_status() -> String:
	var item := get_active_communication_item()
	if item.is_empty():
		return ""
	return "%s ×%d" % [str(item.get("label", "沟通辅助")), int(item.get("charges", 0))]


func should_show_merchant_communication_offer() -> bool:
	return conversation_actor_type == "merchant" and conversation_phase == "result" and conversation_understood and conversation_selected_choice_id == "ask_goods"


func preview_typed_reality_choice(choice_id: String) -> String:
	for choice in conversation_choices:
		if str(choice.get("id", "")) == choice_id:
			return _sentence_with_legacy(str(choice.get("sentence", "")))
	return ""


func select_typed_reality_choice(choice_id: String) -> bool:
	if conversation_phase != "choosing":
		return false
	var sentence := preview_typed_reality_choice(choice_id)
	if sentence.is_empty():
		return false
	conversation_selected_choice_id = choice_id
	conversation_clean_sentence = sentence
	conversation_revealed_units = []
	conversation_reveal_index = 0
	conversation_understood = false
	conversation_understanding_rolls = []
	conversation_phase = "typing"
	return true


func advance_typed_reality_character() -> Dictionary:
	var result := {
		"advanced": false,
		"completed": false,
		"action_spent": false,
		"understood": false,
		"locked_out": false,
	}
	if conversation_phase != "typing":
		return result
	if conversation_reveal_index >= conversation_clean_sentence.length():
		return result
	var clean_character := conversation_clean_sentence.substr(conversation_reveal_index, 1)
	var roll := _conversation_roll("character", conversation_reveal_index, 0)
	var corrupted := roll < pollution
	var display_character := clean_character
	if corrupted:
		display_character = _conversation_corruption_text(roll, conversation_reveal_index)
	conversation_revealed_units.append({
		"clean": clean_character,
		"display": display_character,
		"corrupted": corrupted,
		"roll": roll,
	})
	conversation_reveal_index += 1
	result["advanced"] = true
	if conversation_reveal_index < conversation_clean_sentence.length():
		return result

	result["completed"] = true
	if not spend_action("typed-reality-dialogue"):
		conversation_phase = "result"
		conversation_feedback = "今天已经没有能说出口的行动。"
		return result
	result["action_spent"] = true
	conversation_attempts += 1
	reality_dialogue_count += 1
	last_clean_sentence = conversation_clean_sentence
	last_polluted_sentence = get_typed_reality_spoken_sentence()
	var understood := _resolve_typed_reality_understanding()
	conversation_understood = understood
	result["understood"] = understood
	if understood:
		conversation_phase = "result"
		conversation_feedback = "%s听懂了你的意思。%s" % [conversation_actor_label, _communication_item_feedback()]
		return result

	last_relationship_residue_gain = clampi(1 + int(pollution / 18.0) + legacy_rules.size(), 1, 14)
	relationship_residue = clampi(relationship_residue + last_relationship_residue_gain, 0, 100)
	if conversation_attempts >= 3:
		conversation_phase = "locked_out"
		conversation_feedback = "%s第三次移开了视线。%s" % [conversation_actor_label, _communication_item_feedback()]
		result["locked_out"] = true
		return result

	conversation_phase = "choosing"
	conversation_feedback = "%s没有听懂。再试一次（%d/3）。%s" % [conversation_actor_label, conversation_attempts, _communication_item_feedback()]
	conversation_selected_choice_id = ""
	conversation_clean_sentence = ""
	conversation_revealed_units = []
	conversation_reveal_index = 0
	return result


func get_typed_reality_spoken_sentence() -> String:
	var pieces: Array[String] = []
	for unit in conversation_revealed_units:
		pieces.append(str(unit.get("display", "")))
	return "".join(pieces)


func get_typed_reality_unrevealed_suffix() -> String:
	if conversation_clean_sentence.is_empty() or conversation_reveal_index >= conversation_clean_sentence.length():
		return ""
	return conversation_clean_sentence.substr(conversation_reveal_index)


func _sentence_with_legacy(base_sentence: String) -> String:
	var sentence := base_sentence.strip_edges()
	while sentence.ends_with("。") or sentence.ends_with("！") or sentence.ends_with("？"):
		sentence = sentence.substr(0, sentence.length() - 1)
	for rule in legacy_rules:
		var required_text := str(rule.get("required_text", "")).strip_edges()
		if required_text.is_empty() or sentence.contains(required_text):
			continue
		sentence += "，" + required_text
	return sentence + "。"


func _conversation_corruption_text(roll: int, character_index: int) -> String:
	if not completed_memes.is_empty() and posmod(roll + character_index, 3) == 0:
		var meme_index := posmod(roll + conversation_attempts + character_index, completed_memes.size())
		var meme: Dictionary = completed_memes[meme_index]
		var meme_text := str(meme.get("title", meme.get("text", ""))).strip_edges()
		if not meme_text.is_empty():
			return meme_text.substr(0, mini(4, meme_text.length()))
	return REALITY_CORRUPTION_GLYPHS[posmod(roll + character_index, REALITY_CORRUPTION_GLYPHS.size())]


func _resolve_typed_reality_understanding() -> bool:
	conversation_understanding_rolls = []
	last_communication_item_used = ""
	last_communication_item_remaining = 0
	var legacy_penalty := legacy_rules.size() * 6
	var base_clear_chance := clampi(100 - pollution - legacy_penalty, 5, 96)
	var check_count := 3 if conversation_actor_type == "merchant" else 1
	var understood := false
	for check_index in check_count:
		var roll := _conversation_roll("understanding", conversation_reveal_index, check_index)
		conversation_understanding_rolls.append(roll)
		if roll < base_clear_chance:
			understood = true
	var effective_clear_chance := base_clear_chance
	if not understood:
		var aid := get_active_communication_item()
		if not aid.is_empty():
			effective_clear_chance = clampi(base_clear_chance + int(aid.get("clarity_bonus", 0)), 5, 98)
			_consume_communication_item(str(aid.get("id", "")))
			for roll in conversation_understanding_rolls:
				if roll < effective_clear_chance:
					understood = true
	npc_understanding = effective_clear_chance
	return understood


func _consume_communication_item(item_id: String) -> void:
	for index in owned_communication_items.size():
		var item: Dictionary = owned_communication_items[index]
		if str(item.get("id", "")) != item_id or int(item.get("charges", 0)) <= 0:
			continue
		item["charges"] = maxi(0, int(item.get("charges", 0)) - 1)
		owned_communication_items[index] = item
		last_communication_item_used = str(item.get("label", "沟通辅助"))
		last_communication_item_remaining = int(item.get("charges", 0))
		return


func _communication_item_feedback() -> String:
	if last_communication_item_used.is_empty():
		return ""
	return "（%s生效，剩余 %d 次）" % [last_communication_item_used, last_communication_item_remaining]


func _conversation_roll(channel: String, character_index: int, check_index: int) -> int:
	var key := "%s|%s|%d|%d|%d|%d|%s" % [
		conversation_actor_id,
		conversation_selected_choice_id,
		day,
		conversation_attempts,
		character_index,
		check_index,
		channel,
	]
	return posmod(int(hash(key)), 100)


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
	reset_typed_reality_conversation()
	daily_emotion_slot_id = _emotion_slot_for_day(day)
	daily_arcana_card_id = _arcana_for_day(day)
	daily_arcana_bought = false
	daily_communication_item_bought = false
	last_communication_item_used = ""
	last_communication_item_remaining = 0
	signal_contract_offset = 0
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


func get_daily_arcana_card() -> Dictionary:
	return (ARCANA_CARDS.get(daily_arcana_card_id, {}) as Dictionary).duplicate(true)


func get_owned_arcana_card_data() -> Array:
	var result: Array = []
	for held in owned_arcana_cards:
		var card: Dictionary = ARCANA_CARDS.get(str(held.get("id", "")), {})
		if card.is_empty():
			continue
		var item := card.duplicate(true)
		item["uid"] = str(held.get("uid", ""))
		item["bought_day"] = int(held.get("bought_day", day))
		result.append(item)
	return result


func buy_daily_arcana_card() -> bool:
	if daily_arcana_bought or owned_arcana_cards.size() >= MAX_HELD_ARCANA_CARDS:
		return false
	var card := get_daily_arcana_card()
	if card.is_empty():
		return false
	var price := int(card.get("price", 7))
	if money < price:
		return false
	if not spend_action("buy-arcana-card"):
		return false
	money -= price
	arcana_sequence += 1
	owned_arcana_cards.append({
		"uid": "arcana-%s-%d-%d" % [str(card.get("id", "card")), day, arcana_sequence],
		"id": str(card.get("id", "")),
		"bought_day": day,
	})
	daily_arcana_bought = true
	event_log.push_front("玄牌入手：%s。它会一直留在手里，直到被使用。" % str(card.get("label", "未命名")))
	return true


func can_use_arcana_card(card_uid: String, meme_id: String = "") -> bool:
	var held_index := _find_held_arcana_index(card_uid)
	if held_index < 0:
		return false
	var held: Dictionary = owned_arcana_cards[held_index]
	var card: Dictionary = ARCANA_CARDS.get(str(held.get("id", "")), {})
	if card.is_empty():
		return false
	match str(card.get("effect", "")):
		"add_trend_tag":
			return _find_missing_trend_tag(meme_id) != ""
		"clarity_for_base":
			return clarity >= int(card.get("clarity_cost", 0))
	return true


func use_arcana_card(card_uid: String, meme_id: String = "") -> bool:
	var held_index := _find_held_arcana_index(card_uid)
	if held_index < 0 or not can_use_arcana_card(card_uid, meme_id):
		return false
	var held: Dictionary = owned_arcana_cards[held_index]
	var card: Dictionary = ARCANA_CARDS.get(str(held.get("id", "")), {})
	var label := str(card.get("label", "未命名玄牌"))
	match str(card.get("effect", "")):
		"next_multiplier_bonus":
			_ensure_pending_arcana_effects()
			pending_arcana_effects["multiplier_bonus"] = int(pending_arcana_effects.get("multiplier_bonus", 0)) + int(card.get("value", 0))
			pending_arcana_effects["pollution_risk"] = int(pending_arcana_effects.get("pollution_risk", 0)) + int(card.get("pollution_risk", 0))
			_append_pending_arcana_label(label)
		"force_contract":
			_ensure_pending_arcana_effects()
			pending_arcana_effects["force_contract"] = true
			pending_arcana_effects["pollution_risk"] = int(pending_arcana_effects.get("pollution_risk", 0)) + int(card.get("pollution_risk", 0))
			_append_pending_arcana_label(label)
		"repeat_grace":
			_ensure_pending_arcana_effects()
			pending_arcana_effects["repeat_grace"] = int(pending_arcana_effects.get("repeat_grace", 0)) + int(card.get("value", 1))
			_append_pending_arcana_label(label)
		"clarity_for_base":
			clarity = clampi(clarity - int(card.get("clarity_cost", 0)), 0, 100)
			_ensure_pending_arcana_effects()
			pending_arcana_effects["base_bonus"] = int(pending_arcana_effects.get("base_bonus", 0)) + int(card.get("value", 0))
			_append_pending_arcana_label(label)
		"add_trend_tag":
			var target_index := _find_completed_meme_index(meme_id)
			var tag_to_add := _find_missing_trend_tag(meme_id)
			if target_index < 0 or tag_to_add.is_empty():
				return false
			var target: Dictionary = completed_memes[target_index]
			var tags: Array = target.get("tags", []).duplicate()
			tags.append(tag_to_add)
			target["tags"] = _unique(tags)
			target["rarity"] = _meme_rarity_from_tags(target["tags"])
			target["pollution_bias"] = int(target.get("pollution_bias", 0)) + 1
			var marks: Array = target.get("arcana_marks", []).duplicate()
			marks.append(label)
			target["arcana_marks"] = _unique(marks)
			completed_memes[target_index] = target
		"reroll_contract":
			signal_contract_offset = posmod(signal_contract_offset + 1, SIGNAL_CONTRACTS.size())
	owned_arcana_cards.remove_at(held_index)
	event_log.push_front("玄牌生效：%s。" % label)
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
	pollution_gain += int(breakdown.get("arcana_pollution_risk", 0))
	if not spend_action("confirm-dialogue"):
		return false
	last_publish_breakdown = breakdown.duplicate(true)
	if bool(breakdown.get("contract_matched", false)):
		event_log.push_front("牌型完成：%s，整数倍率 +%d。" % [
			str(breakdown.get("contract_label", "未知牌型")),
			int(breakdown.get("contract_multiplier_bonus", 0)),
		])
	var arcana_labels: Array = breakdown.get("active_arcana_labels", [])
	if not arcana_labels.is_empty():
		event_log.push_front("玄牌结算：%s。" % " / ".join(arcana_labels))
	var world_item_labels: Array = breakdown.get("active_world_item_labels", [])
	if not world_item_labels.is_empty():
		event_log.push_front("街区遗物结算：%s。" % " / ".join(world_item_labels))
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
	pending_arcana_effects.clear()
	pending_world_item_effects.clear()
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
	return SIGNAL_CONTRACTS[posmod(day - 1 + signal_contract_offset, SIGNAL_CONTRACTS.size())].duplicate(true)


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
	var force_contract := bool(pending_arcana_effects.get("force_contract", false))
	if force_contract and not bool(contract_result.get("matched", false)):
		contract_result["matched"] = true
		contract_result["progress"] = "高塔覆写 / 强制成立"
	var source_base_bonus := 0
	var source_repeat_grace := 0
	var active_source_passive_labels: Array[String] = []
	for passive in meme.get("source_passives", []):
		var effect_id := str(passive.get("effect", ""))
		var value := float(passive.get("value", 0.0))
		var active := false
		match effect_id:
			"base_bonus":
				source_base_bonus += int(round(value))
				active = true
			"trend_base":
				if not matching_tags.is_empty():
					source_base_bonus += int(round(value))
					active = true
			"pollution_base":
				if pollution >= 40:
					source_base_bonus += int(round(value))
					active = true
			"repeat_grace":
				source_repeat_grace += maxi(0, int(round(value)))
				active = repeat_count > 0
			# Older crafted memes remain readable after the integer-score migration.
			"synergy_step":
				if not matching_tags.is_empty():
					source_base_bonus += int(round(value * 100.0))
					active = true
			"pollution_bonus":
				if pollution >= 40:
					source_base_bonus += int(round(value * 100.0))
					active = true
			"repeat_relief":
				source_repeat_grace += 1 if value > 0.0 else 0
				active = repeat_count > 0
		if active:
			active_source_passive_labels.append(str(passive.get("label", "来源被动")))
	var empty_base_bonus := int(round(_modifier_total("empty_base"))) if ("空位" in tags or "沉默" in tags) else 0
	var pollution_base_bonus := int(round(_modifier_total("pollution_base"))) if pollution >= 40 else 0
	var emotion_base_bonus: int = mini(16, maxi(0, int(meme.get("pollution_bias", 0))) * 2)
	emotion_base_bonus += maxi(0, int(meme.get("emotion_count", 0))) * int(round(_modifier_total("emotion_base")))
	var contract_base_bonus := int(contract_result.get("base_bonus", 0)) if bool(contract_result.get("matched", false)) else 0
	var arcana_base_bonus := int(pending_arcana_effects.get("base_bonus", 0))
	var world_item_base_bonus := int(pending_world_item_effects.get("base_bonus", 0))
	var base_value: int = 12 + rarity * 6 + matching_tags.size() * 8 + empty_base_bonus + pollution_base_bonus + emotion_base_bonus + source_base_bonus + contract_base_bonus + arcana_base_bonus + world_item_base_bonus
	var trend_multiplier_bonus := mini(2, matching_tags.size())
	if matching_tags.size() >= 2:
		trend_multiplier_bonus += int(round(_modifier_total("trend_multiplier_bonus")))
	var pollution_multiplier_bonus := (1 if pollution >= 40 else 0) + (1 if pollution >= 70 else 0)
	var arcana_repeat_grace := int(pending_arcana_effects.get("repeat_grace", 0))
	var effective_repeat_count := maxi(0, repeat_count - int(round(_modifier_total("repeat_grace"))) - source_repeat_grace - arcana_repeat_grace)
	var repeat_penalty := mini(2, effective_repeat_count)
	var contract_multiplier_bonus := int(contract_result.get("multiplier_bonus", 0)) if bool(contract_result.get("matched", false)) else 0
	var arcana_multiplier_bonus := int(pending_arcana_effects.get("multiplier_bonus", 0))
	var world_item_multiplier_bonus := int(pending_world_item_effects.get("multiplier_bonus", 0))
	var total_multiplier := maxi(1, 1 + trend_multiplier_bonus + pollution_multiplier_bonus + contract_multiplier_bonus + arcana_multiplier_bonus + world_item_multiplier_bonus - repeat_penalty)
	var score := maxi(1, base_value * total_multiplier)
	var active_modifier_labels: Array[String] = []
	for modifier in permanent_modifiers:
		var effect_id := str(modifier.get("effect", ""))
		var is_active := effect_id == "pollution_base" and pollution >= 40
		is_active = is_active or (effect_id == "trend_multiplier_bonus" and matching_tags.size() >= 2)
		is_active = is_active or (effect_id == "repeat_grace" and repeat_count > 0)
		is_active = is_active or (effect_id == "empty_base" and empty_base_bonus > 0)
		is_active = is_active or (effect_id == "emotion_base" and int(meme.get("emotion_count", 0)) > 0)
		if is_active:
			active_modifier_labels.append(str(modifier.get("label", "永久许可")))
	return {
		"base_value": base_value,
		"matching_tags": matching_tags.duplicate(),
		"trend_multiplier_bonus": trend_multiplier_bonus,
		"pollution_multiplier_bonus": pollution_multiplier_bonus,
		"repeat_penalty": repeat_penalty,
		"synergy_multiplier": 1 + trend_multiplier_bonus,
		"pollution_multiplier": 1 + pollution_multiplier_bonus,
		"emotion_multiplier": 1,
		"repeat_multiplier": 1,
		"contract_id": str(contract_result.get("id", "")),
		"contract_label": str(contract_result.get("label", "未命名牌型")),
		"contract_description": str(contract_result.get("description", "")),
		"contract_progress": str(contract_result.get("progress", "")),
		"contract_matched": bool(contract_result.get("matched", false)),
		"contract_base_bonus": contract_base_bonus,
		"contract_multiplier_bonus": contract_multiplier_bonus,
		"contract_multiplier": 1 + contract_multiplier_bonus,
		"contract_pollution_risk": int(contract_result.get("pollution_risk", 0)) if bool(contract_result.get("matched", false)) else 0,
		"arcana_base_bonus": arcana_base_bonus,
		"arcana_multiplier_bonus": arcana_multiplier_bonus,
		"arcana_multiplier": 1 + arcana_multiplier_bonus,
		"arcana_pollution_risk": int(pending_arcana_effects.get("pollution_risk", 0)),
		"arcana_force_contract": force_contract,
		"arcana_repeat_grace": arcana_repeat_grace,
		"active_arcana_labels": (pending_arcana_effects.get("labels", []) as Array).duplicate(),
		"world_item_base_bonus": world_item_base_bonus,
		"world_item_multiplier_bonus": world_item_multiplier_bonus,
		"world_item_multiplier": 1 + world_item_multiplier_bonus,
		"active_world_item_labels": (pending_world_item_effects.get("labels", []) as Array).duplicate(),
		"total_multiplier": total_multiplier,
		"repeat_count": repeat_count,
		"effective_repeat_count": effective_repeat_count,
		"modifier_base_bonus": empty_base_bonus + pollution_base_bonus + emotion_base_bonus,
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


func _arcana_for_day(value: int) -> String:
	return ARCANA_ROTATION[(value - 1) % ARCANA_ROTATION.size()]


func _find_held_arcana_index(card_uid: String) -> int:
	for index in owned_arcana_cards.size():
		if str(owned_arcana_cards[index].get("uid", "")) == card_uid:
			return index
	return -1


func _find_completed_meme_index(meme_id: String) -> int:
	for index in completed_memes.size():
		if str(completed_memes[index].get("id", "")) == meme_id:
			return index
	return -1


func _find_missing_trend_tag(meme_id: String) -> String:
	var target_index := _find_completed_meme_index(meme_id)
	if target_index < 0:
		return ""
	var tags: Array = completed_memes[target_index].get("tags", [])
	for trend_tag in _current_accepted_tags():
		if trend_tag not in tags:
			return str(trend_tag)
	return ""


func _ensure_pending_arcana_effects() -> void:
	if pending_arcana_effects.is_empty():
		pending_arcana_effects = {
			"base_bonus": 0,
			"multiplier_bonus": 0,
			"pollution_risk": 0,
			"repeat_grace": 0,
			"force_contract": false,
			"labels": [],
		}


func _append_pending_arcana_label(label: String) -> void:
	var labels: Array = pending_arcana_effects.get("labels", []).duplicate()
	if label not in labels:
		labels.append(label)
	pending_arcana_effects["labels"] = labels


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
