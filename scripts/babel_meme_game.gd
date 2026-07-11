extends Node3D

const MemeGameStateScript = preload("res://scripts/meme_game_state.gd")
const DraggableButtonScript = preload("res://scripts/ui/draggable_button.gd")
const DropButtonScript = preload("res://scripts/ui/drop_button.gd")
const RealityFloorGeneratorScript = preload("res://scripts/reality_floor_generator.gd")

const PALETTE_1 := {
	"name": "palette_1",
	"bg": "B7D957",
	"surface": "FFF1C9",
	"text": "10140F",
	"ink": "10140F",
	"accent": "365B2D",
	"muted": "DDEB8A",
	"danger_stripe": "10140F",
	"flash_text": "9CFF24",
}
const POLLUTION_PALETTE_5 := {
	"name": "pollution_palette_5",
	"bg": "9CFF24",
	"surface": "FFF2B8",
	"text": "0D1009",
	"ink": "0D1009",
	"accent": "2F6B1F",
	"muted": "D8FF66",
	"danger_stripe": "0D1009",
	"flash_text": "39FF14",
}

const PHONE_DOWN_BACKDROP_PATH := "res://assets/generated/world/phone_down_backdrop.png"
const NPC_SIGNAL_PORTRAIT_PATH := "res://assets/generated/world/npc_signal_portrait.png"
const NO_SIGNAL_ICON_PATH := "res://assets/generated/ui/no_signal_icon.png"
const HUD_DAY_ICON_PATH := "res://assets/generated/ui/hud_day_icon.png"
const HUD_POLLUTION_ICON_PATH := "res://assets/generated/ui/hud_pollution_icon.png"
const HUD_MONEY_ICON_PATH := "res://assets/generated/ui/hud_money_icon.png"
const HUD_SETTINGS_ICON_PATH := "res://assets/generated/ui/hud_settings_icon.png"
const SOCIAL_POSTER_SHEET_PATH := "res://assets/generated/social/poster_sheet.png"
const ARCANA_SHEET_PATH := "res://assets/generated/ui/arcana_sheet.png"
const PHONE_AMBIENCE_PATH := "res://assets/generated/audio/phone_road_loop.wav"
const REALITY_AMBIENCE_PATH := "res://assets/generated/audio/reality_room_loop.wav"
const FLASHBACK_AUDIO_PATH := "res://assets/generated/audio/pollution_flashback.wav"
const ACTION_TICK_AUDIO_PATH := "res://assets/generated/audio/action_tick.wav"
const SOCIAL_POSTER_COLUMNS := 4
const SOCIAL_POSTER_ROWS := 3
const SOCIAL_POSTER_COUNT := SOCIAL_POSTER_COLUMNS * SOCIAL_POSTER_ROWS
const ARCANA_SHEET_COLUMNS := 3
const ARCANA_SHEET_ROWS := 2
const ARCANA_SHEET_COUNT := ARCANA_SHEET_COLUMNS * ARCANA_SHEET_ROWS
const SOCIAL_FEED_WHEEL_STEP := 2
const REALITY_MOVE_SPEED := 3.3
const REALITY_ACCELERATION := 14.0
const REALITY_MOUSE_SENSITIVITY := 0.085
const REALITY_INTERACTION_DISTANCE := 2.25
const REALITY_FALL_RECOVERY_Y := -3.0
const REALITY_SAFE_INSET := 1.2
const CINEMATIC_ASPECT_RATIO := 2.35
const SOCIAL_POST_CARDS := [
	{
		"id": "floor_13", "poster_cell": 0, "caption": "旧教学楼昨晚多出一层", "handle": "塔下施工档案",
		"text": "实拍：封闭的教学楼昨晚多出一层，末班电梯停在那里。", "tags": ["巴别塔", "空位"], "rarity": 2, "passive": {"id": "floor_draft", "label": "空层底稿", "description": "传播基础 +4", "effect": "base_bonus", "value": 4.0},
		"tokens": [
			{"id": "floor", "text": "不存在的十三层", "tags": ["巴别塔", "空位"], "rarity": 2},
			{"id": "last_lift", "text": "末班电梯", "tags": ["日常", "巴别塔"], "rarity": 1},
			{"id": "still_building", "text": "还在施工", "tags": ["刷新", "追问"], "rarity": 2},
		],
	},
	{
		"id": "self_call", "poster_cell": 1, "caption": "无信号时收到明天短信", "handle": "无信号通勤",
		"text": "求证：断网后，我收到明天的自己发来的哈吉米。", "tags": ["哈吉米", "刷新", "追问"], "rarity": 3, "passive": {"id": "callback_resonance", "label": "回拨共鸣", "description": "每个命中风向额外 +0.10", "effect": "synergy_step", "value": 0.10},
		"tokens": [
			{"id": "no_signal", "text": "无信号", "tags": ["沉默", "空位"], "rarity": 1},
			{"id": "self_call", "text": "自己发来的", "tags": ["追问", "反问"], "rarity": 2},
			{"id": "hajimi", "text": "哈吉米", "tags": ["哈吉米", "刷新"], "rarity": 2},
		],
	},
	{
		"id": "missing_window", "poster_cell": 2, "caption": "塔下每晚少一个窗口", "handle": "塔下夜巡",
		"text": "记录：塔下每到午夜，就少一扇亮着的窗。", "tags": ["巴别塔", "沉默"], "rarity": 2, "passive": {"id": "blackout_dividend", "label": "熄灯增益", "description": "污染倍率额外 +0.08", "effect": "pollution_bonus", "value": 0.08},
		"tokens": [
			{"id": "midnight", "text": "每到午夜", "tags": ["日常", "刷新"], "rarity": 1},
			{"id": "one_less", "text": "少一扇窗", "tags": ["沉默", "空位"], "rarity": 2},
			{"id": "under_tower", "text": "塔下", "tags": ["巴别塔", "信徒"], "rarity": 1},
		],
	},
	{
		"id": "extra_moon", "poster_cell": 3, "caption": "照片里月亮多了一颗", "handle": "夜空误差簿",
		"text": "对照：昨晚的照片里，月亮比现实多一颗。", "tags": ["信徒", "圣歌", "追问"], "rarity": 2, "passive": {"id": "moon_buffer", "label": "月相缓冲", "description": "复读衰减减轻 0.12", "effect": "repeat_relief", "value": 0.12},
		"tokens": [
			{"id": "extra_moon", "text": "多一颗月亮", "tags": ["圣歌", "信徒"], "rarity": 2},
			{"id": "than_reality", "text": "比现实更多", "tags": ["追问", "反问"], "rarity": 2},
			{"id": "last_night", "text": "昨晚的照片", "tags": ["日常"], "rarity": 1},
		],
	},
	{
		"id": "last_bus", "poster_cell": 4, "caption": "最后一班车没有终点", "handle": "末班路线图",
		"text": "旧帖：最后一班车从来没有终点站。", "tags": ["日常", "空位"], "rarity": 2, "passive": {"id": "last_bus_draft", "label": "末班底稿", "description": "传播基础 +5", "effect": "base_bonus", "value": 5.0},
		"tokens": [
			{"id": "last_bus", "text": "最后一班车", "tags": ["日常"], "rarity": 1},
			{"id": "no_terminal", "text": "没有终点", "tags": ["空位", "沉默"], "rarity": 2},
			{"id": "old_post", "text": "旧帖", "tags": ["刷新", "哈吉米"], "rarity": 1},
		],
	},
	{
		"id": "blackout_broadcast", "poster_cell": 5, "caption": "停电后广播喊了我名字", "handle": "废站收音机",
		"text": "录音：停电以后，废站广播准时报站，然后叫了我的名字。", "tags": ["圣歌", "刷新", "沉默"], "rarity": 3, "passive": {"id": "broadcast_resonance", "label": "广播共鸣", "description": "每个命中风向额外 +0.08", "effect": "synergy_step", "value": 0.08},
		"tokens": [
			{"id": "blackout", "text": "停电以后", "tags": ["沉默", "空位"], "rarity": 1},
			{"id": "broadcast", "text": "广播喊我名字", "tags": ["圣歌", "刷新"], "rarity": 2},
			{"id": "dead_station", "text": "废站", "tags": ["巴别塔", "日常"], "rarity": 2},
		],
	},
	{
		"id": "station_lit", "poster_cell": 6, "caption": "废站台昨晚重新亮灯", "handle": "封站观察员",
		"text": "目击：封了十年的站台，昨晚重新亮灯。", "tags": ["巴别塔", "刷新"], "rarity": 2, "passive": {"id": "restart_dividend", "label": "重启增益", "description": "污染倍率额外 +0.10", "effect": "pollution_bonus", "value": 0.10},
		"tokens": [
			{"id": "ten_years", "text": "封了十年", "tags": ["禁问", "沉默"], "rarity": 2},
			{"id": "lit_again", "text": "重新亮灯", "tags": ["刷新", "巴别塔"], "rarity": 2},
			{"id": "platform", "text": "站台", "tags": ["日常", "空位"], "rarity": 1},
		],
	},
	{
		"id": "no_shadow", "poster_cell": 7, "caption": "便利店店员没有影子", "handle": "凌晨便利店",
		"text": "路过：店整夜开着，店员却没有影子。", "tags": ["日常", "沉默", "追问"], "rarity": 2, "passive": {"id": "shadow_buffer", "label": "无影缓冲", "description": "复读衰减减轻 0.10", "effect": "repeat_relief", "value": 0.10},
		"tokens": [
			{"id": "all_night", "text": "整夜开着", "tags": ["日常"], "rarity": 1},
			{"id": "no_shadow", "text": "没有影子", "tags": ["沉默", "空位"], "rarity": 2},
			{"id": "clerk", "text": "店员", "tags": ["追问", "反问"], "rarity": 1},
		],
	},
	{
		"id": "future_notice", "poster_cell": 8, "caption": "小区群里出现不存在的住户", "handle": "明日群公告",
		"text": "截图：小区群凌晨多出一个查不到门牌的住户，还发来明天的失踪通知。", "tags": ["刷新", "禁问", "反问"], "rarity": 3, "passive": {"id": "tomorrow_draft", "label": "明日底稿", "description": "传播基础 +6", "effect": "base_bonus", "value": 6.0},
		"tokens": [
			{"id": "tomorrow", "text": "明天的通知", "tags": ["刷新", "反问"], "rarity": 2},
			{"id": "missing", "text": "失踪", "tags": ["禁问", "沉默"], "rarity": 3},
			{"id": "group", "text": "小区群", "tags": ["日常"], "rarity": 1},
		],
	},
	{
		"id": "old_post_today", "poster_cell": 9, "caption": "十年前旧帖今天回复我", "handle": "旧帖考古队",
		"text": "考古：十年前的旧帖今天突然回复我，头像是现在的我。", "tags": ["刷新", "哈吉米", "反问"], "rarity": 3, "passive": {"id": "archive_resonance", "label": "旧帖共鸣", "description": "每个命中风向额外 +0.12", "effect": "synergy_step", "value": 0.12},
		"tokens": [
			{"id": "ten_year_post", "text": "十年前的旧帖", "tags": ["刷新", "哈吉米"], "rarity": 2},
			{"id": "today_me", "text": "今天的我", "tags": ["日常", "追问"], "rarity": 2},
			{"id": "archaeology", "text": "考古", "tags": ["信徒", "反问"], "rarity": 1},
		],
	},
	{
		"id": "deleted_road", "poster_cell": 10, "caption": "地图上少了一条回家路", "handle": "绿色路线图",
		"text": "更新：地图删掉了我每天回家的那条路。", "tags": ["空位", "日常", "刷新"], "rarity": 2, "passive": {"id": "lost_road_dividend", "label": "迷路增益", "description": "污染倍率额外 +0.08", "effect": "pollution_bonus", "value": 0.08},
		"tokens": [
			{"id": "deleted", "text": "地图删掉了", "tags": ["刷新", "空位"], "rarity": 2},
			{"id": "way_home", "text": "回家的路", "tags": ["日常"], "rarity": 1},
			{"id": "this_road", "text": "这条小路", "tags": ["追问", "空位"], "rarity": 1},
		],
	},
	{
		"id": "access_record", "poster_cell": 11, "caption": "门禁说我没回家我却在屋里", "handle": "门禁空号",
		"text": "记录：门禁说我没回来，可我一直在屋里。", "tags": ["禁问", "追问", "日常"], "rarity": 2, "passive": {"id": "access_buffer", "label": "门禁缓冲", "description": "复读衰减减轻 0.12", "effect": "repeat_relief", "value": 0.12},
		"tokens": [
			{"id": "not_home", "text": "我没回来", "tags": ["禁问", "追问"], "rarity": 2},
			{"id": "inside", "text": "一直在屋里", "tags": ["日常", "反问"], "rarity": 1},
			{"id": "access", "text": "门禁记录", "tags": ["巴别塔", "刷新"], "rarity": 1},
		],
	},
]
const DAY_PLANS := [
	{
		"title": "旧帖被顶上来",
		"trends": ["哈吉米", "追问", "日常"],
		"speaker": "同学",
		"line": "你刚才想说什么？",
		"feed": [
			{"id": "d1_a", "handle": "BABEL_404", "text": "有人说哈吉米只是一个打错的名字，但打错的人已经注销。", "tokens": [
				{"id": "phrase", "text": "打错的人已经注销", "tags": ["哈吉米", "追问"], "rarity": 1},
				{"id": "hajimi", "text": "哈吉米", "tags": ["哈吉米"], "rarity": 1},
				{"id": "wrong", "text": "打错", "tags": ["追问"], "rarity": 1},
			]},
			{"id": "d1_b", "handle": "课桌下的账号", "text": "别急着懂。先把它转出去，懂会在后面补票。", "tokens": [
				{"id": "phrase", "text": "懂会在后面补票", "tags": ["反问", "日常"], "rarity": 1},
				{"id": "understand", "text": "懂", "tags": ["清晰"], "rarity": 1},
			]},
		],
	},
	{
		"title": "沉默用户在线",
		"trends": ["空位", "沉默", "哈吉米"],
		"speaker": "塔下信徒",
		"line": "你可以不用那些词，试着直接回答我。",
		"feed": [
			{"id": "d2_a", "handle": "SILENT_ROOT", "text": "那个沉默用户又在线了。在线本身就是发言。", "tokens": [
				{"id": "phrase", "text": "在线本身就是发言", "tags": ["沉默", "空位"], "rarity": 2},
				{"id": "silent", "text": "沉默", "tags": ["沉默"], "rarity": 1},
			]},
			{"id": "d2_b", "handle": "回声管理员", "text": "哈吉米没有解释，哈吉米只返回你发出去的形状。", "tokens": [
				{"id": "phrase", "text": "返回你发出去的形状", "tags": ["哈吉米", "空位"], "rarity": 2},
				{"id": "shape", "text": "形状", "tags": ["空位"], "rarity": 1},
			]},
		],
	},
	{
		"title": "第一层通知",
		"trends": ["巴别塔", "信徒", "刷新"],
		"speaker": "班里的转发者",
		"line": "你在哪一层？别说塔内地址，说你自己的话。",
		"feed": [
			{"id": "d3_a", "handle": "塔讯快报", "text": "第一级台阶确认开放。请用更新后的句式进入。", "tokens": [
				{"id": "phrase", "text": "更新后的句式", "tags": ["巴别塔", "刷新"], "rarity": 2},
				{"id": "tower", "text": "台阶", "tags": ["巴别塔"], "rarity": 1},
			]},
			{"id": "d3_b", "handle": "朝圣二群", "text": "塔不是建筑。塔是大家同时把解释往上挂。", "tokens": [
				{"id": "phrase", "text": "把解释往上挂", "tags": ["巴别塔", "信徒"], "rarity": 3},
				{"id": "hang", "text": "往上挂", "tags": ["信徒"], "rarity": 1},
			]},
		],
	},
	{
		"title": "解释开始收费",
		"trends": ["反问", "禁问", "哈吉米"],
		"speaker": "梗店店员",
		"line": "如果不用它，你还剩下什么表达？",
		"feed": [
			{"id": "d4_a", "handle": "付费问答残页", "text": "为什么智者不说话？你为什么需要他说话？", "tokens": [
				{"id": "phrase", "text": "你为什么需要他说话", "tags": ["反问", "禁问"], "rarity": 2},
				{"id": "why", "text": "为什么", "tags": ["追问"], "rarity": 1},
			]},
			{"id": "d4_b", "handle": "旧语言清仓", "text": "普通话库存不足，剩余词义按污染价处理。", "tokens": [
				{"id": "phrase", "text": "词义按污染价处理", "tags": ["清晰", "禁问"], "rarity": 3},
				{"id": "price", "text": "污染价", "tags": ["禁问"], "rarity": 1},
			]},
		],
	},
	{
		"title": "圣歌体扩散",
		"trends": ["圣歌", "信徒", "巴别塔"],
		"speaker": "楼梯口合唱者",
		"line": "你能把自己的问题说出来，而不是唱出来吗？",
		"feed": [
			{"id": "d5_a", "handle": "塔间合唱", "text": "塔啊，请把所有人挂成同一个句子。", "tokens": [
				{"id": "phrase", "text": "挂成同一个句子", "tags": ["圣歌", "巴别塔"], "rarity": 3},
				{"id": "chant", "text": "塔啊", "tags": ["圣歌"], "rarity": 1},
			]},
			{"id": "d5_b", "handle": "未命名小组", "text": "哈吉米在副歌里出现三次，第四次必须空着。", "tokens": [
				{"id": "phrase", "text": "第四次必须空着", "tags": ["哈吉米", "空位", "圣歌"], "rarity": 3},
				{"id": "empty", "text": "空着", "tags": ["空位"], "rarity": 1},
			]},
		],
	},
	{
		"title": "没有人在顶上",
		"trends": ["空位", "沉默", "巴别塔"],
		"speaker": "塔顶",
		"line": " ",
		"feed": [
			{"id": "d6_a", "handle": "塔顶直播", "text": "直播间没有画面。弹幕说这就是画面。", "tokens": [
				{"id": "phrase", "text": "这就是画面", "tags": ["空位", "巴别塔"], "rarity": 5},
				{"id": "blank", "text": "没有画面", "tags": ["空位"], "rarity": 3},
			]},
			{"id": "d6_b", "handle": "智者账号", "text": "该用户不存在。不存在是最后一次上线。", "tokens": [
				{"id": "phrase", "text": "不存在是最后一次上线", "tags": ["沉默", "空位"], "rarity": 5},
				{"id": "silence", "text": "不存在", "tags": ["沉默"], "rarity": 3},
			]},
		],
	},
]

var game = MemeGameStateScript.new()
var selected_token_id := ""
var selected_meme_id := ""
var log_text := ""
var _road_scroll := 0.0
var _input_locked := false

var _camera: Camera3D
var _road: Node3D
var _phone_rig: Node3D
var _npc: Node3D
var _reality_player: CharacterBody3D
var _reality_floor
var _reality_built_floor := 0
var _reality_yaw := 0.0
var _reality_pitch := 0.0
var _reality_last_safe_position := Vector3.ZERO
var _reality_mouse_look_enabled := false
var _nearby_reality_actor: Area3D
var _nearby_reality_item: Area3D
var _active_reality_actor: Area3D
var _reality_interaction_active := false
var _canvas: CanvasLayer
var _ui_root: Control
var _texture_cache: Dictionary = {}
var _phone_down_backdrop_image: TextureRect
var _hand_phone_image: TextureRect
var _cinematic_top_bar: ColorRect
var _cinematic_bottom_bar: ColorRect
var _stats_label: Label
var _actions_label: Label
var _hud_panel: PanelContainer
var _hud_settings_icon: Button
var _hud_day_value: Label
var _hud_heat_value: Label
var _hud_pollution_value: Label
var _hud_clarity_value: Label
var _hud_floor_value: Label
var _hud_money_value: Label
var _hud_actions_label: Label
var _hud_tooltip: PanelContainer
var _hud_tooltip_label: Label
var _world_prompt: Label
var _desk_log: Label
var _main_menu_layer: Control
var _settings_window: PanelContainer
var _settings_content: VBoxContainer
var _volume_slider: HSlider
var _vhs_toggle: CheckButton
var _view_toggle_button: Button
var _vhs_overlay: Control
var _vhs_scanlines: Array[ColorRect] = []
var _phone_panel: PanelContainer
var _phone_tab: Button
var _phone_content: Control
var _phone_title: Label
var _app_window: PanelContainer
var _app_title: Label
var _app_body: VBoxContainer
var _app_windows: Dictionary = {}
var _app_titles: Dictionary = {}
var _app_bodies: Dictionary = {}
var _publish_panel: PanelContainer
var _publish_blank: DropButton
var _confirm_publish_button: Button
var _meme_bank_tab: Button
var _meme_bank_drag_handle: Label
var _meme_bank_window: PanelContainer
var _meme_bank_content: Control
var _bank_list: HBoxContainer
var _reality_subtitle_panel: PanelContainer
var _reality_subtitle_label: Label
var _reality_choice_row: HBoxContainer
var _reality_intent_preview: Label
var _reality_typing_line: RichTextLabel
var _reality_typing_progress: Label
var _reality_continue_button: Button
var _reality_aid_status: Label
var _reality_merchant_offer: PanelContainer
var _reality_merchant_offer_text: Label
var _reality_merchant_buy_button: Button
var _reality_hover_choice_id := ""
var _flashback_overlay: Control
var _flashback_noise: ColorRect
var _flashback_blackout: ColorRect
var _flashback_words: Array[Label] = []
var _flashback_tween: Tween
var _phone_ambience: AudioStreamPlayer
var _reality_ambience: AudioStreamPlayer
var _flashback_audio: AudioStreamPlayer
var _action_tick_audio: AudioStreamPlayer
var _audio_tween: Tween
var _action_spend_overlay: Control
var _action_spend_blackout: ColorRect
var _action_spend_label: Label
var _action_spend_tween: Tween
var _action_spend_after_actions := -1
var _action_spend_should_settle := false
var _day_transition_overlay: Control
var _day_transition_day_label: Label
var _day_transition_meta_label: Label
var _day_transition_rule: ColorRect
var _day_transition_tween: Tween
var _day_transition_settled := false
var _meme_bank_open := false
var _phone_popup_expanded := true
var _phone_launcher_open := true
var _meme_bank_layout_mode := ""
var _open_app_windows: Dictionary = {}
var _social_screen := "home"
var _social_channel := "发现"
var _social_detail_post_index := 0
var _social_detail_open := false
var _social_detail_window: PanelContainer
var _social_detail_body: VBoxContainer
var _social_detail_title: Label
var _draggable_windows: Dictionary = {}
var _dragged_window: Control
var _drag_offset := Vector2.ZERO
var _last_responsive_layout_size := Vector2.ZERO
var _game_started := false
var _settings_open := false
var _vhs_enabled := true
var _master_volume := 80.0
var _phone_art_alpha := 0.0


func _ready() -> void:
	show_main_menu()


func _process(delta: float) -> void:
	if _camera == null:
		return
	if _game_started:
		_ensure_reality_floor_current()
		_refresh_nearby_reality_actor()
		_apply_responsive_layouts_if_needed()
	_animate_world(delta)


func _physics_process(delta: float) -> void:
	if not _game_started or _reality_player == null:
		return
	_update_reality_player(delta)


func _input(event: InputEvent) -> void:
	if _input_locked:
		return
	if _dragged_window == null:
		return
	if event is InputEventMouseMotion:
		_dragged_window.global_position = _event_pointer_position(event) - _drag_offset
		_clamp_window_to_viewport(_dragged_window)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if _dragged_window == _meme_bank_window:
			_avoid_meme_bank_overlaps()
		_dragged_window = null
	elif event is InputEventScreenDrag:
		_dragged_window.global_position = _event_pointer_position(event) - _drag_offset
		_clamp_window_to_viewport(_dragged_window)
	elif event is InputEventScreenTouch and not event.pressed:
		if _dragged_window == _meme_bank_window:
			_avoid_meme_bank_overlaps()
		_dragged_window = null


