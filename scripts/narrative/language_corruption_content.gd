class_name LanguageCorruptionContent
extends RefCounted

## Authored narrative data only. State changes remain the responsibility of MemeGameState.

const REALITY_DIALOGUES_BY_FLOOR := {
	1: [
		{
			"line_id": "f1_npc0_open",
			"speaker_id": "latecomer",
			"speaker": "迟到者",
			"line": "这张票印的是明天。可车刚走。你能陪我等下一班吗？",
			"result": "迟到者把票折回掌心，往旁边让出半个座位。",
			"subtext": "他怕的不是迟到，而是独自留下。",
			"choices": [
				{"id": "f1n0_wait", "intent": "approach", "summary": "陪他等", "sentence": "我陪你等。下一班来了再看日期。"},
				{"id": "f1n0_time", "intent": "check", "summary": "核对站钟", "sentence": "先看站钟。它停在九点十七分。"},
				{"id": "f1n0_leave", "intent": "refuse", "summary": "沿路离开", "sentence": "我不等了。你要一起沿车辙走吗？"},
			],
		},
		{
			"line_id": "f1_npc1_open",
			"speaker_id": "echo_tenant",
			"speaker": "回声住户",
			"line": "水阀关了，楼上还在滴。你听，门后是不是有人？",
			"result": "住户没去碰门，只把一把小扳手递了过来。",
			"subtext": "他想有人同行，又不敢确认屋里是谁。",
			"choices": [
				{"id": "f1n1_home", "intent": "approach", "summary": "陪他上楼", "sentence": "我陪你上去。先别开门。"},
				{"id": "f1n1_pipe", "intent": "check", "summary": "再关水阀", "sentence": "把扳手给我。我再关一次。"},
				{"id": "f1n1_name", "intent": "check", "summary": "确认名字", "sentence": "等一下。刚才叫的是谁的名字？"},
			],
		},
		{
			"line_id": "f1_npc2_open",
			"speaker_id": "copyist",
			"speaker": "抄写员",
			"line": "第四行被擦过。不是我擦的。你看，橡皮屑还在。",
			"result": "抄写员按住纸角，拇指上沾着同色的灰。",
			"subtext": "他改过记录，却希望纸替他承担责任。",
			"choices": [
				{"id": "f1n2_count", "intent": "approach", "summary": "重新核对", "sentence": "从第一行重数。你念，我记。"},
				{"id": "f1n2_blank", "intent": "check", "summary": "保留空行", "sentence": "第四行先空着。别替它填人。"},
				{"id": "f1n2_stop", "intent": "refuse", "summary": "让他停笔", "sentence": "把笔放下。纸边还有你的指印。"},
			],
		},
		{
			"line_id": "f1_npc3_open",
			"speaker_id": "believer",
			"speaker": "无名信徒",
			"line": "队伍只差一个位置。你站进去，我们就能开始。",
			"result": "信徒朝空位点头，没有看主角一眼。",
			"subtext": "他想躲进群体，也需要别人替他承担被看见。",
			"choices": [
				{"id": "f1n3_sky", "intent": "approach", "summary": "站在队尾", "sentence": "我站边上。先看是谁没来。"},
				{"id": "f1n3_receipt", "intent": "check", "summary": "查看次序纸", "sentence": "这张次序纸是谁写的？"},
				{"id": "f1n3_ground", "intent": "refuse", "summary": "留下空位", "sentence": "我不占那个位置。让它空着。"},
			],
		},
		{
			"line_id": "f1_npc4_open",
			"speaker_id": "post_witness",
			"speaker": "旧帖目击者",
			"line": "我删过三次。这句回复每次都会回来：‘你到了吗？’",
			"result": "目击者熄掉屏幕。那五个字仍映在指甲上。",
			"subtext": "他想证明自己没编造，又不敢独自读下去。",
			"choices": [
				{"id": "f1n4_yes", "intent": "approach", "summary": "承认见过", "sentence": "像是我回的。可我不记得发过。"},
				{"id": "f1n4_no", "intent": "check", "summary": "查看时间", "sentence": "不是我。先看发送时间。"},
				{"id": "f1n4_reply", "intent": "approach", "summary": "留下回复", "sentence": "别删了。回一句‘还没有’。"},
			],
		},
	],
	2: [
		{
			"line_id": "f2_npc0_open",
			"speaker_id": "latecomer",
			"speaker": "迟到者",
			"line": "我想跟司机道歉。可一开口，就是楼下那句。你先听哪句？",
			"result": "迟到者张了张嘴，旧句先替他吸了一口气。",
			"subtext": "他需要有人承认，道歉后面还有自己的理由。",
			"choices": [
				{"id": "f2n0_order", "intent": "approach", "summary": "等他说完", "sentence": "先把旧句说完。我等你自己的话。"},
				{"id": "f2n0_reason", "intent": "check", "summary": "先问迟到", "sentence": "先说为什么迟到。别管它插嘴。"},
				{"id": "f2n0_refuse", "intent": "refuse", "summary": "不再道歉", "sentence": "别道歉了。把票递给他就走。"},
			],
		},
		{
			"line_id": "f2_npc1_open",
			"speaker_id": "echo_tenant",
			"speaker": "回声住户",
			"line": "我问邻居借扳手。他只回楼下那句话。是没听见吗？",
			"result": "住户把耳朵贴在门上，钥匙却插进了自己的锁。",
			"subtext": "他想确认邻居还在，又怕答案只是一句借来的话。",
			"choices": [
				{"id": "f2n1_lock", "intent": "refuse", "summary": "先锁好门", "sentence": "先锁门。今晚别让那句话进来。"},
				{"id": "f2n1_follow", "intent": "check", "summary": "再问一次", "sentence": "我替你问。只问扳手，不提楼下。"},
				{"id": "f2n1_return", "intent": "approach", "summary": "归还旧话", "sentence": "把那句写下来，明早放回楼梯口。"},
			],
		},
		{
			"line_id": "f2_npc2_open",
			"speaker_id": "copyist",
			"speaker": "抄写员",
			"line": "表上写‘已说明’，下面却没有我的话。你听见我说什么了吗？",
			"result": "抄写员把空白转向主角，印章藏进袖口。",
			"subtext": "他需要证人，也害怕证人说出不同版本。",
			"choices": [
				{"id": "f2n2_again", "intent": "approach", "summary": "请他重说", "sentence": "再说一次。慢一点，我听着。"},
				{"id": "f2n2_record", "intent": "check", "summary": "核对笔迹", "sentence": "先看‘已说明’是谁写的。"},
				{"id": "f2n2_stamp", "intent": "refuse", "summary": "不要盖章", "sentence": "别盖。空白至少没有冒充你。"},
			],
		},
		{
			"line_id": "f2_npc3_open",
			"speaker_id": "believer",
			"speaker": "无名信徒",
			"line": "点名时，他们念楼下那句，不念名字。现在轮到你了。",
			"result": "人群齐齐吸气。信徒自己的名字卡在喉咙里。",
			"subtext": "他维护规则，因为规则能遮住自己的声音。",
			"choices": [
				{"id": "f2n3_name", "intent": "refuse", "summary": "只说名字", "sentence": "我只报名字。后面那句不是我。"},
				{"id": "f2n3_legacy", "intent": "approach", "summary": "照例点名", "sentence": "我先念旧句。名字留到最后。"},
				{"id": "f2n3_none", "intent": "refuse", "summary": "保持沉默", "sentence": "这次我不答。你们可以跳过去。"},
			],
		},
	],
	3: [
		{
			"line_id": "f3_npc0_open",
			"speaker_id": "latecomer",
			"speaker": "迟到者",
			"line": "票上只剩‘去’。站名没了。你……还看得懂吗？",
			"result": "迟到者把票举到眼前。‘去’字朝两边同时褪色。",
			"subtext": "他已无法说明目的地，只想有人一起做决定。",
			"choices": [
				{"id": "f3n0_submit", "intent": "approach", "summary": "先上车", "sentence": "去。先上车。"},
				{"id": "f3n0_copy", "intent": "check", "summary": "认出笔迹", "sentence": "这字……像我的。"},
				{"id": "f3n0_window", "intent": "refuse", "summary": "不提交票", "sentence": "不。没有站名。"},
			],
		},
		{
			"line_id": "f3_npc1_open",
			"speaker_id": "echo_tenant",
			"speaker": "回声住户",
			"line": "门牌只剩‘我’。里面有人说，那是他的。",
			"result": "住户试了两把钥匙。门内外同时响了一声。",
			"subtext": "方位和人称一起松动，他不敢再说这是自己的家。",
			"choices": [
				{"id": "f3n1_actual", "intent": "approach", "summary": "试着开门", "sentence": "门。钥匙。先开……"},
				{"id": "f3n1_metaphor", "intent": "check", "summary": "问谁写的", "sentence": "‘我’是谁写的？"},
				{"id": "f3n1_nohome", "intent": "refuse", "summary": "擦掉门牌", "sentence": "擦掉。别留给下一户。"},
			],
		},
		{
			"line_id": "f3_npc2_open",
			"speaker_id": "copyist",
			"speaker": "抄写员",
			"line": "缺失栏……它自己填了你的名字。",
			"result": "抄写员没有碰纸。笔尖仍在一下一下地点。",
			"subtext": "记录终于指向主角，他无法再假装只是文书错误。",
			"choices": [
				{"id": "f3n2_self", "intent": "check", "summary": "先划掉", "sentence": "先划掉。那是我……不，是名字。"},
				{"id": "f3n2_missing", "intent": "refuse", "summary": "保持缺失", "sentence": "空着。让缺失还是缺失。"},
				{"id": "f3n2_drawer", "intent": "approach", "summary": "打开抽屉", "sentence": "抽屉里。有人在呼吸。打开。"},
			],
		},
	],
}

