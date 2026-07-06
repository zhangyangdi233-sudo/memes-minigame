extends Node3D

const MemeGameStateScript = preload("res://scripts/meme_game_state.gd")
const DraggableButtonScript = preload("res://scripts/ui/draggable_button.gd")
const DropButtonScript = preload("res://scripts/ui/drop_button.gd")

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
var selected_reality_tile_id := ""
var feed_shift := 0
var log_text := ""
var _road_scroll := 0.0
var _input_locked := false

var _camera: Camera3D
var _road: Node3D
var _phone_rig: Node3D
var _npc: Node3D
var _canvas: CanvasLayer
var _ui_root: Control
var _stats_label: Label
var _actions_label: Label
var _world_prompt: Label
var _desk_log: Label
var _phone_panel: PanelContainer
var _phone_tab: Button
var _phone_title: Label
var _app_window: PanelContainer
var _app_title: Label
var _app_body: VBoxContainer
var _publish_panel: PanelContainer
var _publish_blank: DropButton
var _confirm_publish_button: Button
var _meme_bank_tab: Button
var _meme_bank_window: PanelContainer
var _bank_list: HBoxContainer
var _reality_panel: PanelContainer
var _reality_tile_row: HBoxContainer
var _reality_slot_box: HBoxContainer
var _reality_result: Label
var _confirm_reality_button: Button
var _npc_chat_bubble: PanelContainer
var _npc_chat_label: Label
var _reality_dim_overlay: ColorRect
var _player_portrait: Control
var _thought_word_layer: Control
var _flashback_overlay: Control
var _flashback_noise: ColorRect
var _flashback_blackout: ColorRect
var _flashback_words: Array[Label] = []
var _flashback_tween: Tween
var _meme_bank_open := false
var _draggable_windows: Dictionary = {}
var _dragged_window: Control
var _drag_offset := Vector2.ZERO


func _ready() -> void:
	new_game()


func _process(delta: float) -> void:
	if _camera == null:
		return
	_animate_world(delta)


func _input(event: InputEvent) -> void:
	if _input_locked:
		return
	if _dragged_window == null:
		return
	if event is InputEventMouseMotion:
		_dragged_window.global_position = get_viewport().get_mouse_position() - _drag_offset
		_clamp_window_to_viewport(_dragged_window)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_dragged_window = null


func new_game() -> void:
	game = MemeGameStateScript.new()
	game.new_run()
	selected_token_id = ""
	selected_meme_id = ""
	selected_reality_tile_id = ""
	feed_shift = 0
	_meme_bank_open = false
	_draggable_windows = {}
	_dragged_window = null
	_drag_offset = Vector2.ZERO
	log_text = "你低头，手机边框从视野下方亮起来。"
	_build_world()
	_build_ui()
	_render()


func set_view_state(value: String) -> void:
	if _input_locked:
		return
	if game.set_view_state(value):
		if value == "npc_up":
			log_text = "你放下手机，视线抬到对方脸上。"
			_meme_bank_open = false
		else:
			log_text = "你又低头看向手机。"
		_render()


func begin_reality_player_turn() -> void:
	if _input_locked:
		return
	if game.begin_reality_player_turn():
		log_text = "你开始在脑内拼一句尽量普通的话。"
	_render()


