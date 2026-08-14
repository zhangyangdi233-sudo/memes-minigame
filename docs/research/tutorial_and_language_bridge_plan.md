# 缝线布偶教程导演研究与实施决策

## 目标与边界

缝线布偶既是新手教程向导，也是世界中的长期关键角色。教程必须先可靠地教会玩家完成一次完整循环：找到向导、打开社交媒体、进入帖子、拾取三个词、打开笔记本、组句、发布，再与医生说话。布偶可以对世界作出可疑解释，但不能谎报操作、设置、存档、跳过或退出方法。

本轮只实现纯逻辑教程导演，不接管场景、输入、行动数、对话 UI 或存档文件。导演接收领域事件并返回新的可序列化进度字典；主状态和表现层在后续接线。

## 引导设计依据

- CHI 2012 的大规模实验指出，情境化提示能帮助玩家学习复杂机制，而限制玩家自由并没有呈现同等收益。因此教程应在玩家需要时提示，并在成功后立即撤去，而不是长时间锁死其它操作。[Designing Games to Discourage Tutorial Skipping](https://grail.cs.washington.edu/projects/game-abtesting/chi2012/chi2012.pdf)
- Apple 的游戏引导建议强调短步骤、立即实践、尽快恢复自主，并允许玩家跳过或重播。这里对应为一步一个事件、`skip()` 和 `replay()`，而不是一段无法中断的说明演出。[Onboarding for games](https://developer.apple.com/app-store/onboarding-for-games/)
- Godot 的信号用于对象间解耦通信，适合由场景将 `phone_raised`、`post_opened` 等领域事件转交给纯逻辑导演；导演本身不需要进入场景树。[Godot Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

推荐提示分层：先用布偶朝向、伸爪或目标轻微响应进行无文字提示；停滞后显示一句世界内提示；再次停滞或失败后才显示明确的测试操作文本。当前测试阶段可以直接显示 `test_instruction`，正式版本应由表现层关闭这一层。

## 开源方案比较

| 项目 | 主要功能 | 架构与技术线 | 许可 | 优点 | 对本项目的缺点 |
| --- | --- | --- | --- | --- | --- |
| [Godot State Charts](https://github.com/derkork/godot-statecharts) | 层级、并行、历史状态，守卫条件，延迟转移和运行时调试 | Godot 4 插件；以 Node、Signal 和声明式 StateChart 工作；支持 GDScript 与 C# | MIT | 分支多、并行学习目标多时很清晰；调试视图成熟 | 当前九步线性教程规模太小，引入节点图和插件生命周期会增加状态来源与升级成本 |
| [Questify](https://github.com/TheWalruzz/godot-questify) | 图形化任务、目标与条件、信号、参数化任务、序列化 | Godot 4 编辑器插件；Resource 图实例化后由 Autoload 管理；条件可轮询或手动更新 | MIT | 数据驱动、存档和条件图值得借鉴；适合以后扩展大量支线 | 默认模型偏任务清单；轮询条件不如本项目的领域事件直接；引入 Autoload 会与现有主状态重叠 |
| [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) | 非线性对话 DSL、条件、mutation、本地化、无状态运行时 | Godot 4 插件；编辑器加脚本文本；游戏自身仍是状态权威 | MIT | 无状态原则和文本版本管理很适合布偶台词；与现有状态低耦合 | 不负责教程推进、提示层级和计数；当前主项目已经有自定义对话与本地化路径，迁移收益有限 |
| [Dialogic](https://github.com/dialogic-godot/dialogic) | 可视化时间线、角色、选项、变量、动画、历史和存档子系统 | Godot 4 大型 GDScript 插件；以 Timeline 与多个运行时子系统协作 | MIT | 编剧和演出工具完整，适合大量视觉小说式内容 | 依赖面大；当前版本仍提示 API 和存档可能发生破坏性变化；会与现有对话、保存和 UI 状态重复 |
| [Escoria](https://escoria-framework.org/) | 点击式冒险的角色移动、房间、物品、对话、镜头、音频、保存与设置 | Godot 的完整 2D point-and-click 框架；以专用节点和事件脚本组织游戏 | MIT | 完整事件管线、交互与存档迁移经验值得参考 | 面向第三人称点击式冒险，远超本项目教程需求；迁移会牵动现有 3D 相机、手机 UI 和交互架构 |

## 决策：不安装大型插件

当前教程是严格顺序的九个步骤，只有一个累计条件。为此引入大型插件会产生第二套状态源、额外 Autoload、编辑器依赖和存档迁移风险。项目采用轻量 `TutorialDirector`：

1. 使用常量字典定义步骤，借鉴 Questify 的数据化目标，但不采用图编辑器和轮询。
2. 使用事件驱动推进，借鉴 Godot State Charts 的单一事件入口，但不创建场景节点。
3. 保持导演无状态，借鉴 Dialogue Manager 的“游戏是状态权威”原则。
4. 让表现层继续负责角色、动画、提示和本地化，不引入 Dialogic 或 Escoria 的完整运行时。
5. 当教程出现十几个分支、并行目标、可回退历史状态时，再重新评估 Godot State Charts；当布偶和医生台词量显著增长时，再评估 Dialogue Manager 作为纯表现层。

## 当前逻辑契约

固定静态 API：

```gdscript
TutorialDirector.initial_progress() -> Dictionary
TutorialDirector.normalize_progress(progress) -> Dictionary
TutorialDirector.notify(progress, event_id, payload = {}) -> Dictionary
TutorialDirector.current_step(progress) -> Dictionary
TutorialDirector.skip(progress) -> Dictionary
TutorialDirector.replay(progress) -> Dictionary
```

步骤事件按顺序为：

| Step ID | Event ID | 完成条件 |
| --- | --- | --- |
| `find_guide` | `guide_found` | 1 次 |
| `open_social` | `social_opened` | 1 次 |
| `open_post` | `post_opened` | 1 次 |
| `collect_words` | `collect_word` | 累计 3 次 |
| `open_notebook` | `notebook_opened` | 1 次 |
| `compose_sentence` | `sentence_composed` | 1 次 |
| `publish_sentence` | `sentence_published` | 1 次 |
| `speak_to_doctor` | `doctor_spoken` | 1 次 |
| `complete` | 无 | 终态 |

`notify()` 只处理当前步骤期待的事件，忽略越序事件，也不修改传入字典。`payload.amount` 可一次累计多个同类事件，默认值为 1。进度只包含 JSON 可序列化数据；旧键名、非法步骤、负数计数和不连续完成记录由 `normalize_progress()` 归一化。`skip()` 进入终态但只保留真实完成步骤；`replay()` 清空步骤和计数并增加重播次数。所有方法都不接触行动数。

## 两个世界的语言污染研究

### 互动必须就是表达

- *Florence* 把拖动和拼图直接当成角色表达的隐喻；团队强调故事感受应该来自交互本身，而不是一张图后面附着无关小游戏。因此本项目的三词拼句不是发布前的装饰操作，它就是玩家当次说话的过程。[Designing Florence to convey the ineffable feeling of being in love](https://www.gamedeveloper.com/audio/designing-i-florence-i-to-convey-the-ineffable-feeling-of-being-in-love)
- *Signs of the Sojourner* 将玩家手上的对话牌理解为情绪状态和被他人理解的不完全控制，并让对话无论是否顺利都继续。本项目因此不将医生对话做成“答错重来”，而是保留玩家已经说出的句子和污染结果。[Creating conversations from card game mechanics in Signs of the Sojourner](https://www.gamedeveloper.com/design/creating-conversations-from-card-game-mechanics-in-i-signs-of-the-sojourner-i-)
- *Heaven's Vault* 的语言推理让词的意义在多个上下文中逐渐稳定，而不是每次随机改义。这支持了“稳定 lexeme ID + 作者预写世界表面”的实现：玩家能认出这还是同一个词，却无法确定哪个世界的释义才是原义。[How Inkle developed its own ancient language for Heaven's Vault](https://www.gamedeveloper.com/design/how-inkle-developed-its-own-ancient-language-for-i-heaven-s-vault-i-)
- Godot `Control` 的拖放 API 提供 `_get_drag_data()`、`_can_drop_data()` 和 `_drop_data()`；项目同时保留“点词后点槽位”的同等路径，使触摸板、触摸屏和无精确拖拽环境都能完成句子。[Godot Control documentation](https://docs.godotengine.org/en/stable/classes/class_control.html)

### 开源技术线比较

| 项目 | 能提供什么 | 优点 | 不直接接入的原因 |
| --- | --- | --- | --- |
| [ink](https://github.com/inkle/ink) | 可标记、分支、条件和外部函数的互动文本运行时 | 撰写和变体组织成熟，MIT，适合以后管理大量对话 | 本项目已有 GDScript 存档、三语目录和 UI 渲染；现在接入会制造第二个状态权威，且不解决拖放和词语世界状态 |
| [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) | Godot 4 中的条件对话、mutation 与本地化 | 对话层保持无状态，可与游戏状态分离 | 当前瓶颈是词的身份、句法槽和跨世界记录，不是对话文件播放 |
| [Godot State Charts](https://github.com/derkork/godot-statecharts) | 层级/并行状态、守卫、延迟转移与调试 | 若以后同时有多条语言学习线，能避免 FSM 状态爆炸 | 当前教程和三槽句子是严格线性，一个纯函数导演足够；插件会增加编辑器依赖 |
| [Questify](https://github.com/TheWalruzz/godot-questify) | 图形化任务、条件查询、信号和序列化 | 适合未来有大量并行可选目标 | 它的任务清单模型会把隐藏第四层变成可见 checklist，与正式版叙事目标冲突 |

### 实施的语言桥契约

1. 每个可拾取词使用稳定 `lexeme_id`，并带有一个固定句法角色：`subject`、`action`、`object`。
2. 每个 lexeme 可有 `phone_surface`、`doctor_surface`、`doll_surface`；不做随机同义词替换，关键词变体全部由作者预写。
3. 点击帖子拾词消耗行动，但不增加污染；词被确认组成完整句并发布后，才记录 `used_worlds.phone` 并增加污染。
4. 医生世界只接受已经在手机世界发布过的词。同一组 ID 以 `doctor_surface` 显示，让玩家看见“是同一个词，但已被另一套语言系统重新命名”。
5. 确认医生句子后记录原词、手机句、医生句、理解度和污染阶段，而不输出胜负。
6. 旧“遗产规则”不再参与新局、升层或医生句槽。存档迁移只忽略旧字段，不把旧梗强行塞进玩家新句子。

## 测试阶段与正式版的信息边界

`OS.is_debug_build()` 或 `BABEL_PLAYTEST_ASSIST=1` 时，场景可显示小型荧光 `TEST` 标记、当层关键 NPC 状态、已显形前置物位置与 `3/3 + 80%` 测试条件。当该开关关闭时，正式玩家只能看到布偶和 NPC 的世界内提示，不显示隐藏第四层的数量或污染阈值。

世界标记定为 `14px` 字号和 `3px` 轮廓；它们始终面向镜头，但不应覆盖角色或大面积道路。测试中还通过场景截图和 `font_size <= 16` 回归断言锁定这个上限。