const REALITY_FOLLOWUPS_BY_NPC_INDEX := {
	0: {
		"archetype": "latecomer",
		"turns": [
			{
				"line_id": "late_followup_clock",
				"line": "站钟走了两分钟，票却退回一分钟。你信哪一个？",
				"result": "迟到者把票压在表盘下，只露出那行日期。",
				"choices": [
					{"id": "late_signal_wait", "intent": "approach", "summary": "相信站钟", "sentence": "信站钟。它至少还在往前。"},
					{"id": "late_signal_tower", "intent": "check", "summary": "检查票背", "sentence": "先看票背。有没有改过的墨？"},
					{"id": "late_signal_walk", "intent": "refuse", "summary": "沿车辙走", "sentence": "都不信。我们沿车辙走。"},
				],
			},
			{
				"line_id": "late_followup_stop",
				"line": "车来了。报站器只念旧句。你在哪儿下？",
				"result": "迟到者把手停在铃上，等一句不属于楼下的话。",
				"choices": [
					{"id": "late_stop_today", "intent": "approach", "summary": "等今天的停顿", "sentence": "旧句念完，第一处停顿就下。"},
					{"id": "late_stop_silence", "intent": "check", "summary": "听沉默站点", "sentence": "它不报站的地方。就那里。"},
					{"id": "late_stop_own", "intent": "refuse", "summary": "暂不下车", "sentence": "先不下。等有人自己说地名。"},
				],
			},
		],
		"interrupt": "报站声盖过最后一个字。迟到者说：‘算了，车还没来。’",
	},
	1: {
		"archetype": "echo_tenant",
		"turns": [
			{
				"line_id": "echo_followup_wall",
				"line": "墙里把你刚才的话说了一遍，多了我的门牌。留哪句？",
				"result": "住户拿粉笔圈住多出的门牌，没有念出来。",
				"choices": [
					{"id": "echo_keep_original", "intent": "approach", "summary": "留下原话", "sentence": "留第一遍。那才是我说的。"},
					{"id": "echo_mark_legacy", "intent": "check", "summary": "标出多余处", "sentence": "把多的圈起来。别擦。"},
					{"id": "echo_close_pipe", "intent": "refuse", "summary": "关掉管道", "sentence": "先关阀。今晚不回答墙。"},
				],
			},
			{
				"line_id": "echo_followup_water",
				"line": "水出来了。它叫了我一声，又叫成楼下。你听见了吗？",
				"result": "住户接住一杯水，没敢把杯子带回屋。",
				"choices": [
					{"id": "echo_check_reflection", "intent": "check", "summary": "看杯中倒影", "sentence": "先看倒影。别回答它。"},
					{"id": "echo_try_name", "intent": "approach", "summary": "再叫一次水", "sentence": "我只叫它水。看它回什么。"},
					{"id": "echo_leave_nameless", "intent": "refuse", "summary": "不再命名", "sentence": "别叫了。让它先流走。"},
				],
			},
		],
		"interrupt": "墙里抢着回答。住户拧紧阀门：‘今晚到这里。’",
	},
	2: {
		"archetype": "copyist",
		"turns": [
			{
				"line_id": "copy_followup_source",
				"line": "‘来源’那栏被涂黑了。主管会问。你让我写什么？",
				"result": "抄写员悬着笔，墨在纸上落成一个小圆点。",
				"choices": [
					{"id": "copy_source_now", "intent": "approach", "summary": "填写此刻", "sentence": "写‘刚才’。别补具体时间。"},
					{"id": "copy_refuse_source", "intent": "refuse", "summary": "保持空白", "sentence": "不填。活话不需要出处。"},
					{"id": "copy_mark_pollution", "intent": "check", "summary": "注明被改过", "sentence": "写‘被改过’。别写是谁。"},
				],
			},
			{
				"line_id": "copy_followup_stamp",
				"line": "章盖下去，主语就没了。还盖吗？",
				"result": "抄写员把章翻过来，底面粘着一个很小的‘我’。",
				"choices": [
					{"id": "copy_no_stamp", "intent": "refuse", "summary": "不盖章", "sentence": "不盖。把‘我’放回句首。"},
					{"id": "copy_edge_stamp", "intent": "check", "summary": "盖在纸边", "sentence": "盖边上。别碰那句话。"},
					{"id": "copy_rewrite_rule", "intent": "approach", "summary": "先改说明", "sentence": "先写清楚：章不能删主语。"},
				],
			},
		],
		"interrupt": "盖章机咬住纸角。抄写员断电，没再说‘流程’。",
	},
	3: {
		"archetype": "believer",
		"turns": [
			{
				"line_id": "believer_followup_speaker",
				"line": "喇叭没接线。大家还是听见了。你呢？",
				"result": "信徒等人群先点头，自己最后才轻轻点了一下。",
				"choices": [
					{"id": "believer_crowd", "intent": "approach", "summary": "听见人群", "sentence": "我听见他们互相跟着念。"},
					{"id": "believer_legacy", "intent": "check", "summary": "听见旧句", "sentence": "只听见楼下那句。没有旋律。"},
					{"id": "believer_static", "intent": "refuse", "summary": "只承认杂音", "sentence": "我听见电流。别替它起名。"},
				],
			},
			{
				"line_id": "believer_followup_lead",
				"line": "轮到你领唱。说一句不会逼别人跟着的话。",
				"result": "信徒没有复述，只替下一人留出一口气。",
				"choices": [
					{"id": "believer_question", "intent": "check", "summary": "允许不回答", "sentence": "你可以不回答。"},
					{"id": "believer_names", "intent": "approach", "summary": "归还名字", "sentence": "名字请各自拿回去。"},
					{"id": "believer_pause", "intent": "refuse", "summary": "留下停顿", "sentence": "我说完了。现在不唱。"},
				],
			},
		],
		"interrupt": "人群抢走第一个音。信徒抬手：‘停。让她自己说。’",
	},
	4: {
		"archetype": "post_witness",
		"turns": [
			{
				"line_id": "post_followup_future",
				"line": "帖子写着十年后。下面有人刚回了‘在吗’。点开吗？",
				"result": "目击者把屏幕侧过来，只让主角看见发送时间。",
				"choices": [
					{"id": "post_earliest", "intent": "check", "summary": "看第一条", "sentence": "点最早那条。先看头像。"},
					{"id": "post_unsent", "intent": "approach", "summary": "看未发送的", "sentence": "看草稿。它还没成为回复。"},
					{"id": "post_close", "intent": "refuse", "summary": "关掉页面", "sentence": "先关掉。它在等我们回答。"},
				],
			},
			{
				"line_id": "post_followup_blank",
				"line": "空框问：今天留哪个词？我不想替你选。",
				"result": "目击者松开手机。空框没有自动填字。",
				"choices": [
					{"id": "post_leave_exist", "intent": "approach", "summary": "留下‘在’", "sentence": "留‘在’。只留这一个字。"},
					{"id": "post_leave_signal", "intent": "check", "summary": "留下‘断线’", "sentence": "留‘断线’。免得沉默被误认。"},
					{"id": "post_leave_nothing", "intent": "refuse", "summary": "保持空框", "sentence": "什么都不留。空着也算回答。"},
				],
			},
		],
		"interrupt": "页面开始替主角输入。目击者锁屏：‘这句不算。’",
	},
}