func _build_world() -> void:
	for child in get_children():
		child.queue_free()

	_camera = Camera3D.new()
	_camera.name = "Camera3D"
	add_child(_camera)
	_camera.current = true
	_camera.fov = 58.0

	var light := DirectionalLight3D.new()
	light.name = "StreetLight"
	light.rotation_degrees = Vector3(-55.0, 20.0, 0.0)
	light.light_energy = 1.1
	add_child(light)

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
	npc_mat.emission_enabled = true
	npc_mat.emission = _theme_color("muted")
	npc_mat.emission_energy_multiplier = 0.12
	npc_body.material_override = npc_mat
	_npc.add_child(npc_body)

	_canvas = CanvasLayer.new()
	_canvas.name = "CanvasLayer"
	add_child(_canvas)


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
	_ui_root.add_child(vignette)

	var status := HBoxContainer.new()
	status.name = "StatusBar"
	status.set_anchors_preset(Control.PRESET_TOP_WIDE)
	status.offset_left = 14
	status.offset_top = 12
	status.offset_right = -14
	status.offset_bottom = 70
	status.add_theme_constant_override("separation", 10)
	_ui_root.add_child(status)

	var brand := _panel()
	brand.custom_minimum_size.x = 260
	status.add_child(brand)
	brand.add_child(_label("BABEL PHONE / 巴别塔", 20, _theme_color("ink")))

	var stats_panel := _panel()
	stats_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_child(stats_panel)
	_stats_label = _label("", 16, _theme_color("ink"))
	stats_panel.add_child(_stats_label)

	var action_panel := _panel()
	action_panel.custom_minimum_size.x = 260
	status.add_child(action_panel)
	_actions_label = _label("", 16, _theme_color("accent"))
	action_panel.add_child(_actions_label)

	_world_prompt = _label("", 20, _theme_color("ink"))
	_world_prompt.name = "WorldPrompt"
	_world_prompt.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_world_prompt.offset_left = 24
	_world_prompt.offset_top = 86
	_world_prompt.offset_right = 620
	_world_prompt.offset_bottom = 164
	_world_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ui_root.add_child(_world_prompt)

	_phone_panel = _panel()
	_phone_panel.name = "PhoneEdge"
	_phone_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_phone_panel.offset_left = -300
	_phone_panel.offset_top = -250
	_phone_panel.offset_right = -16
	_phone_panel.offset_bottom = -150
	_ui_root.add_child(_phone_panel)
	var phone_box := VBoxContainer.new()
	phone_box.add_theme_constant_override("separation", 8)
	_phone_panel.add_child(phone_box)
	_phone_title = _label("PHONE", 18, _theme_color("accent"))
	phone_box.add_child(_phone_title)
	var app_row := HBoxContainer.new()
	app_row.add_theme_constant_override("separation", 5)
	phone_box.add_child(app_row)
	for app in [
		{"id": "babel", "label": "塔"},
		{"id": "social", "label": "帖"},
		{"id": "shop", "label": "店"},
		{"id": "notebook", "label": "本"},
	]:
		var button := Button.new()
		button.text = app["label"]
		button.custom_minimum_size = Vector2(58, 42)
		button.pressed.connect(_on_app_pressed.bind(app["id"]))
		app_row.add_child(button)
	var raise_button := Button.new()
	raise_button.text = "放下手机"
	raise_button.custom_minimum_size.y = 42
	raise_button.pressed.connect(set_view_state.bind("npc_up"))
	phone_box.add_child(raise_button)

	_phone_tab = Button.new()
	_phone_tab.name = "PhoneTab"
	_phone_tab.text = "PHONE"
	_phone_tab.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_phone_tab.offset_left = -78
	_phone_tab.offset_top = 180
	_phone_tab.offset_right = -16
	_phone_tab.offset_bottom = -180
	_phone_tab.pressed.connect(set_view_state.bind("phone_down"))
	_ui_root.add_child(_phone_tab)

	_app_window = _panel()
	_app_window.name = "FloatingAppWindow"
	_app_window.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_app_window.offset_left = -820
	_app_window.offset_top = 84
	_app_window.offset_right = -320
	_app_window.offset_bottom = 560
	_ui_root.add_child(_app_window)
	var app_box := VBoxContainer.new()
	app_box.add_theme_constant_override("separation", 8)
	_app_window.add_child(app_box)
	_app_title = _label("", 21, _theme_color("accent"))
	_app_title.name = "AppWindowHandle"
	_app_title.mouse_filter = Control.MOUSE_FILTER_STOP
	app_box.add_child(_app_title)
	_make_draggable_window(_app_window, "app", _app_title)
	var app_scroll := ScrollContainer.new()
	app_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	app_box.add_child(app_scroll)
	_app_body = VBoxContainer.new()
	_app_body.add_theme_constant_override("separation", 8)
	app_scroll.add_child(_app_body)

	_publish_panel = _panel()
	_publish_panel.name = "PublishPanel"
	_publish_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_publish_panel.offset_left = 16
	_publish_panel.offset_top = -250
	_publish_panel.offset_right = 520
	_publish_panel.offset_bottom = -150
	_ui_root.add_child(_publish_panel)
	var publish_box := VBoxContainer.new()
	publish_box.add_theme_constant_override("separation", 8)
	_publish_panel.add_child(publish_box)
	var publish_title := _label("手机发布空格", 18, _theme_color("accent"))
	publish_title.mouse_filter = Control.MOUSE_FILTER_STOP
	publish_box.add_child(publish_title)
	_make_draggable_window(_publish_panel, "publish", publish_title)
	_publish_blank = DropButtonScript.new()
	_publish_blank.custom_minimum_size.y = 46
	_publish_blank.configure_drop_target("meme", "blank_1")
	_publish_blank.dropped.connect(_on_dialogue_meme_dropped)
	_publish_blank.pressed.connect(_on_dialogue_blank_pressed)
	publish_box.add_child(_publish_blank)
	_confirm_publish_button = Button.new()
	_confirm_publish_button.text = "确认发布"
	_confirm_publish_button.custom_minimum_size.y = 44
	_confirm_publish_button.pressed.connect(_on_confirm_dialogue_pressed)
	publish_box.add_child(_confirm_publish_button)

	_reality_dim_overlay = ColorRect.new()
	_reality_dim_overlay.name = "RealityDimOverlay"
	_reality_dim_overlay.color = Color(0, 0, 0, 0.28)
	_reality_dim_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reality_dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reality_dim_overlay.z_index = 4
	_ui_root.add_child(_reality_dim_overlay)

	_npc_chat_bubble = _panel()
	_npc_chat_bubble.name = "NPCChatBubble"
	_npc_chat_bubble.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_npc_chat_bubble.offset_left = -430
	_npc_chat_bubble.offset_top = 126
	_npc_chat_bubble.offset_right = -38
	_npc_chat_bubble.offset_bottom = 278
	_npc_chat_bubble.z_index = 12
	_ui_root.add_child(_npc_chat_bubble)
	var bubble_box := VBoxContainer.new()
	bubble_box.add_theme_constant_override("separation", 8)
	_npc_chat_bubble.add_child(bubble_box)
	_npc_chat_label = _label("", 18, _theme_color("ink"))
	_npc_chat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble_box.add_child(_npc_chat_label)
	var bubble_continue := Button.new()
	bubble_continue.text = "组织语言"
	bubble_continue.custom_minimum_size.y = 44
	bubble_continue.pressed.connect(begin_reality_player_turn)
	bubble_box.add_child(bubble_continue)

	_player_portrait = _build_player_portrait()
	_player_portrait.name = "PlayerPortrait"
	_player_portrait.z_index = 14
	_ui_root.add_child(_player_portrait)

	_thought_word_layer = Control.new()
	_thought_word_layer.name = "ThoughtWordLayer"
	_thought_word_layer.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_thought_word_layer.offset_left = 220
	_thought_word_layer.offset_top = 318
	_thought_word_layer.offset_right = -170
	_thought_word_layer.offset_bottom = 408
	_thought_word_layer.z_index = 13
	_ui_root.add_child(_thought_word_layer)
	_reality_tile_row = HBoxContainer.new()
	_reality_tile_row.add_theme_constant_override("separation", 9)
	_reality_tile_row.set_anchors_preset(Control.PRESET_FULL_RECT)
	_thought_word_layer.add_child(_reality_tile_row)

	_reality_panel = _panel()
	_reality_panel.name = "LanguagePuzzleFrame"
	_reality_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_reality_panel.offset_left = 260
	_reality_panel.offset_top = -222
	_reality_panel.offset_right = -72
	_reality_panel.offset_bottom = -36
	_reality_panel.z_index = 15
	_ui_root.add_child(_reality_panel)
	var reality_box := VBoxContainer.new()
	reality_box.add_theme_constant_override("separation", 8)
	_reality_panel.add_child(reality_box)
	var reality_title := _label("语言组成框", 22, _theme_color("accent"))
	reality_title.mouse_filter = Control.MOUSE_FILTER_STOP
	reality_box.add_child(reality_title)
	_make_draggable_window(_reality_panel, "reality", reality_title)
	_reality_slot_box = HBoxContainer.new()
	_reality_slot_box.add_theme_constant_override("separation", 8)
	reality_box.add_child(_reality_slot_box)
	_confirm_reality_button = Button.new()
	_confirm_reality_button.text = "尽量正常地说出口"
	_confirm_reality_button.custom_minimum_size.y = 42
	_confirm_reality_button.pressed.connect(_on_confirm_reality_pressed)
	reality_box.add_child(_confirm_reality_button)
	_reality_result = _label("", 16, _theme_color("accent"))
	_reality_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reality_box.add_child(_reality_result)

	_meme_bank_tab = Button.new()
	_meme_bank_tab.name = "MemeBankTab"
	_meme_bank_tab.text = "梗仓库"
	_meme_bank_tab.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_meme_bank_tab.offset_left = 16
	_meme_bank_tab.offset_top = -118
	_meme_bank_tab.offset_right = 150
	_meme_bank_tab.offset_bottom = -72
	_meme_bank_tab.pressed.connect(_toggle_meme_bank)
	_ui_root.add_child(_meme_bank_tab)

	_meme_bank_window = _panel()
	_meme_bank_window.name = "MemeBankWindow"
	_meme_bank_window.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_meme_bank_window.offset_left = 16
	_meme_bank_window.offset_top = -178
	_meme_bank_window.offset_right = 760
	_meme_bank_window.offset_bottom = -22
	_ui_root.add_child(_meme_bank_window)
	var bank_box := VBoxContainer.new()
	bank_box.add_theme_constant_override("separation", 8)
	_meme_bank_window.add_child(bank_box)
	var bank_title := _label("梗仓库", 18, _theme_color("accent"))
	bank_title.mouse_filter = Control.MOUSE_FILTER_STOP
	bank_box.add_child(bank_title)
	_make_draggable_window(_meme_bank_window, "bank", bank_title)
	_bank_list = HBoxContainer.new()
	_bank_list.add_theme_constant_override("separation", 8)
	bank_box.add_child(_bank_list)

	_desk_log = _label("", 16, _theme_color("accent"))
	_desk_log.name = "DeskLog"
	_desk_log.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_desk_log.offset_left = 24
	_desk_log.offset_top = -146
	_desk_log.offset_right = 680
	_desk_log.offset_bottom = -112
	_desk_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ui_root.add_child(_desk_log)

	_build_flashback_overlay()