func _unhandled_input(event: InputEvent) -> void:
	if _input_locked or not _game_started:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _reality_interaction_active and game.conversation_phase == "typing" and event.keycode != KEY_ESCAPE:
			if _advance_typed_reality_character():
				get_viewport().set_input_as_handled()
				return
		if event.is_action_pressed("reality_interact"):
			_try_reality_interaction()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("reality_phone"):
			_toggle_view_state()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_ESCAPE:
			if _reality_interaction_active:
				_exit_reality_interaction()
			else:
				_set_reality_mouse_look(false)
			get_viewport().set_input_as_handled()
			return
	if game.view_state != "npc_up" or _reality_interaction_active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_set_reality_mouse_look(true)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _reality_mouse_look_enabled:
		var motion := event as InputEventMouseMotion
		_reality_yaw -= motion.relative.x * REALITY_MOUSE_SENSITIVITY
		_reality_pitch = clampf(_reality_pitch - motion.relative.y * REALITY_MOUSE_SENSITIVITY, -68.0, 72.0)
		get_viewport().set_input_as_handled()


func new_game() -> void:
	_game_started = true
	_settings_open = false
	_phone_art_alpha = 1.0
	game = MemeGameStateScript.new()
	game.new_run()
	selected_token_id = ""
	selected_meme_id = ""
	_meme_bank_open = false
	_phone_popup_expanded = true
	_phone_launcher_open = false
	_meme_bank_layout_mode = ""
	_open_app_windows = {"social": true}
	_social_screen = "home"
	_social_channel = "发现"
	_social_detail_post_index = 0
	_social_detail_open = false
	_app_windows = {}
	_app_titles = {}
	_app_bodies = {}
	_action_spend_after_actions = -1
	_action_spend_should_settle = false
	_day_transition_settled = false
	_draggable_windows = {}
	_dragged_window = null
	_drag_offset = Vector2.ZERO
	_last_responsive_layout_size = Vector2.ZERO
	_reality_built_floor = 0
	_reality_yaw = 0.0
	_reality_pitch = 0.0
	_set_reality_mouse_look(false)
	_nearby_reality_actor = null
	_nearby_reality_item = null
	_active_reality_actor = null
	_reality_interaction_active = false
	log_text = "你低头，手机边框从视野下方亮起来。"
	_build_world()
	_build_ui()
	_render()
	_sync_audio_state(true)


func show_main_menu() -> void:
	_game_started = false
	_settings_open = false
	_input_locked = false
	_phone_art_alpha = 0.0
	_phone_launcher_open = false
	_reality_interaction_active = false
	_active_reality_actor = null
	_nearby_reality_actor = null
	_nearby_reality_item = null
	_set_reality_mouse_look(false)
	_build_world()
	_build_main_menu()
	_sync_audio_state(true)


func set_view_state(value: String) -> void:
	if _input_locked:
		return
	if game.set_view_state(value):
		_reality_interaction_active = false
		_active_reality_actor = null
		_nearby_reality_actor = null
		_nearby_reality_item = null
		_reality_hover_choice_id = ""
		game.reset_typed_reality_conversation()
		if value == "npc_up":
			_set_reality_mouse_look(true)
			log_text = "你放下手机，大街重新获得纵深。"
			_meme_bank_open = false
			_phone_launcher_open = false
		else:
			_set_reality_mouse_look(false)
			log_text = "你又低头看向手机。"
			_phone_launcher_open = game.active_app_window.is_empty()
			if not game.active_app_window.is_empty():
				_open_app_windows[game.active_app_window] = true
			if _phone_panel != null:
				_phone_panel.move_to_front()
		_render()
		_sync_audio_state(false)


func _toggle_view_state() -> void:
	if game.view_state == "phone_down":
		set_view_state("npc_up")
	else:
		set_view_state("phone_down")


func _set_reality_mouse_look(enabled: bool) -> void:
	_reality_mouse_look_enabled = enabled
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE)


func _build_world() -> void:
	if _day_transition_tween != null and _day_transition_tween.is_valid():
		_day_transition_tween.kill()
	_day_transition_tween = null
	if _audio_tween != null and _audio_tween.is_valid():
		_audio_tween.kill()
	_audio_tween = null
	for child in get_children():
		remove_child(child)
		child.free()

	_camera = Camera3D.new()
	_camera.name = "Camera3D"
	add_child(_camera)
	_camera.current = true
	_camera.fov = 58.0
	_ensure_reality_input_map()

	_reality_player = CharacterBody3D.new()
	_reality_player.name = "RealityPlayer"
	_reality_player.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	_reality_player.collision_layer = 1
	_reality_player.collision_mask = 1
	add_child(_reality_player)
	var player_collision := CollisionShape3D.new()
	player_collision.name = "PlayerCollision"
	var player_capsule := CapsuleShape3D.new()
	player_capsule.radius = 0.34
	player_capsule.height = 1.72
	player_collision.shape = player_capsule
	player_collision.position.y = 0.88
	_reality_player.add_child(player_collision)

	var light := DirectionalLight3D.new()
	light.name = "StreetLight"
	light.rotation_degrees = Vector3(-55.0, 20.0, 0.0)
	light.light_energy = 0.25
	add_child(light)

	_reality_floor = RealityFloorGeneratorScript.new()
	_reality_floor.name = "RealityFloor"
	add_child(_reality_floor)
	_rebuild_reality_floor()

	_road = Node3D.new()
	_road.name = "Road"
	add_child(_road)
	for index in 3:
		var tile := MeshInstance3D.new()
		tile.name = "RoadTile%d" % index
		var plane := PlaneMesh.new()
		plane.size = Vector2(7.0, 4.0)
		tile.mesh = plane
		tile.position = Vector3(0.0, -0.08, -2.0 - index * 3.8)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = _theme_color("accent").darkened(0.50 - index * 0.08)
		mat.roughness = 0.8
		tile.material_override = mat
		_road.add_child(tile)

	_phone_rig = Node3D.new()
	_phone_rig.name = "PhoneRig"
	add_child(_phone_rig)
	var phone_body := MeshInstance3D.new()
	phone_body.name = "PhoneBody"
	var phone_box := BoxMesh.new()
	phone_box.size = Vector3(1.0, 0.08, 1.65)
	phone_body.mesh = phone_box
	var phone_mat := StandardMaterial3D.new()
	phone_mat.albedo_color = _theme_color("accent")
	phone_body.material_override = phone_mat
	_phone_rig.add_child(phone_body)
	var phone_screen := MeshInstance3D.new()
	phone_screen.name = "PhoneScreen"
	var screen_box := BoxMesh.new()
	screen_box.size = Vector3(0.84, 0.085, 1.35)
	phone_screen.mesh = screen_box
	phone_screen.position = Vector3(0.0, 0.006, 0.0)
	var screen_mat := StandardMaterial3D.new()
	screen_mat.albedo_color = _theme_color("ink")
	screen_mat.emission_enabled = true
	screen_mat.emission = _theme_color("accent")
	screen_mat.emission_energy_multiplier = 0.35
	phone_screen.material_override = screen_mat
	_phone_rig.add_child(phone_screen)

	_npc = Node3D.new()
	_npc.name = "NPC"
	add_child(_npc)
	var npc_body := MeshInstance3D.new()
	npc_body.name = "NPCPlane"
	var npc_quad := QuadMesh.new()
	npc_quad.size = Vector2(1.6, 2.4)
	npc_body.mesh = npc_quad
	npc_body.position = Vector3(0.0, 1.25, -3.2)
	var npc_mat := StandardMaterial3D.new()
	npc_mat.albedo_color = _theme_color("surface")
	npc_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	npc_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	npc_mat.emission_enabled = true
	npc_mat.emission = _theme_color("muted")
	npc_mat.emission_energy_multiplier = 0.12
	npc_body.material_override = npc_mat
	_npc.add_child(npc_body)

	_canvas = CanvasLayer.new()
	_canvas.name = "CanvasLayer"
	add_child(_canvas)
	_build_audio_players()


func _ensure_reality_input_map() -> void:
	_set_key_action("reality_forward", [KEY_W, KEY_UP])
	_set_key_action("reality_back", [KEY_S, KEY_DOWN])
	_set_key_action("reality_left", [KEY_A, KEY_LEFT])
	_set_key_action("reality_right", [KEY_D, KEY_RIGHT])
	_set_key_action("reality_interact", [KEY_F])
	_set_key_action("reality_phone", [KEY_TAB])


func _set_key_action(action_name: StringName, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	for keycode in keycodes:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = int(keycode)
		InputMap.action_add_event(action_name, key_event)


func _rebuild_reality_floor() -> void:
	if _reality_floor == null or game == null:
		return
	var npc_texture := _load_runtime_texture(NPC_SIGNAL_PORTRAIT_PATH)
	_reality_floor.rebuild(game.tower_floor, _active_palette(), npc_texture)
	_reality_floor.sync_collected_items(game.collected_world_item_ids)
	_reality_built_floor = game.tower_floor
	_reality_interaction_active = false
	_active_reality_actor = null
	_nearby_reality_actor = null
	_nearby_reality_item = null
	if _reality_player != null:
		_reality_last_safe_position = _reality_floor.start_position()
		_reality_player.position = _reality_last_safe_position
		_reality_player.velocity = Vector3.ZERO
	_reality_yaw = 0.0
	_reality_pitch = 0.0


func _ensure_reality_floor_current() -> void:
	if _reality_floor == null or game == null:
		return
	if _reality_built_floor != game.tower_floor:
		_rebuild_reality_floor()


func _room_count_for_floor(floor_number: int) -> int:
	return RealityFloorGeneratorScript.room_count_for_floor(floor_number)


func _npc_count_for_floor(floor_number: int) -> int:
	return RealityFloorGeneratorScript.npc_count_for_floor(floor_number)


func _update_reality_player(delta: float) -> void:
	if _should_recover_reality_player():
		_recover_reality_player()
		return
	var can_walk: bool = game.view_state == "npc_up" and not _reality_interaction_active and not _input_locked
	var input_vector := Vector2.ZERO
	if can_walk:
		input_vector = Input.get_vector("reality_left", "reality_right", "reality_forward", "reality_back")
	var local_direction := Vector3(input_vector.x, 0.0, input_vector.y)
	var world_direction := Basis(Vector3.UP, deg_to_rad(_reality_yaw)) * local_direction
	if world_direction.length_squared() > 0.001:
		world_direction = world_direction.normalized()
	var target_velocity := world_direction * REALITY_MOVE_SPEED
	_reality_player.velocity.x = move_toward(_reality_player.velocity.x, target_velocity.x, REALITY_ACCELERATION * delta)
	_reality_player.velocity.z = move_toward(_reality_player.velocity.z, target_velocity.z, REALITY_ACCELERATION * delta)
	if not _reality_player.is_on_floor():
		_reality_player.velocity.y -= 18.0 * delta
	else:
		_reality_player.velocity.y = 0.0
	_reality_player.rotation.y = deg_to_rad(_reality_yaw)
	_reality_player.move_and_slide()
	if _should_recover_reality_player():
		_recover_reality_player()
	elif _reality_player.is_on_floor() and _reality_floor != null and _reality_floor.contains_playable_position(_reality_player.position, REALITY_SAFE_INSET):
		_reality_last_safe_position = _reality_player.position


func _should_recover_reality_player() -> bool:
	if _reality_player == null or _reality_floor == null:
		return false
	if _reality_player.position.y < REALITY_FALL_RECOVERY_Y:
		return true
	return not _reality_floor.contains_playable_position(_reality_player.position, -2.0)


func _recover_reality_player() -> void:
	if _reality_player == null or _reality_floor == null:
		return
	var recovery_position := _reality_last_safe_position
	if not _reality_floor.contains_playable_position(recovery_position, REALITY_SAFE_INSET):
		recovery_position = _reality_floor.start_position()
	recovery_position = _reality_floor.clamp_to_playable_position(recovery_position, REALITY_SAFE_INSET)
	recovery_position.y = 0.08
	_reality_player.position = recovery_position
	_reality_player.velocity = Vector3.ZERO


func _refresh_nearby_reality_actor() -> void:
	var previous_actor := _nearby_reality_actor
	var previous_item := _nearby_reality_item
	if game.view_state != "npc_up" or _reality_interaction_active or _reality_floor == null or _reality_player == null:
		_nearby_reality_actor = null
		_nearby_reality_item = null
		if previous_actor != null or previous_item != null:
			_render_world_prompt()
			if _world_prompt != null:
				_world_prompt.visible = false
		return
	var nearest: Area3D = null
	var nearest_kind := ""
	var nearest_distance := REALITY_INTERACTION_DISTANCE
	for actor in _reality_floor.get_interactable_actors():
		var offset: Vector3 = actor.position - _reality_player.position
		offset.y = 0.0
		var distance: float = offset.length()
		if distance <= nearest_distance:
			nearest = actor
			nearest_kind = "actor"
			nearest_distance = distance
	for item in _reality_floor.get_interactable_items():
		var item_offset: Vector3 = item.position - _reality_player.position
		item_offset.y = 0.0
		var item_distance: float = item_offset.length()
		if item_distance <= nearest_distance:
			nearest = item
			nearest_kind = "item"
			nearest_distance = item_distance
	_nearby_reality_actor = nearest if nearest_kind == "actor" else null
	_nearby_reality_item = nearest if nearest_kind == "item" else null
	if previous_actor != _nearby_reality_actor or previous_item != _nearby_reality_item:
		_render_world_prompt()
		if _world_prompt != null:
			_world_prompt.visible = nearest != null


func _try_reality_interaction() -> bool:
	if game.view_state != "npc_up":
		return false
	if _reality_interaction_active:
		_exit_reality_interaction()
		return true
	_refresh_nearby_reality_actor()
	if _nearby_reality_item != null:
		return _collect_nearby_reality_item()
	if _nearby_reality_actor == null:
		return false
	_active_reality_actor = _nearby_reality_actor
	var actor_id := str(_active_reality_actor.get_meta("actor_id", "actor"))
	var actor_type := str(_active_reality_actor.get_meta("actor_type", "npc"))
	var actor_label := str(_active_reality_actor.get_meta("display_name", "对方"))
	if not game.start_typed_reality_conversation(actor_id, actor_type, actor_label):
		_active_reality_actor = null
		return false
	var actor_direction: Vector3 = _active_reality_actor.position - _reality_player.position
	if actor_direction.length_squared() > 0.001:
		_reality_yaw = rad_to_deg(atan2(-actor_direction.x, -actor_direction.z))
		_reality_pitch = -2.0
	_reality_interaction_active = true
	_reality_hover_choice_id = ""
	_set_reality_mouse_look(false)
	log_text = "你停在%s面前。" % _active_actor_display_name()
	_render()
	_sync_audio_state(false)
	return true


func _collect_nearby_reality_item() -> bool:
	if _nearby_reality_item == null:
		return false
	var item := _nearby_reality_item
	var item_data := {
		"id": str(item.get_meta("item_id", "")),
		"label": str(item.get_meta("display_name", "街区遗物")),
		"effect": str(item.get_meta("item_effect", "")),
		"value": item.get_meta("item_value", 0),
		"description": str(item.get_meta("item_description", "")),
	}
	if not game.collect_world_item(item_data):
		return false
	item.set_meta("collected", true)
	item.visible = false
	item.monitoring = false
	item.monitorable = false
	_nearby_reality_item = null
	if not game.event_log.is_empty():
		log_text = game.event_log[0]
	_render()
	return true


func _exit_reality_interaction(should_render: bool = true) -> void:
	_reality_interaction_active = false
	_active_reality_actor = null
	_reality_hover_choice_id = ""
	game.reset_typed_reality_conversation()
	if game.view_state == "npc_up":
		_set_reality_mouse_look(true)
	if should_render:
		_render()
		_sync_audio_state(false)


func _active_actor_display_name() -> String:
	if _active_reality_actor == null:
		return "对方"
	return str(_active_reality_actor.get_meta("display_name", "对方"))


func _build_audio_players() -> void:
	_phone_ambience = _make_audio_player("PhoneRoadAmbience", PHONE_AMBIENCE_PATH, true, -60.0)
	_reality_ambience = _make_audio_player("RealityRoomAmbience", REALITY_AMBIENCE_PATH, true, -60.0)
	_flashback_audio = _make_audio_player("PollutionFlashbackAudio", FLASHBACK_AUDIO_PATH, false, -8.0)
	_action_tick_audio = _make_audio_player("ActionTickAudio", ACTION_TICK_AUDIO_PATH, false, -15.0)
	_sync_audio_state(true)


func _make_audio_player(node_name: String, path: String, looped: bool, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.stream = _load_generated_wav(path, looped)
	player.volume_db = volume_db
	player.set_meta("generated_audio_path", path)
	player.set_meta("looped", looped)
	add_child(player)
	return player


func _load_generated_wav(path: String, looped: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.load_from_file(path)
	if stream == null:
		return null
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		var channel_count := 2 if stream.stereo else 1
		var bytes_per_sample := 2 if stream.format == AudioStreamWAV.FORMAT_16_BITS else 1
		stream.loop_end = int(stream.data.size() / maxi(1, channel_count * bytes_per_sample))
	return stream


func _sync_audio_state(immediate: bool = false) -> void:
	if _phone_ambience == null or _reality_ambience == null:
		return
	if not _game_started or game == null:
		_phone_ambience.set_meta("target_volume_db", -60.0)
		_reality_ambience.set_meta("target_volume_db", -60.0)
		if is_inside_tree():
			_phone_ambience.stop()
			_reality_ambience.stop()
			if _flashback_audio != null:
				_flashback_audio.stop()
		return
	var in_phone: bool = game.view_state == "phone_down"
	var phone_target: float = -18.0 if in_phone else -48.0
	var intimate_typing: bool = _reality_interaction_active and game.conversation_phase == "typing"
	var reality_target: float = -48.0 if in_phone else (-16.0 if intimate_typing else -21.0)
	_phone_ambience.set_meta("target_volume_db", phone_target)
	_reality_ambience.set_meta("target_volume_db", reality_target)
	_phone_ambience.set_meta("flashback_ducked", false)
	_reality_ambience.set_meta("flashback_ducked", false)
	if _audio_tween != null and _audio_tween.is_valid():
		_audio_tween.kill()
	_audio_tween = null
	if immediate:
		_phone_ambience.volume_db = phone_target
		_reality_ambience.volume_db = reality_target
	if not is_inside_tree():
		return
	if not _phone_ambience.playing:
		_phone_ambience.play()
	if not _reality_ambience.playing:
		_reality_ambience.play()
	if immediate:
		return
	_audio_tween = create_tween().set_parallel(true)
	_audio_tween.tween_property(_phone_ambience, "volume_db", phone_target, 0.55).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_audio_tween.tween_property(_reality_ambience, "volume_db", reality_target, 0.55).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)


func _duck_ambience_for_flashback() -> void:
	if _audio_tween != null and _audio_tween.is_valid():
		_audio_tween.kill()
	_audio_tween = null
	for player in [_phone_ambience, _reality_ambience]:
		if player != null:
			player.set_meta("flashback_ducked", true)
	if not is_inside_tree():
		for player in [_phone_ambience, _reality_ambience]:
			if player != null:
				player.volume_db = -44.0
		return
	_audio_tween = create_tween().set_parallel(true)
	for player in [_phone_ambience, _reality_ambience]:
		if player != null:
			_audio_tween.tween_property(player, "volume_db", -44.0, 0.10).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _build_main_menu() -> void:
	if _canvas == null:
		return
	for child in _canvas.get_children():
		child.queue_free()

	_ui_root = Control.new()
	_ui_root.name = "UIRoot"
	_ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.add_child(_ui_root)

	_main_menu_layer = Control.new()
	_main_menu_layer.name = "MainMenuLayer"
	_main_menu_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_root.add_child(_main_menu_layer)

	var bg := ColorRect.new()
	bg.name = "MainMenuGreenBackground"
	bg.color = Color("5DAE6B")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_main_menu_layer.add_child(bg)

	for index in 7:
		var stripe := ColorRect.new()
		stripe.name = "MainMenuPosterStripe%d" % index
		stripe.color = Color(_theme_color("surface"), 0.96 if index % 2 == 0 else 0.0)
		stripe.set_anchors_preset(Control.PRESET_TOP_LEFT)
		stripe.offset_left = 74 + index * 144
		stripe.offset_top = 322
		stripe.offset_right = stripe.offset_left + 122
		stripe.offset_bottom = 430
		_main_menu_layer.add_child(stripe)
		var cut := ColorRect.new()
		cut.name = "MainMenuBlackCut%d" % index
		cut.color = _theme_color("ink")
		cut.set_anchors_preset(Control.PRESET_TOP_LEFT)
		cut.offset_left = stripe.offset_left + 10
		cut.offset_top = 322 + (index % 3) * 18
		cut.offset_right = cut.offset_left + 118
		cut.offset_bottom = cut.offset_top + 22
		cut.rotation = deg_to_rad(-22 + index * 9)
		_main_menu_layer.add_child(cut)

	var title_stack := VBoxContainer.new()
	title_stack.name = "MainMenuTextStack"
	title_stack.set_anchors_preset(Control.PRESET_TOP_LEFT)
	title_stack.offset_left = 70
	title_stack.offset_top = 218
	title_stack.offset_right = 1040
	title_stack.offset_bottom = 560
	title_stack.add_theme_constant_override("separation", 18)
	_main_menu_layer.add_child(title_stack)

	var chapter := _label("Cartridge 3", 52, Color(_theme_color("surface"), 0.82))
	chapter.name = "MainMenuChapter"
	title_stack.add_child(chapter)

	var title := _label("HAJIMI", 94, _theme_color("surface"))
	title.name = "MainMenuTitle"
	title.add_theme_color_override("font_shadow_color", _theme_color("ink"))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 0)
	title_stack.add_child(title)

	var subtitle := _label("Die Grenzen meiner Sprache bedeuten die Grenzen meiner Welt.", 28, Color(_theme_color("surface"), 0.78))
	subtitle.name = "MainMenuSubtitle"
	title_stack.add_child(subtitle)

	var buttons := HBoxContainer.new()
	buttons.name = "MainMenuButtons"
	buttons.add_theme_constant_override("separation", 18)
	title_stack.add_child(buttons)

	var start_button := Button.new()
	start_button.name = "MainMenuStartButton"
	start_button.text = "开始游戏"
	start_button.custom_minimum_size = Vector2(168, 54)
	start_button.pressed.connect(new_game, CONNECT_DEFERRED)
	buttons.add_child(start_button)

	var exit_button := Button.new()
	exit_button.name = "MainMenuExitButton"
	exit_button.text = "退出游戏"
	exit_button.custom_minimum_size = Vector2(168, 54)
	exit_button.pressed.connect(_quit_game)
	buttons.add_child(exit_button)

	var mark := Control.new()
	mark.name = "MainMenuCornerMark"
	mark.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	mark.offset_left = -150
	mark.offset_top = -126
	mark.offset_right = -56
	mark.offset_bottom = -36
	_main_menu_layer.add_child(mark)
	var mark_circle := ColorRect.new()
	mark_circle.color = _theme_color("surface")
	mark_circle.set_anchors_preset(Control.PRESET_TOP_LEFT)
	mark_circle.offset_left = 28
	mark_circle.offset_top = 0
	mark_circle.offset_right = 62
	mark_circle.offset_bottom = 34
	mark.add_child(mark_circle)
	var mark_stem := ColorRect.new()
	mark_stem.color = _theme_color("ink")
	mark_stem.set_anchors_preset(Control.PRESET_TOP_LEFT)
	mark_stem.offset_left = 46
	mark_stem.offset_top = 0
	mark_stem.offset_right = 62
	mark_stem.offset_bottom = 34
	mark.add_child(mark_stem)
	for index in 3:
		var base := ColorRect.new()
		base.color = _theme_color("surface")
		base.set_anchors_preset(Control.PRESET_TOP_LEFT)
		base.offset_left = 20 - index * 2
		base.offset_top = 54 + index * 10
		base.offset_right = 76 + index * 2
		base.offset_bottom = base.offset_top + 4
		mark.add_child(base)

	_apply_ui_theme()


func _build_ui() -> void:
	if _canvas == null:
		return
	for child in _canvas.get_children():
		child.queue_free()

	_ui_root = Control.new()
	_ui_root.name = "UIRoot"
	_ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.add_child(_ui_root)

	var vignette := ColorRect.new()
	vignette.color = _theme_color("ink").darkened(0.15)
	vignette.modulate.a = 0.16
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.z_index = 2
	_ui_root.add_child(vignette)

	_build_vhs_overlay()

	_phone_down_backdrop_image = TextureRect.new()
	_phone_down_backdrop_image.name = "PhoneDownBackdropImage"
	_phone_down_backdrop_image.texture = _load_runtime_texture(PHONE_DOWN_BACKDROP_PATH)
	_phone_down_backdrop_image.set_meta("asset_path", PHONE_DOWN_BACKDROP_PATH)
	_phone_down_backdrop_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_phone_down_backdrop_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_phone_down_backdrop_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phone_down_backdrop_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	_phone_down_backdrop_image.set_meta("walking_bob_amplitude", 2.4)
	_phone_down_backdrop_image.z_index = 1
	_ui_root.add_child(_phone_down_backdrop_image)
	_hand_phone_image = null
	_build_cinematic_bars()

	_build_apple_hud()

	_world_prompt = _label("", 18, _theme_color("surface"))
	_world_prompt.name = "WorldPrompt"
	_world_prompt.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_world_prompt.offset_left = 520
	_world_prompt.offset_top = -162
	_world_prompt.offset_right = -520
	_world_prompt.offset_bottom = -108
	_world_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_world_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_world_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_world_prompt.set_meta("on_dark", true)
	_world_prompt.add_theme_color_override("font_outline_color", Color("050705"))
	_world_prompt.add_theme_constant_override("outline_size", 6)
	_world_prompt.z_index = 10
	_ui_root.add_child(_world_prompt)

	_phone_panel = _panel()
	_phone_panel.name = "PhonePopup"
	_phone_panel.set_meta("phone_shell", true)
	_phone_panel.clip_contents = true
	_phone_panel.z_index = 20
	_ui_root.add_child(_phone_panel)
	_apply_phone_popup_layout(true)

	var phone_shell := VBoxContainer.new()
	phone_shell.name = "PhoneShell"
	phone_shell.add_theme_constant_override("separation", 0)
	_phone_panel.add_child(phone_shell)

	_phone_tab = Button.new()
	_phone_tab.name = "PhoneTab"
	_phone_tab.text = "PHONE\n打开"
	_phone_tab.custom_minimum_size = Vector2(78, 168)
	_phone_tab.pressed.connect(_open_phone_launcher)
	phone_shell.add_child(_phone_tab)

	_phone_content = VBoxContainer.new()
	_phone_content.name = "PhoneContent"
	_phone_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	(_phone_content as VBoxContainer).add_theme_constant_override("separation", 8)
	phone_shell.add_child(_phone_content)

	var phone_header := HBoxContainer.new()
	phone_header.name = "PhoneWindowHeader"
	phone_header.custom_minimum_size.y = 60
	phone_header.mouse_filter = Control.MOUSE_FILTER_STOP
	phone_header.add_theme_constant_override("separation", 8)
	_phone_content.add_child(phone_header)

	_phone_title = _label("PHONE", 20, _theme_color("accent"))
	_phone_title.name = "PhoneWindowHandle"
	_phone_title.mouse_filter = Control.MOUSE_FILTER_STOP
	_phone_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phone_header.add_child(_phone_title)
	var phone_signal_icon := TextureRect.new()
	phone_signal_icon.name = "PhoneHomeNoSignalIcon"
	phone_signal_icon.texture = _load_runtime_texture(NO_SIGNAL_ICON_PATH)
	phone_signal_icon.custom_minimum_size = Vector2(22, 22)
	phone_signal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	phone_signal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	phone_signal_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phone_header.add_child(phone_signal_icon)
	var phone_signal := _label("无信号", 13, _theme_color("accent"))
	phone_signal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	phone_header.add_child(phone_signal)
	var phone_close := Button.new()
	phone_close.name = "PhoneHomeCloseButton"
	phone_close.text = "X"
	phone_close.custom_minimum_size = Vector2(56, 56)
	phone_close.pressed.connect(set_view_state.bind("npc_up"))
	phone_header.add_child(phone_close)
	_make_draggable_window(_phone_panel, "phone", phone_header)
	_make_draggable_window(_phone_panel, "phone", _phone_title)

	var phone_screen := _panel()
	phone_screen.name = "PhoneScreenPanel"
	phone_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_phone_content.add_child(phone_screen)
	var screen_box := VBoxContainer.new()
	screen_box.add_theme_constant_override("separation", 12)
	phone_screen.add_child(screen_box)
	var app_grid := GridContainer.new()
	app_grid.columns = 2
	app_grid.add_theme_constant_override("h_separation", 10)
	app_grid.add_theme_constant_override("v_separation", 10)
	screen_box.add_child(app_grid)
	for app in [
		{"id": "babel", "label": "塔\nBABEL"},
		{"id": "social", "label": "帖\nSOCIAL"},
		{"id": "shop", "label": "店\nSHOP"},
		{"id": "notebook", "label": "本\nNOTE"},
	]:
		var button := Button.new()
		button.name = "PhoneAppIcon%s" % str(app["id"]).capitalize()
		button.text = app["label"]
		button.custom_minimum_size = Vector2(160, 112)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_app_pressed.bind(app["id"]))
		app_grid.add_child(button)

	_view_toggle_button = Button.new()
	_view_toggle_button.name = "PhoneViewToggleButton"
	_view_toggle_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_view_toggle_button.offset_left = 470
	_view_toggle_button.offset_top = -92
	_view_toggle_button.offset_right = 596
	_view_toggle_button.offset_bottom = -36
	_view_toggle_button.custom_minimum_size = Vector2(126, 56)
	_view_toggle_button.z_index = 42
	_view_toggle_button.pressed.connect(_toggle_view_state)
	_ui_root.add_child(_view_toggle_button)

	_build_app_window("social", "社交媒体 App", "SocialAppWindow", -809.0, 28.0, -389.0, 880.0)
	_build_app_window("babel", "巴别塔 App", "BabelAppWindow", -1032.0, 96.0, -592.0, 676.0)
	_build_app_window("shop", "信号商店", "ShopAppWindow", -1000.0, 124.0, -560.0, 704.0)
	_build_app_window("notebook", "笔记本 App", "NotebookAppWindow", -968.0, 152.0, -528.0, 732.0)
	_build_social_detail_window()

	_reality_intent_preview = _label("", 28, _theme_color("surface"))
	_reality_intent_preview.name = "RealityIntentPreview"
	_reality_intent_preview.set_meta("on_dark", true)
	_reality_intent_preview.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_intent_preview.offset_left = 310
	_reality_intent_preview.offset_top = -360
	_reality_intent_preview.offset_right = -250
	_reality_intent_preview.offset_bottom = -286
	_reality_intent_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reality_intent_preview.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_reality_intent_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reality_intent_preview.add_theme_color_override("font_outline_color", Color("050705"))
	_reality_intent_preview.add_theme_constant_override("outline_size", 8)
	_reality_intent_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reality_intent_preview.z_index = 14
	_ui_root.add_child(_reality_intent_preview)

	_reality_choice_row = HBoxContainer.new()
	_reality_choice_row.name = "RealityResponseChoices"
	_reality_choice_row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_choice_row.offset_left = 350
	_reality_choice_row.offset_top = -270
	_reality_choice_row.offset_right = -290
	_reality_choice_row.offset_bottom = -206
	_reality_choice_row.add_theme_constant_override("separation", 14)
	_reality_choice_row.z_index = 15
	_ui_root.add_child(_reality_choice_row)

	_reality_typing_line = RichTextLabel.new()
	_reality_typing_line.name = "RealityTypingLine"
	_reality_typing_line.bbcode_enabled = true
	_reality_typing_line.fit_content = false
	_reality_typing_line.scroll_active = false
	_reality_typing_line.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_typing_line.offset_left = 280
	_reality_typing_line.offset_top = -300
	_reality_typing_line.offset_right = -220
	_reality_typing_line.offset_bottom = -206
	_reality_typing_line.add_theme_font_size_override("normal_font_size", 30)
	_reality_typing_line.add_theme_color_override("default_color", _theme_color("surface"))
	_reality_typing_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reality_typing_line.z_index = 15
	_ui_root.add_child(_reality_typing_line)

	_reality_typing_progress = _label("", 14, _theme_color("muted"))
	_reality_typing_progress.name = "RealityTypingProgress"
	_reality_typing_progress.set_meta("on_dark", true)
	_reality_typing_progress.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_typing_progress.offset_left = 520
	_reality_typing_progress.offset_top = -210
	_reality_typing_progress.offset_right = -460
	_reality_typing_progress.offset_bottom = -184
	_reality_typing_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reality_typing_progress.z_index = 15
	_ui_root.add_child(_reality_typing_progress)

	_reality_aid_status = _label("", 14, _theme_color("muted"))
	_reality_aid_status.name = "RealityAidStatus"
	_reality_aid_status.set_meta("on_dark", true)
	_reality_aid_status.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_aid_status.offset_left = 520
	_reality_aid_status.offset_top = -204
	_reality_aid_status.offset_right = -460
	_reality_aid_status.offset_bottom = -180
	_reality_aid_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reality_aid_status.z_index = 15
	_ui_root.add_child(_reality_aid_status)

	_reality_merchant_offer = _panel()
	_reality_merchant_offer.name = "RealityMerchantOffer"
	_reality_merchant_offer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_merchant_offer.offset_left = 480
	_reality_merchant_offer.offset_top = -330
	_reality_merchant_offer.offset_right = -420
	_reality_merchant_offer.offset_bottom = -210
	_reality_merchant_offer.z_index = 15
	_ui_root.add_child(_reality_merchant_offer)
	var merchant_offer_box := HBoxContainer.new()
	merchant_offer_box.add_theme_constant_override("separation", 14)
	_reality_merchant_offer.add_child(merchant_offer_box)
	_reality_merchant_offer_text = _label("", 17, _theme_color("ink"))
	_reality_merchant_offer_text.name = "RealityMerchantOfferText"
	_reality_merchant_offer_text.custom_minimum_size = Vector2(120, 80)
	_reality_merchant_offer_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reality_merchant_offer_text.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	_reality_merchant_offer_text.clip_text = true
	merchant_offer_box.add_child(_reality_merchant_offer_text)
	_reality_merchant_buy_button = Button.new()
	_reality_merchant_buy_button.name = "RealityMerchantBuyButton"
	_reality_merchant_buy_button.custom_minimum_size = Vector2(132, 56)
	_reality_merchant_buy_button.pressed.connect(_on_buy_communication_item)
	merchant_offer_box.add_child(_reality_merchant_buy_button)

	_reality_subtitle_panel = PanelContainer.new()
	_reality_subtitle_panel.name = "RealitySubtitlePanel"
	_reality_subtitle_panel.set_meta("movie_subtitle", true)
	_reality_subtitle_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_subtitle_panel.offset_left = 360
	_reality_subtitle_panel.offset_top = -178
	_reality_subtitle_panel.offset_right = -300
	_reality_subtitle_panel.offset_bottom = -104
	_reality_subtitle_panel.z_index = 14
	_ui_root.add_child(_reality_subtitle_panel)
	var subtitle_box := HBoxContainer.new()
	subtitle_box.add_theme_constant_override("separation", 12)
	_reality_subtitle_panel.add_child(subtitle_box)
	_reality_subtitle_label = _label("", 20, _theme_color("surface"))
	_reality_subtitle_label.name = "RealitySubtitleLabel"
	_reality_subtitle_label.set_meta("on_dark", true)
	_reality_subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reality_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reality_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_reality_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reality_subtitle_label.add_theme_color_override("font_outline_color", Color("050705"))
	_reality_subtitle_label.add_theme_constant_override("outline_size", 6)
	subtitle_box.add_child(_reality_subtitle_label)
	_reality_continue_button = Button.new()
	_reality_continue_button.name = "RealityConversationContinue"
	_reality_continue_button.text = "结束"
	_reality_continue_button.custom_minimum_size = Vector2(92, 48)
	_reality_continue_button.pressed.connect(_exit_reality_interaction)
	subtitle_box.add_child(_reality_continue_button)

	_meme_bank_window = _panel()
	_meme_bank_window.name = "MemeBankPopup"
	_meme_bank_window.set_meta("meme_bank_popup", true)
	_meme_bank_window.z_index = 18
	_ui_root.add_child(_meme_bank_window)
	_apply_meme_bank_popup_layout("peek")
	var bank_box := VBoxContainer.new()
	bank_box.name = "MemeBankShell"
	bank_box.add_theme_constant_override("separation", 8)
	_meme_bank_window.add_child(bank_box)

	var bank_header := HBoxContainer.new()
	bank_header.name = "MemeBankHeader"
	bank_header.add_theme_constant_override("separation", 6)
	bank_box.add_child(bank_header)

	_meme_bank_tab = Button.new()
	_meme_bank_tab.name = "MemeBankTab"
	_meme_bank_tab.text = "›"
	_meme_bank_tab.set_meta("meme_bank_tab", true)
	_meme_bank_tab.custom_minimum_size = Vector2(52, 52)
	_meme_bank_tab.pressed.connect(_toggle_meme_bank)
	bank_header.add_child(_meme_bank_tab)

	_meme_bank_drag_handle = _label("拖拽", 14, _theme_color("accent"))
	_meme_bank_drag_handle.name = "MemeBankDragHandle"
	_meme_bank_drag_handle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_meme_bank_drag_handle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_meme_bank_drag_handle.custom_minimum_size = Vector2(54, 52)
	_meme_bank_drag_handle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bank_header.add_child(_meme_bank_drag_handle)
	_make_draggable_window(_meme_bank_window, "bank", _meme_bank_drag_handle)

	_meme_bank_content = VBoxContainer.new()
	_meme_bank_content.name = "MemeBankContent"
	(_meme_bank_content as VBoxContainer).add_theme_constant_override("separation", 8)
	bank_box.add_child(_meme_bank_content)
	var bank_title := _label("完整梗文件", 18, _theme_color("accent"))
	_meme_bank_content.add_child(bank_title)
	_bank_list = HBoxContainer.new()
	_bank_list.add_theme_constant_override("separation", 8)
	_meme_bank_content.add_child(_bank_list)

	_desk_log = _label("", 16, _theme_color("accent"))
	_desk_log.name = "DeskLog"
	_desk_log.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_desk_log.offset_left = 282
	_desk_log.offset_top = -146
	_desk_log.offset_right = 820
	_desk_log.offset_bottom = -112
	_desk_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ui_root.add_child(_desk_log)

	_build_action_spend_overlay()
	_build_settings_window()
	_build_day_transition_overlay()
	_build_flashback_overlay()
	_apply_responsive_layouts_if_needed(true)