const LANGUAGE_PERSONA_SCENES := [
	{
		"scene_id": "doll_names_lamp",
		"floor": 1,
		"speaker_id": "doll",
		"speaker": "玩偶",
		"line": "你又叫它台灯。它叫小月亮。我们以前说好的。",
		"subtext": "玩偶把共享称呼当作两人关系的凭证。",
	},
	{
		"scene_id": "doll_safe_first",
		"floor": 1,
		"speaker_id": "doll",
		"speaker": "玩偶",
		"line": "我只是想让你留在安全的地方。",
		"subtext": "温柔的保护同时是一项留下来的要求。",
	},
	{
		"scene_id": "doctor_safe_repeat",
		"floor": 2,
		"speaker_id": "doctor",
		"speaker": "医生",
		"line": "我只是想让你留在安全的地方。",
		"subtext": "同一句话被程序化语气接管，来源开始不稳定。",
	},
	{
		"scene_id": "doctor_voice_first",
		"floor": 2,
		"speaker_id": "doctor",
		"speaker": "医生",
		"line": "你不需要再听见那个声音。",
		"subtext": "医生把无法分类的语言当作应当停止的刺激。",
	},
	{
		"scene_id": "doll_voice_repeat",
		"floor": 3,
		"speaker_id": "doll",
		"speaker": "玩偶",
		"line": "你不需要再听见那个声音。",
		"subtext": "玩偶借用医生的句式，试图把医生排除在世界外。",
	},
	{
		"scene_id": "unregistered_safe_residue",
		"floor": 4,
		"speaker_id": "blank",
		"speaker": "",
		"line": "我只是想让你留在安全的地方。",
		"subtext": "说话者消失后，句子仍在决定什么叫安全。",
	},
]