func _render() -> void:
	if game.ending_unlocked:
		_render_ending()
		return
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
	_stats_label.text = "DAY %d   热度 %d   污染 %d%%   清晰 %d%%   塔层 %d/%d   资金 %d" % [
		game.day, game.heat, game.pollution, game.clarity, game.tower_floor, MemeGameStateScript.MAX_TOWER_FLOOR, game.money
	]
	var pips := ""
	for index in game.max_actions_per_day:
		pips += "●" if index < game.actions_remaining else "○"
	_actions_label.text = "今日操作 %s" % pips
	_desk_log.text = log_text


func _render_world_prompt() -> void:
	var plan := _day_plan()
	if game.view_state == "phone_down":
		_world_prompt.text = "DAY %d. %s\n路面在脚下滑动。手机 App 的窗口浮在屏幕旁边。" % [game.day, plan["title"]]
	else:
		_world_prompt.text = "%s：%s" % [plan["speaker"], _corrupt(str(plan["line"]))]


func _render_app() -> void:
	match game.active_app_window:
		"babel":
			_app_title.text = "巴别塔 App"
			_render_babel_app()
		"shop":
			_app_title.text = "情绪槽商店"
			_render_shop_app()
		"notebook":
			_app_title.text = "笔记本 App"
			_render_notebook_app()
		"social":
			_app_title.text = "社交媒体 App"
			_render_social_app()
		_:
			_clear(_app_body)