func _build_apple_hud() -> void:
	_hud_panel = _panel()
	_hud_panel.name = "InternationalHUDRail"
	_hud_panel.set_meta("dark_rail", true)
	_hud_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_hud_panel.offset_left = 0
	_hud_panel.offset_top = 0
	_hud_panel.offset_right = 158
	_hud_panel.offset_bottom = 720
	_hud_panel.z_index = 40
	_hud_panel.add_theme_stylebox_override("panel", _style(_theme_color("ink"), Color(_theme_color("muted"), 0.22)))
	_ui_root.add_child(_hud_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	_hud_panel.add_child(box)

	_hud_day_value = null
	_hud_heat_value = null
	_hud_pollution_value = null
	_hud_clarity_value = null
	_hud_floor_value = null
	_hud_money_value = null

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 34
	box.add_child(spacer)

	_add_hud_icon(box, "HUDDayIcon", "day", HUD_DAY_ICON_PATH)
	_add_hud_icon(box, "HUDPollutionIcon", "pollution", HUD_POLLUTION_ICON_PATH)
	_add_hud_icon(box, "HUDMoneyIcon", "money", HUD_MONEY_ICON_PATH)

	var action_divider := ColorRect.new()
	action_divider.color = _theme_color("muted")
	action_divider.modulate.a = 0.42
	action_divider.custom_minimum_size.y = 1
	box.add_child(action_divider)

	var action_spacer := Control.new()
	action_spacer.custom_minimum_size.y = 10
	box.add_child(action_spacer)

	_hud_actions_label = _label("", 20, _theme_color("muted"))
	_hud_actions_label.name = "HUDActionsLabel"
	_hud_actions_label.set_meta("action_animation_mode", "inline_pulse")
	_hud_actions_label.set_meta("hud_action_label", true)
	_hud_actions_label.custom_minimum_size = Vector2(118, 70)
	_hud_actions_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_hud_actions_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_actions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_hud_actions_label)
	_actions_label = _hud_actions_label

	var settings_spacer := Control.new()
	settings_spacer.custom_minimum_size.y = 20
	box.add_child(settings_spacer)
	_hud_settings_icon = _add_hud_icon(box, "HUDSettingsIcon", "settings", HUD_SETTINGS_ICON_PATH)
	_hud_settings_icon.pressed.connect(_toggle_settings_window)

	_hud_tooltip = _panel()
	_hud_tooltip.name = "HUDTooltip"
	_hud_tooltip.set_meta("tooltip_panel", true)
	_hud_tooltip.visible = false
	_hud_tooltip.z_index = 45
	_hud_tooltip.add_theme_stylebox_override("panel", _style(_theme_color("muted"), _theme_color("accent")))
	_ui_root.add_child(_hud_tooltip)
	_hud_tooltip_label = _label("", 19, _theme_color("ink"))
	_hud_tooltip_label.name = "HUDTooltipLabel"
	_hud_tooltip.add_child(_hud_tooltip_label)


func _add_hud_icon(parent: VBoxContainer, node_name: String, kind: String, texture_path: String) -> Button:
	var icon := Button.new()
	icon.name = node_name
	icon.set_meta("hud_icon", true)
	icon.text = ""
	icon.icon = _load_runtime_texture(texture_path)
	icon.custom_minimum_size = Vector2(68, 68)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.focus_mode = Control.FOCUS_ALL
	icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	icon.pressed.connect(_show_hud_tooltip.bind(kind, icon))
	icon.mouse_entered.connect(_show_hud_tooltip.bind(kind, icon))
	icon.mouse_exited.connect(_hide_hud_tooltip)
	parent.add_child(icon)
	return icon


func _show_hud_tooltip(kind: String, source: Control) -> void:
	if _hud_tooltip == null or _hud_tooltip_label == null or source == null:
		return
	match kind:
		"day":
			_hud_tooltip_label.text = "DAY %d" % game.day
		"pollution":
			_hud_tooltip_label.text = "污染 %d%%" % game.pollution
		"money":
			_hud_tooltip_label.text = "资金 %d" % game.money
		"settings":
			_hud_tooltip_label.text = "设置"
		_:
			_hud_tooltip_label.text = ""
	_hud_tooltip.position = source.global_position + Vector2(118, 18)
	_hud_tooltip.visible = true


func _hide_hud_tooltip() -> void:
	if _hud_tooltip != null:
		_hud_tooltip.visible = false


func _add_hud_metric(parent: VBoxContainer, label_text: String, value_name: String) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var key := _label(label_text, 13, _theme_color("accent"))
	key.custom_minimum_size.x = 70
	row.add_child(key)
	var value := _label("", 17, _theme_color("ink"))
	value.name = value_name
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	return value


func _build_vhs_overlay() -> void:
	_vhs_scanlines.clear()
	_vhs_overlay = Control.new()
	_vhs_overlay.name = "VHSOverlay"
	_vhs_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vhs_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vhs_overlay.visible = _vhs_enabled
	_vhs_overlay.z_index = 3
	_ui_root.add_child(_vhs_overlay)

	var tint := ColorRect.new()
	tint.name = "VHSTint"
	tint.color = Color(_theme_color("ink"), 0.08)
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vhs_overlay.add_child(tint)

	for index in 34:
		var line := ColorRect.new()
		line.name = "VHSScanline%d" % index
		line.color = Color(_theme_color("muted"), 0.055 if index % 2 == 0 else 0.025)
		line.set_anchors_preset(Control.PRESET_TOP_WIDE)
		line.offset_left = -12
		line.offset_right = 12
		line.offset_top = index * 24
		line.offset_bottom = line.offset_top + 2
		_vhs_overlay.add_child(line)
		_vhs_scanlines.append(line)

	var side_noise := ColorRect.new()
	side_noise.name = "VHSSideNoise"
	side_noise.color = Color(_theme_color("flash_text"), 0.10)
	side_noise.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	side_noise.offset_left = 0
	side_noise.offset_right = 6
	_vhs_overlay.add_child(side_noise)


func _build_cinematic_bars() -> void:
	_cinematic_top_bar = ColorRect.new()
	_cinematic_top_bar.name = "CinematicTopBar"
	_cinematic_top_bar.color = Color("050705")
	_cinematic_top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cinematic_top_bar.z_index = 8
	_ui_root.add_child(_cinematic_top_bar)

	_cinematic_bottom_bar = ColorRect.new()
	_cinematic_bottom_bar.name = "CinematicBottomBar"
	_cinematic_bottom_bar.color = Color("050705")
	_cinematic_bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cinematic_bottom_bar.z_index = 8
	_ui_root.add_child(_cinematic_bottom_bar)
	_layout_cinematic_bars()


func _layout_cinematic_bars() -> void:
	if _cinematic_top_bar == null or _cinematic_bottom_bar == null:
		return
	var viewport_size := _viewport_size()
	var picture_height := viewport_size.x / CINEMATIC_ASPECT_RATIO
	var bar_height := clampf((viewport_size.y - picture_height) * 0.5, 28.0, viewport_size.y * 0.18)
	_cinematic_top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_cinematic_top_bar.offset_left = 0.0
	_cinematic_top_bar.offset_top = 0.0
	_cinematic_top_bar.offset_right = 0.0
	_cinematic_top_bar.offset_bottom = bar_height
	_cinematic_bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_cinematic_bottom_bar.offset_left = 0.0
	_cinematic_bottom_bar.offset_top = -bar_height
	_cinematic_bottom_bar.offset_right = 0.0
	_cinematic_bottom_bar.offset_bottom = 0.0
	_cinematic_top_bar.set_meta("target_aspect_ratio", CINEMATIC_ASPECT_RATIO)
	_cinematic_bottom_bar.set_meta("target_aspect_ratio", CINEMATIC_ASPECT_RATIO)


func _build_settings_window() -> void:
	_settings_window = _panel()
	_settings_window.name = "SettingsWindow"
	_settings_window.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_settings_window.offset_left = 180
	_settings_window.offset_top = 410
	_settings_window.offset_right = 500
	_settings_window.offset_bottom = 664
	_settings_window.z_index = 30
	_settings_window.visible = false
	_ui_root.add_child(_settings_window)

	_settings_content = VBoxContainer.new()
	_settings_content.name = "SettingsContent"
	_settings_content.add_theme_constant_override("separation", 12)
	_settings_window.add_child(_settings_content)

	var title_bar := HBoxContainer.new()
	title_bar.name = "SettingsTitleBar"
	title_bar.custom_minimum_size.y = 48
	title_bar.add_theme_constant_override("separation", 8)
	_settings_content.add_child(title_bar)
	_make_draggable_window(_settings_window, "settings", title_bar)

	var title := _label("设置", 24, _theme_color("accent"))
	title.name = "SettingsWindowHandle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title)
	_make_draggable_window(_settings_window, "settings", title)
	var close := Button.new()
	close.name = "SettingsCloseButton"
	close.text = "X"
	close.custom_minimum_size = Vector2(56, 56)
	close.pressed.connect(_close_settings_window)
	title_bar.add_child(close)

	var volume_label := _label("音量", 17, _theme_color("ink"))
	_settings_content.add_child(volume_label)
	_volume_slider = HSlider.new()
	_volume_slider.name = "SettingsVolumeSlider"
	_volume_slider.min_value = 0
	_volume_slider.max_value = 100
	_volume_slider.step = 1
	_volume_slider.value = _master_volume
	_volume_slider.custom_minimum_size = Vector2(260, 44)
	_volume_slider.value_changed.connect(_on_volume_changed)
	_settings_content.add_child(_volume_slider)

	_vhs_toggle = CheckButton.new()
	_vhs_toggle.name = "SettingsVHSToggle"
	_vhs_toggle.text = "开启 VHS 质感"
	_vhs_toggle.button_pressed = _vhs_enabled
	_vhs_toggle.custom_minimum_size.y = 48
	_vhs_toggle.toggled.connect(_on_vhs_toggled)
	_settings_content.add_child(_vhs_toggle)

	var main_menu_button := Button.new()
	main_menu_button.name = "SettingsReturnMainButton"
	main_menu_button.text = "退回主画面"
	main_menu_button.custom_minimum_size.y = 50
	main_menu_button.pressed.connect(_on_return_main_menu_pressed)
	_settings_content.add_child(main_menu_button)