const AUTHORED_CRITICAL_CORRUPTIONS := [
	{
		"corruption_id": "safe_becomes_stable",
		"source_line_id": "doll_safe_first",
		"minimum_pollution": 60,
		"original_speaker": "玩偶",
		"current_speaker": "医生",
		"clean_text": "我只是想让你留在安全的地方。",
		"display_text": "我只是想让你留在{del}安全{/del}{ins}稳定{/ins}的地方。",
	},
	{
		"corruption_id": "voice_becomes_outside",
		"source_line_id": "doctor_voice_first",
		"minimum_pollution": 68,
		"original_speaker": "医生",
		"current_speaker": "玩偶",
		"clean_text": "你不需要再听见那个声音。",
		"display_text": "你不需要再听见{del}那个声音{/del}{ins}外面的声音{/ins}。",
	},
	{
		"corruption_id": "ticket_date_reversal",
		"source_line_id": "f1_npc0_open",
		"minimum_pollution": 35,
		"original_speaker": "迟到者",
		"current_speaker": "迟到者",
		"clean_text": "这张票印的是明天。可车刚走。",
		"display_text": "这张票印的是{del}明天{/del}{ins}昨天{/ins}。可车刚走。",
	},
	{
		"corruption_id": "form_claims_consent",
		"source_line_id": "f2_npc2_open",
		"minimum_pollution": 55,
		"original_speaker": "抄写员",
		"current_speaker": "抄写员",
		"clean_text": "表上写‘已说明’，下面却没有我的话。",
		"display_text": "表上写‘{del}已说明{/del}{ins}已同意{/ins}’，下面却没有我的话。",
	},
	{
		"corruption_id": "missing_name_ownership",
		"source_line_id": "f3_npc2_open",
		"minimum_pollution": 75,
		"original_speaker": "抄写员",
		"current_speaker": "主角",
		"clean_text": "缺失栏……它自己填了你的名字。",
		"display_text": "缺失栏……{del}它{/del}{ins}我{/ins}自己填了你的名字。",
	},
]