func _render_babel_app() -> void:
	_clear(_app_body)
	_app_body.add_child(_label("第 %d 层 / %d" % [game.tower_floor, MemeGameStateScript.MAX_TOWER_FLOOR], 24, _theme_color("ink")))
	_app_body.add_child(_label("下一门槛：%d" % game.next_threshold, 17, _theme_color("accent")))
	_app_body.add_child(_label("遗产规则", 18, _theme_color("accent")))
	if game.legacy_rules.is_empty():
		_app_body.add_child(_label("还没有上一层语言留下来。", 16, _theme_color("accent")))
	for rule in game.legacy_rules:
		_app_body.add_child(_label("第 %d 层：%s" % [int(rule.get("floor", 1)), str(rule.get("required_text", ""))], 16, _theme_color("ink")))
	for item in game.event_log:
		_app_body.add_child(_label(str(item), 15, _theme_color("accent")))


func _render_social_app() -> void:
	_clear(_app_body)
	var controls := HBoxContainer.new()
	var refresh := Button.new()
	refresh.text = "刷帖子"
	refresh.pressed.connect(func():
		feed_shift += 1
		log_text = "帖子刷新了。"
		_render()
	)
	controls.add_child(refresh)
	_app_body.add_child(controls)
	var feed: Array = _day_plan()["feed"]
	for post_index in feed.size():
		var post: Dictionary = feed[(post_index + feed_shift) % feed.size()]
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 5)
		card.add_child(_label("@%s" % post["handle"], 15, _theme_color("accent")))
		var post_text := _label(_corrupt(str(post["text"])), 16, _theme_color("ink"))
		post_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(post_text)
		var tokens := HBoxContainer.new()
		tokens.add_theme_constant_override("separation", 5)
		for token in post["tokens"]:
			var btn := Button.new()
			btn.text = str(token["text"])
			btn.disabled = game.actions_remaining <= 0
			btn.pressed.connect(_on_token_pressed.bind(post["id"], token))
			tokens.add_child(btn)
		card.add_child(tokens)
		_app_body.add_child(_wrap(card))


