# 语言污染存档 V2 兼容方案

## 回溯说明

本文是旧状态字段的第二份可回溯记录。实际迁移前保留 Git 提交；删除旧运行逻辑不等于无法读取旧存档。

## 原则

- V1 存档仍可读取。
- `pollution` 原名保留，范围归一为 `0..100`。
- 旧热度、清晰、资金、阈值折扣、塔罗、遗产规则和沟通道具可被读取以避免解析失败，但不再决定楼层或结局。
- V2 保存不新增理智、信任、危险、清醒度或语言能力。
- 隐藏进度不出现在 UI，但必须可靠保存。

## V2 新字段

```text
save_version = 2
pending_floor_transition
formal_floor_three_complete
collected_echo_fragment_ids
completed_dialogue_key_ids
claimed_doll_ids
doll_choice_results
history_entries
ending_route
exit_prompt_seen
```

`history_entries` 每项只允许：

```text
lineId
originalSpeaker
currentSpeaker
originalText
displayText
revisionStage
revisionMarkup
```

`revisionMarkup` 只处理 `{del}` 与 `{ins}`，一条最多组合两种强调。

## 固定隐藏数据

回声碎片共三个：

```text
echo_room_name   # 第一层
echo_safe_place  # 第二层
echo_blank_voice # 第三层
```

NPC 对话钥匙共三个，附着于现有 choice ID：

```text
dialogue_key_name   -> f1n1_name
dialogue_key_source -> copy_refuse_source
dialogue_key_voice  -> believer_question
```

任一路线完整即可令 `hiddenLayerUnlocked` 为真。保存时只记录 ID 数组，不额外保存可漂移的计数。

## V1 到 V2 映射

| V1 数据 | V2 行为 |
| --- | --- |
| `tower_floor` 1 | 保持 1；污染达到 25 后在边界请求 2 |
| `tower_floor` 2 | 保持 2；污染达到 60 后在边界请求 3 |
| `tower_floor` 3 | 保持 3 |
| `tower_floor` 4 或 5 | 若隐藏条件尚无记录，归到 3 并保留污染；不凭旧层数自动解锁隐藏层 |
| `pollution_flashback_seen` | 保持，避免旧存档重复闪回 |
| `owned_meme_frames` | 保持库存数量 |
| 商店和沟通道具字段 | 读取后忽略，不写入 V2 新存档 |
| 旧 conversation history | 转成只读 history entry；缺失的 speaker/text 字段使用安全默认值 |
| 热度、清晰、资金等 | 可读取用于兼容，不再作为流程判定，不显示为进度 |

## 楼层恢复

加载后不在一句对话中跳层。先根据污染与当前层设置 `pending_floor_transition`，再由下一个合法边界提交。第三层进入第四层必须重新满足：

```text
pollution >= 80
AND
(三个 echo ID 全部存在 OR 三个 dialogue key ID 全部存在)
```

否则第三层正式结束进入普通结局。

## 测试矩阵

1. V1 的 1、2、3、4、5 层存档均能加载且不崩溃。
2. V1 的 5 层不能绕过隐藏条件进入第四层。
3. V2 保存往返保持碎片、对话钥匙、玩偶领取、历史条目和闪回一次性状态。
4. 未知 ID 被忽略，重复 ID 去重。
5. 污染小于 0 或大于 100 会被 clamp。
6. 加载时正在对话不会立即切层。
7. 删除商人字段后旧存档中的相应键不会导致 `load_save_data()` 失败。