const PROTECTED_TEXTS := [
	"我只是想让你留在安全的地方。",
	"你不需要再听见那个声音。",
	"玩偶",
	"医生",
	"主角",
	"语言污染",
	"安全",
	"声音",
	"名字",
	"退出游戏",
	"返回",
	"仍然退出",
]

const PROTECTED_PUNCTUATION := [
	"，", "。", "！", "？", "；", "：", "、", "……", "…",
	",", ".", "!", "?", ";", ":", "‘", "’", "“", "”", "（", "）", "(", ")",
]

const PLAYER_CHOICE_FRAGMENTS_BY_FLOOR := {
	1: [
		{"intent": "approach", "revision_stage": 0, "display_text": "我先陪你。", "tiles": ["我", "先", "陪你"]},
		{"intent": "check", "revision_stage": 0, "display_text": "等一下，让我确认。", "tiles": ["等一下", "让我", "确认"]},
		{"intent": "refuse", "revision_stage": 0, "display_text": "不了。我先走。", "tiles": ["不了", "我", "先走"]},
	],
	2: [
		{"intent": "approach", "revision_stage": 1, "display_text": "我先……陪你。", "tiles": ["我先……", "陪你"]},
		{"intent": "check", "revision_stage": 1, "display_text": "等一下，是谁在说？", "tiles": ["等一下", "谁", "在说"]},
		{"intent": "refuse", "revision_stage": 1, "display_text": "不是。我没有答应。", "tiles": ["不是", "我没有", "答应"]},
	],
	3: [
		{"intent": "approach", "revision_stage": 2, "display_text": "我 / 先……", "tiles": ["我", "先……"]},
		{"intent": "check", "revision_stage": 2, "display_text": "谁 / 在说", "tiles": ["谁", "在说"]},
		{"intent": "refuse", "revision_stage": 2, "display_text": "不 / ……", "tiles": ["不", "……"]},
	],
}