func _render_shop_app() -> void:
	_clear(_app_body)
	var slot := game.get_daily_emotion_slot()
	if slot.is_empty():
		_app_body.add_child(_label("今日没有新槽位。", 16, _theme_color("accent")))
		return
	_app_body.add_child(_label("今日情绪槽", 18, _theme_color("accent")))
	var bought: bool = str(slot["id"]) in game.owned_emotion_slots
	var buy := Button.new()
	buy.text = "%s  %d 热币" % [slot["label"], slot["price"]]
	buy.disabled = bought or game.money < int(slot["price"]) or game.actions_remaining <= 0
	buy.pressed.connect(_on_buy_emotion_slot_pressed)
	_app_body.add_child(buy)
	_app_body.add_child(_label("购买后可以自由改写这个情绪的显示文字。", 15, _theme_color("accent")))
	if bought:
		_app_body.add_child(_label("已购买：%s" % game.emotion_slot_texts.get(slot["id"], ""), 16, _theme_color("ink")))


func _render_notebook_app() -> void:
	_clear(_app_body)
	_app_body.add_child(_label("拾取词语", 18, _theme_color("accent")))
	var token_row := HBoxContainer.new()
	token_row.add_theme_constant_override("separation", 5)
	for token in game.notebook_tokens:
		var btn_token = DraggableButtonScript.new()
		btn_token.text = str(token["text"])
		btn_token.set_drag_payload("token", str(token["id"]), str(token["text"]))
		btn_token.pressed.connect(_on_note_token_pressed.bind(str(token["id"])))
		token_row.add_child(btn_token)
	_app_body.add_child(token_row)

	_app_body.add_child(_label("核心槽", 18, _theme_color("accent")))
	for slot in game.get_craft_slots():
		var slot_id := str(slot["id"])
		if slot_id.begins_with("emotion:"):
			continue
		var btn_slot = DropButtonScript.new()
		btn_slot.custom_minimum_size.y = 44
		btn_slot.text = "%s：%s" % [slot["label"], _slot_text(slot_id, str(slot.get("placeholder", "")))]
		btn_slot.configure_drop_target("token", slot_id)
		btn_slot.dropped.connect(_on_slot_token_dropped)
		btn_slot.pressed.connect(_on_slot_pressed.bind(slot_id))
		_app_body.add_child(btn_slot)

	_app_body.add_child(_label("情绪槽文字", 18, _theme_color("accent")))
	if game.owned_emotion_slots.is_empty():
		_app_body.add_child(_label("去商店购买一个情绪槽。", 15, _theme_color("accent")))
	for emotion in game.get_owned_emotion_slot_data():
		var slot_id := str(emotion["id"])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.add_child(_label(str(emotion["label"]), 16, _theme_color("ink")))
		var edit := LineEdit.new()
		edit.text = str(game.emotion_slot_texts.get(slot_id, emotion.get("default_text", "")))
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		edit.text_changed.connect(_on_emotion_text_changed.bind(slot_id))
		row.add_child(edit)
		_app_body.add_child(row)

	var preview := _label("预览：%s" % _craft_preview_text(), 15, _theme_color("accent"))
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_app_body.add_child(preview)
	var craft := Button.new()
	craft.text = "确认合成"
	craft.custom_minimum_size.y = 46
	craft.disabled = game.actions_remaining <= 0
	craft.pressed.connect(_on_confirm_craft_pressed)
	_app_body.add_child(craft)


func _render_publish() -> void:
	var meme := _placed_meme()
	_publish_blank.text = "发布空格：%s" % (meme.get("title", "等待完整梗") if not meme.is_empty() else "等待完整梗")
	_confirm_publish_button.disabled = meme.is_empty() or game.actions_remaining <= 0