func _toggle_settings_window() -> void:
	if _settings_window == null:
		return
	_settings_open = not _settings_open
	_settings_window.visible = _settings_open
	if _settings_open:
		_settings_window.move_to_front()
	_hide_hud_tooltip()


func _close_settings_window() -> void:
	_settings_open = false
	if _settings_window != null:
		_settings_window.visible = false


func _on_volume_changed(value: float) -> void:
	_master_volume = value
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(0.001, value / 100.0)))


func _on_return_main_menu_pressed() -> void:
	call_deferred("show_main_menu")


func _on_vhs_toggled(value: bool) -> void:
	_vhs_enabled = value
	if _vhs_overlay != null:
		_vhs_overlay.visible = value


func _quit_game() -> void:
	get_tree().quit()


func _build_app_window(app_id: String, title: String, node_name: String, left: float, top: float, right: float, bottom: float) -> void:
	var window := _panel()
	window.name = node_name
	window.clip_contents = true
	if app_id == "social":
		window.set_meta("phone_shell", true)
	window.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_apply_app_window_layout(window, app_id, left, top, right, bottom)
	window.z_index = 10
	_ui_root.add_child(window)

	var app_box := VBoxContainer.new()
	app_box.add_theme_constant_override("separation", 4 if app_id == "social" else 8)
	window.add_child(app_box)

	var title_label := _label(title, 21, _theme_color("accent"))
	title_label.name = "%sHandle" % node_name
	title_label.mouse_filter = Control.MOUSE_FILTER_STOP
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close_button := Button.new()
	close_button.name = "%sCloseButton" % node_name
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(56, 56)
	close_button.pressed.connect(_close_app_window.bind(app_id))
	if app_id == "social":
		title_label.visible = false
		window.add_child(title_label)
	else:
		var title_bar := HBoxContainer.new()
		title_bar.name = "%sTitleBar" % node_name
		title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
		title_bar.custom_minimum_size.y = 56
		title_bar.add_theme_constant_override("separation", 8)
		app_box.add_child(title_bar)
		title_bar.add_child(title_label)
		_make_draggable_window(window, "app:%s" % app_id, title_bar)
		_make_draggable_window(window, "app:%s" % app_id, title_label)
		title_bar.add_child(close_button)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	if app_id == "social" or app_id == "notebook":
		body.name = "SocialAppBody"
		if app_id == "notebook":
			body.name = "NotebookAppBody"
		body.size_flags_vertical = Control.SIZE_EXPAND_FILL
		app_box.add_child(body)
	else:
		var app_scroll := ScrollContainer.new()
		app_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		app_box.add_child(app_scroll)
		app_scroll.add_child(body)

	_app_windows[app_id] = window
	_app_titles[app_id] = title_label
	_app_bodies[app_id] = body
	if app_id == "social":
		_app_window = window
		_app_title = title_label
		_app_body = body


func _build_social_detail_window() -> void:
	_social_detail_window = _panel()
	_social_detail_window.name = "SocialDetailWindow"
	_social_detail_window.set_meta("detail_dark_panel", true)
	_social_detail_window.clip_contents = true
	_social_detail_window.z_index = 24
	_ui_root.add_child(_social_detail_window)
	_apply_social_detail_window_layout()

	var shell := VBoxContainer.new()
	shell.name = "SocialDetailShell"
	shell.add_theme_constant_override("separation", 8)
	_social_detail_window.add_child(shell)

	var header := HBoxContainer.new()
	header.name = "SocialDetailWindowHeader"
	header.custom_minimum_size.y = 56
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.add_theme_constant_override("separation", 8)
	shell.add_child(header)

	_social_detail_title = _label("塔层 1/5", 18, _theme_color("surface"))
	_social_detail_title.name = "SocialDetailWindowHandle"
	_social_detail_title.set_meta("on_dark", true)
	_social_detail_title.mouse_filter = Control.MOUSE_FILTER_STOP
	_social_detail_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_social_detail_title)
	_make_draggable_window(_social_detail_window, "social-detail", header)
	_make_draggable_window(_social_detail_window, "social-detail", _social_detail_title)

	var close_button := Button.new()
	close_button.name = "SocialDetailWindowCloseButton"
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(56, 56)
	close_button.pressed.connect(_close_social_detail_window)
	header.add_child(close_button)

	var detail_scroll := ScrollContainer.new()
	detail_scroll.name = "SocialDetailScroll"
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	shell.add_child(detail_scroll)

	_social_detail_body = VBoxContainer.new()
	_social_detail_body.name = "SocialDetailBody"
	_social_detail_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_social_detail_body.add_theme_constant_override("separation", 8)
	detail_scroll.add_child(_social_detail_body)
	_social_detail_window.visible = false


func _apply_social_detail_window_layout() -> void:
	if _social_detail_window == null:
		return
	var viewport_size := _viewport_size()
	_social_detail_window.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	if viewport_size.x >= 900.0:
		_social_detail_window.offset_left = -379.0
		_social_detail_window.offset_top = 96.0
		_social_detail_window.offset_right = -24.0
		_social_detail_window.offset_bottom = minf(850.0, viewport_size.y - 24.0)
		return
	var safe_left := 12.0
	if _hud_panel != null:
		safe_left = _hud_panel.offset_right + 10.0
	var right_margin := 12.0
	var available_width := maxf(220.0, viewport_size.x - safe_left - right_margin)
	var target_width := minf(376.0, available_width)
	_social_detail_window.offset_right = -right_margin
	_social_detail_window.offset_left = _social_detail_window.offset_right - target_width
	_social_detail_window.offset_top = 20.0
	_social_detail_window.offset_bottom = viewport_size.y - 12.0


func _apply_app_window_layout(window: Control, app_id: String, left: float, top: float, right: float, bottom: float) -> void:
	var viewport_size := _viewport_size()
	if viewport_size.x >= 900.0:
		window.offset_left = left
		window.offset_top = top
		window.offset_right = right
		window.offset_bottom = bottom
		return
	var safe_left := 12.0
	if _hud_panel != null:
		safe_left = maxf(safe_left, _hud_panel.offset_right + 10.0)
	var right_margin := 12.0
	var available_width := maxf(220.0, viewport_size.x - safe_left - right_margin)
	var original_width := right - left
	var target_width := minf(original_width, available_width)
	var top_margin := 6.0 if app_id == "social" else clampf(top, 12.0, 72.0)
	if app_id == "social":
		target_width = minf(target_width, (viewport_size.y - top_margin - 8.0) * 0.62)
	window.offset_right = -right_margin
	window.offset_left = window.offset_right - target_width
	window.offset_top = top_margin
	window.offset_bottom = viewport_size.y - 8.0


func _apply_phone_popup_layout(expanded: bool) -> void:
	if _phone_panel == null:
		return
	var viewport_size := _viewport_size()
	_phone_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	if expanded:
		var safe_left := 176.0
		if _hud_panel != null:
			safe_left = _hud_panel.offset_right + 18.0
		var max_height := minf(824.0, viewport_size.y - 32.0)
		var max_width := minf(480.0, viewport_size.x - safe_left - 28.0)
		var phone_width := maxf(286.0, minf(max_width, max_height / 1.72))
		var phone_height := phone_width * 1.72
		_phone_panel.offset_right = -24
		_phone_panel.offset_bottom = -18
		if viewport_size.x < 720.0:
			_phone_panel.offset_right = -8
			_phone_panel.offset_bottom = -8
		_phone_panel.offset_left = _phone_panel.offset_right - phone_width
		_phone_panel.offset_top = _phone_panel.offset_bottom - phone_height
	else:
		_phone_panel.offset_top = -306
		_phone_panel.offset_left = -112
		_phone_panel.offset_right = -12
		_phone_panel.offset_bottom = -94


func _apply_meme_bank_popup_layout(mode: String) -> void:
	if _meme_bank_window == null:
		return
	var viewport_size := _viewport_size()
	if mode == "open":
		_meme_bank_window.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		var safe_left := viewport_size.x * 0.30
		if _hud_panel != null:
			safe_left = maxf(safe_left, _hud_panel.offset_right + 22.0)
		var min_bank_width := 180.0 if viewport_size.x < 560.0 else 296.0
		var bank_width := minf(408.0, maxf(min_bank_width, viewport_size.x - safe_left - 28.0))
		safe_left = clampf(safe_left, 12.0, maxf(12.0, viewport_size.x - bank_width - 12.0))
		_meme_bank_window.offset_left = safe_left
		_meme_bank_window.offset_top = -324
		_meme_bank_window.offset_right = safe_left + bank_width
		_meme_bank_window.offset_bottom = -120
	elif mode == "collapsed":
		_meme_bank_window.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		var collapsed_left := viewport_size.x * 0.30
		if _hud_panel != null:
			collapsed_left = maxf(collapsed_left, _hud_panel.offset_right + 22.0)
		var collapsed_width := 112.0
		collapsed_left = clampf(collapsed_left, 12.0, maxf(12.0, viewport_size.x - collapsed_width - 12.0))
		_meme_bank_window.offset_left = collapsed_left
		_meme_bank_window.offset_top = -82
		_meme_bank_window.offset_right = collapsed_left + collapsed_width
		_meme_bank_window.offset_bottom = -22
	else:
		_meme_bank_window.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		var peek_left := viewport_size.x * 0.30
		if _hud_panel != null:
			peek_left = maxf(peek_left, _hud_panel.offset_right + 22.0)
		var peek_size := 44.0
		peek_left = clampf(peek_left, 12.0, maxf(12.0, viewport_size.x - peek_size - 12.0))
		_meme_bank_window.offset_left = peek_left
		_meme_bank_window.offset_top = -66
		_meme_bank_window.offset_right = peek_left + peek_size
		_meme_bank_window.offset_bottom = -22


func _apply_reality_layout() -> void:
	var viewport_size := _viewport_size()
	var hud_right := 0.0
	if _hud_panel != null:
		hud_right = _hud_panel.offset_right
	var compact := viewport_size.x < 760.0
	var safe_left := maxf(18.0, hud_right + (12.0 if compact else 48.0))
	var right_margin := 118.0 if compact else 150.0
	var content_left := safe_left + (4.0 if compact else 80.0)
	var content_right := -right_margin
	if _reality_intent_preview != null:
		_reality_intent_preview.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_reality_intent_preview.offset_left = content_left
		_reality_intent_preview.offset_top = -354.0
		_reality_intent_preview.offset_right = content_right
		_reality_intent_preview.offset_bottom = -282.0
	if _reality_choice_row != null:
		_reality_choice_row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_reality_choice_row.offset_left = content_left
		_reality_choice_row.offset_top = -272.0
		_reality_choice_row.offset_right = content_right
		_reality_choice_row.offset_bottom = -208.0
	if _reality_typing_line != null:
		_reality_typing_line.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_reality_typing_line.offset_left = content_left
		_reality_typing_line.offset_top = -300.0
		_reality_typing_line.offset_right = content_right
		_reality_typing_line.offset_bottom = -208.0
	if _reality_typing_progress != null:
		_reality_typing_progress.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_reality_typing_progress.offset_left = content_left
		_reality_typing_progress.offset_top = -208.0
		_reality_typing_progress.offset_right = content_right
		_reality_typing_progress.offset_bottom = -182.0
	if _reality_aid_status != null:
		_reality_aid_status.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_reality_aid_status.offset_left = content_left
		_reality_aid_status.offset_top = -204.0
		_reality_aid_status.offset_right = content_right
		_reality_aid_status.offset_bottom = -180.0
	if _reality_merchant_offer != null:
		_reality_merchant_offer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		var offer_inset := 0.0 if compact else 160.0
		_reality_merchant_offer.offset_left = content_left + offer_inset
		_reality_merchant_offer.offset_top = -348.0
		_reality_merchant_offer.offset_right = content_right - offer_inset
		_reality_merchant_offer.offset_bottom = -214.0
	if _reality_subtitle_panel != null:
		_reality_subtitle_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_reality_subtitle_panel.offset_left = content_left
		_reality_subtitle_panel.offset_top = -178.0
		_reality_subtitle_panel.offset_right = content_right
		_reality_subtitle_panel.offset_bottom = -104.0


func _apply_responsive_layouts_if_needed(force: bool = false) -> void:
	var viewport_size := _viewport_size()
	if not force and viewport_size == _last_responsive_layout_size:
		return
	_last_responsive_layout_size = viewport_size
	if _phone_panel != null and game != null:
		_apply_phone_popup_layout(game.view_state == "phone_down")
	if _meme_bank_window != null:
		var show_meme_bank := _should_show_meme_bank()
		var desired_bank_layout := "open" if _meme_bank_open else ("collapsed" if show_meme_bank else "peek")
		_meme_bank_layout_mode = desired_bank_layout
		_apply_meme_bank_popup_layout(desired_bank_layout)
	_apply_social_detail_window_layout()
	_apply_reality_layout()
	_layout_cinematic_bars()


func _render() -> void:
	if game.ending_unlocked:
		_render_ending()
		return
	_ensure_reality_floor_current()
	_render_status()
	_render_world_prompt()
	_render_app()
	_render_publish()
	_render_bank()
	_render_reality()
	_update_visibility()
	_apply_world_theme()
	_apply_ui_theme()


func _render_status() -> void:
	if _hud_day_value != null:
		_hud_day_value.text = str(game.day)
	if _hud_heat_value != null:
		_hud_heat_value.text = str(game.heat)
	if _hud_pollution_value != null:
		_hud_pollution_value.text = "%d%%" % game.pollution
	if _hud_clarity_value != null:
		_hud_clarity_value.text = "%d%%" % game.clarity
	if _hud_floor_value != null:
		_hud_floor_value.text = "%d/%d" % [game.tower_floor, MemeGameStateScript.MAX_TOWER_FLOOR]
	if _hud_money_value != null:
		_hud_money_value.text = str(game.money)
	if _hud_actions_label != null:
		_hud_actions_label.text = _action_text(game.actions_remaining)
	if _actions_label != null and _actions_label != _hud_actions_label:
		_actions_label.text = _action_text(game.actions_remaining)
	if _desk_log != null:
		_desk_log.text = log_text


func _action_text(actions: int) -> String:
	return "今日行动\n%s" % _action_pips(actions)


func _action_pips(actions: int) -> String:
	var pips := ""
	for index in game.max_actions_per_day:
		if index > 0:
			pips += " "
		pips += "●" if index < actions else "○"
	return pips


func _render_world_prompt() -> void:
	var plan := _day_plan()
	if game.view_state == "phone_down":
		_world_prompt.text = "DAY %d. %s\n路面在脚下滑动。手机 App 的窗口浮在屏幕旁边。" % [game.day, plan["title"]]
	elif _reality_interaction_active:
		_world_prompt.text = "%s：%s" % [_active_actor_display_name(), _corrupt(str(plan["line"]))]
	elif _nearby_reality_item != null:
		_world_prompt.text = "F  拾取 · %s\n%s" % [
			str(_nearby_reality_item.get_meta("display_name", "街区遗物")),
			str(_nearby_reality_item.get_meta("item_description", "信号已经写入。")),
		]
	elif _nearby_reality_actor != null:
		var action := "交易" if str(_nearby_reality_actor.get_meta("actor_type", "npc")) == "merchant" else "交谈"
		_world_prompt.text = "F  %s · %s" % [action, str(_nearby_reality_actor.get_meta("display_name", "对方"))]
	else:
		_world_prompt.text = ""


func _render_app() -> void:
	for app_id in ["social", "babel", "shop", "notebook"]:
		if not _app_bodies.has(app_id):
			continue
		_app_body = _app_bodies[app_id] as VBoxContainer
		_app_title = _app_titles[app_id] as Label
		match app_id:
			"babel":
				_app_title.text = "巴别塔 App"
				_render_babel_app()
			"shop":
				_app_title.text = "信号商店"
				_render_shop_app()
			"notebook":
				_app_title.text = "笔记本 App"
				_render_notebook_app()
			"social":
				_app_title.text = "社交媒体 App"
				_render_social_app()
	_render_social_detail_companion()


func _render_babel_app() -> void:
	_clear(_app_body)
	_app_body.add_child(_label("第 %d 层 / %d" % [game.tower_floor, MemeGameStateScript.MAX_TOWER_FLOOR], 24, _theme_color("ink")))
	_app_body.add_child(_label("下一门槛：%d" % game.next_threshold, 17, _theme_color("accent")))
	var reward_choices: Array = game.get_pending_ascent_reward_choices()
	if not reward_choices.is_empty():
		_app_body.add_child(_label("第 %d 层许可 / 三选一" % game.pending_ascent_reward_floor, 18, _theme_color("accent")))
		for index in reward_choices.size():
			var reward: Dictionary = reward_choices[index]
			var choice := Button.new()
			choice.name = "AscentRewardChoice%d" % index
			choice.text = "0%d  /  %s\n%s" % [index + 1, str(reward.get("label", "永久修正")), str(reward.get("description", ""))]
			choice.set_meta("ascent_reward_card", true)
			choice.custom_minimum_size.y = 84
			choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
			choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			choice.pressed.connect(_on_ascent_reward_pressed.bind(str(reward.get("id", ""))))
			_app_body.add_child(choice)
		_app_body.add_child(_label("选择许可不消耗今日行动。", 14, _theme_color("accent")))
	if not game.permanent_modifiers.is_empty():
		_app_body.add_child(_label("已保留许可", 18, _theme_color("accent")))
		for modifier in game.permanent_modifiers:
			_app_body.add_child(_label("%s  /  %s" % [str(modifier.get("label", "许可")), str(modifier.get("description", ""))], 15, _theme_color("ink")))
	_app_body.add_child(_label("遗产规则", 18, _theme_color("accent")))
	if game.legacy_rules.is_empty():
		_app_body.add_child(_label("还没有上一层语言留下来。", 16, _theme_color("accent")))
	for rule in game.legacy_rules:
		_app_body.add_child(_label("第 %d 层：%s" % [int(rule.get("floor", 1)), str(rule.get("required_text", ""))], 16, _theme_color("ink")))
	for item in game.event_log:
		_app_body.add_child(_label(str(item), 15, _theme_color("accent")))


func _render_social_app() -> void:
	_clear(_app_body)
	_publish_blank = null
	_confirm_publish_button = null
	var phone_view := _panel()
	phone_view.name = "SocialPhoneView"
	phone_view.set_meta("phone_surface", true)
	phone_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_app_body.add_child(phone_view)

	var phone_box := VBoxContainer.new()
	phone_box.add_theme_constant_override("separation", 4)
	phone_view.add_child(phone_box)

	var status_bar := HBoxContainer.new()
	status_bar.name = "SocialPhoneStatusBar"
	status_bar.custom_minimum_size.y = 52
	status_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	status_bar.add_theme_constant_override("separation", 6)
	phone_box.add_child(status_bar)
	_make_draggable_window(_app_windows.get("social", null) as Control, "app:social", status_bar)
	var time_label := _label("9:41", 14, _theme_color("ink"))
	time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	time_label.custom_minimum_size.x = 40
	status_bar.add_child(time_label)
	var no_signal_group := HBoxContainer.new()
	no_signal_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	no_signal_group.add_theme_constant_override("separation", 5)
	status_bar.add_child(no_signal_group)
	var no_signal_icon := TextureRect.new()
	no_signal_icon.name = "SocialNoSignalIcon"
	no_signal_icon.texture = _load_runtime_texture(NO_SIGNAL_ICON_PATH)
	no_signal_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	no_signal_icon.visible = true
	no_signal_icon.custom_minimum_size = Vector2(22, 22)
	no_signal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	no_signal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	no_signal_group.add_child(no_signal_icon)
	var signal_label := _label("无信号", 13, _theme_color("accent"))
	signal_label.name = "SocialNoSignalLabel"
	signal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	no_signal_group.add_child(signal_label)
	var top_spacer := Control.new()
	top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_bar.add_child(top_spacer)
	var drag_grip := ColorRect.new()
	drag_grip.name = "SocialStatusDragGrip"
	drag_grip.color = _theme_color("accent")
	drag_grip.modulate.a = 0.45
	drag_grip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_grip.custom_minimum_size = Vector2(36, 3)
	drag_grip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status_bar.add_child(drag_grip)
	var close_social := Button.new()
	close_social.name = "SocialAppInlineCloseButton"
	close_social.text = "X"
	close_social.custom_minimum_size = Vector2(48, 48)
	close_social.pressed.connect(_close_app_window.bind("social"))
	status_bar.add_child(close_social)

	var channel_tabs := HBoxContainer.new()
	channel_tabs.name = "SocialChannelTabs"
	channel_tabs.custom_minimum_size.y = 48
	channel_tabs.add_theme_constant_override("separation", 2)
	phone_box.add_child(channel_tabs)
	for tab_text in ["关注", "发现", "塔下", "附近"]:
		var tab_item := VBoxContainer.new()
		tab_item.name = "SocialChannelTabItem%s" % tab_text
		tab_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_item.add_theme_constant_override("separation", 0)
		channel_tabs.add_child(tab_item)
		var tab := Button.new()
		tab.name = "SocialChannelTab%s" % tab_text
		tab.text = tab_text
		tab.set_meta("flat_phone_button", true)
		tab.custom_minimum_size = Vector2(88, 48)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.pressed.connect(_on_social_channel_pressed.bind(tab_text))
		tab_item.add_child(tab)
		var underline := ColorRect.new()
		underline.name = "SocialChannelTabUnderline%s" % tab_text
		underline.color = _theme_color("muted")
		underline.custom_minimum_size.y = 3
		underline.visible = tab_text == _social_channel
		tab_item.add_child(underline)

	var page_host := VBoxContainer.new()
	page_host.name = "SocialPageHost"
	page_host.clip_contents = true
	page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_host.add_theme_constant_override("separation", 8)
	phone_box.add_child(page_host)

	match _social_screen:
		"detail":
			_render_social_detail_page(page_host)
		"publish":
			_render_social_publish_page(page_host)
		"profile":
			_render_social_profile_page(page_host)
		_:
			_render_social_home_page(page_host)

	_render_social_bottom_nav(phone_box)


func _render_social_home_page(parent: VBoxContainer) -> void:
	var home_page := VBoxContainer.new()
	home_page.name = "SocialHomePage"
	home_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	home_page.add_theme_constant_override("separation", 0)
	parent.add_child(home_page)
	if _social_channel == "附近":
		_render_social_channel_empty_state(
			home_page,
			"SocialNearbyUnavailable",
			"无法定位",
			"设备保持无信号。附近内容无法取得位置。"
		)
		return

	var visible_post_indices := _social_visible_post_indices()
	if _social_channel == "关注" and visible_post_indices.is_empty():
		_render_social_channel_empty_state(
			home_page,
			"SocialFollowingEmptyState",
			"还没有关注",
			"在发现瀑布流里关注一个账号，它的帖子会留在这里。"
		)
		return

	var feed_frame := PanelContainer.new()
	feed_frame.name = "SocialFeedDarkFrame"
	feed_frame.set_meta("social_feed_dark", true)
	feed_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	home_page.add_child(feed_frame)

	var feed_scroll := ScrollContainer.new()
	feed_scroll.name = "SocialFeedScroll"
	feed_scroll.set_meta("slow_scroll_step", SOCIAL_FEED_WHEEL_STEP)
	feed_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	feed_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	feed_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	feed_scroll.gui_input.connect(_on_social_feed_scroll_gui_input.bind(feed_scroll))
	feed_frame.add_child(feed_scroll)

	var masonry := HBoxContainer.new()
	masonry.name = "SocialFeedMasonry"
	masonry.add_theme_constant_override("separation", 12)
	masonry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feed_scroll.add_child(masonry)
	var columns: Array[VBoxContainer] = []
	for column_index in 2:
		var column := VBoxContainer.new()
		column.name = "SocialMasonryColumn%d" % column_index
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 10)
		masonry.add_child(column)
		columns.append(column)
	for visible_index in visible_post_indices.size():
		var post_index: int = int(visible_post_indices[visible_index])
		var post := _social_post_for_index(post_index)
		var card_panel := _panel()
		card_panel.name = "SocialPostCard%d" % post_index
		card_panel.set_meta("social_card", true)
		card_panel.custom_minimum_size = Vector2(0, 232 + (post_index % 4) * 38)
		card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		card_panel.gui_input.connect(_on_social_card_gui_input.bind(post_index))
		card_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		columns[visible_index % columns.size()].add_child(card_panel)
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 6)
		card_panel.add_child(card)
		_render_social_card_poster(card, post_index, post)
		var caption := _label(_social_caption(post, post_index), 14, _theme_color("ink"))
		caption.name = "SocialPostCaption%d" % post_index
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(caption)
		var meta_row := HBoxContainer.new()
		meta_row.add_theme_constant_override("separation", 4)
		card.add_child(meta_row)
		var likes := Button.new()
		likes.name = "SocialPostLikeButton%d" % post_index
		likes.text = _social_like_text(post, post_index)
		likes.set_meta("flat_phone_button", true)
		likes.custom_minimum_size = Vector2(64, 44)
		likes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		likes.pressed.connect(_on_social_like_pressed.bind(str(post.get("id", ""))))
		meta_row.add_child(likes)
		var follow := Button.new()
		follow.name = "SocialPostFollowButton%d" % post_index
		follow.text = "已关注" if game.is_social_following(str(post.get("handle", ""))) else "关注"
		follow.set_meta("flat_phone_button", true)
		follow.custom_minimum_size = Vector2(74, 44)
		follow.pressed.connect(_on_social_follow_pressed.bind(str(post.get("handle", ""))))
		meta_row.add_child(follow)
	var scroll_hint := _label("继续下滑浏览更多信号", 13, _theme_color("accent"))
	scroll_hint.name = "SocialScrollHint"
	scroll_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columns[0].add_child(scroll_hint)


