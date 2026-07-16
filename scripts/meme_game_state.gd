class_name MemeGameState
extends RefCounted

const GameLocaleScript = preload("res://scripts/localization/game_locale.gd")
const MAX_TOWER_FLOOR := 5
const TOWER_THRESHOLDS := [0, 144, 256, 376, 480, 600]
const MAX_THRESHOLD_DISCOUNT := 280
const POLLUTION_LOCK_THRESHOLD := 70
const POLLUTION_FLASHBACK_THRESHOLD := 60
const BASE_ACTIONS_PER_DAY := 5
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
		"id": "single_glyph",
		"label": "独字成句",
		"description": "发布一个只含 1 个语言单位的基础梗",
		"rule": "unit_count",
		"threshold": 1,
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

const MEME_FRAME_PRICE := 7
const MEME_FRAME_OFFER_INTERVAL := 3
const NPC_MEME_FRAME_REWARD_CHANCE_PERCENT := 45
const NPC_MEME_FRAME_REWARD_PITY_LIMIT := 3
const ASCENT_REWARDS := [
	{"id": "star", "tarot_id": "star", "numeral": "XVII", "label": "星星", "description": "命中至少 2 个风向时，整数倍率额外 +1。", "effect": "trend_multiplier_bonus", "value": 1.0},
	{"id": "sun", "tarot_id": "sun", "numeral": "XIX", "label": "太阳", "description": "每次发布获得额外 14 点传播基础。", "effect": "publish_base", "value": 14.0},
	{"id": "moon", "tarot_id": "moon", "numeral": "XVIII", "label": "月亮", "description": "污染达到 40% 时，传播基础 +16。", "effect": "pollution_base", "value": 16.0},
	{"id": "hermit", "tarot_id": "hermit", "numeral": "IX", "label": "隐者", "description": "第一次复用相同表达不触发衰减。", "effect": "repeat_grace", "value": 1.0},
	{"id": "tower", "tarot_id": "tower", "numeral": "XVI", "label": "高塔", "description": "融合梗的整数倍率额外 +1。", "effect": "fusion_multiplier_bonus", "value": 1.0},
	{"id": "hanged", "tarot_id": "hanged", "numeral": "XII", "label": "倒吊人", "description": "每条遗产造成的隐性交流损耗减少 4。", "effect": "legacy_relief", "value": 4.0},
	{"id": "judgement", "tarot_id": "judgement", "numeral": "XX", "label": "审判", "description": "今日牌型成立时再获得 18 点传播基础。", "effect": "contract_base", "value": 18.0},
]
const TAROT_COMBOS := [
	{"id": "day_and_night", "label": "不分昼夜", "requires": ["star", "sun", "moon"], "description": "每天多 1 次行动。", "effect": "max_actions_bonus", "value": 1},
	{"id": "falling_tower", "label": "星坠高塔", "requires": ["star", "tower"], "description": "融合梗的整数倍率再 +1。", "effect": "fusion_multiplier_bonus", "value": 1},
	{"id": "lunar_solitude", "label": "月下隐者", "requires": ["moon", "hermit"], "description": "额外忽略 1 次复读衰减。", "effect": "repeat_grace", "value": 1},
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
const REALITY_DIALOGUES_BY_FLOOR := {
	1: [
		{"line": "你也在等那班已经经过、但谁都没看见的车吗？", "result": "迟到者看了一眼空荡荡的站牌，像是在替它保守秘密。", "choices": [
			{"id": "f1n0_wait", "summary": "一起等", "sentence": "我没有看见那班车，但我可以陪你再等一会儿。"},
			{"id": "f1n0_time", "summary": "核对时间", "sentence": "站牌上的时间没有变，也许车还没有真正经过。"},
			{"id": "f1n0_leave", "summary": "先离开", "sentence": "如果下一班也没有声音，我们就沿着路走回去。"},
		]},
		{"line": "楼上的水管昨晚喊了我的名字。你住哪一户？", "result": "回声住户把钥匙攥紧了一点，管道在墙里轻轻敲了三下。", "choices": [
			{"id": "f1n1_home", "summary": "说出住处", "sentence": "我住在路尽头那扇总是关不严的门后面。"},
			{"id": "f1n1_pipe", "summary": "问水管", "sentence": "也许水管只是记住了你每天回家的脚步声。"},
			{"id": "f1n1_name", "summary": "确认名字", "sentence": "它喊的是你的名字，还是住在这里的每一个名字？"},
		]},
		{"line": "我把门牌抄了三遍，每一遍都少一个人。你能替我数吗？", "result": "抄写员没有递出纸，只把空着的第四行折进掌心。", "choices": [
			{"id": "f1n2_count", "summary": "重新数", "sentence": "我们从第一扇门开始，名字和门牌分开数。"},
			{"id": "f1n2_blank", "summary": "保留空行", "sentence": "少掉的人也许需要一个空位置，而不是另一个名字。"},
			{"id": "f1n2_stop", "summary": "停止抄写", "sentence": "先别写第四遍，纸可能正在学习怎样删掉人。"},
		]},
		{"line": "你刚才抬头了吗？塔上掉下来一片像收据的云。", "result": "无名信徒把那片不存在的纸塞进口袋，动作十分熟练。", "choices": [
			{"id": "f1n3_sky", "summary": "描述天空", "sentence": "我只看见绿色的天，云上没有价格，也没有日期。"},
			{"id": "f1n3_receipt", "summary": "索要收据", "sentence": "如果它真是收据，上面应该写着是谁买下了这座塔。"},
			{"id": "f1n3_ground", "summary": "看着地面", "sentence": "我没有抬头，我怕地面趁机换掉回去的方向。"},
		]},
		{"line": "我在十年前的帖子里看见今天的你。那是你吗？", "result": "旧帖目击者没有展示截图，屏幕却自行亮了一瞬。", "choices": [
			{"id": "f1n4_yes", "summary": "承认", "sentence": "如果照片里的我正在等今天，那个人也可以算是我。"},
			{"id": "f1n4_no", "summary": "否认", "sentence": "十年前我不在这里，帖子也不该记得我的脸。"},
			{"id": "f1n4_reply", "summary": "留下回复", "sentence": "请替我回复一句，让过去不要继续往前翻页。"},
		]},
	],
	2: [
		{"line": "先说上一层留下的那句话，再告诉我你为什么迟到。顺序不能反。", "result": "迟到者认真听完规定的部分，剩下的话被风带到很远。", "choices": [
			{"id": "f2n0_order", "summary": "照顺序说", "sentence": "我会先念完遗产，然后说明路口为什么没有放我过去。"},
			{"id": "f2n0_reason", "summary": "先说理由", "sentence": "我迟到是因为那条路反复把我送回同一块路牌。"},
			{"id": "f2n0_refuse", "summary": "拒绝顺序", "sentence": "如果原因只能排在旧话后面，它就不再是我的原因。"},
		]},
		{"line": "这层每户都要保管一句旧话。我家的那句半夜会自己换位置。", "result": "回声住户点了点头，像是刚完成一次例行点名。", "choices": [
			{"id": "f2n1_lock", "summary": "锁住它", "sentence": "把那句话写在门背后，也许它就找不到新的房间。"},
			{"id": "f2n1_follow", "summary": "记录移动", "sentence": "今晚记下它每次换位置的时间，不要改动其中的字。"},
			{"id": "f2n1_return", "summary": "送回楼下", "sentence": "旧话来自上一层，我们可以沿楼梯把它送回原处。"},
		]},
		{"line": "登记表说你已经回答过了。可我这里还是空白。", "result": "抄写员在空白处盖章，印泥发出一声很轻的叹息。", "choices": [
			{"id": "f2n2_again", "summary": "再回答", "sentence": "我可以再说一次，但请保留这次说话留下的空白。"},
			{"id": "f2n2_record", "summary": "质疑记录", "sentence": "表格记住的是动作，不一定记住了我真正说过什么。"},
			{"id": "f2n2_stamp", "summary": "请求盖章", "sentence": "请先证明这里曾经空着，再把我的句子写进去。"},
		]},
		{"line": "我们不再问你叫什么。我们只核对你携带了哪一句遗产。", "result": "无名信徒在听见遗产时微笑，在听见其余内容时闭上眼睛。", "choices": [
			{"id": "f2n3_name", "summary": "坚持名字", "sentence": "遗产跟着我，但我的名字仍然应该先于它出现。"},
			{"id": "f2n3_legacy", "summary": "出示遗产", "sentence": "我带着上一层最响的句子，它比我更容易被认出来。"},
			{"id": "f2n3_none", "summary": "声称空手", "sentence": "我想试着什么都不携带，只用今天剩下的词站在这里。"},
		]},
	],
	3: [
		{"line": "请提交一句未被使用过的自己。重复部分将退回上一窗口。", "result": "迟到者撕下回执，纸的背面印着同一张回执。", "choices": [
			{"id": "f3n0_submit", "summary": "提交原句", "sentence": "这句话只在现在出现，请不要替它补上以前的编号。"},
			{"id": "f3n0_copy", "summary": "承认重复", "sentence": "我借用了旧句子的结构，但其中的犹豫是今天才有的。"},
			{"id": "f3n0_window", "summary": "寻找窗口", "sentence": "上一窗口已经封死，我只能把退件留在这里。"},
		]},
		{"line": "你所在的住处已被归类为比喻。实体住址需要另行申请。", "result": "回声住户把申请表对折，折痕恰好穿过自己的地址。", "choices": [
			{"id": "f3n1_actual", "summary": "申报实体", "sentence": "我的房间有墙和门，也有一盏会在凌晨熄灭的灯。"},
			{"id": "f3n1_metaphor", "summary": "接受比喻", "sentence": "如果住处只是比喻，请注明我究竟被比作了什么。"},
			{"id": "f3n1_nohome", "summary": "撤销地址", "sentence": "取消我的地址吧，这样回去的时候就不会再次走错。"},
		]},
		{"line": "缺失人员栏不能留空。请填写一个仍然存在的人。", "result": "抄写员将答案归档，抽屉里传来某个人翻身的声音。", "choices": [
			{"id": "f3n2_self", "summary": "填写自己", "sentence": "先写我的名字，至少此刻我还站在表格外面。"},
			{"id": "f3n2_missing", "summary": "保留缺失", "sentence": "缺失不是空白，它是一个人离开后留下的准确形状。"},
			{"id": "f3n2_drawer", "summary": "询问抽屉", "sentence": "请打开抽屉，里面的人也许知道自己是否仍然存在。"},
		]},
	],
	4: [
		{"line": "我们唱到你的名字时，请不要回答。回答会破坏和声。", "result": "合唱没有停下，只在主角应该出现的位置稍微变调。", "choices": [
			{"id": "f4n0_silence", "summary": "保持沉默", "sentence": "我会让名字从我身边经过，不把它认领回来。"},
			{"id": "f4n0_answer", "summary": "打断合唱", "sentence": "那是我的名字，它不该只作为你们旋律里的一个音。"},
			{"id": "f4n0_hum", "summary": "轻声跟唱", "sentence": "我只跟着最后一个音，不唱名字，也不唱塔。"},
		]},
		{"line": "圣歌需要一个空位。大家一致认为那个位置很像你。", "result": "无名信徒向旁边挪开半步，空位却仍然跟着主角。", "choices": [
			{"id": "f4n1_enter", "summary": "站进空位", "sentence": "我可以站在那里，但不会把沉默假装成赞同。"},
			{"id": "f4n1_decline", "summary": "拒绝位置", "sentence": "像我不等于属于我，请把那个位置继续空着。"},
			{"id": "f4n1_ask", "summary": "询问缺席者", "sentence": "这个空位原来属于谁，你们为什么不再唱那个人？"},
		]},
	],
	5: [
		{"line": "你 / 还 / 把 / 自己 / 带着吗", "result": "迟到者的嘴唇动了五次，只有斜线抵达空气。", "choices": [
			{"id": "f5n0_here", "summary": "仍在这里", "sentence": "我还在这里，只是句子比我先到了一步。"},
			{"id": "f5n0_lost", "summary": "遗失一部分", "sentence": "有一部分留在楼下，正在替我继续回答问题。"},
			{"id": "f5n0_count", "summary": "逐字确认", "sentence": "我会一个字一个字地数，数到停下的地方就是我。"},
		]},
		{"line": "窗 / 外 / 有 / 一只 / 没有过去的鸟", "result": "旧帖目击者望向窗外。那里没有窗，鸟仍然飞过了一次。", "choices": [
			{"id": "f5n1_bird", "summary": "描述那只鸟", "sentence": "它没有向前飞，只让身后的世界不断离开。"},
			{"id": "f5n1_window", "summary": "寻找窗户", "sentence": "先找到窗户吧，不然我们不知道外面究竟属于哪里。"},
			{"id": "f5n1_signal", "summary": "发送信号", "sentence": "如果它没有过去，就让这句话追上它，替我们问候一次。"},
		]},
	],
}
const REALITY_FOLLOWUPS_BY_NPC_INDEX := {
	0: {
		"turns": [
			{"line": "站牌忽然显示“无信号”。可这条街从来没有接入过线路。你还要等吗？", "result": "迟到者把手机举向塔影，屏幕上的叉号短暂变成一扇门。", "choices": [
				{"id": "late_signal_wait", "summary": "继续等候", "sentence": "再等一班吧；没有线路，不等于没有人正试着抵达。"},
				{"id": "late_signal_tower", "summary": "追查塔影", "sentence": "信号也许不是从天上消失，而是被塔一层层收走了。"},
				{"id": "late_signal_walk", "summary": "沿路步行", "sentence": "我们顺着遗产标记走，看看旧句子把终点改到了哪里。"},
			]},
			{"line": "车终于来了。报站器只念上一层留下的梗，不再念地名。你在哪里下车？", "result": "迟到者在没有地名的一站按铃。车门打开，塔的影子没有跟下来。", "choices": [
				{"id": "late_stop_today", "summary": "遗产之后", "sentence": "等它念完遗产，我要在第一个属于今天的停顿下车。"},
				{"id": "late_stop_silence", "summary": "沉默站点", "sentence": "没有报站声的地方就是我的站，至少那里还没有被命名。"},
				{"id": "late_stop_own", "summary": "留在车上", "sentence": "我先不下车，直到有人用自己的话说出一个方向。"},
			]},
		],
		"interrupt": "报站声被污染成连续的旧梗。迟到者捂住听筒，车还没有来，谈话先驶远了。",
	},
	1: {
		"turns": [
			{"line": "墙里的回声开始替我们回答，而且每次都比原话多一句遗产。要把哪一句留下？", "result": "回声住户贴近墙面，听见自己的声音从更高一层缓慢返回。", "choices": [
				{"id": "echo_keep_original", "summary": "留下原话", "sentence": "只留下我们刚才说的句子，遗产可以经过，但不要冒充回声。"},
				{"id": "echo_mark_legacy", "summary": "标记遗产", "sentence": "把多出来的旧话标上楼层，让它不能假装今天才出生。"},
				{"id": "echo_close_pipe", "summary": "关闭管道", "sentence": "先关掉这段管道，沉默也比被替写的回答更诚实。"},
			]},
			{"line": "水龙头流出一串陌生口音。住户说这就是语言污染的味道。你怎么确认还是水？", "result": "回声住户接住一滴无声的水。它没有复述任何人，钥匙终于松开。", "choices": [
				{"id": "echo_check_reflection", "summary": "观察倒影", "sentence": "如果倒影还会被波纹打断，它至少没有完全变成一句口号。"},
				{"id": "echo_try_name", "summary": "尝试命名", "sentence": "先叫它水一次；如果它立刻要求复读，我们就换一个杯子。"},
				{"id": "echo_leave_nameless", "summary": "保持无名", "sentence": "不急着命名，让它在语言找到之前先作为液体留下。"},
			]},
		],
		"interrupt": "管道抢先说完所有答案。回声住户关上阀门，墙里仍有人继续这场谈话。",
	},
	2: {
		"turns": [
			{"line": "档案柜要求给你的每句话填写“遗产来源”。原创一栏已经被涂黑。你填什么？", "result": "抄写员把表格转过来，背面密密麻麻都是尚未发生的引用。", "choices": [
				{"id": "copy_source_now", "summary": "填写此刻", "sentence": "来源写此刻；这句话也许借过词，但犹豫是我自己的。"},
				{"id": "copy_refuse_source", "summary": "拒绝来源", "sentence": "我不替活着的话伪造祖先，请把这一栏保持空白。"},
				{"id": "copy_mark_pollution", "summary": "登记污染", "sentence": "标注语言污染；相似不一定是继承，也可能是感染。"},
			]},
			{"line": "盖章机说，未被塔收录的句子不算存在。抄写员把印章递给你。", "result": "抄写员收回没有落下的印章，把你的句子夹进两页制度之间。", "choices": [
				{"id": "copy_no_stamp", "summary": "不盖印章", "sentence": "存在不该由塔批准；让这句话带着空白离开档案。"},
				{"id": "copy_edge_stamp", "summary": "盖在边缘", "sentence": "只盖在纸的边缘，证明制度碰过它，却没有拥有它。"},
				{"id": "copy_rewrite_rule", "summary": "改写条款", "sentence": "先把条款改成“说出即存在”，再决定是否需要印章。"},
			]},
		],
		"interrupt": "盖章机吞掉了句子的主语。抄写员拉下断电杆，本次登记以空白中止。",
	},
	3: {
		"turns": [
			{"line": "塔里的发射机没有接线，信徒却说每晚都能收到圣歌。你认为声音从哪里来？", "result": "无名信徒仰头辨认那段旋律，塔窗一层接一层地亮错顺序。", "choices": [
				{"id": "believer_crowd", "summary": "来自人群", "sentence": "也许是人群在塔下互相复述，最后忘了第一句话属于谁。"},
				{"id": "believer_legacy", "summary": "来自遗产", "sentence": "遗产梗会自己寻找嗓子，圣歌只是它们同时借到人的时刻。"},
				{"id": "believer_static", "summary": "来自静电", "sentence": "没有信号时，静电也会被当成启示；先别急着跪下。"},
			]},
			{"line": "信徒请你献出一句不会污染别人的话，作为进入上层的圣歌。", "result": "无名信徒没有唱你的句子，只把它安静地留在门外。塔门第一次自己开了。", "choices": [
				{"id": "believer_question", "summary": "保留疑问", "sentence": "我只能献出一个问题：我们是否允许别人不回答。"},
				{"id": "believer_names", "summary": "归还名字", "sentence": "把每个人的名字还给本人，不把它们编进共同的副歌。"},
				{"id": "believer_pause", "summary": "献出停顿", "sentence": "我献出一句话结束后的停顿，让下一人有地方开口。"},
			]},
		],
		"interrupt": "圣歌突然只剩同一个梗。无名信徒停止合唱，塔门在污染扩散前合上。",
	},
	4: {
		"turns": [
			{"line": "旧帖显示这里“信号满格”，可所有回复都写着十年后发送。你要点开哪一条？", "result": "旧帖目击者滑动屏幕，日期栏像坏掉的电梯一样上下跳动。", "choices": [
				{"id": "post_earliest", "summary": "最早回复", "sentence": "打开最早的一条，看看是谁先把未来误认成了遗产。"},
				{"id": "post_unsent", "summary": "未发回复", "sentence": "打开那条尚未发送的，也许它还来得及换一种说法。"},
				{"id": "post_close", "summary": "关闭帖子", "sentence": "先关掉帖子；无信号时，时间不该假装自己已经上传。"},
			]},
			{"line": "最后一条回复只有一个梗框，里面空着。帖子问：要把今天的哪个词留给过去？", "result": "旧帖目击者没有截屏。空框自行保存，又把今天完整地退还给你。", "choices": [
				{"id": "post_leave_exist", "summary": "留下存在", "sentence": "留下“存在”；过去需要知道我们没有只活成引用。"},
				{"id": "post_leave_signal", "summary": "留下无信号", "sentence": "留下“无信号”；让未来明白沉默也可能是线路断了。"},
				{"id": "post_leave_nothing", "summary": "什么不留", "sentence": "什么都不留；过去不该提前继承我们尚未说完的话。"},
			]},
		],
		"interrupt": "帖子开始自动复制你尚未说出的词。旧帖目击者拔掉电源，屏幕仍亮在中断处。",
	},
}
const MERCHANT_DIALOGUES_BY_FLOOR := {
	1: {"line": "我卖的是能装住一个字的空框。字会漏出来，框不会。", "result": "信号商人敲了敲柜台，空框发出比内容更清楚的声音。"},
	2: {"line": "本层交易必须附上一句遗产。价格不会因此减少。", "result": "信号商人收走了声音，没有说明它被记在哪一本账里。"},
	3: {"line": "请确认购买者与说话者为同一实体。无法确认也可以签字。", "result": "信号商人把签名盖在照片上，照片里的人没有动。"},
	4: {"line": "交换也是圣歌。你给出一句，我归还一个更响的空位。", "result": "信号商人低声唱出价格，数字在最后一个音里消失。"},
	5: {"line": "买 / 卖 / 留下 / 哪一个", "result": "信号商人伸出空手。主角无法判断交易是否已经发生。"},
}
const MERCHANT_CHOICES_BY_FLOOR := {
	1: [
		{"id": "trade", "summary": "询问梗框", "sentence": "我想要一个只装一个字的框，它不需要替我解释。"},
		{"id": "ask_empty", "summary": "询问空框", "sentence": "空框为什么比装进去的字更容易被人记住？"},
		{"id": "leave", "summary": "暂不交易", "sentence": "我先保留手里的字，等它愿意进入一个边界。"},
	],
	2: [
		{"id": "trade", "summary": "按遗产交易", "sentence": "我会带上旧句子，但梗框里只放今天拾到的字。"},
		{"id": "ask_price", "summary": "质疑价格", "sentence": "遗产已经替我说过一次，为什么还要支付第二次价格？"},
		{"id": "leave", "summary": "拒绝附言", "sentence": "不能不带旧话交易的话，我就让这次交易保持空白。"},
	],
	3: [
		{"id": "trade", "summary": "签字购买", "sentence": "购买者和说话者暂时是同一个人，我愿意在这里签字。"},
		{"id": "ask_form", "summary": "索要表格", "sentence": "请给我一份没有预填答案的申请表。"},
		{"id": "leave", "summary": "撤回申请", "sentence": "如果签名会替我继续说话，我撤回这次购买。"},
	],
	4: [
		{"id": "trade", "summary": "加入交换", "sentence": "我给出一句没有旋律的话，只换一个安静的梗框。"},
		{"id": "ask_song", "summary": "询问价格歌", "sentence": "价格唱完以后消失了，我该把钱交给哪个音？"},
		{"id": "leave", "summary": "退出合唱", "sentence": "我不想让交易变成副歌，今天先不买。"},
	],
	5: [
		{"id": "trade", "summary": "买", "sentence": "我 / 买 / 一个 / 空框。"},
		{"id": "ask_hand", "summary": "看空手", "sentence": "你 / 手里 / 已经 / 有 / 我的东西吗。"},
		{"id": "leave", "summary": "留下", "sentence": "字 / 留下 / 我 / 走。"},
	],
}
const REALITY_CORRUPTION_GLYPHS := ["■", "▦", "∴", "//", "哈", "吉", "米", "空位"]
const COMMUNICATION_ITEMS := {
	"silence_patch": {
		"id": "silence_patch", "label": "静音贴", "price": 6, "charges": 2, "clarity_bonus": 18,
		"description": "现实句子严重失真时，临时压低 18% 的污染噪声。",
	},
	"semantic_anchor": {
		"id": "semantic_anchor", "label": "语义锚", "price": 9, "charges": 3, "clarity_bonus": 14,
		"description": "现实句子严重失真时，临时压低 14% 的污染噪声。",
	},
	"dictionary_leaf": {
		"id": "dictionary_leaf", "label": "旧词典页", "price": 12, "charges": 1, "clarity_bonus": 32,
		"description": "仅能使用一次，但会压低 32% 的污染噪声。",
	},
}
const COMMUNICATION_ITEM_ROTATION := ["silence_patch", "semantic_anchor", "dictionary_leaf"]
const ENDING_LANGUAGE_CHOICES := [
	{"id": "blank", "label": "空白", "output": "（空白）"},
	{"id": "blocks", "label": "■■■■", "output": "■ ■ ■ ■"},
	{"id": "hajimi", "label": "哈吉米", "output": "哈吉米"},
	{"id": "silence", "label": "沉默", "output": "……"},
]
const PROLOGUE_LINES := [
	"（先确认一件事。你手里拿着什么？）",
	"一部没有信号的手机。它在我醒来以前就亮着。",
	"（你在等谁的消息？）",
	"不。我在等路面停止向后移动。它每退一步，塔就多出一层。",
	"城市广播说今天一切正常。广播重复了七次，正常因此变成一个可疑的词。",
	"（从哪里开始？）",
	"从一个字开始。先让它进入框里，再看它会把谁赶出去。",
]
const EPILOGUE_LINES := [
	"所有遗产规则都说智者住在这里。这里没有智者。",
	"塔顶只有一台没有接线的发射机。指示灯按照你的呼吸闪烁。",
	"（它在发送什么？）",
	"你把耳朵贴近外壳。里面传来整座城市的声音，每个人都在准确重复别人。",
	"你想说一句普通的话。每一层却先替你开口。",
]
const SAVE_DATA_VERSION := 1
const SAVE_FIELD_NAMES := [
	"day", "heat", "pollution", "clarity", "tower_floor", "threshold_discount", "next_threshold",
	"ending_unlocked", "ending_language_choice", "money", "actions_remaining", "max_actions_per_day",
	"needs_day_settlement", "day_ended_reason", "pollution_flashback_seen", "pollution_flashback_pending",
	"view_state", "phone_visible", "phone_open", "active_app", "active_app_window",
	"notebook_tokens", "draft_slots", "completed_memes", "owned_meme_frames", "daily_meme_frame_bought",
	"fusion_slots", "fused_meme_pairs", "dialogue_blanks", "published_memes", "last_publish_breakdown",
	"event_log", "social_followed_handles", "social_liked_post_ids", "collected_world_item_ids",
	"pending_world_item_effects", "permanent_modifiers", "owned_tarot_ids", "pending_ascent_reward_choices",
	"pending_ascent_reward_floor", "queued_ascent_reward_floors", "rewarded_ascent_floors",
	"reality_sentence_slots", "legacy_rules", "last_clean_sentence", "last_polluted_sentence",
	"npc_understanding", "reality_phase", "relationship_residue", "last_relationship_residue_gain",
	"last_relationship_money_loss", "reality_dialogue_count", "owned_communication_items",
	"daily_communication_item_bought", "last_communication_item_used", "last_communication_item_remaining",
	"npc_meme_frame_reward_pity", "npc_meme_frame_reward_attempt_keys", "last_npc_meme_frame_reward",
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
var owned_meme_frames: int = 0
var daily_meme_frame_bought: bool = false
var fusion_slots: Dictionary = {}
var fused_meme_pairs: Array[String] = []
var dialogue_blanks: Dictionary = {}
var published_memes: Array = []
var last_publish_breakdown: Dictionary = {}
var event_log: Array[String] = []
var social_followed_handles: Array[String] = []
var social_liked_post_ids: Array[String] = []

var collected_world_item_ids: Array[String] = []
var pending_world_item_effects: Dictionary = {}

var permanent_modifiers: Array = []
var owned_tarot_ids: Array[String] = []
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
var conversation_prompt: String = ""
var conversation_result_line: String = ""
var conversation_choices: Array = []
var conversation_selected_choice_id: String = ""
var conversation_clean_sentence: String = ""
var conversation_revealed_units: Array = []
var conversation_reveal_index: int = 0
var conversation_attempts: int = 0
var conversation_understood: bool = false
var conversation_understanding_rolls: Array[int] = []
var conversation_feedback: String = ""
var conversation_locale: String = "zh"
var conversation_clean_units: Array[String] = []
var conversation_legacy_texts: Array[String] = []
var conversation_turns: Array = []
var conversation_turn_index: int = 0
var conversation_history: Array = []
var conversation_can_continue: bool = false
var conversation_completed: bool = false
var conversation_interrupted: bool = false
var conversation_interrupt_line: String = ""
var conversation_action_spent: bool = false
var conversation_reward: Dictionary = {}
var owned_communication_items: Array = []
var daily_communication_item_bought: bool = false
var last_communication_item_used: String = ""
var last_communication_item_remaining: int = 0
var npc_meme_frame_reward_pity: int = 0
var npc_meme_frame_reward_attempt_keys: Array[String] = []
var last_npc_meme_frame_reward: Dictionary = {}


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
	max_actions_per_day = BASE_ACTIONS_PER_DAY
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
	owned_meme_frames = 0
	daily_meme_frame_bought = false
	fusion_slots = {}
	fused_meme_pairs = []
	dialogue_blanks = {}
	published_memes = []
	last_publish_breakdown = {}
	event_log = []
	social_followed_handles = []
	social_liked_post_ids = []
	collected_world_item_ids = []
	pending_world_item_effects = {}
	permanent_modifiers = []
	owned_tarot_ids = []
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
	npc_meme_frame_reward_pity = 0
	npc_meme_frame_reward_attempt_keys = []
	last_npc_meme_frame_reward = {}
	reset_typed_reality_conversation()


func to_save_data() -> Dictionary:
	var state_data := {}
	for field_name in SAVE_FIELD_NAMES:
		var value: Variant = get(field_name)
		state_data[field_name] = value.duplicate(true) if value is Array or value is Dictionary else value
	return {
		"version": SAVE_DATA_VERSION,
		"state": state_data,
	}


func load_save_data(save_data: Dictionary) -> bool:
	if int(save_data.get("version", -1)) != SAVE_DATA_VERSION:
		return false
	var state_data: Variant = save_data.get("state", {})
	if not state_data is Dictionary:
		return false
	new_run()
	for field_name in SAVE_FIELD_NAMES:
		if not state_data.has(field_name):
			continue
		var value: Variant = state_data[field_name]
		set(field_name, value.duplicate(true) if value is Array or value is Dictionary else value)
	day = maxi(1, day)
	tower_floor = clampi(tower_floor, 1, MAX_TOWER_FLOOR)
	max_actions_per_day = maxi(1, max_actions_per_day)
	actions_remaining = clampi(actions_remaining, 0, max_actions_per_day)
	pollution = clampi(pollution, 0, 100)
	clarity = clampi(clarity, 0, 100)
	npc_meme_frame_reward_pity = clampi(npc_meme_frame_reward_pity, 0, NPC_MEME_FRAME_REWARD_PITY_LIMIT - 1)
	if view_state != "phone_down" and view_state != "npc_up":
		view_state = "phone_down"
	reset_typed_reality_conversation()
	return true


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
	var dialogue := _reality_dialogue_for_actor(actor_id, conversation_actor_type)
	conversation_turns = [{
		"line": str(dialogue.get("line", "你打算说什么？")),
		"result": str(dialogue.get("result", "%s移开了视线。" % actor_label)),
		"choices": (dialogue.get("choices", []) as Array).duplicate(true),
	}]
	for followup in dialogue.get("continuation_turns", []):
		conversation_turns.append((followup as Dictionary).duplicate(true))
	conversation_turn_index = 0
	conversation_history = []
	conversation_can_continue = false
	conversation_completed = false
	conversation_interrupted = false
	conversation_interrupt_line = str(dialogue.get("interrupt", ""))
	conversation_action_spent = false
	conversation_reward = {}
	conversation_attempts = 0
	conversation_locale = "zh"
	conversation_legacy_texts = []
	last_communication_item_used = ""
	last_communication_item_remaining = 0
	_load_typed_reality_turn(0)
	conversation_phase = "choosing"
	return true


func reset_typed_reality_conversation() -> void:
	conversation_phase = "idle"
	conversation_actor_id = ""
	conversation_actor_type = "npc"
	conversation_actor_label = ""
	conversation_prompt = ""
	conversation_result_line = ""
	conversation_prompt = ""
	conversation_result_line = ""
	conversation_choices = []
	conversation_selected_choice_id = ""
	conversation_clean_sentence = ""
	conversation_revealed_units = []
	conversation_reveal_index = 0
	conversation_attempts = 0
	conversation_understood = false
	conversation_understanding_rolls = []
	conversation_feedback = ""
	conversation_locale = "zh"
	conversation_clean_units = []
	conversation_legacy_texts = []
	conversation_turns = []
	conversation_turn_index = 0
	conversation_history = []
	conversation_can_continue = false
	conversation_completed = false
	conversation_interrupted = false
	conversation_interrupt_line = ""
	conversation_action_spent = false
	conversation_reward = {}
	last_communication_item_used = ""
	last_communication_item_remaining = 0


func get_typed_reality_choices() -> Array:
	return conversation_choices.duplicate(true)


func get_typed_reality_progress() -> Dictionary:
	return {
		"phase": conversation_phase,
		"turn_index": conversation_turn_index,
		"turn_number": conversation_turn_index + 1 if not conversation_turns.is_empty() else 0,
		"total_turns": conversation_turns.size(),
		"can_continue": conversation_can_continue,
		"completed": conversation_completed,
		"interrupted": conversation_interrupted,
		"action_spent": conversation_action_spent,
		"history_count": conversation_history.size(),
		"reward": conversation_reward.duplicate(true),
	}


func get_typed_reality_history() -> Array:
	return conversation_history.duplicate(true)


func continue_typed_reality_conversation() -> bool:
	if conversation_phase != "result" or not conversation_can_continue:
		return false
	var next_turn := conversation_turn_index + 1
	if next_turn >= conversation_turns.size():
		return false
	conversation_can_continue = false
	_load_typed_reality_turn(next_turn)
	conversation_phase = "choosing"
	return true


func _load_typed_reality_turn(turn_index: int) -> void:
	if turn_index < 0 or turn_index >= conversation_turns.size():
		return
	var turn: Dictionary = conversation_turns[turn_index]
	conversation_turn_index = turn_index
	conversation_prompt = str(turn.get("line", "你打算说什么？"))
	conversation_result_line = str(turn.get("result", "%s移开了视线。" % conversation_actor_label))
	conversation_choices = (turn.get("choices", []) as Array).duplicate(true)
	conversation_selected_choice_id = ""
	conversation_clean_sentence = ""
	conversation_revealed_units = []
	conversation_reveal_index = 0
	conversation_understood = false
	conversation_understanding_rolls = []
	conversation_feedback = ""
	conversation_clean_units = []


func configure_conversation_locale(locale_code: String, localized_legacy_texts: Array[String]) -> void:
	conversation_locale = locale_code if locale_code in ["zh", "ja", "en"] else "zh"
	conversation_legacy_texts = localized_legacy_texts.duplicate()
	if not conversation_clean_sentence.is_empty():
		conversation_clean_units = _conversation_units(conversation_clean_sentence)


func _reality_dialogue_for_actor(actor_id: String, actor_type: String) -> Dictionary:
	var floor_number := clampi(tower_floor, 1, MAX_TOWER_FLOOR)
	if actor_type == "merchant":
		var merchant_entry: Dictionary = (MERCHANT_DIALOGUES_BY_FLOOR.get(floor_number, MERCHANT_DIALOGUES_BY_FLOOR[1]) as Dictionary).duplicate(true)
		merchant_entry["choices"] = (MERCHANT_CHOICES_BY_FLOOR.get(floor_number, MERCHANT_CHOICES_BY_FLOOR[1]) as Array).duplicate(true)
		return merchant_entry
	var entries: Array = REALITY_DIALOGUES_BY_FLOOR.get(floor_number, REALITY_DIALOGUES_BY_FLOOR[1])
	var actor_index := _reality_actor_index(actor_id)
	if entries.is_empty():
		return {"line": "你打算说什么？", "result": "对方没有马上回答。", "choices": (REALITY_RESPONSE_SETS["npc"] as Array).duplicate(true)}
	var dialogue: Dictionary = (entries[actor_index % entries.size()] as Dictionary).duplicate(true)
	var arc: Dictionary = REALITY_FOLLOWUPS_BY_NPC_INDEX.get(actor_index, REALITY_FOLLOWUPS_BY_NPC_INDEX[0])
	dialogue["continuation_turns"] = (arc.get("turns", []) as Array).duplicate(true)
	dialogue["interrupt"] = str(arc.get("interrupt", ""))
	return dialogue


func _reality_actor_index(actor_id: String) -> int:
	for index in 8:
		if actor_id.ends_with("npc%d" % index):
			return index
	return 0


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
	return conversation_actor_type == "merchant" and conversation_phase == "result" and conversation_selected_choice_id == "trade"


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
	conversation_clean_units = _conversation_units(sentence)
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
		"conversation_completed": false,
		"can_continue": false,
		"interrupted": false,
		"reward": {},
	}
	if conversation_phase != "typing":
		return result
	if conversation_reveal_index >= conversation_clean_units.size():
		return result
	var clean_character := conversation_clean_units[conversation_reveal_index]
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
	if conversation_reveal_index < conversation_clean_units.size():
		return result

	result["completed"] = true
	if not conversation_action_spent:
		if not spend_action("typed-reality-dialogue"):
			conversation_phase = "result"
			conversation_interrupted = true
			conversation_feedback = "今天已经没有能说出口的行动。"
			result["locked_out"] = true
			result["interrupted"] = true
			return result
		conversation_action_spent = true
		result["action_spent"] = true
		reality_dialogue_count += 1
	conversation_attempts += 1
	last_clean_sentence = conversation_clean_sentence
	last_polluted_sentence = get_typed_reality_spoken_sentence()
	var understood := _resolve_typed_reality_understanding()
	conversation_understood = understood
	result["understood"] = understood
	if not understood:
		last_relationship_residue_gain = clampi(1 + int(pollution / 18.0) + legacy_rules.size(), 1, 14)
		relationship_residue = clampi(relationship_residue + last_relationship_residue_gain, 0, 100)
	conversation_feedback = conversation_result_line
	var aid_feedback := _communication_item_feedback()
	if not aid_feedback.is_empty():
		conversation_feedback += "\n" + aid_feedback
	conversation_history.append({
		"turn_index": conversation_turn_index,
		"prompt": conversation_prompt,
		"choice_id": conversation_selected_choice_id,
		"clean_sentence": conversation_clean_sentence,
		"spoken_sentence": last_polluted_sentence,
		"understood": understood,
		"understanding_rolls": conversation_understanding_rolls.duplicate(),
		"result": conversation_result_line,
	})
	conversation_phase = "result"
	if not understood:
		conversation_can_continue = false
		conversation_interrupted = true
		if not conversation_interrupt_line.is_empty():
			conversation_feedback += "\n" + conversation_interrupt_line
		result["interrupted"] = true
		return result

	if conversation_turn_index + 1 < conversation_turns.size():
		conversation_can_continue = true
		result["can_continue"] = true
		return result

	conversation_can_continue = false
	conversation_completed = true
	result["conversation_completed"] = true
	if conversation_actor_type == "npc":
		conversation_reward = _resolve_npc_meme_frame_reward(conversation_actor_id)
		result["reward"] = conversation_reward.duplicate(true)
		if bool(conversation_reward.get("awarded", false)):
			conversation_feedback += "\n对方把一个梗框留在你手边。框沿没有商人的价签。"
	return result


func get_typed_reality_spoken_sentence() -> String:
	var pieces: Array[String] = []
	for unit in conversation_revealed_units:
		pieces.append(str(unit.get("display", "")))
	return "".join(pieces)


func get_typed_reality_unrevealed_suffix() -> String:
	if conversation_clean_units.is_empty() or conversation_reveal_index >= conversation_clean_units.size():
		return ""
	var suffix := ""
	for index in range(conversation_reveal_index, conversation_clean_units.size()):
		suffix += conversation_clean_units[index]
	return suffix


func get_typed_reality_unit_count() -> int:
	return conversation_clean_units.size()


func _sentence_with_legacy(base_sentence: String) -> String:
	var sentence := base_sentence.strip_edges()
	while sentence.ends_with("。") or sentence.ends_with("！") or sentence.ends_with("？") or sentence.ends_with(".") or sentence.ends_with("!") or sentence.ends_with("?"):
		sentence = sentence.substr(0, sentence.length() - 1)
	for rule_index in legacy_rules.size():
		var rule: Dictionary = legacy_rules[rule_index]
		var required_text := str(rule.get("required_text", "")).strip_edges()
		if rule_index < conversation_legacy_texts.size():
			required_text = conversation_legacy_texts[rule_index].strip_edges()
		if required_text.is_empty() or sentence.contains(required_text):
			continue
		if conversation_locale == "en":
			sentence += "; " + required_text
		else:
			sentence += "，" + required_text
	return sentence + ("." if conversation_locale == "en" else "。")


func _conversation_units(sentence: String) -> Array[String]:
	return GameLocaleScript.split_dialogue_units(sentence, conversation_locale)


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
	var legacy_relief := int(round(_modifier_total("legacy_relief")))
	var legacy_penalty_per_rule := maxi(2, 6 - legacy_relief)
	var legacy_penalty := legacy_rules.size() * legacy_penalty_per_rule
	var base_clear_chance := clampi(100 - pollution - legacy_penalty, 5, 96)
	var check_count := 3 if conversation_actor_type == "merchant" else 1
	var understood := false
	for check_index in check_count:
		var roll := _conversation_roll("understanding", 0, check_index)
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


func get_npc_meme_frame_reward_rules() -> Dictionary:
	return {
		"chance_percent": NPC_MEME_FRAME_REWARD_CHANCE_PERCENT,
		"pity_limit": NPC_MEME_FRAME_REWARD_PITY_LIMIT,
		"pity_progress": npc_meme_frame_reward_pity,
		"successes_until_guarantee": maxi(1, NPC_MEME_FRAME_REWARD_PITY_LIMIT - npc_meme_frame_reward_pity),
		"dedup_scope": "actor_per_day",
	}


func get_last_npc_meme_frame_reward() -> Dictionary:
	return last_npc_meme_frame_reward.duplicate(true)


func _npc_meme_frame_reward_roll(actor_id: String, reward_day: int = -1) -> int:
	var resolved_day := day if reward_day < 0 else reward_day
	return posmod(int(hash("npc-meme-frame|%d|%s" % [resolved_day, actor_id])), 100)


func _resolve_npc_meme_frame_reward(actor_id: String) -> Dictionary:
	var attempt_key := "%d|%s" % [day, actor_id]
	var reward := {
		"eligible": true,
		"awarded": false,
		"duplicate": false,
		"guaranteed": false,
		"actor_id": actor_id,
		"day": day,
		"chance_percent": NPC_MEME_FRAME_REWARD_CHANCE_PERCENT,
		"roll": -1,
		"pity_before": npc_meme_frame_reward_pity,
		"pity_after": npc_meme_frame_reward_pity,
		"reason": "none",
	}
	if attempt_key in npc_meme_frame_reward_attempt_keys:
		reward["eligible"] = false
		reward["duplicate"] = true
		last_npc_meme_frame_reward = reward.duplicate(true)
		return reward

	npc_meme_frame_reward_attempt_keys.append(attempt_key)
	var roll := _npc_meme_frame_reward_roll(actor_id, day)
	var guaranteed := npc_meme_frame_reward_pity + 1 >= NPC_MEME_FRAME_REWARD_PITY_LIMIT
	var awarded := guaranteed or roll < NPC_MEME_FRAME_REWARD_CHANCE_PERCENT
	reward["roll"] = roll
	reward["guaranteed"] = guaranteed
	reward["awarded"] = awarded
	if awarded:
		owned_meme_frames += 1
		npc_meme_frame_reward_pity = 0
		reward["reason"] = "pity" if guaranteed else "chance"
		var reason_label := "保底" if guaranteed else "概率命中"
		event_log.push_front("现实交流奖励：获得一个梗框（%s）。" % reason_label)
	else:
		npc_meme_frame_reward_pity += 1
	reward["pity_after"] = npc_meme_frame_reward_pity
	last_npc_meme_frame_reward = reward.duplicate(true)
	return reward


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
	fusion_slots.clear()
	dialogue_blanks.clear()
	reality_sentence_slots.clear()
	reset_reality_phase_for_day()
	reset_typed_reality_conversation()
	daily_meme_frame_bought = false
	daily_communication_item_bought = false
	last_communication_item_used = ""
	last_communication_item_remaining = 0
	heat = maxi(10, int(round(float(heat) * 0.82)))
	money += 5 + tower_floor * 2
	return true


func pick_token(post_id: String, token: Dictionary) -> bool:
	var content_locale := str(token.get("content_locale", "zh"))
	var picked_character := _first_pickable_character(str(token.get("text", "")), content_locale)
	if picked_character.is_empty():
		return false
	var note := {
		"id": "%s-%s-%d" % [post_id, token.get("id", "token"), day],
		"text": picked_character,
		"source_text": str(token.get("source_text", token.get("text", ""))),
		"content_locale": content_locale,
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


func get_daily_meme_frame_offer() -> Dictionary:
	var available := day == 1 or posmod(day - 1, MEME_FRAME_OFFER_INTERVAL) == 0
	if not available:
		return {}
	return {
		"id": "meme-frame-day-%d" % day,
		"label": "梗框",
		"price": MEME_FRAME_PRICE + maxi(0, tower_floor - 1) * 2,
		"available": true,
		"bought": daily_meme_frame_bought,
	}


func buy_daily_meme_frame() -> bool:
	var offer := get_daily_meme_frame_offer()
	if offer.is_empty() or daily_meme_frame_bought:
		return false
	var price := int(offer.get("price", MEME_FRAME_PRICE))
	if money < price or not spend_action("buy-meme-frame"):
		return false
	money -= price
	owned_meme_frames += 1
	daily_meme_frame_bought = true
	event_log.push_front("你买到一个梗框。它只能容纳一个字。")
	return true


func get_craft_slots() -> Array:
	return [{"id": "glyph", "label": "梗框", "placeholder": "放入一个字", "required": true}]


func get_draft_source_passives() -> Array:
	var result: Array = []
	for token_id in [str(draft_slots.get("glyph", ""))]:
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
	if slot_id != "glyph" or _find_token_text(token_id).is_empty():
		return false
	draft_slots[slot_id] = token_id
	return true


func confirm_craft() -> bool:
	var token_id := str(draft_slots.get("glyph", ""))
	var glyph_text := _find_token_text(token_id)
	if owned_meme_frames <= 0 or glyph_text.is_empty():
		return false
	if not spend_action("craft-meme"):
		return false
	owned_meme_frames -= 1
	var tags: Array = _unique(_find_token_tags(token_id))
	var source_passives: Array = get_draft_source_passives()
	var meme := {
		"id": "meme-%d-%d" % [day, completed_memes.size() + 1],
		"title": "梗字「%s」" % glyph_text,
		"text": glyph_text,
		"tags": tags,
		"rarity": _meme_rarity_from_tags(tags),
		"pollution_bias": maxi(1, int(_find_token_rarity(token_id)) - 1),
		"clarity_bias": -1,
		"fusion_level": 0,
		"unit_count": 1,
		"source_passives": source_passives,
		"created_day": day,
	}
	completed_memes.push_front(meme)
	draft_slots.clear()
	return true


func place_meme_in_fusion_slot(slot_id: String, meme_id: String) -> bool:
	if slot_id != "left" and slot_id != "right":
		return false
	if _find_completed_meme_index(meme_id) < 0:
		return false
	var other_slot := "right" if slot_id == "left" else "left"
	if str(fusion_slots.get(other_slot, "")) == meme_id:
		return false
	fusion_slots[slot_id] = meme_id
	return true


func confirm_meme_fusion() -> bool:
	var left_id := str(fusion_slots.get("left", ""))
	var right_id := str(fusion_slots.get("right", ""))
	if left_id.is_empty() or right_id.is_empty() or left_id == right_id:
		return false
	var left_index := _find_completed_meme_index(left_id)
	var right_index := _find_completed_meme_index(right_id)
	if left_index < 0 or right_index < 0:
		return false
	var pair_ids: Array[String] = [left_id, right_id]
	pair_ids.sort()
	var pair_key := "%s+%s" % [pair_ids[0], pair_ids[1]]
	if pair_key in fused_meme_pairs:
		return false
	if not spend_action("fuse-memes"):
		return false
	var left: Dictionary = completed_memes[left_index]
	var right: Dictionary = completed_memes[right_index]
	var fusion_level := mini(3, maxi(int(left.get("fusion_level", 0)), int(right.get("fusion_level", 0))) + 1)
	var tags: Array = _unique((left.get("tags", []) as Array) + (right.get("tags", []) as Array))
	var source_passives: Array = []
	for passive in (left.get("source_passives", []) as Array) + (right.get("source_passives", []) as Array):
		var passive_id := str(passive.get("id", ""))
		var already_present := false
		for existing in source_passives:
			if str(existing.get("id", "")) == passive_id:
				already_present = true
				break
		if not already_present:
			source_passives.append((passive as Dictionary).duplicate(true))
	var left_text := str(left.get("text", ""))
	var right_text := str(right.get("text", ""))
	var fused_text := "%s%s" % [left_text, right_text]
	var meme := {
		"id": "fusion-%d-%d" % [day, completed_memes.size() + 1],
		"title": "复合「%s」" % fused_text,
		"text": fused_text,
		"tags": tags,
		"rarity": clampi(maxi(int(left.get("rarity", 1)), int(right.get("rarity", 1))) + 1, 1, 5),
		"pollution_bias": int(left.get("pollution_bias", 0)) + int(right.get("pollution_bias", 0)) + 6 + fusion_level * 2,
		"clarity_bias": int(left.get("clarity_bias", 0)) + int(right.get("clarity_bias", 0)) - 4,
		"fusion_level": fusion_level,
		"unit_count": maxi(2, int(left.get("unit_count", 1)) + int(right.get("unit_count", 1))),
		"fused_from": pair_ids,
		"source_passives": source_passives,
		"created_day": day,
	}
	completed_memes.push_front(meme)
	fused_meme_pairs.append(pair_key)
	fusion_slots.clear()
	var previous_pollution := pollution
	pollution = clampi(pollution + 3 + fusion_level * 2, 0, 100)
	check_pollution_flashback(previous_pollution)
	event_log.push_front("两个旧梗粘在一起。新梗更响，也更脏。")
	return true


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
		event_log.push_front("牌型完成：%s，整数倍率 +%d。" % [
			str(breakdown.get("contract_label", "未知牌型")),
			int(breakdown.get("contract_multiplier_bonus", 0)),
		])
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


func get_active_tarot_combos() -> Array:
	var result: Array = []
	for combo in TAROT_COMBOS:
		var complete := true
		for tarot_id in combo.get("requires", []):
			if str(tarot_id) not in owned_tarot_ids:
				complete = false
				break
		if complete:
			result.append(combo.duplicate(true))
	return result


func choose_ascent_reward(reward_id: String) -> bool:
	var selected: Dictionary = {}
	for reward in pending_ascent_reward_choices:
		if str(reward.get("id", "")) == reward_id:
			selected = reward
			break
	if selected.is_empty():
		return false
	permanent_modifiers.append(selected.duplicate(true))
	var tarot_id := str(selected.get("tarot_id", selected.get("id", "")))
	if not tarot_id.is_empty() and tarot_id not in owned_tarot_ids:
		owned_tarot_ids.append(tarot_id)
	var previous_capacity := max_actions_per_day
	max_actions_per_day = BASE_ACTIONS_PER_DAY + int(round(_tarot_combo_total("max_actions_bonus")))
	if max_actions_per_day > previous_capacity:
		actions_remaining += max_actions_per_day - previous_capacity
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


func _find_token_rarity(token_id: String) -> int:
	for token in notebook_tokens:
		if str(token.get("id", "")) == token_id:
			return int(token.get("rarity", 1))
	return 1


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
	return SIGNAL_CONTRACTS[posmod(day - 1, SIGNAL_CONTRACTS.size())].duplicate(true)


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
	var permanent_base_bonus := int(round(_modifier_total("publish_base")))
	var fusion_level := maxi(0, int(meme.get("fusion_level", 0)))
	var fusion_base_bonus := fusion_level * 18
	var contract_base_bonus := int(contract_result.get("base_bonus", 0)) if bool(contract_result.get("matched", false)) else 0
	if bool(contract_result.get("matched", false)):
		contract_base_bonus += int(round(_modifier_total("contract_base")))
	var world_item_base_bonus := int(pending_world_item_effects.get("base_bonus", 0))
	var base_value: int = 12 + rarity * 6 + matching_tags.size() * 8 + empty_base_bonus + pollution_base_bonus + permanent_base_bonus + fusion_base_bonus + source_base_bonus + contract_base_bonus + world_item_base_bonus
	var trend_multiplier_bonus := mini(2, matching_tags.size())
	if matching_tags.size() >= 2:
		trend_multiplier_bonus += int(round(_modifier_total("trend_multiplier_bonus")))
	var pollution_multiplier_bonus := (1 if pollution >= 40 else 0) + (1 if pollution >= 70 else 0)
	var effective_repeat_count := maxi(0, repeat_count - int(round(_modifier_total("repeat_grace"))) - int(round(_tarot_combo_total("repeat_grace"))) - source_repeat_grace)
	var repeat_penalty := mini(2, effective_repeat_count)
	var contract_multiplier_bonus := int(contract_result.get("multiplier_bonus", 0)) if bool(contract_result.get("matched", false)) else 0
	var world_item_multiplier_bonus := int(pending_world_item_effects.get("multiplier_bonus", 0))
	var fusion_multiplier_bonus := mini(2, fusion_level)
	if fusion_level > 0:
		fusion_multiplier_bonus += int(round(_modifier_total("fusion_multiplier_bonus"))) + int(round(_tarot_combo_total("fusion_multiplier_bonus")))
	var total_multiplier := maxi(1, 1 + trend_multiplier_bonus + pollution_multiplier_bonus + contract_multiplier_bonus + fusion_multiplier_bonus + world_item_multiplier_bonus - repeat_penalty)
	var score := maxi(1, base_value * total_multiplier)
	var active_modifier_labels: Array[String] = []
	for modifier in permanent_modifiers:
		var effect_id := str(modifier.get("effect", ""))
		var is_active := effect_id == "publish_base"
		is_active = is_active or (effect_id == "pollution_base" and pollution >= 40)
		is_active = is_active or (effect_id == "trend_multiplier_bonus" and matching_tags.size() >= 2)
		is_active = is_active or (effect_id == "repeat_grace" and repeat_count > 0)
		is_active = is_active or (effect_id == "empty_base" and empty_base_bonus > 0)
		is_active = is_active or (effect_id == "contract_base" and bool(contract_result.get("matched", false)))
		is_active = is_active or (effect_id == "fusion_multiplier_bonus" and fusion_level > 0)
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
		"fusion_level": fusion_level,
		"fusion_base_bonus": fusion_base_bonus,
		"fusion_multiplier_bonus": fusion_multiplier_bonus,
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
		"world_item_base_bonus": world_item_base_bonus,
		"world_item_multiplier_bonus": world_item_multiplier_bonus,
		"world_item_multiplier": 1 + world_item_multiplier_bonus,
		"active_world_item_labels": (pending_world_item_effects.get("labels", []) as Array).duplicate(),
		"total_multiplier": total_multiplier,
		"repeat_count": repeat_count,
		"effective_repeat_count": effective_repeat_count,
		"modifier_base_bonus": empty_base_bonus + pollution_base_bonus + permanent_base_bonus + fusion_base_bonus,
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
		"unit_count":
			current = maxi(1, int(meme.get("unit_count", 1 if int(meme.get("fusion_level", 0)) == 0 else 2)))
			matched = current == threshold
			progress = "%d/%d 语言单位" % [current, threshold]
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
		threshold_discount = maxi(0, threshold_discount - 32)
		event_log.push_front("第二天，巴别塔把你标记到第 %d 层。" % tower_floor)
	elif tower_floor > 1 and progress < int(float(threshold) * 0.62):
		tower_floor = clampi(tower_floor - 1, 1, MAX_TOWER_FLOOR)
		threshold_discount = clampi(threshold_discount + 64, 0, MAX_THRESHOLD_DISCOUNT)
		event_log.push_front("第二天，楼层退回第 %d 层，但遗产规则没有消失。" % tower_floor)
	else:
		threshold_discount = clampi(threshold_discount + 24, 0, MAX_THRESHOLD_DISCOUNT)
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


func _tarot_combo_total(effect_id: String) -> float:
	var total := 0.0
	for combo in get_active_tarot_combos():
		if str(combo.get("effect", "")) == effect_id:
			total += float(combo.get("value", 0.0))
	return total


func _tower_threshold(floor: int) -> int:
	var index := clampi(floor, 1, MAX_TOWER_FLOOR)
	return maxi(72, int(TOWER_THRESHOLDS[index]) - threshold_discount)


func _progress_score() -> int:
	return int(round(float(heat) + float(pollution) * 0.55 + float(100 - clarity) * 0.18))


func _minimum_floor_for_day(current_day: int) -> int:
	var result := 1
	for deadline in FLOOR_DEADLINES.keys():
		if current_day >= int(deadline):
			result = maxi(result, int(FLOOR_DEADLINES[deadline]))
	return result


func _find_completed_meme_index(meme_id: String) -> int:
	for index in completed_memes.size():
		if str(completed_memes[index].get("id", "")) == meme_id:
			return index
	return -1


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


func _first_pickable_character(value: String, locale_code: String = "zh") -> String:
	if locale_code == "en":
		var word_regex := RegEx.new()
		word_regex.compile("[A-Za-z0-9']+")
		var match_result := word_regex.search(value)
		return match_result.get_string() if match_result != null else ""
	var ignored := " \t\r\n　，。！？；：、,.!?;:（）()【】[]《》<>〈〉「」『』〔〕“”\"'—-…・"
	if locale_code == "ja":
		var start := 0
		var end := value.length()
		while start < end and ignored.contains(value.substr(start, 1)):
			start += 1
		while end > start and ignored.contains(value.substr(end - 1, 1)):
			end -= 1
		return value.substr(start, end - start)
	for index in value.length():
		var character := value.substr(index, 1)
		if not ignored.contains(character):
			return character
	return ""