func _render_bank() -> void:
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
	_clear(_reality_tile_row)
	_clear(_reality_slot_box)

	var plan := _day_plan()
	if _npc_chat_label != null:
		_npc_chat_label.text = "%s\n%s" % [str(plan["speaker"]), _corrupt(str(plan["line"]))]

	for tile in game.get_reality_tile_options():
		var btn = DraggableButtonScript.new()
		btn.text = str(tile["text"])
		btn.custom_minimum_size = Vector2(118, 56)
		btn.set_drag_payload("reality", str(tile["id"]), str(tile["text"]))
		btn.pressed.connect(_on_reality_tile_pressed.bind(str(tile["id"])))
		if bool(tile.get("locked", false)):
			btn.disabled = true
			btn.text = "锁定：" + btn.text
		_reality_tile_row.add_child(btn)

	for index in maxi(4, game.legacy_rules.size() + 3):
		var slot_id := "slot_%d" % index
		var drop = DropButtonScript.new()
		drop.custom_minimum_size = Vector2(132, 60)
		drop.text = "%d\n%s" % [index + 1, _reality_slot_text(slot_id)]
		drop.configure_drop_target("reality", slot_id)
		drop.dropped.connect(_on_reality_tile_dropped)
		drop.pressed.connect(_on_reality_slot_pressed.bind(slot_id))
		_reality_slot_box.add_child(drop)

	var required: Array = game.get_required_legacy_tiles()
	var required_texts: Array[String] = []
	for tile in required:
		var suffix := "（锁定）" if bool(tile.get("locked", false)) else ""
		required_texts.append("%s%s" % [str(tile.get("text", "")), suffix])
	if required_texts.is_empty():
		_reality_result.text = "思考词可以自由拼接。"
	else:
		_reality_result.text = "必须进入句子的遗产：%s" % " / ".join(required_texts)
	if game.reality_phase == "reality_result":
		_reality_result.text = "清洁原句：%s\n现实出口：%s\nNPC理解：%d%%" % [
			game.last_clean_sentence,
			game.last_polluted_sentence,
			game.npc_understanding,
		]
	_confirm_reality_button.disabled = game.actions_remaining <= 0 or game.reality_phase == "reality_result"


func _update_visibility() -> void:
	var in_phone: bool = game.view_state == "phone_down"
	_phone_panel.visible = in_phone
	_phone_tab.visible = not in_phone
	_app_window.visible = in_phone and not game.active_app_window.is_empty()
	_publish_panel.visible = in_phone
	_meme_bank_tab.visible = in_phone
	_meme_bank_window.visible = in_phone and _meme_bank_open
	var composing: bool = (not in_phone) and game.reality_phase == "player_composing"
	var result: bool = (not in_phone) and game.reality_phase == "reality_result"
	_npc_chat_bubble.visible = not in_phone
	_reality_dim_overlay.visible = composing
	_player_portrait.visible = composing
	_thought_word_layer.visible = composing
	_reality_panel.visible = composing or result
	if _npc != null:
		_npc.visible = not in_phone


func _animate_world(delta: float) -> void:
	var phone_target := Vector3(0.0, 0.15, -1.15) if game.view_state == "phone_down" else Vector3(1.45, -0.8, -1.0)
	var camera_target_pos := Vector3(0.0, 1.45, 2.2) if game.view_state == "phone_down" else Vector3(0.0, 1.62, 2.7)
	var camera_target_rot := Vector3(-54.0, 0.0, 0.0) if game.view_state == "phone_down" else Vector3(-8.0, 0.0, 0.0)
	_camera.position = _camera.position.lerp(camera_target_pos, minf(1.0, delta * 5.0))
	_camera.rotation_degrees = _camera.rotation_degrees.lerp(camera_target_rot, minf(1.0, delta * 5.0))
	if _phone_rig != null:
		_phone_rig.position = _phone_rig.position.lerp(phone_target, minf(1.0, delta * 6.0))
		_phone_rig.rotation_degrees = Vector3(68.0, 0.0, 0.0)
	if _road != null:
		_road_scroll += delta * 1.4
		for index in _road.get_child_count():
			var tile := _road.get_child(index) as Node3D
			tile.position.z = -2.0 - index * 3.8 + fmod(_road_scroll, 3.8)


func _active_palette() -> Dictionary:
	if game != null and game.pollution >= MemeGameStateScript.POLLUTION_FLASHBACK_THRESHOLD:
		return POLLUTION_PALETTE_5
	return PALETTE_1


func _theme_color(key: String) -> Color:
	var palette := _active_palette()
	return Color(str(palette.get(key, PALETTE_1.get(key, "FFF1C9"))))


func _toggle_meme_bank() -> void:
	if _input_locked:
		return
	_meme_bank_open = not _meme_bank_open
	_render()


func _move_window_for_test(window_id: String, delta: Vector2) -> bool:
	if not _draggable_windows.has(window_id):
		return false
	var window := _draggable_windows[window_id] as Control
	if window == null:
		return false
	window.position += delta
	_clamp_window_to_viewport(window)
	return true


