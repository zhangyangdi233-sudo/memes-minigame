# 商人系统移除与玩偶替换清单

## 回溯说明

本文记录删除前的所有商人职责。Git 历史与本文共同构成可回溯备份。删除时不得只换贴图，必须让每项职责有明确去向。

## 现有商人表面

| 表面 | 当前实现 | 替换方案 |
| --- | --- | --- |
| 3D 商人 | `RealityFloor/Actors/Merchant`，每层固定生成 | 完全删除；前三层各生成一个隐藏 `DollEncounter`，不计入普通 NPC 数量 |
| 商人角色图 | `merchant_frame_vendor.png` | 从运行时依赖和测试移除；保留在 Git 历史，不在游戏加载 |
| 面部涂写 | 商人与 NPC 共用 `FaceScribbleOverlay` | 只保留普通 NPC；玩偶使用原生无脸设计，不套商人遮挡逻辑 |
| 商人对话 | `MERCHANT_DIALOGUES_BY_FLOOR`、`MERCHANT_CHOICES_BY_FLOOR` | 删除；新增作者编写的玩偶短对话，稳定 doll ID 和 choice ID |
| 手机商店 | `shop` launcher、`ShopAppWindow`、`_render_shop_app()` | 删除；手机只保留塔、社媒、笔记本等现有非商店入口 |
| 每日梗框购买 | `get_daily_meme_frame_offer()`、`buy_daily_meme_frame()` | 删除；梗框由玩偶选择结果授予 |
| 现实报价条 | `RealityMerchantOffer` 和购买按钮 | 删除；玩偶结果使用现有对话结果区，不出现价格 |
| 沟通道具 | `COMMUNICATION_ITEMS`、轮换、charges、购买字段 | 删除；不设置替代属性，避免引入第二进度系统 |
| NPC 随机掉框 | `_resolve_npc_meme_frame_reward()` 的 45% 结果 | 删除；普通 NPC 只承担对话与隐藏 key |
| 资金用途 | 商店与沟通道具 | 改为发布结果与轻量资源反馈；不购买梗框，也不决定楼层或结局 |
| 引导文案 | README、提示、F 键“交易” | 改成搜索与交谈玩偶；F 键统一为“交谈/查看” |
| 捕获工具 | shop/merchant capture | 替换为 doll discovery、doll choice、frame grant capture |

## 玩偶世界结构

每层可有多个摆放点，但一次流程只启用少量确定点，避免把探索变成收集清单。

```text
DollEncounter
  doll_id
  floor
  required_pollution_min
  required_pollution_max
  required_dialogue_key
  conversation_id
  frame_choices
  claimed
```

- 玩偶藏在已有掩体、房屋角落、柱后或错误摆放的家具旁。
- 接近后显示短提示，不在地图上画标记。
- 对话不扣除“购买”资金；完成有效选择沿用一次行动成本。
- 每只玩偶只能领取一次梗框，保存 `claimed_doll_ids` 防止刷取。
- 某些选择要求玩家带着已出现过的语言单位或污染达到当前层自然区间，但 UI 不显示数值门槛。
- 玩偶共享两句相同记忆，却在称呼、摆放者和上次见面地点上互相矛盾。

## 普通 NPC 规模保护

`ORDINARY_NPC_COUNTS` 的前三项保持 `4, 3, 2`。玩偶属于独立 `doll` actor 类型，不替换、增加或删除前三层普通 NPC。原第四层可复用已有 NPC 数量，但不显示为正常楼层列表。

## 删除顺序

1. 先增加新存档字段和旧字段兼容加载。
2. 增加玩偶内容与状态测试。
3. 增加地图玩偶和交互测试。
4. 将梗框唯一入口切到玩偶。
5. 删除商店、商人、沟通道具和随机掉框运行入口。
6. 更新本地化、README、捕获工具和旧测试。
7. 用 `rg` 证明运行脚本不再引用 merchant/shop 语义；迁移测试与本档案保留旧字段名作为兼容证据。

## 完成判定

- 游戏场景中不存在 Merchant 节点、商人按钮、商店 App、价格或购买操作。
- 运行时不加载商人图像。
- 普通 NPC 不再随机发放梗框。
- 至少三种玩偶选择能够授予不同梗框，并保存为一次性结果。
- 进度门槛、错误选择和重复交互均有测试。
- 普通结局与隐藏结局都不依赖资金或商人字段。
