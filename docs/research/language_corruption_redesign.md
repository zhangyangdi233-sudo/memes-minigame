# 语言污染重设计研究与实施决策

## 目标边界

本轮只围绕一件事工作：一句话如何逐渐不再属于说话的人。

污染值 `pollution` 是现有代码中的唯一主流程变量，也就是设计文档所说的 `pollutionValue`。实现继续保留原变量名以兼容存档，不再让热度、清晰、资金、塔层折扣或其他数值决定楼层与结局。前三层现有普通 NPC 数量和每个角色的三轮对话规模不变。

## 现状弱点

### 60% 闪回

当前 `_play_pollution_flashback()` 主要依赖随机位置、随机字体大小、随机字符串和快速 glitch。它有四个问题：

1. 画面虽然忙，却没有可追踪的事件顺序。
2. 文本只是在说“信号丢失”或显示污染百分比，没有改变玩家对既有剧情的理解。
3. 每次随机重排让玩家无法记住具体差异，也无法在真结局中回认。
4. 声音只承担冲击，没有建立“谁在说话”的疑问。

### 现有对话

当前文本大量使用抽象名词、完整比喻和整齐的说明句。NPC 经常像在替作者讲设定，而不是在处理眼前的车票、水管、门牌或一段尴尬的对话。三个选择通常只是同一观点的三种修辞，缺少关系压力、回避和代价。

### 商人系统

商人把梗框变成了货币交换，探索只负责走到固定柜台。商店 App、现实商人报价、沟通道具和随机 NPC 掉落又形成了三条互相竞争的获取路径，削弱了“命名和说话本身就是交易”的主题。

### 进度系统

当前楼层由热度、污染、清晰度和阈值折扣共同计算，还允许掉层与追赶。这会让语言污染失去因果中心。原五层正常进度也与“前三层加一个隐藏残留层”的目标冲突。

## 研究结论

研究只提取方法，不复制角色、台词、镜头、地图或声音。

- Akira Yamaoka 对《Silent Hill》的讲述强调省略关键信息、留白和弱化传统音乐提示。对本项目的启发是：闪回必须让玩家少知道一件确定的事，而不是用音量宣布恐怖。[Game Developer](https://www.gamedeveloper.com/audio/postcard-from-gdc-2005-akira-yamaoka-on-i-silent-hill-i-fear-and-audio-for-games)
- 《Paratopic》的创作者把碎裂叙事和声音当作情绪路径，而不是随机滤镜。对本项目的启发是：断帧前后必须存在可比较的对象，例如同一句话的说话者发生变化。[Game Developer](https://www.gamedeveloper.com/business/road-to-the-igf-arbitrary-metric-s-i-paratopic-i-)
- 《F.E.A.R.》的恐怖分析指出，含义不明确的缺席和依赖语境的极少声音，比持续刺激更能让玩家主动补全危险。对本项目的启发是：在最密集的一帧之后安排完整静音。[Game Developer](https://www.gamedeveloper.com/design/don-t-fear-the-yurei-how-f-e-a-r-successfully-embodies-the-traits-of-japanese-horror)
- 《Hellblade》的声音设计把声音位置、亲疏和叙事关系绑定；相关同行评审案例也强调与亲历者和专业人士合作，避免把精神痛苦简化为危险怪物。对本项目的启发是：医生和玩偶是两套内部语言，不是“疯狂音效”，恐怖来自主角失去命名权。[Game Developer](https://www.gamedeveloper.com/audio/how-ninja-theory-created-hellblade-ii-s-unsettling-soundscape), [JMIR Mental Health](https://mental.jmir.org/2019/4/e12432)
- Inkle 的对话设计经验把潜台词和人物当前欲望放在话题穷举之前。对本项目的启发是：玩家选择表达靠近、核对或拒绝的意图，NPC 的回答再改变关系压力，而不是让角色成为设定菜单。[Game Developer](https://www.gamedeveloper.com/design/designing-investigate-conversations)
- GDC 的简洁对白与角色表演资料强调删去语言脂肪、为系统台词保留人格、使用潜台词。对本项目的启发是：每句先完成动作，再允许它携带第二层含义。[GDC Vault: And Make It Quick](https://www.gdcvault.com/play/1013171/-em-And-Make-It), [Realistic Performances in Games](https://media.gdcvault.com/gdc2017/Presentations/James_Ryan_Realistic-Performances-In-Games.pdf)

## 开源项目比较

| 项目 | 优点 | 代价 | 本项目决策 |
| --- | --- | --- | --- |
| [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) | Godot 4、条件与变更、翻译和测试成熟 | 需要迁移现有硬编码对话和 UI 接口 | 不引入插件，采用稳定 ID、条件和 mutation 的数据习惯 |
| [Dialogic](https://github.com/dialogic-godot/dialogic) | 时间线、角色、声音、历史和选择完整 | 体量较大，迁移会重做现有场景与存档 | 不引入，借鉴时间线分层与历史记录职责 |
| [Rakugo Dialogue System](https://github.com/rakugoteam/Rakugo-Dialogue-System) | 类 Ren'Py 脚本、变量、跳转、保存较清晰 | 多一套脚本语言和运行层 | 不引入，保留 GDScript 数据目录 |
| [DialogueQuest](https://github.com/hohfchns/DialogueQuest) | 小而稳定，扩展面窄 | 不直接覆盖现有污染和拖拽系统 | 采用同样的小范围原则 |
| [Escoria](https://github.com/godot-escoria/escoria) | 完整点击冒险框架 | 远超本章需求，会把游戏扩成另一种类型 | 明确不采用 |

结论：新增一个小型、强类型的内容目录脚本，保留现有状态机和场景构建方式。这样能获得稳定 ID、作者预写变体和可测条件，同时避免更换引擎内对话框架。

## 实施架构

1. `pollution` 保持 `0..100`，成为唯一楼层与结局判定值。
2. 楼层改为 1、2、3 和隐藏 4。阈值分别为 25、60、80；转场只在完整对话、日结或正式结尾边界执行。
3. 乱码概率使用 `min(pollution / 100.0, 0.65)`；角色名、标点、关键句和核心关键词受保护。
4. 重要污染由内容目录中的作者版本决定，随机算法只处理普通语言单位。
5. 历史记录只读，保存原说话者、当前说话者、原文、显示文和有限 markup。
6. 每层一个回声碎片，共三个。它们只保存 ID 和是否拾取，不建立物品栏。
7. 三个对话钥匙附着在现有选择节点，不增加 NPC 和对话轮数。
8. 商人、商店 App、沟通道具和随机 NPC 梗框奖励全部移除。梗框只由地图中的玩偶对话获得。
9. 第三层正式结束时：污染不足 80 或隐藏条件未满足进入普通结局；同时满足时进入未登记第四层。

## 分轮交付

1. 研究、语气规范、闪回分镜、迁移和存档兼容文档。
2. 单污染值、四层阈值、隐藏条件、历史数据与测试。
3. 对话逐场改写、菜单污染、退出确认和楼层卡，同时删除旧站数字谜题等与语言污染无关的调查结构。
4. 60% 闪回视觉、声音与自动跳天。
5. 商人完整移除、地图玩偶、梗框分支与引导更新。
6. 全量回归、运行截图、独立 Critic/Evaluator 审查与修复循环。

## 原创性与安全边界

本地安装的《Milk outside a bag of milk outside a bag of milk》只在打包结构和高层呈现方法上观察，不解包、不复制台词、图像或声音。所有新台词、玩偶设定、闪回构图、声音和交互均为本项目原创。视觉紊乱描述主观语言压力，不把精神疾病等同于危险、暴力或怪物。