func _make_draggable_window(window: Control, window_id: String, handle: Control) -> void:
	if window == null or handle == null:
		return
	_draggable_windows[window_id] = window
	handle.mouse_filter = Control.MOUSE_FILTER_STOP
	handle.gui_input.connect(_on_window_handle_gui_input.bind(window_id, window))


func _on_window_handle_gui_input(event: InputEvent, _window_id: String, window: Control) -> void:
	if _input_locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragged_window = window
			_drag_offset = get_viewport().get_mouse_position() - window.global_position
			window.move_to_front()
		else:
			_dragged_window = null
	elif event is InputEventMouseMotion and _dragged_window == window:
		window.global_position = get_viewport().get_mouse_position() - _drag_offset
		_clamp_window_to_viewport(window)


func _clamp_window_to_viewport(window: Control) -> void:
	var viewport_size := Vector2(1280, 720)
	if get_viewport() != null:
		viewport_size = get_viewport().get_visible_rect().size
	var max_x := maxf(0.0, viewport_size.x - maxf(80.0, window.size.x))
	var max_y := maxf(0.0, viewport_size.y - maxf(80.0, window.size.y))
	window.position = Vector2(clampf(window.position.x, 0.0, max_x), clampf(window.position.y, 0.0, max_y))


func _build_player_portrait() -> Control:
	var portrait := PanelContainer.new()
	portrait.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	portrait.offset_left = 24
	portrait.offset_top = -300
	portrait.offset_right = 230
	portrait.offset_bottom = -24
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	portrait.add_child(box)
	var head := PanelContainer.new()
	head.custom_minimum_size = Vector2(128, 94)
	box.add_child(head)
	var face := _label("  o   o\n    ─\n  _____", 24, _theme_color("ink"))
	face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(face)
	var torso := _label("主角\n正在想普通的话", 17, _theme_color("accent"))
	torso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	torso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(torso)
	return portrait


func _apply_world_theme() -> void:
	if _road != null:
		for index in _road.get_child_count():
			var tile := _road.get_child(index) as MeshInstance3D
			if tile == null:
				continue
			var mat := tile.material_override as StandardMaterial3D
			if mat != null:
				mat.albedo_color = _theme_color("accent").darkened(0.50 - index * 0.08)
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
			mat.albedo_color = _theme_color("surface")
			mat.emission = _theme_color("muted")


func _apply_ui_theme(node: Node = null) -> void:
	if node == null:
		node = _ui_root
	if node == null:
		return
	if node is Label and not node.has_meta("flashback_text"):
		(node as Label).add_theme_color_override("font_color", _theme_color("ink"))
	elif node is Button:
		var button := node as Button
		button.add_theme_color_override("font_color", _theme_color("ink"))
		button.add_theme_color_override("font_hover_color", _theme_color("ink"))
		button.add_theme_color_override("font_pressed_color", _theme_color("surface"))
		button.add_theme_color_override("font_disabled_color", _theme_color("accent").lightened(0.22))
		button.add_theme_stylebox_override("normal", _style(_theme_color("surface"), _theme_color("accent")))
		button.add_theme_stylebox_override("hover", _style(_theme_color("muted"), _theme_color("ink")))
		button.add_theme_stylebox_override("pressed", _style(_theme_color("accent"), _theme_color("ink")))
		button.add_theme_stylebox_override("disabled", _style(_theme_color("surface").darkened(0.10), _theme_color("accent").lightened(0.20)))
	elif node is PanelContainer:
		(node as PanelContainer).add_theme_stylebox_override("panel", _style(_theme_color("surface"), _theme_color("accent")))
	elif node is LineEdit:
		var edit := node as LineEdit
		edit.add_theme_color_override("font_color", _theme_color("ink"))
		edit.add_theme_color_override("font_placeholder_color", _theme_color("accent"))
		edit.add_theme_stylebox_override("normal", _style(_theme_color("surface"), _theme_color("accent")))
	for child in node.get_children():
		_apply_ui_theme(child)


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
	_set_input_locked(false)
	var should_settle := game.consume_pollution_flashback()
	if should_settle and game.settle_day_if_needed():
		selected_token_id = ""
		selected_meme_id = ""
		selected_reality_tile_id = ""
		feed_shift = 0
		log_text = "黑屏之后，已经是第二天。"
		if not game.event_log.is_empty():
			log_text = "%s\n%s" % [log_text, game.event_log[0]]
	_render()


func _set_flashback_blackout(value: bool) -> void:
	if _flashback_blackout != null:
		_flashback_blackout.visible = value
	if _flashback_noise != null:
		_flashback_noise.modulate.a = 0.16 if value else 1.0