func _render_social_channel_empty_state(parent: VBoxContainer, node_name: String, title: String, body: String) -> void:
	var frame := PanelContainer.new()
	frame.name = node_name
	frame.set_meta("social_feed_dark", true)
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(frame)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(center)
	var copy := VBoxContainer.new()
	copy.custom_minimum_size.x = 300
	copy.add_theme_constant_override("separation", 12)
	center.add_child(copy)
	var eyebrow := _label("NO SIGNAL / 00", 13, _theme_color("muted"))
	eyebrow.set_meta("on_dark", true)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_child(eyebrow)
	var heading := _label(title, 24, _theme_color("surface"))
	heading.set_meta("on_dark", true)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_child(heading)
	var message := _label(body, 15, _theme_color("muted"))
	message.name = "%sMessage" % node_name
	message.set_meta("on_dark", true)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_child(message)


func _social_visible_post_indices() -> Array[int]:
	var result: Array[int] = []
	for post_index in SOCIAL_POST_CARDS.size():
		if _social_channel == "关注":
			var post := _social_post_for_index(post_index)
			if not game.is_social_following(str(post.get("handle", ""))):
				continue
		result.append(post_index)
	return result


func _social_like_text(post: Dictionary, post_index: int) -> String:
	var liked := game.is_social_post_liked(str(post.get("id", "")))
	var stable_index := int(post.get("card_index", post_index))
	var count := 64 + (stable_index * 31) % 120 + (1 if liked else 0)
	return "%s %d" % ["♥" if liked else "♡", count]


func _render_social_card_poster(parent: VBoxContainer, post_index: int, post: Dictionary) -> void:
	var poster := PanelContainer.new()
	poster.name = "SocialPostPoster%d" % post_index
	poster.set_meta("poster_frame", true)
	poster.custom_minimum_size.y = 136 + (post_index % 4) * 46
	poster.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poster.add_theme_stylebox_override("panel", _style(_social_poster_color(post_index), _theme_color("accent")))
	parent.add_child(poster)

	var poster_texture := TextureRect.new()
	poster_texture.name = "SocialPostTexture%d" % post_index
	var poster_cell := int(post.get("poster_cell", post_index))
	poster_texture.texture = _social_poster_texture(poster_cell)
	poster_texture.set_meta("poster_sheet_path", SOCIAL_POSTER_SHEET_PATH)
	poster_texture.set_meta("poster_sheet_cell", poster_cell % SOCIAL_POSTER_COUNT)
	poster_texture.custom_minimum_size = Vector2(0, poster.custom_minimum_size.y)
	poster_texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poster_texture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	poster_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	poster.add_child(poster_texture)


func _social_poster_color(post_index: int) -> Color:
	match post_index % 4:
		0:
			return _theme_color("muted")
		1:
			return _theme_color("surface")
		2:
			return _theme_color("accent").lightened(0.46)
		_:
			return _theme_color("bg").lightened(0.10)


func _social_poster_headline(post_index: int) -> String:
	var heads := ["BABEL\nSIGNAL", "空位图像", "塔下笔记", "哈吉米\nECHO"]
	return heads[post_index % heads.size()]


func _social_fragment(post: Dictionary) -> String:
	var text := str(post.get("text", ""))
	return text.substr(0, mini(12, text.length()))


func _social_caption(post: Dictionary, _post_index: int) -> String:
	return str(post.get("caption", "未命名信号")).substr(0, 12)


func _render_social_detail_companion() -> void:
	if _social_detail_body == null:
		return
	_clear(_social_detail_body)
	if not _social_detail_open:
		return
	if _social_detail_title != null:
		_social_detail_title.text = "塔层 %d/%d" % [game.tower_floor, MemeGameStateScript.MAX_TOWER_FLOOR]
	_render_social_detail_page(_social_detail_body, true)


func _render_social_detail_page(parent: VBoxContainer, companion: bool = false) -> void:
	var detail_page := VBoxContainer.new()
	detail_page.name = "SocialPostDetailPage"
	detail_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_page.add_theme_constant_override("separation", 8)
	parent.add_child(detail_page)

	var post := _social_post_for_index(_social_detail_post_index)

	if companion:
		var companion_meta := HBoxContainer.new()
		companion_meta.add_theme_constant_override("separation", 8)
		detail_page.add_child(companion_meta)
		var companion_handle := _label("@%s" % post["handle"], 15, _theme_color("surface"))
		companion_handle.set_meta("on_dark", true)
		companion_handle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		companion_meta.add_child(companion_handle)
		var floor_marker := _label("信号档案", 13, _theme_color("muted"))
		floor_marker.name = "SocialDetailSignalArchive"
		floor_marker.set_meta("on_dark", true)
		companion_meta.add_child(floor_marker)
	else:
		var top_row := HBoxContainer.new()
		top_row.add_theme_constant_override("separation", 8)
		detail_page.add_child(top_row)
		var back := Button.new()
		back.name = "SocialBackToHome"
		back.text = "‹"
		back.custom_minimum_size = Vector2(76, 56)
		back.pressed.connect(_close_social_detail_window)
		top_row.add_child(back)
		var title := _label("@%s" % post["handle"], 18, _theme_color("accent"))
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_row.add_child(title)
		var floor_label := _label("塔层 %d/%d" % [game.tower_floor, MemeGameStateScript.MAX_TOWER_FLOOR], 16, _theme_color("ink"))
		floor_label.name = "SocialDetailTowerFloor"
		top_row.add_child(floor_label)

	var detail_card := _panel()
	detail_card.name = "SocialPostDetailCard"
	detail_card.set_meta("detail_dark_panel", true)
	detail_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_page.add_child(detail_card)
	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 9)
	detail_card.add_child(detail_box)
	var media := PanelContainer.new()
	media.custom_minimum_size.y = 320 if companion else 274
	media.set_meta("poster_frame", true)
	media.add_theme_stylebox_override("panel", _style(_theme_color("muted"), _theme_color("accent")))
	detail_box.add_child(media)
	var media_texture := TextureRect.new()
	media_texture.name = "SocialDetailPostTexture"
	var poster_cell := int(post.get("poster_cell", _social_detail_post_index))
	media_texture.texture = _social_poster_texture(poster_cell)
	media_texture.set_meta("poster_sheet_path", SOCIAL_POSTER_SHEET_PATH)
	media_texture.set_meta("poster_sheet_cell", poster_cell % SOCIAL_POSTER_COUNT)
	media_texture.custom_minimum_size = Vector2(300, 320 if companion else 274)
	media_texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	media_texture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	media_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	media_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	media.add_child(media_texture)
	var post_text := _label(_corrupt(str(post["text"])), 17, _theme_color("surface"))
	post_text.set_meta("on_dark", true)
	post_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(post_text)
	var engagement := HBoxContainer.new()
	engagement.name = "SocialDetailEngagementRow"
	engagement.add_theme_constant_override("separation", 8)
	detail_box.add_child(engagement)
	var detail_like := Button.new()
	detail_like.name = "SocialDetailLikeButton"
	detail_like.text = _social_like_text(post, int(post.get("card_index", _social_detail_post_index)))
	detail_like.custom_minimum_size = Vector2(120, 44)
	detail_like.pressed.connect(_on_social_like_pressed.bind(str(post.get("id", ""))))
	engagement.add_child(detail_like)
	var detail_follow := Button.new()
	detail_follow.name = "SocialDetailFollowButton"
	detail_follow.text = "已关注" if game.is_social_following(str(post.get("handle", ""))) else "关注"
	detail_follow.custom_minimum_size = Vector2(120, 44)
	detail_follow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_follow.pressed.connect(_on_social_follow_pressed.bind(str(post.get("handle", ""))))
	engagement.add_child(detail_follow)
	var passive: Dictionary = post.get("passive", {})
	var signal_profile := _label("信号偏向 / %s · %s   稀有度 %d" % [str(passive.get("label", "无")), str(passive.get("description", "")), int(post.get("rarity", 1))], 13, _theme_color("muted"))
	signal_profile.name = "SocialCardSignalProfile"
	signal_profile.set_meta("on_dark", true)
	signal_profile.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_box.add_child(signal_profile)
	var tokens := GridContainer.new()
	tokens.columns = 2
	tokens.add_theme_constant_override("h_separation", 6)
	tokens.add_theme_constant_override("v_separation", 6)
	detail_box.add_child(tokens)
	for token in post["tokens"]:
		var btn := Button.new()
		btn.text = str(token["text"])
		btn.clip_text = true
		btn.disabled = not game.can_spend_action()
		btn.custom_minimum_size = Vector2(120, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_token_pressed.bind(post["id"], token))
		tokens.add_child(btn)