const HISTORY_REVISIONS := [
	{
		"lineId": "history_doll_safe_original",
		"originalSpeaker": "玩偶",
		"currentSpeaker": "玩偶",
		"originalText": "我只是想让你留在安全的地方。",
		"displayText": "我只是想让你留在安全的地方。",
		"revisionStage": 0,
		"revisionMarkup": "none",
	},
	{
		"lineId": "history_doctor_safe_revision",
		"originalSpeaker": "玩偶",
		"currentSpeaker": "医生",
		"originalText": "我只是想让你留在安全的地方。",
		"displayText": "我只是想让你留在{del}安全{/del}{ins}稳定{/ins}的地方。",
		"revisionStage": 1,
		"revisionMarkup": "replace",
	},
	{
		"lineId": "history_doctor_voice_original",
		"originalSpeaker": "医生",
		"currentSpeaker": "医生",
		"originalText": "你不需要再听见那个声音。",
		"displayText": "你不需要再听见那个声音。",
		"revisionStage": 0,
		"revisionMarkup": "none",
	},
	{
		"lineId": "history_doll_voice_revision",
		"originalSpeaker": "医生",
		"currentSpeaker": "玩偶",
		"originalText": "你不需要再听见那个声音。",
		"displayText": "你不需要再听见{del}那个声音{/del}{ins}外面的声音{/ins}。",
		"revisionStage": 2,
		"revisionMarkup": "replace",
	},
	{
		"lineId": "history_unregistered_safe",
		"originalSpeaker": "玩偶",
		"currentSpeaker": "",
		"originalText": "我只是想让你留在安全的地方。",
		"displayText": "我只是想让你留在安全的地方。",
		"revisionStage": 3,
		"revisionMarkup": "speaker_shift",
	},
]

const FLOOR_CARDS := {
	1: {"区域": "被保存的儿童房", "危险": "B", "提示": "《游戏与现实》"},
	2: {"区域": "两次醒来之间", "危险": "A", "提示": "《梦的解析》"},
	3: {"区域": "没有说完的地方", "危险": "A", "提示": "《自我与本我》"},
	4: {"区域": "未记录", "危险": "S", "提示": "《超越快乐原则》"},
}