func _scramble_flashback_words(step: int) -> void:
	var viewport_size := Vector2(1280, 720)
	if get_viewport() != null:
		viewport_size = get_viewport().get_visible_rect().size
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
	var body := _label("所有遗产规则都说智者在这里。\n你想说一句普通的话，但每一层都先替你开口。\n\n哈吉米    ■    ……    沉默", 22, _theme_color("muted"))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center.add_child(body)
	var restart := Button.new()
	restart.text = "重开"
	restart.custom_minimum_size.y = 54
	restart.pressed.connect(new_game)
	center.add_child(restart)


func _on_app_pressed(app_id: String) -> void:
	if _input_locked:
		return
	game.set_view_state("phone_down")
	game.set_active_app(app_id)
	log_text = "打开 %s。" % app_id
	_render()


func _on_token_pressed(post_id: String, token: Dictionary) -> void:
	if _input_locked:
		return
	if game.pick_token(post_id, token):
		selected_token_id = "%s-%s-%d" % [post_id, token.get("id", "token"), game.day]
		log_text = "拾取：%s" % token["text"]
		_after_effective_action()
	else:
		log_text = "这个词没有进入笔记本。"
		_render()


func _on_buy_emotion_slot_pressed() -> void:
	if _input_locked:
		return
	var slot := game.get_daily_emotion_slot()
	if game.buy_daily_emotion_slot():
		log_text = "购买情绪槽：%s" % slot.get("label", "情绪")
		_after_effective_action()
	else:
		log_text = "购买失败。"
		_render()


func _on_emotion_text_changed(text: String, slot_id: String) -> void:
	if _input_locked:
		return
	game.set_emotion_slot_text(slot_id, text)
	log_text = "情绪槽文字已改写。"
	_render_status()


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
	if game.confirm_craft_with_emotions():
		selected_meme_id = str(game.completed_memes[0]["id"])
		log_text = "合成新梗：%s" % game.completed_memes[0]["title"]
		_after_effective_action()
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
	if game.confirm_dialogue():
		selected_meme_id = ""
		log_text = "句子发到手机里。热度在塔下回响。"
		_after_effective_action()
	else:
		log_text = "发布空格里还没有完整梗。"
		_render()


func _on_reality_tile_pressed(tile_id: String) -> void:
	if _input_locked:
		return
	selected_reality_tile_id = tile_id
	log_text = "选中现实词块。"
	_render()


func _on_reality_slot_pressed(slot_id: String) -> void:
	if _input_locked:
		return
	if selected_reality_tile_id.is_empty():
		log_text = "先选一个现实词块。"
	else:
		game.place_reality_tile(slot_id, selected_reality_tile_id)
		log_text = "现实句子又多了一块。"
	_render()


func _on_reality_tile_dropped(data: Dictionary, slot_id: String) -> void:
	if _input_locked:
		return
	var tile_id := str(data.get("id", ""))
	if tile_id.is_empty():
		return
	selected_reality_tile_id = tile_id
	game.place_reality_tile(slot_id, tile_id)
	log_text = "词块已拖入现实句子。"
	_render()


func _on_confirm_reality_pressed() -> void:
	if _input_locked:
		return
	if game.confirm_reality_dialogue():
		selected_reality_tile_id = ""
		log_text = "你说：%s" % game.last_polluted_sentence
		_after_effective_action()
	else:
		log_text = "遗产规则还没有全部进入句子。"
		_render()


func _after_effective_action() -> void:
	if game.pollution_flashback_pending:
		_play_pollution_flashback()
		return
	if game.settle_day_if_needed():
		selected_token_id = ""
		selected_meme_id = ""
		selected_reality_tile_id = ""
		feed_shift = 0
		if not game.event_log.is_empty():
			log_text = game.event_log[0]
	_render()


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
	for emotion in game.get_owned_emotion_slot_data():
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


func _reality_slot_text(slot_id: String) -> String:
	if not game.reality_sentence_slots.has(slot_id):
		return "等待词块"
	var tile_id := str(game.reality_sentence_slots[slot_id])
	if tile_id.begins_with("clean:"):
		return tile_id.substr(6)
	if tile_id.begins_with("emotion:"):
		return str(game.emotion_slot_texts.get(tile_id.substr(8), ""))
	if tile_id.begins_with("legacy:"):
		var rule_id := tile_id.substr(7)
		for rule in game.legacy_rules:
			if str(rule.get("id", "")) == rule_id:
				return str(rule.get("required_text", ""))
	return "等待词块"


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


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