func _render_social_publish_page(parent: VBoxContainer) -> void:
	var publish_page := VBoxContainer.new()
	publish_page.name = "SocialPublishPage"
	publish_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	publish_page.add_theme_constant_override("separation", 8)
	parent.add_child(publish_page)

	publish_page.add_child(_label("发布", 22, _theme_color("accent")))

	var publish_scroll := ScrollContainer.new()
	publish_scroll.name = "SocialPublishScroll"
	publish_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	publish_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	publish_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	publish_page.add_child(publish_scroll)

	var publish_content := VBoxContainer.new()
	publish_content.name = "SocialPublishContent"
	publish_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	publish_content.add_theme_constant_override("separation", 8)
	publish_scroll.add_child(publish_content)

	var placed_meme := _placed_meme()
	var breakdown: Dictionary = game.get_publish_breakdown(placed_meme) if not placed_meme.is_empty() else game.last_publish_breakdown
	var contract: Dictionary = game.get_daily_signal_contract()
	var contract_panel := _panel()
	contract_panel.name = "SocialPublishContractPanel"
	contract_panel.set_meta("signal_contract_panel", true)
	publish_content.add_child(contract_panel)
	var contract_box := VBoxContainer.new()
	contract_box.add_theme_constant_override("separation", 6)
	contract_panel.add_child(contract_box)
	var contract_eyebrow := _label("今日牌型 / DAY %02d" % game.day, 13, _theme_color("muted"))
	contract_eyebrow.set_meta("on_dark", true)
	contract_box.add_child(contract_eyebrow)
	var contract_header := HBoxContainer.new()
	contract_header.add_theme_constant_override("separation", 8)
	contract_box.add_child(contract_header)
	var contract_title := _label(str(contract.get("label", "未命名牌型")), 21, _theme_color("surface"))
	contract_title.name = "SocialPublishContractTitle"
	contract_title.set_meta("on_dark", true)
	contract_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_header.add_child(contract_title)
	var contract_status := _label(_signal_contract_status(breakdown), 14, _theme_color("muted"))
	contract_status.name = "SocialPublishContractStatus"
	contract_status.set_meta("on_dark", true)
	contract_header.add_child(contract_status)
	var contract_text := _label(_signal_contract_text(contract, breakdown), 14, _theme_color("surface"))
	contract_text.name = "SocialPublishContractText"
	contract_text.set_meta("on_dark", true)
	contract_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contract_box.add_child(contract_text)

	var arcana_panel := _panel()
	arcana_panel.name = "SocialPublishArcanaPanel"
	arcana_panel.set_meta("arcana_card_panel", true)
	publish_content.add_child(arcana_panel)
	var arcana_box := VBoxContainer.new()
	arcana_box.add_theme_constant_override("separation", 6)
	arcana_panel.add_child(arcana_box)
	var arcana_header := HBoxContainer.new()
	arcana_header.add_theme_constant_override("separation", 8)
	arcana_box.add_child(arcana_header)
	var arcana_title := _label("玄牌 / HELD", 15, _theme_color("surface"))
	arcana_title.set_meta("on_dark", true)
	arcana_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arcana_header.add_child(arcana_title)
	var arcana_count := _label("%d/%d" % [game.owned_arcana_cards.size(), MemeGameStateScript.MAX_HELD_ARCANA_CARDS], 13, _theme_color("muted"))
	arcana_count.set_meta("on_dark", true)
	arcana_header.add_child(arcana_count)
	var arcana_hand := HFlowContainer.new()
	arcana_hand.name = "SocialPublishArcanaHand"
	arcana_hand.add_theme_constant_override("h_separation", 8)
	arcana_hand.add_theme_constant_override("v_separation", 8)
	arcana_box.add_child(arcana_hand)
	var target_meme_id := str(placed_meme.get("id", ""))
	var held_arcana := game.get_owned_arcana_card_data()
	if held_arcana.is_empty():
		var empty_arcana := _label("商店里的玄牌会留在这里。", 13, _theme_color("muted"))
		empty_arcana.set_meta("on_dark", true)
		arcana_hand.add_child(empty_arcana)
	else:
		for held_card in held_arcana:
			var arcana_button := Button.new()
			var card_uid := str(held_card.get("uid", ""))
			arcana_button.name = "SocialPublishArcana_%s" % card_uid
			arcana_button.set_meta("arcana_button", true)
			arcana_button.text = "%s  %s\n使用" % [str(held_card.get("numeral", "")), str(held_card.get("label", "玄牌"))]
			arcana_button.icon = _arcana_card_texture(str(held_card.get("id", "")))
			arcana_button.expand_icon = true
			arcana_button.add_theme_constant_override("icon_max_width", 52)
			arcana_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			arcana_button.custom_minimum_size = Vector2(178, 78)
			arcana_button.tooltip_text = str(held_card.get("description", ""))
			arcana_button.disabled = not game.can_use_arcana_card(card_uid, target_meme_id)
			arcana_button.pressed.connect(_on_arcana_use_pressed.bind(card_uid))
			arcana_hand.add_child(arcana_button)
	if not game.pending_arcana_effects.is_empty():
		var pending_arcana := _label(_pending_arcana_text(), 13, _theme_color("muted"))
		pending_arcana.name = "SocialPublishArcanaPending"
		pending_arcana.set_meta("on_dark", true)
		pending_arcana.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		arcana_box.add_child(pending_arcana)

	var composer := _panel()
	composer.name = "SocialPublishComposer"
	publish_content.add_child(composer)
	var composer_box := VBoxContainer.new()
	composer_box.add_theme_constant_override("separation", 8)
	composer.add_child(composer_box)
	composer_box.add_child(_label("把梗仓库里的完整梗拖到这里", 16, _theme_color("accent")))
	_publish_blank = DropButtonScript.new()
	_publish_blank.name = "SocialPublishBlank"
	_publish_blank.custom_minimum_size.y = 58
	_publish_blank.configure_drop_target("meme", "blank_1")
	_publish_blank.dropped.connect(_on_dialogue_meme_dropped)
	_publish_blank.pressed.connect(_on_dialogue_blank_pressed)
	composer_box.add_child(_publish_blank)
	var score_breakdown := _panel()
	score_breakdown.name = "SocialPublishScoreBreakdown"
	publish_content.add_child(score_breakdown)
	var score_text := _label("", 16, _theme_color("ink"))
	score_text.name = "SocialPublishScoreText"
	score_text.text = _publish_breakdown_text(breakdown, not placed_meme.is_empty())
	score_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	score_breakdown.add_child(score_text)
	var hint := _label("发布会消耗 1 次行动。浏览、切页和拖拽预览不扣行动。", 15, _theme_color("accent"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	publish_content.add_child(hint)

	var action_bar := _panel()
	action_bar.name = "SocialPublishActionBar"
	action_bar.set_meta("fixed_action_bar", true)
	publish_page.add_child(action_bar)
	var action_box := VBoxContainer.new()
	action_box.add_theme_constant_override("separation", 6)
	action_bar.add_child(action_box)
	_confirm_publish_button = Button.new()
	_confirm_publish_button.name = "SocialPublishButton"
	_confirm_publish_button.text = "确认发布"
	_confirm_publish_button.custom_minimum_size.y = 56
	_confirm_publish_button.pressed.connect(_on_confirm_dialogue_pressed)
	action_box.add_child(_confirm_publish_button)


func _render_social_profile_page(parent: VBoxContainer) -> void:
	var profile_page := VBoxContainer.new()
	profile_page.name = "SocialProfilePage"
	profile_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	profile_page.add_theme_constant_override("separation", 10)
	parent.add_child(profile_page)
	profile_page.add_child(_label("我的", 22, _theme_color("accent")))
	profile_page.add_child(_label("已合成梗：%d" % game.completed_memes.size(), 17, _theme_color("ink")))
	profile_page.add_child(_label("污染：%d%%" % game.pollution, 17, _theme_color("ink")))
	var note := _label("你的语言档案会随着塔层上升变窄。", 16, _theme_color("accent"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_page.add_child(note)


func _render_social_bottom_nav(phone_box: VBoxContainer) -> void:
	var bottom_nav := HBoxContainer.new()
	bottom_nav.name = "SocialBottomNav"
	bottom_nav.set_meta("phone_nav", true)
	bottom_nav.custom_minimum_size.y = 54
	bottom_nav.add_theme_constant_override("separation", 6)
	phone_box.add_child(bottom_nav)
	var nav_items := [
		{"name": "SocialNavHome", "text": "首页", "screen": "home"},
		{"name": "SocialNavCreate", "text": "发布", "screen": "publish"},
		{"name": "SocialNavMine", "text": "我的", "screen": "profile"},
	]
	for nav in nav_items:
		var nav_button := Button.new()
		nav_button.name = str(nav["name"])
		nav_button.text = str(nav["text"])
		nav_button.set_meta("flat_phone_button", true)
		nav_button.custom_minimum_size = Vector2(100, 50)
		nav_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nav_button.pressed.connect(_set_social_screen.bind(str(nav["screen"])))
		bottom_nav.add_child(nav_button)
	var indicator_wrap := CenterContainer.new()
	indicator_wrap.name = "SocialHomeIndicatorWrap"
	indicator_wrap.custom_minimum_size.y = 12
	phone_box.add_child(indicator_wrap)
	var home_indicator := ColorRect.new()
	home_indicator.name = "SocialHomeIndicator"
	home_indicator.color = _theme_color("ink")
	home_indicator.custom_minimum_size = Vector2(94, 4)
	indicator_wrap.add_child(home_indicator)


func _set_social_screen(screen: String) -> void:
	if _input_locked:
		return
	_social_screen = screen
	_social_detail_open = false
	_social_channel = "发现"
	_render()


func _on_social_channel_pressed(channel: String) -> void:
	if _input_locked:
		return
	_social_channel = channel
	if channel == "塔下":
		_social_screen = "home"
		_social_detail_post_index = 0
		_social_detail_open = true
	else:
		_social_screen = "home"
		_social_detail_open = false
	_render()


func _on_social_follow_pressed(handle: String) -> void:
	if _input_locked:
		return
	var followed := game.toggle_social_follow(handle)
	log_text = "已关注 @%s。" % handle if followed else "已取消关注 @%s。" % handle
	_render()


func _on_social_like_pressed(post_id: String) -> void:
	if _input_locked:
		return
	var liked := game.toggle_social_like(post_id)
	log_text = "已保存这条信号。" if liked else "已取消保存。"
	_render()


func _open_social_post(post_index: int) -> void:
	if _input_locked:
		return
	_social_detail_post_index = post_index
	_social_detail_open = true
	if _social_detail_window != null:
		_social_detail_window.move_to_front()
	_render()


func _on_social_card_gui_input(event: InputEvent, post_index: int) -> void:
	if _input_locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_open_social_post(post_index)
	elif event is InputEventScreenTouch and event.pressed:
		_open_social_post(post_index)


func _on_social_feed_scroll_gui_input(event: InputEvent, feed_scroll: ScrollContainer) -> void:
	if _input_locked:
		return
	if event is InputEventMouseButton and event.pressed:
		var direction := 0
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			direction = 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			direction = -1
		if direction != 0:
			_scroll_social_feed(feed_scroll, direction * SOCIAL_FEED_WHEEL_STEP)
			feed_scroll.accept_event()
	elif event is InputEventPanGesture:
		var vertical_delta := int(round((event as InputEventPanGesture).delta.y * float(SOCIAL_FEED_WHEEL_STEP)))
		if vertical_delta != 0:
			_scroll_social_feed(feed_scroll, vertical_delta)
			feed_scroll.accept_event()


func _scroll_social_feed(feed_scroll: ScrollContainer, delta: int) -> void:
	var max_scroll := int(feed_scroll.get_v_scroll_bar().max_value)
	feed_scroll.scroll_vertical = clampi(feed_scroll.scroll_vertical + delta, 0, max_scroll)


func _render_shop_app() -> void:
	_clear(_app_body)
	var shop_content := _app_body
	shop_content.name = "ShopContent"
	shop_content.add_theme_constant_override("separation", 12)

	var slot := game.get_daily_emotion_slot()
	if slot.is_empty():
		shop_content.add_child(_label("今日没有新情绪槽。", 16, _theme_color("accent")))
	else:
		var emotion_section := VBoxContainer.new()
		emotion_section.name = "EmotionShopSection"
		emotion_section.add_theme_constant_override("separation", 6)
		shop_content.add_child(emotion_section)
		emotion_section.add_child(_label("情绪槽 / DAILY", 18, _theme_color("accent")))
		var bought: bool = str(slot["id"]) in game.owned_emotion_slots
		var buy := Button.new()
		buy.name = "DailyEmotionBuyButton"
		buy.text = "%s  %d 热币" % [slot["label"], slot["price"]]
		buy.custom_minimum_size.y = 52
		buy.disabled = bought or game.money < int(slot["price"]) or not game.can_spend_action()
		buy.pressed.connect(_on_buy_emotion_slot_pressed)
		emotion_section.add_child(buy)
		var emotion_hint := _label("买下情绪后，在笔记本改写它的说法。", 14, _theme_color("accent"))
		emotion_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		emotion_section.add_child(emotion_hint)
		if bought:
			emotion_section.add_child(_label("已拥有：%s" % game.emotion_slot_texts.get(slot["id"], ""), 15, _theme_color("ink")))

	var arcana_section := VBoxContainer.new()
	arcana_section.name = "ArcanaShopSection"
	arcana_section.add_theme_constant_override("separation", 7)
	shop_content.add_child(arcana_section)
	var arcana_heading := HBoxContainer.new()
	arcana_heading.add_theme_constant_override("separation", 8)
	arcana_section.add_child(arcana_heading)
	var arcana_title := _label("玄牌 / SIGNAL ARCANA", 18, _theme_color("accent"))
	arcana_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arcana_heading.add_child(arcana_title)
	arcana_heading.add_child(_label("持有 %d/%d" % [game.owned_arcana_cards.size(), MemeGameStateScript.MAX_HELD_ARCANA_CARDS], 14, _theme_color("accent")))

	var card := game.get_daily_arcana_card()
	if card.is_empty():
		arcana_section.add_child(_label("今日信号没有留下牌。", 15, _theme_color("accent")))
	else:
		var card_panel := _panel()
		card_panel.name = "DailyArcanaCardPanel"
		card_panel.set_meta("arcana_card_panel", true)
		arcana_section.add_child(card_panel)
		var card_row := HBoxContainer.new()
		card_row.add_theme_constant_override("separation", 10)
		card_panel.add_child(card_row)
		var art := TextureRect.new()
		art.name = "DailyArcanaCardArt"
		art.texture = _arcana_card_texture(str(card.get("id", "")))
		art.custom_minimum_size = Vector2(112, 112)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_row.add_child(art)
		var card_copy := VBoxContainer.new()
		card_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_copy.add_theme_constant_override("separation", 4)
		card_row.add_child(card_copy)
		var card_title := _label("%s  %s" % [str(card.get("numeral", "")), str(card.get("label", "未命名"))], 20, _theme_color("surface"))
		card_title.set_meta("on_dark", true)
		card_copy.add_child(card_title)
		var card_description := _label(str(card.get("description", "")), 14, _theme_color("surface"))
		card_description.set_meta("on_dark", true)
		card_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_copy.add_child(card_description)
		var buy_arcana := Button.new()
		buy_arcana.name = "DailyArcanaBuyButton"
		buy_arcana.text = "收下玄牌  %d 热币" % int(card.get("price", 7))
		buy_arcana.custom_minimum_size.y = 52
		buy_arcana.disabled = game.daily_arcana_bought or game.owned_arcana_cards.size() >= MemeGameStateScript.MAX_HELD_ARCANA_CARDS or game.money < int(card.get("price", 7)) or not game.can_spend_action()
		buy_arcana.pressed.connect(_on_buy_arcana_card_pressed)
		card_copy.add_child(buy_arcana)

	var held_cards := game.get_owned_arcana_card_data()
	if held_cards.is_empty():
		var held_hint := _label("玄牌最多持有两张；在发布页使用，使用本身不扣行动。", 14, _theme_color("accent"))
		held_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		arcana_section.add_child(held_hint)
	else:
		var held_labels: Array[String] = []
		for held_card in held_cards:
			held_labels.append("%s %s" % [str(held_card.get("numeral", "")), str(held_card.get("label", "玄牌"))])
		arcana_section.add_child(_label("手中：%s" % " / ".join(held_labels), 14, _theme_color("accent")))


func _render_notebook_app() -> void:
	_clear(_app_body)

	var notebook_page := VBoxContainer.new()
	notebook_page.name = "NotebookCraftPage"
	notebook_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notebook_page.add_theme_constant_override("separation", 8)
	_app_body.add_child(notebook_page)

	var notebook_scroll := ScrollContainer.new()
	notebook_scroll.name = "NotebookCraftScroll"
	notebook_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notebook_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	notebook_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	notebook_page.add_child(notebook_scroll)

	var notebook_content := VBoxContainer.new()
	notebook_content.name = "NotebookCraftContent"
	notebook_content.add_theme_constant_override("separation", 8)
	notebook_scroll.add_child(notebook_content)

	notebook_content.add_child(_label("拾取词语", 18, _theme_color("accent")))
	var token_row := HFlowContainer.new()
	token_row.name = "NotebookTokenFlow"
	token_row.add_theme_constant_override("h_separation", 6)
	token_row.add_theme_constant_override("v_separation", 6)
	for token in game.notebook_tokens:
		var btn_token = DraggableButtonScript.new()
		btn_token.name = "NotebookToken_%s" % str(token.get("id", "token"))
		var source_passive: Dictionary = token.get("source_passive", {})
		btn_token.text = str(token["text"])
		if not source_passive.is_empty():
			btn_token.text = "%s\n%s" % [btn_token.text, str(source_passive.get("label", "来源被动"))]
		btn_token.clip_text = true
		btn_token.custom_minimum_size = Vector2(112, 56 if not source_passive.is_empty() else 44)
		btn_token.set_drag_payload("token", str(token["id"]), str(token["text"]))
		btn_token.pressed.connect(_on_note_token_pressed.bind(str(token["id"])))
		token_row.add_child(btn_token)
	notebook_content.add_child(token_row)

	notebook_content.add_child(_label("核心槽", 18, _theme_color("accent")))
	for slot in game.get_craft_slots():
		var slot_id := str(slot["id"])
		if slot_id.begins_with("emotion:"):
			continue
		var btn_slot = DropButtonScript.new()
		btn_slot.custom_minimum_size.y = 52
		btn_slot.text = "%s：%s" % [slot["label"], _slot_text(slot_id, str(slot.get("placeholder", "")))]
		btn_slot.configure_drop_target("token", slot_id)
		btn_slot.dropped.connect(_on_slot_token_dropped)
		btn_slot.pressed.connect(_on_slot_pressed.bind(slot_id))
		notebook_content.add_child(btn_slot)
	var draft_passives: Array = game.get_draft_source_passives()
	if not draft_passives.is_empty():
		var passive_labels: Array[String] = []
		for passive in draft_passives:
			passive_labels.append("%s · %s" % [str(passive.get("label", "来源被动")), str(passive.get("description", ""))])
		var passive_strip := _label("来源被动 / %s" % "  +  ".join(passive_labels), 14, _theme_color("accent"))
		passive_strip.name = "NotebookSourcePassiveStrip"
		passive_strip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notebook_content.add_child(passive_strip)

	notebook_content.add_child(_label("情绪构筑  %d/%d" % [game.equipped_emotion_slots.size(), MemeGameStateScript.MAX_EQUIPPED_EMOTION_SLOTS], 18, _theme_color("accent")))
	notebook_content.add_child(_label("只有装备中的情绪会进入合成和现实词块。", 14, _theme_color("accent")))
	if game.owned_emotion_slots.is_empty():
		notebook_content.add_child(_label("去商店购买一个情绪槽。", 15, _theme_color("accent")))
	for emotion in game.get_owned_emotion_slot_data():
		var slot_id := str(emotion["id"])
		var item := VBoxContainer.new()
		item.name = "EmotionLoadoutItem_%s" % slot_id
		item.add_theme_constant_override("separation", 4)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var emotion_label := _label(str(emotion["label"]), 16, _theme_color("ink"))
		emotion_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(emotion_label)
		var equipped: bool = slot_id in game.equipped_emotion_slots
		var equip := Button.new()
		equip.name = "EmotionEquipButton_%s" % slot_id
		equip.text = "已装备" if equipped else "装备"
		equip.custom_minimum_size = Vector2(92, 44)
		equip.disabled = not equipped and game.equipped_emotion_slots.size() >= MemeGameStateScript.MAX_EQUIPPED_EMOTION_SLOTS
		if equip.disabled:
			equip.tooltip_text = "先卸下一个已装备情绪"
		equip.pressed.connect(_on_emotion_equip_pressed.bind(slot_id))
		row.add_child(equip)
		item.add_child(row)
		var edit := LineEdit.new()
		edit.name = "EmotionTextEdit_%s" % slot_id
		edit.text = str(game.emotion_slot_texts.get(slot_id, emotion.get("default_text", "")))
		edit.custom_minimum_size.y = 44
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		edit.text_changed.connect(_on_emotion_text_changed.bind(slot_id))
		item.add_child(edit)
		notebook_content.add_child(item)

	var preview := _label("预览：%s" % _craft_preview_text(), 15, _theme_color("accent"))
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notebook_content.add_child(preview)

	var action_bar := _panel()
	action_bar.name = "NotebookCraftActionBar"
	action_bar.set_meta("fixed_action_bar", true)
	notebook_page.add_child(action_bar)
	var action_box := VBoxContainer.new()
	action_box.add_theme_constant_override("separation", 6)
	action_bar.add_child(action_box)

	var craft := Button.new()
	craft.name = "NotebookCraftButton"
	craft.text = "确认合成"
	craft.custom_minimum_size.y = 56
	craft.disabled = not game.can_spend_action()
	craft.pressed.connect(_on_confirm_craft_pressed)
	action_box.add_child(craft)


func _render_publish() -> void:
	if _publish_blank == null or _confirm_publish_button == null:
		return
	var meme := _placed_meme()
	_publish_blank.text = "发布空格：%s" % (meme.get("title", "等待完整梗") if not meme.is_empty() else "等待完整梗")
	_confirm_publish_button.disabled = meme.is_empty() or not game.can_spend_action()


func _publish_breakdown_text(breakdown: Dictionary, is_preview: bool) -> String:
	if breakdown.is_empty():
		return "传播基础 / 筹码  --\n共鸣倍率  ×--\n牌型倍率  ×--\n玄牌倍率  ×--\n遗物倍率  ×--\n预计传播  --"
	var prefix := "预计传播" if is_preview else "本次传播"
	var repeated := int(breakdown.get("repeat_count", 0))
	var repeat_note := "\n重复衰减  ×%.2f" % float(breakdown.get("repeat_multiplier", 1.0)) if repeated > 0 else ""
	var active_modifiers: Array = breakdown.get("active_modifier_labels", [])
	var modifier_note := "\n永久许可  %s" % " / ".join(active_modifiers) if not active_modifiers.is_empty() else ""
	var source_passives: Array = breakdown.get("active_source_passive_labels", [])
	var source_note := "\n来源被动  %s" % " / ".join(source_passives) if not source_passives.is_empty() else ""
	var contract_multiplier := float(breakdown.get("contract_multiplier", 1.0))
	var arcana_multiplier := float(breakdown.get("arcana_multiplier", 1.0))
	var world_item_multiplier := float(breakdown.get("world_item_multiplier", 1.0))
	var total_multiplier := float(breakdown.get("total_multiplier", 1.0))
	var separated_multiplier := contract_multiplier * arcana_multiplier * world_item_multiplier
	var resonance_multiplier := total_multiplier / separated_multiplier if separated_multiplier > 0.0 else total_multiplier
	var contract_bonus := int(breakdown.get("contract_base_bonus", 0))
	var arcana_bonus := int(breakdown.get("arcana_base_bonus", 0))
	var world_item_bonus := int(breakdown.get("world_item_base_bonus", 0))
	var base_parts: Array[String] = []
	if contract_bonus > 0:
		base_parts.append("牌型 +%d" % contract_bonus)
	if arcana_bonus > 0:
		base_parts.append("玄牌 +%d" % arcana_bonus)
	if world_item_bonus > 0:
		base_parts.append("遗物 +%d" % world_item_bonus)
	var base_note := "（%s）" % " / ".join(base_parts) if not base_parts.is_empty() else ""
	var arcana_labels: Array = breakdown.get("active_arcana_labels", [])
	var arcana_risk := int(breakdown.get("arcana_pollution_risk", 0))
	var arcana_note := "\n玄牌已装  %s%s" % [
		" / ".join(arcana_labels),
		" · +%d 污染" % arcana_risk if arcana_risk > 0 else "",
	] if not arcana_labels.is_empty() else ""
	var world_item_labels: Array = breakdown.get("active_world_item_labels", [])
	var world_item_note := "\n街区遗物  %s" % " / ".join(world_item_labels) if not world_item_labels.is_empty() else ""
	return "传播基础 / 筹码  %d%s\n共鸣倍率  ×%.2f\n牌型倍率  ×%.2f\n玄牌倍率  ×%.2f\n遗物倍率  ×%.2f\n总倍率  ×%.2f%s%s%s%s%s\n%s  %d" % [
		int(breakdown.get("base_value", 0)),
		base_note,
		resonance_multiplier,
		contract_multiplier,
		arcana_multiplier,
		world_item_multiplier,
		total_multiplier,
		repeat_note,
		modifier_note,
		source_note,
		arcana_note,
		world_item_note,
		prefix,
		int(breakdown.get("score", 0)),
	]


func _signal_contract_status(breakdown: Dictionary) -> String:
	if breakdown.is_empty():
		return "等待组牌"
	if bool(breakdown.get("arcana_force_contract", false)):
		return "高塔覆写"
	return "牌型成立" if bool(breakdown.get("contract_matched", false)) else "尚未成立"


func _signal_contract_text(contract: Dictionary, breakdown: Dictionary) -> String:
	var progress := str(breakdown.get("contract_progress", "尚未放入完整梗")) if not breakdown.is_empty() else "尚未放入完整梗"
	return "%s\n%s\n奖励 +%d 基础 · ×%.2f   代价 +%d 污染" % [
		str(contract.get("description", "等待今日信号")),
		progress,
		int(contract.get("base_bonus", 0)),
		float(contract.get("multiplier", 1.0)),
		int(contract.get("pollution_risk", 0)),
	]


func _pending_arcana_text() -> String:
	var labels: Array = game.pending_arcana_effects.get("labels", [])
	var parts: Array[String] = []
	if not labels.is_empty():
		parts.append("已装：%s" % " / ".join(labels))
	var base_bonus := int(game.pending_arcana_effects.get("base_bonus", 0))
	if base_bonus > 0:
		parts.append("基础 +%d" % base_bonus)
	var multiplier := float(game.pending_arcana_effects.get("multiplier", 1.0))
	if multiplier > 1.0:
		parts.append("倍率 ×%.2f" % multiplier)
	var repeat_grace := int(game.pending_arcana_effects.get("repeat_grace", 0))
	if repeat_grace > 0:
		parts.append("忽略 %d 次复读" % repeat_grace)
	if bool(game.pending_arcana_effects.get("force_contract", false)):
		parts.append("强制牌型")
	var risk := int(game.pending_arcana_effects.get("pollution_risk", 0))
	if risk > 0:
		parts.append("代价 +%d 污染" % risk)
	return "  ·  ".join(parts)


func _render_bank() -> void:
	if _meme_bank_tab != null:
		if _meme_bank_open:
			_meme_bank_tab.text = "梗仓库 ▾"
			_meme_bank_tab.set_meta("meme_bank_peek", false)
			_meme_bank_tab.custom_minimum_size = Vector2(142, 48)
		elif _should_show_meme_bank():
			_meme_bank_tab.text = "梗库"
			_meme_bank_tab.set_meta("meme_bank_peek", false)
			_meme_bank_tab.custom_minimum_size = Vector2(94, 52)
		else:
			_meme_bank_tab.text = "◢"
			_meme_bank_tab.set_meta("meme_bank_peek", true)
			_meme_bank_tab.custom_minimum_size = Vector2(44, 44)
	_clear(_bank_list)
	if game.completed_memes.is_empty():
		_bank_list.add_child(_label("还没有完整梗。", 15, _theme_color("accent")))
		return
	for meme in game.completed_memes:
		var btn = DraggableButtonScript.new()
		btn.custom_minimum_size = Vector2(240, 60)
		btn.text = "%s\n%s" % [meme["title"], _corrupt(str(meme["text"]))]
		btn.set_drag_payload("meme", str(meme["id"]), str(meme["title"]))
		btn.pressed.connect(_on_meme_pressed.bind(str(meme["id"])))
		_bank_list.add_child(btn)


func _render_reality() -> void:
	if _reality_subtitle_label == null:
		return
	_clear(_reality_choice_row)
	var plan := _day_plan()
	var actor_name := _active_actor_display_name()
	var npc_line := str(plan["line"])
	if _active_reality_actor != null and str(_active_reality_actor.get_meta("actor_type", "npc")) == "merchant":
		npc_line = "我只收还能被别人听懂的东西。你要开口吗？"
	var phase := str(game.conversation_phase)
	var subtitle := "%s：%s" % [actor_name, npc_line]
	if not game.conversation_feedback.is_empty():
		subtitle += "\n" + str(game.conversation_feedback)
	_reality_subtitle_label.text = subtitle

	var choosing := _reality_interaction_active and phase == "choosing"
	var typing := _reality_interaction_active and phase == "typing"
	var result := _reality_interaction_active and phase == "result"
	_reality_choice_row.visible = choosing
	_reality_typing_line.visible = typing
	_reality_typing_progress.visible = typing
	_reality_continue_button.visible = result
	var aid_status := game.get_communication_item_status()
	_reality_aid_status.text = "沟通辅助  %s" % aid_status if not aid_status.is_empty() else ""
	_reality_aid_status.visible = _reality_interaction_active and not typing and not aid_status.is_empty()
	var show_offer := _reality_interaction_active and game.should_show_merchant_communication_offer()
	_reality_merchant_offer.visible = show_offer
	if show_offer:
		var offer := game.get_daily_communication_item()
		_reality_merchant_offer_text.text = "%s · %d 次\n%s" % [str(offer.get("label", "沟通辅助")), int(offer.get("charges", 0)), str(offer.get("description", ""))]
		_reality_merchant_buy_button.text = "已购" if game.daily_communication_item_bought else "%d 资金" % int(offer.get("price", 0))
		_reality_merchant_buy_button.disabled = game.daily_communication_item_bought or not game.can_spend_action() or game.money < int(offer.get("price", 0))

	if choosing:
		for choice in game.get_typed_reality_choices():
			var choice_id := str(choice.get("id", ""))
			var button := Button.new()
			button.name = "RealityChoice%s" % choice_id.to_pascal_case()
			button.text = str(choice.get("summary", "回应"))
			button.custom_minimum_size = Vector2(96 if _viewport_size().x < 760.0 else 164, 56)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.set_meta("reality_response_choice", true)
			button.mouse_entered.connect(_on_reality_choice_hovered.bind(choice_id))
			button.mouse_exited.connect(_on_reality_choice_unhovered.bind(choice_id))
			button.pressed.connect(_on_reality_choice_selected.bind(choice_id))
			_reality_choice_row.add_child(button)
		if _reality_hover_choice_id.is_empty():
			_reality_intent_preview.text = ""
		else:
			_reality_intent_preview.text = game.preview_typed_reality_choice(_reality_hover_choice_id)
	_reality_intent_preview.visible = choosing and not _reality_intent_preview.text.is_empty()

	if typing:
		_reality_typing_line.text = _typed_reality_bbcode()
		_reality_typing_progress.text = "任意键  %d / %d" % [game.conversation_reveal_index, game.conversation_clean_sentence.length()]
	else:
		_reality_typing_line.text = ""
		_reality_typing_progress.text = ""


func _typed_reality_bbcode() -> String:
	var normal_color := _theme_color("surface").to_html(false)
	var pending_color := Color("777B72").to_html(false)
	var corrupted_color := Color("FF3B30").to_html(false)
	var parts: Array[String] = []
	for unit in game.conversation_revealed_units:
		var color := corrupted_color if bool(unit.get("corrupted", false)) else normal_color
		parts.append("[color=#%s]%s[/color]" % [color, _escape_bbcode(str(unit.get("display", "")))])
	var suffix := game.get_typed_reality_unrevealed_suffix()
	if not suffix.is_empty():
		parts.append("[color=#%s]%s[/color]" % [pending_color, _escape_bbcode(suffix)])
	return "".join(parts)


func _escape_bbcode(value: String) -> String:
	return value.replace("[", "[lb]").replace("]", "[rb]")


func _on_reality_choice_hovered(choice_id: String) -> void:
	_reality_hover_choice_id = choice_id
	if _reality_intent_preview != null:
		_reality_intent_preview.text = game.preview_typed_reality_choice(choice_id)
		_reality_intent_preview.visible = not _reality_intent_preview.text.is_empty()


func _on_reality_choice_unhovered(choice_id: String) -> void:
	if _reality_hover_choice_id != choice_id:
		return
	_reality_hover_choice_id = ""
	if _reality_intent_preview != null:
		_reality_intent_preview.text = ""
		_reality_intent_preview.visible = false


func _on_reality_choice_selected(choice_id: String) -> void:
	if _input_locked:
		return
	if game.select_typed_reality_choice(choice_id):
		_reality_hover_choice_id = ""
		_render()
		_sync_audio_state(false)


func _on_buy_communication_item() -> void:
	if _input_locked:
		return
	var actions_before := int(game.actions_remaining)
	var item := game.get_daily_communication_item()
	if game.buy_daily_communication_item():
		log_text = "买到%s。" % str(item.get("label", "沟通辅助"))
		_after_effective_action(actions_before)
	else:
		log_text = "这件沟通辅助没有成交。"
		_render()


func _advance_typed_reality_character() -> bool:
	if _input_locked or not _reality_interaction_active:
		return false
	var actions_before := int(game.actions_remaining)
	var result: Dictionary = game.advance_typed_reality_character()
	if not bool(result.get("advanced", false)):
		return false
	if bool(result.get("locked_out", false)):
		_reality_interaction_active = false
		_active_reality_actor = null
		_nearby_reality_actor = null
		_nearby_reality_item = null
		_set_reality_mouse_look(true)
	if bool(result.get("action_spent", false)):
		_after_effective_action(actions_before)
	else:
		_render()
	return true


func _update_visibility() -> void:
	var in_phone: bool = game.view_state == "phone_down"
	var show_phone_home := in_phone and _phone_launcher_open
	if _phone_popup_expanded != show_phone_home:
		_phone_popup_expanded = show_phone_home
		_apply_phone_popup_layout(show_phone_home)
	_phone_panel.visible = _game_started
	_phone_tab.visible = not show_phone_home
	_phone_content.visible = show_phone_home
	if in_phone and not game.active_app_window.is_empty():
		_open_app_windows[game.active_app_window] = true
	for app_id in _app_windows.keys():
		var app_window := _app_windows[app_id] as Control
		if app_window != null:
			app_window.visible = in_phone and bool(_open_app_windows.get(app_id, false))
	if _social_detail_window != null:
		_social_detail_window.visible = in_phone and _social_detail_open and bool(_open_app_windows.get("social", false))
	if _publish_panel != null:
		_publish_panel.visible = false
	var show_meme_bank := _should_show_meme_bank()
	var peek_meme_bank := _should_peek_meme_bank()
	_meme_bank_window.visible = show_meme_bank or peek_meme_bank
	if not show_meme_bank:
		_meme_bank_open = false
	var desired_bank_layout := "open" if _meme_bank_open else ("collapsed" if show_meme_bank else "peek")
	if _meme_bank_layout_mode != desired_bank_layout:
		_meme_bank_layout_mode = desired_bank_layout
		_apply_meme_bank_popup_layout(desired_bank_layout)
	if _meme_bank_content != null:
		_meme_bank_content.visible = show_meme_bank and _meme_bank_open
	_avoid_meme_bank_overlaps()
	if _phone_down_backdrop_image != null:
		_phone_down_backdrop_image.visible = in_phone or _phone_art_alpha > 0.03
	if _hand_phone_image != null:
		_hand_phone_image.visible = in_phone or _phone_art_alpha > 0.03
	if _view_toggle_button != null:
		_view_toggle_button.visible = _game_started and (in_phone or not _reality_interaction_active)
		_view_toggle_button.text = "放下手机" if in_phone else "拿起手机"
	if _settings_window != null:
		_settings_window.visible = _settings_open and _game_started
	if _desk_log != null:
		_desk_log.visible = in_phone
	if _vhs_overlay != null:
		_vhs_overlay.visible = _vhs_enabled and _game_started
	if _world_prompt != null:
		_world_prompt.visible = (not in_phone) and (not _reality_interaction_active) and (_nearby_reality_actor != null or _nearby_reality_item != null)
	var interaction_visible := (not in_phone) and _reality_interaction_active
	if _reality_subtitle_panel != null:
		_reality_subtitle_panel.visible = interaction_visible
	if _reality_choice_row != null:
		_reality_choice_row.visible = interaction_visible and game.conversation_phase == "choosing"
	if _reality_intent_preview != null:
		_reality_intent_preview.visible = interaction_visible and game.conversation_phase == "choosing" and not _reality_intent_preview.text.is_empty()
	if _reality_typing_line != null:
		_reality_typing_line.visible = interaction_visible and game.conversation_phase == "typing"
	if _reality_typing_progress != null:
		_reality_typing_progress.visible = interaction_visible and game.conversation_phase == "typing"
	if _reality_aid_status != null:
		_reality_aid_status.visible = interaction_visible and game.conversation_phase != "typing" and not game.get_communication_item_status().is_empty()
	if _reality_merchant_offer != null:
		_reality_merchant_offer.visible = interaction_visible and game.should_show_merchant_communication_offer()
	if _reality_floor != null:
		_reality_floor.visible = not in_phone
	if _reality_player != null:
		_reality_player.visible = not in_phone
	if _npc != null:
		_npc.visible = false
	if _phone_rig != null:
		_phone_rig.visible = false
	if _cinematic_top_bar != null:
		_cinematic_top_bar.visible = _game_started
	if _cinematic_bottom_bar != null:
		_cinematic_bottom_bar.visible = _game_started


func _animate_world(delta: float) -> void:
	if not _game_started:
		if _camera != null:
			_camera.position = _camera.position.lerp(Vector3(0.0, 1.54, 2.55), minf(1.0, delta * 3.0))
			_camera.rotation_degrees = _camera.rotation_degrees.lerp(Vector3(-18.0, 0.0, 0.0), minf(1.0, delta * 3.0))
		_animate_vhs(delta)
		return
	var phone_target := Vector3(0.0, 0.15, -1.15) if game.view_state == "phone_down" else Vector3(1.45, -0.8, -1.0)
	var camera_target_pos := Vector3(0.0, 1.45, 2.2)
	var camera_target_rot := Vector3(-54.0, 0.0, 0.0)
	if game.view_state == "npc_up" and _reality_player != null:
		camera_target_pos = _reality_player.position + Vector3(0.0, 1.56, 0.0)
		camera_target_rot = Vector3(_reality_pitch, _reality_yaw, 0.0)
	var camera_lerp := minf(1.0, delta * (7.0 if game.view_state == "npc_up" else 5.0))
	_camera.position = _camera.position.lerp(camera_target_pos, camera_lerp)
	var current_rotation := _camera.rotation_degrees
	current_rotation.x = lerpf(current_rotation.x, camera_target_rot.x, camera_lerp)
	current_rotation.y = rad_to_deg(lerp_angle(deg_to_rad(current_rotation.y), deg_to_rad(camera_target_rot.y), camera_lerp))
	current_rotation.z = lerpf(current_rotation.z, 0.0, camera_lerp)
	_camera.rotation_degrees = current_rotation
	_camera.fov = lerpf(_camera.fov, 52.0 if _reality_interaction_active else 58.0, minf(1.0, delta * 4.0))
	if _phone_rig != null:
		_phone_rig.position = _phone_rig.position.lerp(phone_target, minf(1.0, delta * 6.0))
		_phone_rig.rotation_degrees = Vector3(68.0, 0.0, 0.0)
	var target_alpha := 1.0 if game.view_state == "phone_down" else 0.0
	_phone_art_alpha = lerpf(_phone_art_alpha, target_alpha, minf(1.0, delta * 3.4))
	_road_scroll += delta * 1.4
	if _phone_down_backdrop_image != null:
		_phone_down_backdrop_image.visible = game.view_state == "phone_down" or _phone_art_alpha > 0.03
		_phone_down_backdrop_image.modulate.a = _phone_art_alpha
		var viewport_size := _viewport_size()
		var bob := sin(_road_scroll * 2.2) * 2.4
		var sway := sin(_road_scroll * 1.1) * 1.1
		_phone_down_backdrop_image.pivot_offset = viewport_size * 0.5
		_phone_down_backdrop_image.scale = Vector2(1.012, 1.012)
		var settled_position := Vector2(-viewport_size.x * 0.006 + sway, -viewport_size.y * 0.006 + bob)
		_phone_down_backdrop_image.position = Vector2(settled_position.x, lerpf(70.0, settled_position.y, _phone_art_alpha))
	if _road != null:
		for index in _road.get_child_count():
			var tile := _road.get_child(index) as Node3D
			tile.position.z = -2.0 - index * 3.8 + fmod(_road_scroll, 3.8)
	_animate_vhs(delta)


func _animate_vhs(delta: float) -> void:
	if _vhs_overlay == null or not _vhs_enabled:
		return
	_vhs_overlay.modulate.a = 0.88 + sin(Time.get_ticks_msec() / 130.0) * 0.04
	for index in _vhs_scanlines.size():
		var line := _vhs_scanlines[index]
		if line == null:
			continue
		var base_y := float(index * 24)
		var drift := fmod(Time.get_ticks_msec() / 42.0 + index * 3.0, 24.0)
		line.offset_top = base_y + drift * delta
		line.offset_bottom = line.offset_top + 2


func _active_palette() -> Dictionary:
	if game != null and game.pollution >= MemeGameStateScript.POLLUTION_FLASHBACK_THRESHOLD:
		return POLLUTION_PALETTE_5
	return PALETTE_1


func _theme_color(key: String) -> Color:
	var palette := _active_palette()
	return Color(str(palette.get(key, PALETTE_1.get(key, "FFF1C9"))))


func _viewport_size() -> Vector2:
	if get_viewport() != null:
		return get_viewport().get_visible_rect().size
	return Vector2(
		float(ProjectSettings.get_setting("display/window/size/viewport_width", 1600)),
		float(ProjectSettings.get_setting("display/window/size/viewport_height", 900))
	)


func _load_runtime_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]
	var image := Image.new()
	if FileAccess.file_exists(path):
		var bytes := FileAccess.get_file_as_bytes(path)
		var err := image.load_png_from_buffer(bytes)
		if err != OK:
			err = image.load_jpg_from_buffer(bytes)
		if err != OK:
			err = image.load_webp_from_buffer(bytes)
		if err != OK:
			return null
		var texture := ImageTexture.create_from_image(image)
		_texture_cache[path] = texture
		return texture
	if FileAccess.file_exists("%s.import" % path):
		var resource := load(path)
		if resource is Texture2D:
			_texture_cache[path] = resource
			return resource
	return null


func _social_poster_texture_path(post_index: int) -> String:
	return SOCIAL_POSTER_SHEET_PATH


func _social_poster_texture(post_index: int) -> Texture2D:
	var cell_index := posmod(post_index, SOCIAL_POSTER_COUNT)
	var cache_key := "%s#cell-%d" % [SOCIAL_POSTER_SHEET_PATH, cell_index]
	if _texture_cache.has(cache_key):
		return _texture_cache[cache_key]
	var sheet := _load_runtime_texture(SOCIAL_POSTER_SHEET_PATH)
	if sheet == null:
		return null
	var cell_size := Vector2(
		floorf(float(sheet.get_width()) / SOCIAL_POSTER_COLUMNS),
		floorf(float(sheet.get_height()) / SOCIAL_POSTER_ROWS)
	)
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var row := floori(float(cell_index) / SOCIAL_POSTER_COLUMNS)
	atlas.region = Rect2(
		Vector2(cell_index % SOCIAL_POSTER_COLUMNS, row) * cell_size,
		cell_size
	)
	_texture_cache[cache_key] = atlas
	return atlas


func _arcana_card_texture(card_id: String) -> Texture2D:
	var cell_index := MemeGameStateScript.ARCANA_ROTATION.find(card_id)
	if cell_index < 0:
		cell_index = 0
	cell_index = posmod(cell_index, ARCANA_SHEET_COUNT)
	var cache_key := "%s#cell-%d" % [ARCANA_SHEET_PATH, cell_index]
	if _texture_cache.has(cache_key):
		return _texture_cache[cache_key]
	var sheet := _load_runtime_texture(ARCANA_SHEET_PATH)
	if sheet == null:
		return null
	var cell_size := Vector2(
		floorf(float(sheet.get_width()) / ARCANA_SHEET_COLUMNS),
		floorf(float(sheet.get_height()) / ARCANA_SHEET_ROWS)
	)
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var row := floori(float(cell_index) / ARCANA_SHEET_COLUMNS)
	atlas.region = Rect2(
		Vector2(cell_index % ARCANA_SHEET_COLUMNS, row) * cell_size,
		cell_size
	)
	_texture_cache[cache_key] = atlas
	return atlas


func _social_post_for_index(post_index: int) -> Dictionary:
	if SOCIAL_POST_CARDS.is_empty():
		return {}
	var day_offset := 0 if game == null else maxi(0, game.day - 1) * 3
	var card_index := posmod(post_index + day_offset, SOCIAL_POST_CARDS.size())
	var post: Dictionary = (SOCIAL_POST_CARDS[card_index] as Dictionary).duplicate(true)
	post["card_index"] = card_index
	var source_passive: Dictionary = post.get("passive", {})
	var prepared_tokens: Array = []
	for token_data in post.get("tokens", []):
		var token: Dictionary = (token_data as Dictionary).duplicate(true)
		token["source_card_id"] = str(post.get("id", ""))
		token["source_passive"] = source_passive.duplicate(true)
		prepared_tokens.append(token)
	post["tokens"] = prepared_tokens
	return post


func _toggle_meme_bank() -> void:
	if _input_locked:
		return
	if not _should_show_meme_bank():
		log_text = "梗仓库只在社交发布页出现。"
		_render_status()
		return
	_meme_bank_open = not _meme_bank_open
	if _meme_bank_open and _meme_bank_window != null:
		_meme_bank_window.move_to_front()
	_render()


func _close_app_window(app_id: String) -> void:
	if _input_locked:
		return
	_open_app_windows[app_id] = false
	if app_id == "social":
		_social_detail_open = false
	if game.active_app_window == app_id:
		game.active_app_window = ""
		for candidate in ["social", "babel", "shop", "notebook"]:
			if bool(_open_app_windows.get(candidate, false)):
				game.active_app = candidate
				game.active_app_window = candidate
				break
	var any_open := false
	for open_value in _open_app_windows.values():
		if bool(open_value):
			any_open = true
			break
	_phone_launcher_open = not any_open
	log_text = "关闭 %s 窗口。" % app_id
	_render()


func _open_phone_launcher() -> void:
	if _input_locked:
		return
	game.set_view_state("phone_down")
	_set_reality_mouse_look(false)
	_phone_launcher_open = true
	if _phone_panel != null:
		_phone_panel.move_to_front()
	log_text = "展开手机主页。"
	_render()


func _close_social_detail_window() -> void:
	if _input_locked:
		return
	_social_detail_open = false
	if _social_channel == "塔下":
		_social_channel = "发现"
	log_text = "关闭社交详情。"
	_render()


func _move_window_for_test(window_id: String, delta: Vector2) -> bool:
	if not _draggable_windows.has(window_id):
		return false
	var window := _draggable_windows[window_id] as Control
	if window == null:
		return false
	window.position += delta
	window.move_to_front()
	if window is CanvasItem:
		(window as CanvasItem).z_index = maxi((window as CanvasItem).z_index, 24)
	_clamp_window_to_viewport(window)
	return true


func _window_position_for_test(window_id: String) -> Vector2:
	if not _draggable_windows.has(window_id):
		return Vector2.INF
	var window := _draggable_windows[window_id] as Control
	if window == null:
		return Vector2.INF
	return window.position


func _make_draggable_window(window: Control, window_id: String, handle: Control) -> void:
	if window == null or handle == null:
		return
	_draggable_windows[window_id] = window
	if bool(handle.get_meta("drag_connected", false)) and str(handle.get_meta("drag_window_id", "")) == window_id:
		return
	handle.set_meta("drag_connected", true)
	handle.set_meta("drag_window_id", window_id)
	handle.set_meta("drag_handle", true)
	handle.mouse_filter = Control.MOUSE_FILTER_STOP
	handle.mouse_default_cursor_shape = Control.CURSOR_MOVE
	handle.gui_input.connect(_on_window_handle_gui_input.bind(window_id, window, handle))


func _should_show_meme_bank() -> bool:
	if game.view_state != "phone_down":
		return false
	var social_publish_open := bool(_open_app_windows.get("social", false)) and _social_screen == "publish"
	return social_publish_open


func _should_peek_meme_bank() -> bool:
	return false


func _avoid_meme_bank_overlaps() -> void:
	if _meme_bank_window == null or not _meme_bank_window.visible:
		return
	var targets := _meme_bank_overlap_targets()
	if not _meme_bank_conflicts_at(_meme_bank_window.global_position, targets):
		return
	var bank_rect := _meme_bank_window.get_global_rect()
	var viewport_size := _viewport_size()
	var margin := 12.0
	var min_x := margin
	if _hud_panel != null and _hud_panel.visible:
		min_x = maxf(min_x, _hud_panel.get_global_rect().end.x + margin)
	var max_x := maxf(min_x, viewport_size.x - bank_rect.size.x - margin)
	var max_y := maxf(margin, viewport_size.y - bank_rect.size.y - margin)
	var current := _meme_bank_window.global_position
	var candidates: Array[Vector2] = []
	for target in targets:
		if target == null or not target.is_visible_in_tree():
			continue
		var target_rect := target.get_global_rect()
		if not Rect2(current, bank_rect.size).intersects(target_rect):
			continue
		candidates.append(Vector2(target_rect.position.x - bank_rect.size.x - margin, current.y))
		candidates.append(Vector2(target_rect.end.x + margin, current.y))
		candidates.append(Vector2(current.x, target_rect.position.y - bank_rect.size.y - margin))
		candidates.append(Vector2(current.x, target_rect.end.y + margin))
	candidates.append(Vector2(min_x, current.y))
	candidates.append(Vector2(max_x, current.y))
	for candidate in candidates:
		var clamped := Vector2(
			clampf(candidate.x, min_x, max_x),
			clampf(candidate.y, margin, max_y)
		)
		if not _meme_bank_conflicts_at(clamped, targets):
			_meme_bank_window.global_position = clamped
			return


func _meme_bank_overlap_targets() -> Array[Control]:
	var targets: Array[Control] = []
	for app_id in _app_windows.keys():
		var app_window := _app_windows[app_id] as Control
		if app_window != null and app_window.is_visible_in_tree():
			targets.append(app_window)
	if _view_toggle_button != null and _view_toggle_button.is_visible_in_tree():
		targets.append(_view_toggle_button)
	if _hud_actions_label != null and _hud_actions_label.is_visible_in_tree():
		targets.append(_hud_actions_label)
	for node_name in ["SocialBottomNav", "SocialHomeIndicator"]:
		var social_control := _find_control_by_name(_ui_root, node_name)
		if social_control != null and social_control.is_visible_in_tree():
			targets.append(social_control)
	return targets


func _find_control_by_name(node: Node, node_name: String) -> Control:
	if node == null:
		return null
	if node.name == node_name and node is Control:
		return node as Control
	for child in node.get_children():
		var found := _find_control_by_name(child, node_name)
		if found != null:
			return found
	return null


func _meme_bank_conflicts_at(position: Vector2, targets: Array[Control]) -> bool:
	if _meme_bank_window == null:
		return false
	var rect := Rect2(position, _meme_bank_window.get_global_rect().size)
	for target in targets:
		if target == null or not target.is_visible_in_tree():
			continue
		if rect.intersects(target.get_global_rect()):
			return true
	return false


func _on_window_handle_gui_input(event: InputEvent, _window_id: String, window: Control, handle: Control) -> void:
	if _input_locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragged_window = window
			_drag_offset = _event_pointer_position(event) - window.global_position
			window.move_to_front()
			if window is CanvasItem:
				(window as CanvasItem).z_index = maxi((window as CanvasItem).z_index, 24)
		else:
			_dragged_window = null
		if not (handle is Button):
			handle.accept_event()
	elif event is InputEventMouseMotion and _dragged_window == window:
		window.global_position = _event_pointer_position(event) - _drag_offset
		_clamp_window_to_viewport(window)
		if not (handle is Button):
			handle.accept_event()
	elif event is InputEventScreenTouch:
		if event.pressed:
			_dragged_window = window
			_drag_offset = _event_pointer_position(event) - window.global_position
			window.move_to_front()
		else:
			if _dragged_window == _meme_bank_window:
				_avoid_meme_bank_overlaps()
			_dragged_window = null
		handle.accept_event()
	elif event is InputEventScreenDrag and _dragged_window == window:
		window.global_position = _event_pointer_position(event) - _drag_offset
		_clamp_window_to_viewport(window)
		handle.accept_event()


func _event_pointer_position(event: InputEvent) -> Vector2:
	if event is InputEventMouse:
		var mouse_event := event as InputEventMouse
		return mouse_event.global_position
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	if event is InputEventScreenDrag:
		return (event as InputEventScreenDrag).position
	if get_viewport() != null:
		return get_viewport().get_mouse_position()
	return Vector2.ZERO


func _clamp_window_to_viewport(window: Control) -> void:
	var viewport_size := _viewport_size()
	var visible_edge := 88.0
	var min_x := -maxf(0.0, window.size.x - visible_edge)
	if window == _meme_bank_window and _hud_panel != null:
		min_x = _hud_panel.get_global_rect().end.x + 12.0
	var max_x := viewport_size.x - visible_edge
	var max_y := viewport_size.y - 56.0
	window.position = Vector2(clampf(window.position.x, min_x, max_x), clampf(window.position.y, 0.0, max_y))


func _apply_world_theme() -> void:
	if _reality_floor != null:
		_reality_floor.apply_palette(_active_palette())
	if _road != null:
		for index in _road.get_child_count():
			var tile := _road.get_child(index) as MeshInstance3D
			if tile == null:
				continue
			var mat := tile.material_override as StandardMaterial3D
			if mat != null:
				mat.albedo_color = Color.WHITE if mat.albedo_texture != null else _theme_color("accent").darkened(0.50 - index * 0.08)
	if _phone_rig != null:
		var phone_body := _phone_rig.get_node_or_null("PhoneBody") as MeshInstance3D
		if phone_body != null and phone_body.material_override is StandardMaterial3D:
			(phone_body.material_override as StandardMaterial3D).albedo_color = _theme_color("accent")
		var phone_screen := _phone_rig.get_node_or_null("PhoneScreen") as MeshInstance3D
		if phone_screen != null and phone_screen.material_override is StandardMaterial3D:
			var mat := phone_screen.material_override as StandardMaterial3D
			mat.albedo_color = _theme_color("ink")
			mat.emission = _theme_color("accent")
	if _npc != null:
		var npc_body := _npc.get_node_or_null("NPCPlane") as MeshInstance3D
		if npc_body != null and npc_body.material_override is StandardMaterial3D:
			var mat := npc_body.material_override as StandardMaterial3D
			mat.albedo_color = Color.WHITE if mat.albedo_texture != null else _theme_color("surface")
			mat.emission = _theme_color("muted")
func _apply_ui_theme(node: Node = null) -> void:
	if node == null:
		node = _ui_root
	if node == null:
		return
	if node is Label and not node.has_meta("flashback_text") and not node.has_meta("action_overlay_text"):
		if node.has_meta("hud_action_label"):
			(node as Label).add_theme_color_override("font_color", _theme_color("muted"))
		elif node.has_meta("on_dark"):
			(node as Label).add_theme_color_override("font_color", _theme_color("surface"))
		else:
			(node as Label).add_theme_color_override("font_color", _theme_color("ink"))
	elif node is Button:
		var button := node as Button
		if button.has_meta("hud_icon"):
			var empty := StyleBoxEmpty.new()
			button.add_theme_stylebox_override("normal", empty)
			button.add_theme_stylebox_override("hover", _style(Color(_theme_color("muted"), 0.18), Color(_theme_color("muted"), 0.20)))
			button.add_theme_stylebox_override("pressed", _style(Color(_theme_color("muted"), 0.32), Color(_theme_color("muted"), 0.32)))
		elif button.has_meta("ascent_reward_card"):
			button.add_theme_color_override("font_color", _theme_color("surface"))
			button.add_theme_color_override("font_hover_color", _theme_color("ink"))
			button.add_theme_color_override("font_pressed_color", _theme_color("ink"))
			button.add_theme_stylebox_override("normal", _reward_card_style(_theme_color("ink"), _theme_color("muted")))
			button.add_theme_stylebox_override("hover", _reward_card_style(_theme_color("muted"), _theme_color("ink")))
			button.add_theme_stylebox_override("pressed", _reward_card_style(_theme_color("accent"), _theme_color("ink")))
		elif button.has_meta("arcana_button"):
			button.add_theme_color_override("font_color", _theme_color("surface"))
			button.add_theme_color_override("font_hover_color", _theme_color("ink"))
			button.add_theme_color_override("font_pressed_color", _theme_color("ink"))
			button.add_theme_color_override("font_disabled_color", _theme_color("accent").lightened(0.25))
			button.add_theme_stylebox_override("normal", _style(_theme_color("ink"), _theme_color("muted")))
			button.add_theme_stylebox_override("hover", _style(_theme_color("muted"), _theme_color("ink")))
			button.add_theme_stylebox_override("pressed", _style(_theme_color("surface"), _theme_color("ink")))
			button.add_theme_stylebox_override("disabled", _style(_theme_color("ink").lightened(0.08), _theme_color("accent")))
		elif button.has_meta("meme_bank_tab") and bool(button.get_meta("meme_bank_peek", false)):
			button.add_theme_color_override("font_color", _theme_color("muted"))
			button.add_theme_color_override("font_hover_color", _theme_color("surface"))
			button.add_theme_color_override("font_pressed_color", _theme_color("surface"))
			button.add_theme_stylebox_override("normal", _file_corner_style(Color(_theme_color("ink"), 0.72), Color(_theme_color("muted"), 0.28)))
			button.add_theme_stylebox_override("hover", _file_corner_style(Color(_theme_color("ink"), 0.88), Color(_theme_color("muted"), 0.46)))
			button.add_theme_stylebox_override("pressed", _file_corner_style(_theme_color("ink"), _theme_color("muted")))
		elif button.has_meta("meme_bank_tab") and not _meme_bank_open:
			button.add_theme_color_override("font_color", _theme_color("muted"))
			button.add_theme_color_override("font_hover_color", _theme_color("surface"))
			button.add_theme_color_override("font_pressed_color", _theme_color("surface"))
			button.add_theme_stylebox_override("normal", _style(Color(_theme_color("ink"), 0.78), Color(_theme_color("muted"), 0.24)))
			button.add_theme_stylebox_override("hover", _style(Color(_theme_color("ink"), 0.92), Color(_theme_color("muted"), 0.42)))
			button.add_theme_stylebox_override("pressed", _style(_theme_color("ink"), _theme_color("muted")))
		elif button.has_meta("flat_phone_button"):
			var flat := StyleBoxEmpty.new()
			button.add_theme_color_override("font_color", _theme_color("ink"))
			button.add_theme_color_override("font_hover_color", _theme_color("accent"))
			button.add_theme_color_override("font_pressed_color", _theme_color("ink"))
			button.add_theme_stylebox_override("normal", flat)
			button.add_theme_stylebox_override("hover", _flat_button_state_style(Color(_theme_color("muted"), 0.24)))
			button.add_theme_stylebox_override("pressed", _flat_button_state_style(Color(_theme_color("muted"), 0.40)))
		else:
			button.add_theme_color_override("font_color", _theme_color("ink"))
			button.add_theme_color_override("font_hover_color", _theme_color("ink"))
			button.add_theme_color_override("font_pressed_color", _theme_color("surface"))
			button.add_theme_color_override("font_disabled_color", _theme_color("accent").lightened(0.22))
			button.add_theme_stylebox_override("normal", _style(_theme_color("surface"), _theme_color("accent")))
			button.add_theme_stylebox_override("hover", _style(_theme_color("muted"), _theme_color("ink")))
			button.add_theme_stylebox_override("pressed", _style(_theme_color("accent"), _theme_color("ink")))
			button.add_theme_stylebox_override("disabled", _style(_theme_color("surface").darkened(0.10), _theme_color("accent").lightened(0.20)))
	elif node is PanelContainer:
		if node.has_meta("phone_shell"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _phone_shell_style())
		elif node.has_meta("movie_subtitle"):
			(node as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		elif node.has_meta("portrait_panel"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _reward_card_style(_theme_color("ink"), _theme_color("muted")))
		elif node.has_meta("phone_surface"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _phone_surface_style())
		elif node.has_meta("social_card"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _social_card_style())
		elif node.has_meta("poster_frame"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _poster_frame_style())
		elif node.has_meta("detail_dark_panel"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _detail_dark_style())
		elif node.has_meta("social_feed_dark"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _social_feed_dark_style())
		elif node.has_meta("meme_bank_popup") and not _meme_bank_open:
			(node as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		elif node.has_meta("dark_rail"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _style(_theme_color("ink"), Color(_theme_color("muted"), 0.22)))
		elif node.has_meta("tooltip_panel"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _style(_theme_color("muted"), _theme_color("accent")))
		elif node.has_meta("signal_contract_panel"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _style(_theme_color("ink"), _theme_color("muted")))
		elif node.has_meta("arcana_card_panel"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _style(_theme_color("ink"), _theme_color("muted")))
		elif node.has_meta("soft_panel"):
			(node as PanelContainer).add_theme_stylebox_override("panel", _soft_style(_theme_color("surface"), _theme_color("accent")))
		else:
			(node as PanelContainer).add_theme_stylebox_override("panel", _style(_theme_color("surface"), _theme_color("accent")))
	elif node is LineEdit:
		var edit := node as LineEdit
		edit.add_theme_color_override("font_color", _theme_color("ink"))
		edit.add_theme_color_override("font_placeholder_color", _theme_color("accent"))
		edit.add_theme_stylebox_override("normal", _style(_theme_color("surface"), _theme_color("accent")))
	for child in node.get_children():
		_apply_ui_theme(child)


func _build_action_spend_overlay() -> void:
	_action_spend_overlay = Control.new()
	_action_spend_overlay.name = "ActionSpendOverlay"
	_action_spend_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_action_spend_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_action_spend_overlay.visible = false
	_action_spend_overlay.z_index = 90
	_ui_root.add_child(_action_spend_overlay)

	_action_spend_blackout = null

	_action_spend_label = Label.new()
	_action_spend_label.name = "ActionSpendLabel"
	_action_spend_label.set_meta("action_overlay_text", false)
	_action_spend_label.set_meta("action_animation_mode", "inline_pulse")
	_action_spend_label.visible = false
	_action_spend_label.add_theme_font_size_override("font_size", 20)
	_action_spend_label.add_theme_color_override("font_color", _theme_color("muted"))
	_action_spend_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_action_spend_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_action_spend_overlay.add_child(_action_spend_label)


func _play_action_spend_animation(before_actions: int, after_actions: int) -> void:
	if _hud_actions_label == null:
		return
	if _action_tick_audio != null and _action_tick_audio.stream != null and _action_tick_audio.is_inside_tree():
		_action_tick_audio.play()
	if _action_spend_tween != null and _action_spend_tween.is_valid():
		_action_spend_tween.kill()
	_action_spend_after_actions = after_actions
	_action_spend_should_settle = game.needs_day_settlement
	_hud_actions_label.text = _action_text(before_actions)
	_hud_actions_label.scale = Vector2.ONE
	_hud_actions_label.pivot_offset = _hud_actions_label.size * 0.5
	if _action_spend_overlay != null:
		_action_spend_overlay.visible = false
	_set_input_locked(true)

	_action_spend_tween = create_tween()
	_action_spend_tween.tween_property(_hud_actions_label, "scale", Vector2(1.07, 1.07), 0.08).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_action_spend_tween.tween_callback(_set_action_spend_center_text.bind(after_actions))
	_action_spend_tween.tween_property(_hud_actions_label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_action_spend_tween.tween_callback(_finish_action_spend_animation)


func _set_action_spend_center_text(after_actions: int) -> void:
	if _hud_actions_label != null:
		_hud_actions_label.text = _action_text(after_actions)
	if _action_spend_label != null:
		_action_spend_label.text = _action_text(after_actions)


func _finish_action_spend_animation() -> void:
	if _action_spend_tween != null and _action_spend_tween.is_valid():
		_action_spend_tween.kill()
	_action_spend_tween = null
	if _action_spend_overlay != null:
		_action_spend_overlay.visible = false
	if _action_spend_label != null:
		_action_spend_label.scale = Vector2.ONE
	if _hud_actions_label != null:
		_hud_actions_label.scale = Vector2.ONE
	var should_transition := _action_spend_should_settle
	_action_spend_should_settle = false
	if should_transition:
		_action_spend_after_actions = -1
		_play_day_transition()
		return
	_set_input_locked(false)
	_render()
	if _hud_actions_label != null and _action_spend_after_actions >= 0:
		_hud_actions_label.text = _action_text(_action_spend_after_actions)
	_action_spend_after_actions = -1


func _action_spend_start_position() -> Vector2:
	if _hud_actions_label == null:
		return Vector2(28, 320)
	return _hud_actions_label.global_position


func _action_spend_center_position() -> Vector2:
	var viewport_size := _viewport_size()
	var label_size := _action_spend_label.custom_minimum_size if _action_spend_label != null else Vector2(620, 92)
	return (viewport_size - label_size) * 0.5


func _build_day_transition_overlay() -> void:
	_day_transition_overlay = Control.new()
	_day_transition_overlay.name = "DayTransitionOverlay"
	_day_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_day_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_day_transition_overlay.visible = false
	_day_transition_overlay.z_index = 95
	_day_transition_overlay.set_meta("duration_seconds", 3.6)
	_ui_root.add_child(_day_transition_overlay)

	var background := ColorRect.new()
	background.name = "DayTransitionBlack"
	background.color = Color("050705")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_day_transition_overlay.add_child(background)

	_day_transition_rule = ColorRect.new()
	_day_transition_rule.name = "DayTransitionRule"
	_day_transition_rule.color = _theme_color("flash_text")
	_day_transition_rule.set_anchors_preset(Control.PRESET_CENTER)
	_day_transition_rule.offset_left = -620
	_day_transition_rule.offset_top = -8
	_day_transition_rule.offset_right = 620
	_day_transition_rule.offset_bottom = 8
	_day_transition_rule.pivot_offset = Vector2(620, 8)
	_day_transition_rule.rotation = deg_to_rad(-5.0)
	_day_transition_overlay.add_child(_day_transition_rule)

	_day_transition_day_label = _label("DAY 01", 96, _theme_color("surface"))
	_day_transition_day_label.name = "DayTransitionDayLabel"
	_day_transition_day_label.set_meta("on_dark", true)
	_day_transition_day_label.set_anchors_preset(Control.PRESET_CENTER)
	_day_transition_day_label.offset_left = -520
	_day_transition_day_label.offset_top = -168
	_day_transition_day_label.offset_right = 520
	_day_transition_day_label.offset_bottom = -28
	_day_transition_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_day_transition_day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_day_transition_day_label.pivot_offset = Vector2(520, 70)
	_day_transition_overlay.add_child(_day_transition_day_label)

	_day_transition_meta_label = _label("", 20, _theme_color("muted"))
	_day_transition_meta_label.name = "DayTransitionMetaLabel"
	_day_transition_meta_label.set_meta("on_dark", true)
	_day_transition_meta_label.set_anchors_preset(Control.PRESET_CENTER)
	_day_transition_meta_label.offset_left = -440
	_day_transition_meta_label.offset_top = 44
	_day_transition_meta_label.offset_right = 440
	_day_transition_meta_label.offset_bottom = 112
	_day_transition_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_day_transition_meta_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_day_transition_overlay.add_child(_day_transition_meta_label)


func _play_day_transition() -> void:
	if _day_transition_overlay == null:
		_settle_day_and_present_rewards()
		_set_input_locked(false)
		_render()
		return
	if _day_transition_tween != null and _day_transition_tween.is_valid():
		_day_transition_tween.kill()
	_day_transition_settled = false
	_set_input_locked(true)
	_day_transition_overlay.visible = true
	_day_transition_overlay.modulate = Color(1, 1, 1, 0)
	_day_transition_day_label.text = "DAY %02d" % game.day
	_day_transition_day_label.scale = Vector2(0.86, 0.86)
	_day_transition_meta_label.text = "TODAY'S ACTIONS DEPLETED  /  楼层 %d" % game.tower_floor
	_day_transition_rule.scale = Vector2(0.04, 1.0)
	if not is_inside_tree():
		return
	_day_transition_tween = create_tween()
	_day_transition_tween.set_parallel(true)
	_day_transition_tween.tween_property(_day_transition_overlay, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_day_transition_tween.tween_property(_day_transition_rule, "scale:x", 1.0, 0.72).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_day_transition_tween.set_parallel(false)
	_day_transition_tween.tween_property(_day_transition_day_label, "scale", Vector2.ONE, 0.58).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_day_transition_tween.tween_interval(0.55)
	_day_transition_tween.tween_callback(_commit_day_transition_settlement)
	_day_transition_tween.tween_interval(0.95)
	_day_transition_tween.tween_property(_day_transition_overlay, "modulate:a", 0.0, 0.80).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_day_transition_tween.tween_callback(_finish_day_transition)


func _commit_day_transition_settlement() -> void:
	if _day_transition_settled:
		return
	_day_transition_settled = true
	if _settle_day_and_present_rewards():
		selected_token_id = ""
		selected_meme_id = ""
		if not game.event_log.is_empty():
			log_text = game.event_log[0]
	_day_transition_day_label.text = "DAY %02d" % game.day
	_day_transition_meta_label.text = "NEXT SIGNAL ACQUIRED  /  楼层 %d" % game.tower_floor


func _finish_day_transition() -> void:
	if _day_transition_tween != null and _day_transition_tween.is_valid():
		_day_transition_tween.kill()
	_day_transition_tween = null
	if not _day_transition_settled:
		_commit_day_transition_settlement()
	if _day_transition_overlay != null:
		_day_transition_overlay.visible = false
		_day_transition_overlay.modulate = Color.WHITE
	_set_input_locked(false)
	_sync_audio_state(false)
	_render()


func _build_flashback_overlay() -> void:
	_flashback_words.clear()
	_flashback_overlay = Control.new()
	_flashback_overlay.name = "PollutionFlashbackOverlay"
	_flashback_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flashback_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flashback_overlay.visible = false
	_flashback_overlay.z_index = 100
	_ui_root.add_child(_flashback_overlay)

	var bg := ColorRect.new()
	bg.color = _theme_color("ink")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flashback_overlay.add_child(bg)

	_flashback_noise = ColorRect.new()
	_flashback_noise.color = Color(_theme_color("flash_text"), 0.20)
	_flashback_noise.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flashback_overlay.add_child(_flashback_noise)

	for index in 14:
		var stripe := ColorRect.new()
		stripe.color = Color(_theme_color("flash_text"), 0.20 + float(index % 4) * 0.08)
		stripe.set_anchors_preset(Control.PRESET_TOP_WIDE)
		stripe.offset_left = -80 + (index % 3) * 28
		stripe.offset_right = 80 - (index % 2) * 34
		stripe.offset_top = 32 + index * 45
		stripe.offset_bottom = stripe.offset_top + 4 + (index % 5) * 4
		_flashback_overlay.add_child(stripe)

	_flashback_blackout = ColorRect.new()
	_flashback_blackout.color = _theme_color("ink")
	_flashback_blackout.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flashback_blackout.visible = false
	_flashback_overlay.add_child(_flashback_blackout)

	var words := [
		"哈吉米",
		"我想正常说话",
		"必须进入句子",
		"信号丢失",
		"POLLUTION 60",
		"哈吉米    哈吉米    哈吉米",
		"normal speech failed",
		"必须进入句子\n必须进入句子\n必须进入句子",
	]
	for index in words.size():
		var label := Label.new()
		label.text = words[index]
		label.set_meta("flashback_text", true)
		label.add_theme_font_size_override("font_size", 28 + index % 3 * 12)
		label.add_theme_color_override("font_color", _theme_color("flash_text"))
		label.modulate.a = 0.88
		label.position = Vector2(34 + index * 122, 40 + index % 4 * 128)
		label.rotation = deg_to_rad(-4 + index % 5 * 2)
		_flashback_overlay.add_child(label)
		_flashback_words.append(label)


func _play_pollution_flashback() -> void:
	if _flashback_overlay == null:
		return
	_set_input_locked(true)
	_flashback_overlay.visible = true
	_flashback_overlay.modulate.a = 1.0
	_flashback_blackout.visible = false
	_flashback_noise.visible = true
	_scramble_flashback_words(0)
	_duck_ambience_for_flashback()
	if _flashback_audio != null and _flashback_audio.stream != null and _flashback_audio.is_inside_tree():
		_flashback_audio.play()
	if _flashback_tween != null and _flashback_tween.is_valid():
		_flashback_tween.kill()
	_flashback_tween = create_tween()
	for step in 7:
		_flashback_tween.tween_callback(_scramble_flashback_words.bind(step))
		_flashback_tween.tween_interval(0.12)
	_flashback_tween.tween_callback(_set_flashback_blackout.bind(true))
	for step in range(7, 12):
		_flashback_tween.tween_callback(_scramble_flashback_words.bind(step))
		_flashback_tween.tween_interval(0.13)
	_flashback_tween.tween_interval(0.18)
	_flashback_tween.tween_callback(_finish_pollution_flashback)


func _finish_pollution_flashback() -> void:
	if _flashback_tween != null and _flashback_tween.is_valid():
		_flashback_tween.kill()
	_flashback_tween = null
	if _flashback_overlay != null:
		_flashback_overlay.visible = false
	if _flashback_blackout != null:
		_flashback_blackout.visible = false
	if _flashback_audio != null:
		_flashback_audio.stop()
	_set_input_locked(false)
	var should_settle := game.consume_pollution_flashback()
	if should_settle and _settle_day_and_present_rewards():
		selected_token_id = ""
		selected_meme_id = ""
		log_text = "黑屏之后，已经是第二天。"
		if not game.event_log.is_empty():
			log_text = "%s\n%s" % [log_text, game.event_log[0]]
	_sync_audio_state(false)
	_render()


func _set_flashback_blackout(value: bool) -> void:
	if _flashback_blackout != null:
		_flashback_blackout.visible = value
	if _flashback_noise != null:
		_flashback_noise.modulate.a = 0.16 if value else 1.0


func _scramble_flashback_words(step: int) -> void:
	var viewport_size := _viewport_size()
	var phrases := [
		"哈吉米",
		"哈吉米    哈吉米    哈吉米",
		"我想正常说话",
		"必须进入句子",
		"信号丢失",
		"□□□□□□",
		"POLLUTION 60",
		"normal speech failed",
	]
	for index in _flashback_words.size():
		var label := _flashback_words[index]
		label.text = phrases[(index + step) % phrases.size()]
		label.add_theme_color_override("font_color", _theme_color("flash_text"))
		label.add_theme_font_size_override("font_size", 26 + ((index + step) % 5) * 10)
		label.position = Vector2(
			randf_range(-80.0, viewport_size.x - 120.0),
			randf_range(0.0, viewport_size.y - 60.0)
		)
		label.rotation = deg_to_rad(randf_range(-7.0, 7.0))
		label.modulate.a = randf_range(0.45, 1.0)


func _set_input_locked(value: bool) -> void:
	_input_locked = value
	if _flashback_overlay != null:
		_flashback_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	if _action_spend_overlay != null:
		_action_spend_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if value and _action_spend_overlay.visible else Control.MOUSE_FILTER_IGNORE
	if _day_transition_overlay != null:
		_day_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if value and _day_transition_overlay.visible else Control.MOUSE_FILTER_IGNORE


func _render_ending() -> void:
	if _canvas == null:
		_build_world()
	for child in _canvas.get_children():
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = _theme_color("ink")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.add_child(bg)
	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.offset_left = -360
	center.offset_right = 360
	center.offset_top = -190
	center.offset_bottom = 190
	center.add_theme_constant_override("separation", 18)
	_canvas.add_child(center)
	var title := _label("塔顶没有人", 40, _theme_color("surface"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)
	var body := _label("所有遗产规则都说智者在这里。\n你想说一句普通的话，但每一层都先替你开口。\n\n哈吉米    ■    ……    沉默\n\n关系残留 %d / 100 · %s" % [game.relationship_residue, game.get_relationship_state_label()], 22, _theme_color("muted"))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center.add_child(body)
	var restart := Button.new()
	restart.text = "重开"
	restart.custom_minimum_size.y = 54
	restart.pressed.connect(new_game, CONNECT_DEFERRED)
	center.add_child(restart)


func _on_app_pressed(app_id: String) -> void:
	if _input_locked:
		return
	game.set_view_state("phone_down")
	_set_reality_mouse_look(false)
	game.set_active_app(app_id)
	_open_app_windows[app_id] = true
	_phone_launcher_open = false
	if _app_windows.has(app_id):
		var window := _app_windows[app_id] as Control
		if window != null:
			window.move_to_front()
	log_text = "打开 %s。" % app_id
	_render()


func _on_token_pressed(post_id: String, token: Dictionary) -> void:
	if _input_locked:
		return
	var actions_before: int = int(game.actions_remaining)
	if game.pick_token(post_id, token):
		selected_token_id = "%s-%s-%d" % [post_id, token.get("id", "token"), game.day]
		log_text = "拾取：%s" % token["text"]
		_after_effective_action(actions_before)
	else:
		log_text = "这个词没有进入笔记本。"
		_render()


func _on_buy_emotion_slot_pressed() -> void:
	if _input_locked:
		return
	var slot := game.get_daily_emotion_slot()
	var actions_before: int = int(game.actions_remaining)
	if game.buy_daily_emotion_slot():
		log_text = "购买情绪槽：%s" % slot.get("label", "情绪")
		_after_effective_action(actions_before)
	else:
		log_text = "购买失败。"
		_render()


func _on_buy_arcana_card_pressed() -> void:
	if _input_locked:
		return
	var card := game.get_daily_arcana_card()
	var actions_before: int = int(game.actions_remaining)
	if game.buy_daily_arcana_card():
		log_text = "收下玄牌：%s" % str(card.get("label", "玄牌"))
		_after_effective_action(actions_before)
	else:
		log_text = "玄牌没有进入手中。检查资金、行动和两个持有位。"
		_render()


func _on_arcana_use_pressed(card_uid: String) -> void:
	if _input_locked:
		return
	var placed := _placed_meme()
	var target_meme_id := str(placed.get("id", ""))
	if game.use_arcana_card(card_uid, target_meme_id):
		log_text = "玄牌已经改写本次构筑。"
	else:
		log_text = "这张玄牌需要先在发布空格里放入可改写的完整梗。"
	_render()


func _on_emotion_text_changed(text: String, slot_id: String) -> void:
	if _input_locked:
		return
	game.set_emotion_slot_text(slot_id, text)
	log_text = "情绪槽文字已改写。"
	_render_status()


func _on_emotion_equip_pressed(slot_id: String) -> void:
	if _input_locked:
		return
	if game.toggle_equipped_emotion_slot(slot_id):
		log_text = "情绪构筑已更新。"
	else:
		log_text = "最多只能装备两个情绪。"
	_render()


func _on_ascent_reward_pressed(reward_id: String) -> void:
	if _input_locked:
		return
	if game.choose_ascent_reward(reward_id):
		log_text = "永久许可已写入本层。"
	else:
		log_text = "这项许可已经关闭。"
	_render()


func _on_note_token_pressed(token_id: String) -> void:
	if _input_locked:
		return
	selected_token_id = token_id
	log_text = "选中词语。"
	_render()


func _on_slot_token_dropped(data: Dictionary, slot_id: String) -> void:
	if _input_locked:
		return
	var token_id := str(data.get("id", ""))
	if token_id.is_empty():
		return
	selected_token_id = token_id
	game.place_token_in_slot(slot_id, token_id)
	log_text = "词语已拖入槽位。"
	_render()


func _on_slot_pressed(slot_id: String) -> void:
	if _input_locked:
		return
	if selected_token_id.is_empty():
		log_text = "先选一个词语。"
	else:
		game.place_token_in_slot(slot_id, selected_token_id)
		log_text = "词语已放入槽位。"
	_render()


func _on_confirm_craft_pressed() -> void:
	if _input_locked:
		return
	var actions_before: int = int(game.actions_remaining)
	if game.confirm_craft_with_emotions():
		selected_meme_id = str(game.completed_memes[0]["id"])
		log_text = "合成新梗：%s" % game.completed_memes[0]["title"]
		_after_effective_action(actions_before)
	else:
		log_text = "对象和说法还没有形成句子。"
		_render()


func _on_meme_pressed(meme_id: String) -> void:
	if _input_locked:
		return
	selected_meme_id = meme_id
	log_text = "选中完整梗。"
	_render()


func _on_dialogue_blank_pressed() -> void:
	if _input_locked:
		return
	if selected_meme_id.is_empty():
		log_text = "空格还在等一个完整梗。"
	else:
		game.place_meme_in_blank("blank_1", selected_meme_id)
		log_text = "梗已经塞进手机发布空格。"
	_render()


func _on_dialogue_meme_dropped(data: Dictionary, blank_id: String) -> void:
	if _input_locked:
		return
	var meme_id := str(data.get("id", ""))
	if meme_id.is_empty():
		return
	selected_meme_id = meme_id
	game.place_meme_in_blank(blank_id, meme_id)
	log_text = "完整梗已拖进发布空格。"
	_render()


func _on_confirm_dialogue_pressed() -> void:
	if _input_locked:
		return
	var actions_before: int = int(game.actions_remaining)
	if game.confirm_dialogue():
		selected_meme_id = ""
		log_text = "句子发到手机里。热度在塔下回响。"
		_after_effective_action(actions_before)
	else:
		log_text = "发布空格里还没有完整梗。"
		_render()


func _after_effective_action(actions_before: int = -1) -> void:
	if game.pollution_flashback_pending:
		_play_pollution_flashback()
		return
	if actions_before >= 0 and game.actions_remaining < actions_before:
		_render()
		if _hud_actions_label != null:
			_hud_actions_label.text = _action_text(actions_before)
		_play_action_spend_animation(actions_before, game.actions_remaining)
		return
	if _settle_day_and_present_rewards():
		selected_token_id = ""
		selected_meme_id = ""
		if not game.event_log.is_empty():
			log_text = game.event_log[0]
	_render()


func _settle_day_and_present_rewards() -> bool:
	if not game.settle_day_if_needed():
		return false
	_reality_interaction_active = false
	_active_reality_actor = null
	_nearby_reality_actor = null
	_nearby_reality_item = null
	_reality_hover_choice_id = ""
	selected_token_id = ""
	selected_meme_id = ""
	if not game.pending_ascent_reward_choices.is_empty():
		game.set_view_state("phone_down")
		_set_reality_mouse_look(false)
		game.set_active_app("babel")
		_open_app_windows["babel"] = true
		_phone_launcher_open = false
	_sync_audio_state(false)
	return true


func _day_plan() -> Dictionary:
	return DAY_PLANS[mini(game.day, DAY_PLANS.size()) - 1]


func _slot_text(slot_id: String, placeholder: String) -> String:
	if game.draft_slots.has(slot_id):
		var token_id := str(game.draft_slots[slot_id])
		for token in game.notebook_tokens:
			if str(token["id"]) == token_id:
				return str(token["text"])
	return placeholder


func _craft_preview_text() -> String:
	var pieces: Array[String] = []
	pieces.append(_slot_text("object", "对象"))
	pieces.append(_slot_text("saying", "说法"))
	for emotion in game.get_equipped_emotion_slot_data():
		var slot_id := str(emotion["id"])
		var text := str(game.emotion_slot_texts.get(slot_id, emotion.get("default_text", "")))
		if not text.strip_edges().is_empty():
			pieces.append("%s：%s" % [str(emotion["label"]), text])
	return " / ".join(pieces)


func _placed_meme() -> Dictionary:
	if game.dialogue_blanks.has("blank_1"):
		var meme_id := str(game.dialogue_blanks["blank_1"])
		for meme in game.completed_memes:
			if str(meme["id"]) == meme_id:
				return meme
	return {}


func _corrupt(text: String) -> String:
	if game.pollution < 35:
		return text
	var result := ""
	var replacements := ["哈吉米", "□", "沉默", "……"]
	for index in text.length():
		var ch := text.substr(index, 1)
		if index % maxi(2, 8 - int(game.pollution / 14)) == 0 and ch != " ":
			result += replacements[(index + game.day) % replacements.size()]
		else:
			result += ch
	return result


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(_theme_color("surface"), _theme_color("accent")))
	return panel


func _wrap(node: Control) -> PanelContainer:
	var panel := _panel()
	panel.add_child(node)
	return panel


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(10)
	return style


func _soft_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg, 0.94)
	style.border_color = Color(border, 0.24)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(16)
	return style


func _phone_shell_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _theme_color("ink")
	style.border_color = _theme_color("ink")
	style.set_border_width_all(6)
	style.set_corner_radius_all(24)
	style.set_content_margin_all(6)
	return style


func _phone_surface_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _theme_color("surface")
	style.border_color = _theme_color("surface")
	style.set_border_width_all(0)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(10)
	return style


func _reward_card_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	return style


func _social_feed_dark_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _theme_color("ink")
	style.border_color = Color(_theme_color("muted"), 0.18)
	style.set_border_width_all(0)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(6)
	return style


func _social_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _theme_color("surface")
	style.border_color = Color(_theme_color("muted"), 0.62)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(6)
	return style


func _poster_frame_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _theme_color("muted")
	style.border_color = Color(_theme_color("ink"), 0.65)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(0)
	return style


func _detail_dark_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _theme_color("ink")
	style.border_color = _theme_color("ink")
	style.set_border_width_all(0)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
	return style


func _flat_button_state_style(bg: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(bg, 0.0)
	style.set_border_width_all(0)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(4)
	return style


func _file_corner_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.set_content_margin_all(6)
	return style


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