const FLOOR_CARD_DISPLAY_VARIANTS := {
	1: {"区域": "被保存的儿童□", "危险": "B", "提示": "《游戏与现实》"},
	2: {"区域": "两次醒来之□", "危险": "A", "提示": "《梦的解□》"},
	3: {"区域": "没□说完的地□□", "危险": "A", "提示": "《自□与本我》"},
	4: {"区域": "未□□录", "危险": "S", "提示": "《超□□乐原□》"},
}

const MENU_LABEL_VARIANTS := {
	"save": {"function_id": "save", "stages": ["保存", "保 存", "留下"]},
	"autoplay": {"function_id": "autoplay", "stages": ["自动播放", "替你播放", "不用开口"]},
	"history": {"function_id": "history", "stages": ["历史记录", "已经说过", "不是你说的"]},
	"settings": {"function_id": "settings", "stages": ["设置", "修正", "恢复正常"]},
}


static func get_dialogues_for_floor(floor_number: int) -> Array:
	var entries: Array = REALITY_DIALOGUES_BY_FLOOR.get(floor_number, [])
	return entries.duplicate(true)


static func get_followups_for_archetype(archetype_index: int) -> Dictionary:
	var entry: Dictionary = REALITY_FOLLOWUPS_BY_NPC_INDEX.get(archetype_index, {})
	return entry.duplicate(true)


static func get_language_persona_scenes() -> Array:
	return LANGUAGE_PERSONA_SCENES.duplicate(true)


static func get_authored_critical_corruptions() -> Array:
	return AUTHORED_CRITICAL_CORRUPTIONS.duplicate(true)


static func get_protected_texts() -> Array:
	return PROTECTED_TEXTS.duplicate()


static func get_protected_punctuation() -> Array:
	return PROTECTED_PUNCTUATION.duplicate()


static func get_player_choice_fragments_for_floor(floor_number: int) -> Array:
	var entries: Array = PLAYER_CHOICE_FRAGMENTS_BY_FLOOR.get(floor_number, [])
	return entries.duplicate(true)


static func get_history_revisions() -> Array:
	return HISTORY_REVISIONS.duplicate(true)


static func get_floor_card(floor_number: int) -> Dictionary:
	var card: Dictionary = FLOOR_CARDS.get(floor_number, {})
	return card.duplicate(true)


static func get_floor_card_display(floor_number: int) -> Dictionary:
	var card: Dictionary = FLOOR_CARD_DISPLAY_VARIANTS.get(floor_number, FLOOR_CARDS.get(floor_number, {}))
	return card.duplicate(true)


static func get_menu_label_variants() -> Dictionary:
	return MENU_LABEL_VARIANTS.duplicate(true)


static func get_all_choice_ids() -> Array[String]:
	var ids: Array[String] = []
	for floor_number in [1, 2, 3]:
		for dialogue: Dictionary in get_dialogues_for_floor(floor_number):
			for choice: Dictionary in dialogue.get("choices", []):
				ids.append(str(choice.get("id", "")))
	for archetype_index in range(5):
		var followup: Dictionary = get_followups_for_archetype(archetype_index)
		for turn: Dictionary in followup.get("turns", []):
			for choice: Dictionary in turn.get("choices", []):
				ids.append(str(choice.get("id", "")))
	return ids


static func get_catalog_snapshot() -> Dictionary:
	return {
		"dialogues": REALITY_DIALOGUES_BY_FLOOR.duplicate(true),
		"followups": REALITY_FOLLOWUPS_BY_NPC_INDEX.duplicate(true),
		"persona_scenes": LANGUAGE_PERSONA_SCENES.duplicate(true),
		"critical_corruptions": AUTHORED_CRITICAL_CORRUPTIONS.duplicate(true),
		"protected_texts": PROTECTED_TEXTS.duplicate(),
		"protected_punctuation": PROTECTED_PUNCTUATION.duplicate(),
		"choice_fragments": PLAYER_CHOICE_FRAGMENTS_BY_FLOOR.duplicate(true),
		"history_revisions": HISTORY_REVISIONS.duplicate(true),
		"floor_cards": FLOOR_CARDS.duplicate(true),
		"floor_card_display_variants": FLOOR_CARD_DISPLAY_VARIANTS.duplicate(true),
		"menu_labels": MENU_LABEL_VARIANTS.duplicate(true),
	}
