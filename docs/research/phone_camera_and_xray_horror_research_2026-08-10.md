# 手机摄像头接入与 X-ray 心理恐怖边框研究

日期：2026-08-10
项目：`babel-meme-game` / Godot 4.6.3
范围：手部关键点 X-ray 玩法的测试阶段。本文只给出可验证的接入路线与视觉方案，不代表已经把互联网配对服务部署到生产环境。

## 结论先行

1. **测试阶段立即可用路径**：电脑按钮使用电脑内置/USB 摄像头；手机按钮使用操作系统已经暴露给电脑的手机镜头（macOS/iPhone 的 Continuity Camera，或第三方虚拟摄像头）。两条路径都继续进入现有 Python + MediaPipe 管线，Godot 只接收归一化关键点，不接收或保存原始视频。
2. **普通玩家的正式手机路径**：做一个“扫码 + 一次性配对码”的手机网页，通过 WebRTC 把手机视频发给电脑侧 Python `aiortc` 接收器；帧直接交给同一套 MediaPipe；关键点仍通过现有 localhost UDP 协议进入 Godot。Godot 不应承担视频解码与 MediaPipe 推理。
3. **X-ray 视觉**：采用局部的 `babel_signal_contamination_v2`——酸性黄绿主边、锈红/病态青绿色错位边、常驻轻微画面不同步、短促多段横向跳帧、断裂报码和沿边爬行伤痕。效果只作用于矩形窗口附近，不污染全屏，也不叠加高频强闪。
4. **手势**：只保留双手拇指与食指的四个指尖所形成的矩形窗。三指三角窗曾通过绘制验证，但真机更容易丢点，已从运行时、提示文案和测试中撤下。

---

## 一、玩家手机如何连接

### 1. 当前项目的技术边界

当前链路是：

```text
电脑或系统虚拟摄像头
  → OpenCV 采集
  → MediaPipe Hands
  → JSON/UDP（localhost，仅关键点）
  → Godot HandTrackingReceiver
  → HandXRayOverlay
```

这条边界很好：视频帧和机器视觉都留在 Python 进程，Godot 只负责游戏状态与绘制。因此正式的手机方案只应替换“OpenCV 摄像头采集”这一段，不要重写后半段。

### 2. 调研对象比较

| 方案 / 参考实现 | 功能与架构 | 技术线 | 优点 | 缺点 / 风险 | 对本项目的判断 |
|---|---|---|---|---|---|
| [Apple Continuity Camera](https://support.apple.com/en-la/102546) | iPhone 被 macOS 直接枚举为摄像头 | Apple 系统级相机桥接；Wi‑Fi + Bluetooth | 零安装、低开发量、可直接复用 OpenCV 枚举 | 仅 Apple 生态；需要满足系统版本、Apple Account、距离及无线条件；不能覆盖 Windows/Android | **保留为测试阶段快捷路径** |
| [VDO.Ninja](https://github.com/steveseguin/vdo.ninja) | 手机浏览器发布摄像头，观看端通过 WebRTC 接收；含托管握手、STUN、可选 TURN、WHIP/WHEP 与自托管 | Browser WebRTC + WebSocket signaling + STUN/TURN | 成熟、低延迟、手机浏览器体验已经被大量使用；证明“链接即相机”可行 | 工程体量大；许可为“mostly open-source”而非简单 MIT；其 OBS/导播功能远超本项目需求；公网 TURN 有运营成本 | **学习配对和网络回退，不直接复制整库** |
| [PHONE_CAMERA](https://github.com/andrewaltair/PHONE_CAMERA) | PC 显示二维码；iPhone Safari 扫码；本地 Node 信令；视频 P2P | `getUserMedia` + WebRTC + WebSocket + mkcert HTTPS | 结构小，最接近目标交互；二维码、本地信令、浏览器授权链路清楚；MIT | 项目很新且规模小；开发流程要求手机信任本地 CA，普通玩家体验差；Safari 进入后台会中断；PIN/安全加固仍不完整 | **适合做 LAN 原型骨架，不适合原样发布** |
| [aiortc](https://github.com/aiortc/aiortc) | Python 原生 WebRTC/ORTC；接收媒体轨并可把帧转给 OpenCV | Python asyncio + ICE/DTLS/SRTP + VP8/H.264 + PyAV/OpenCV | BSD-3-Clause；与当前 Python/MediaPipe sidecar 同语言、同进程；无需让 Godot 解码视频 | 需要自行实现配对页、信令、重连与打包；编解码依赖增加 | **正式方案的首选接收端** |
| [MediaMTX](https://github.com/bluenviron/mediamtx) | 独立媒体路由器，支持 WebRTC/WHIP/WHEP/RTSP/RTMP/HLS，带认证、API、指标 | 单独服务进程 + 多协议媒体网关 | MIT；成熟、跨平台、单文件部署；重连、多流、录制扩展能力强 | 对“一台手机给一个本地游戏”偏重；还要把流解码后交给 MediaPipe；增加端口、配置与故障面 | **需要多流/录制/转发时再升级** |
| [Godot WebRTC / webrtc-native](https://docs.godotengine.org/en/4.6/tutorials/networking/webrtc.html) | Godot 中建立 WebRTC peer/data channel；原生导出依赖额外扩展 | Godot WebRTCPeerConnection + native GDExtension | 游戏内状态统一；数据通道适合控制消息 | 官方路径更偏 peer/data channel；把浏览器媒体轨直接送 MediaPipe 不如 Python 自然；增加各平台扩展构建与兼容测试 | **不作为视频入口；可选作未来控制通道** |
| [Android IP Camera](https://github.com/DigitallyRefined/android-ip-camera) | Android 安装应用后提供 H.264/MJPEG HTTPS 视频服务器 | 原生 Android + HTTP(S) stream | URL 直接、概念简单、可做密码/TLS | Android-only；玩家要装 App；MJPEG 带宽/延迟较高；H.264 解码与网络权限需要额外处理 | **只作无 WebRTC 环境的备选** |

补充事实：浏览器相机 API [`getUserMedia`](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia) 只在安全上下文中提供，并必须经过用户明确许可。因此“同一 Wi‑Fi 下显示一个 `http://192.168...` 二维码”不能作为通用成品；HTTPS 证书、权限说明与错误恢复是产品的一部分。

### 3. 推荐架构

```text
Godot 设置页
  ├─ 打开电脑摄像头 → 现有 OpenCV camera index
  └─ 连接手机摄像头 → 打开连接窗口
                         ├─ 会话二维码 / 6 位码 / 过期时间
                         ├─ 等待 → 授权 → 直连/中继 → 收到画面
                         └─ 重试 / 继续游戏 / 关闭摄像头

手机 HTTPS 网页
  → 明确点击“允许摄像头”
  → getUserMedia（默认后置或可切换）
  → WebRTC 视频轨
  → Python aiortc receiver
  → MediaPipe Hands
  → 原有 landmarks UDP schema
  → Godot X-ray

公网薄服务
  → HTTPS 静态配对页
  → WebSocket 信令（只交换 SDP / ICE / 会话状态）
  → STUN；仅 ICE 直连失败时使用 TURN
```

关键选择：**手机视频不经过信令服务器**；正常情况点对点传输，只有严格 NAT/蜂窝网络等直连失败时才走 TURN。VDO.Ninja 的项目说明称其典型连接中大多数为直连，并估计约 5% 远端来宾需要 TURN，这可作为容量预估而不是本项目 SLA。

### 4. 为什么不是“本地 HTTP + 二维码”

- iOS/Android 浏览器通常拒绝在非 HTTPS 页面开放相机。
- 开发阶段用 mkcert 并要求玩家安装根证书，既不可信也不可发布。
- 家用路由器可能启用客户端隔离；Windows/macOS 防火墙也可能阻断手机主动访问电脑端口。
- 公共 HTTPS 配对页 + 桌面端主动建立出站信令连接，不要求玩家理解 IP 地址或修改防火墙，覆盖率更高。

### 5. 会话、安全与隐私契约

- 二维码携带 128-bit 随机会话 token；另显示 6 位人工核对码。
- token 一次性、2 分钟过期、只允许一个发布者；连接后立即失效。
- 手机端必须显式点击后才请求摄像头；默认不请求麦克风。
- UI 明示“仅实时分析手部关键点，不录制、不上传视频”；关闭玩法时立即 `track.stop()` 并销毁 peer。
- Godot 状态区应展示 `local/direct/relay`、连接质量、实际相机与最后一帧时间；不要只显示一个容易误导的绿色按钮。
- 信令日志不记录 SDP、IP、token；TURN 凭据短期化；加入速率限制与会话所有权校验。

### 6. 分阶段实施方案

#### P0：当前测试版（本次已实现）

- 电脑与手机按钮互斥，点击哪个就启动哪个并让对应按钮进入选中绿色态。
- 手机连接窗口在点击手机按钮时一定出现；只有收到真实帧后才显示“已连接”，避免把“进程已启动”误报为相机成功。
- 当前手机入口明确说明依赖 Continuity Camera 或其他已经安装的虚拟摄像头。
- `source_ready(source, selected_index)` 把 sidecar 的真实来源与系统相机编号传回 UI。
- macOS `system_profiler` 返回空列表时，手机来源仍会尝试非 0 的 AVFoundation 槽位 1–5；0 号继续保留给电脑按钮，避免来源倒置。开发者可用 `BABEL_PHONE_CAMERA_INDEX` 显式覆盖特殊设备索引。

#### P1：LAN/browser 技术验证（建议 2–4 天）

- Python sidecar 加入 `aiortc` receiver 与最小 HTTPS/WS 信令。
- 手机页只做授权、前后摄像头切换、连接/断开、帧率降级。
- 使用开发证书验证端到端：手机帧 → MediaPipe → 同一 landmarks UDP 包。
- 指标：720p 输入、MediaPipe 目标 24–30Hz；同 LAN P95 关键点端到端延迟 < 180ms；断流 2 秒内 UI 可见。

#### P2：普通玩家配对（建议 1–2 周）

- 上线公共 HTTPS 配对页与轻量信令服务；加入 STUN/TURN。
- Godot 连接窗生成 QR、一次性码、到期倒计时、直连/中继状态。
- Windows + Android、Windows + iPhone、macOS + Android、macOS + iPhone 四组网络矩阵；家庭 Wi‑Fi、访客 Wi‑Fi、蜂窝网络分别测试。

#### P3：发布加固

- 把 Python/WebRTC/MediaPipe 依赖按平台打包并签名；崩溃/权限/编解码错误归一化为稳定错误码。
- 自适应分辨率与帧率；CPU 过载时先降输入帧率，不延迟积压旧帧。
- 只采集匿名连接阶段和延迟分桶；不采集视频、关键点或 IP 明文。

### 7. 可迁移接口

保持 Godot 侧接口不变：

```json
{
  "schema_version": 1,
  "timestamp_ms": 1786330000000,
  "mirrored": true,
  "camera_source": "phone",
  "selected_index": -1,
  "transport": "webrtc_direct",
  "hands": [
    {
      "handedness": "Right",
      "score": 0.98,
      "landmarks": [{"x": 0.5, "y": 0.3, "z": -0.02}]
    }
  ]
}
```

新增字段必须向后兼容；Godot 继续只依赖 `hands`。建议连接状态另走控制包：`pairing_waiting`、`permission_denied`、`ice_connecting`、`webrtc_direct`、`webrtc_relay`、`camera_stalled`、`peer_closed`。

---

## 二、X-ray 心理恐怖边框

### 1. 研究提炼

- 2025 年发表、2026 年刊载于 Nature 的[视频通话 glitch 研究](https://www.nature.com/articles/s41586-025-09823-0)通过五项实验、三项补充研究及现实数据发现：轻微、间歇的视听故障会打破“面对面”的错觉并产生 uncanny 感。对本项目的推论是：**罕见且短暂的失真比持续强噪声更像异常事件**。
- Tinwell 等人的[生存恐怖 uncanny 行为研究](https://intellectdiscover.com/content/journals/10.1386/jgvw.2.1.3_1)让 100 名参与者评价角色片段，运动、声音及不同步与怪异/恐惧评价有关。它支持“微小时间错位”这个方向，但该实验研究角色而非 HUD，因此这里只作为设计类比。
- Game Studies 对 *Anatomy* 的[分析](https://gamestudies.org/2403/articles/leblanc)把 programmed failure、found footage、低保真、崩溃与 glitch 视作玩家不适感和“游戏身体伤痕”的组成。它支持把边框做成偶尔失灵的窥视器，而不是装饰性霓虹框。
- [SIGNALIS 开发者文章](https://blog.playstation.com/2022/07/07/signalis-brings-multilayered-psychological-sci-fi-survival-horror-to-ps4-october-27/)强调 CRT、监控影像和官僚技术语言的组合；[FAITH 美术演讲](https://gdcvault.com/play/1026045/The-Art-of-FAITH-Horror)则说明受限的视觉语言也能建立强烈恐怖。两者共同支持克制、系统化的局部信号语言。
- 可复制的 [Godot 4 VHS shader](https://godotshaders.com/shader/retro-vhs-glitch-for-godot-4/) 提供 scanline、RGB shift、slicing、ghosting 等组件参考，但整套直接套入会与项目既有 VHS 画面重复，且降低 X-ray 内部可读性。

### 2. 方案比较

| 方案 | 功能 | 美观 / 叙事契合 | 复杂度 | 主要 bug / 风险 | 优缺点 | 决策 |
|---|---|---|---|---|---|---|
| A. `CanvasItem._draw()` 局部信号污染 | 矩形按四个指尖外接框绘制；色边错位、断裂报码、横向跳帧、扫线、伤痕 | 4.5/5；像被污染的医疗/监控终端，且能保持主体可读 | 低–中 | 关键点抖动、纹理采样区域、绘制顺序、线段越界 | 无额外 shader/viewport；形状精确；容易测试。纹理噪声丰富度有限 | **本次采用** |
| B. 边框专用 CanvasItem shader | 连续噪声、RGB 分离、侵蚀、边缘 mask | 4.5/5；可更有机 | 中 | 动态多边形 SDF/mask 难；材质参数同步；不同 GPU 编译差异 | 视觉上限高、运行成本可控；实现和调参成本高于当前需求 | 后续增强候选 |
| C. SubViewport + 后处理 | 对第二层窗口本身做扭曲、残影、色散 | 5/5；能制造“另一层正在反噬” | 高 | 额外显存、viewport 缩放、采样延迟、UI 层级/输入、窗口尺寸变化 | 最强叙事潜力；故障面最大 | 叙事确认后再做 |
| D. 全屏 CRT/VHS glitch | 直接覆盖全屏 scanline/噪声/扭曲 | 2/5；容易成为通用恐怖滤镜 | 低–中 | 可读性、眩晕/光敏、与既有 VHS 叠加、截屏/后处理次序 | 快、素材多；却无法强调“指尖窗口是异常源” | **拒绝** |

### 3. 本次采用的视觉参数

效果名：`babel_signal_contamination_v2`

- 主边：酸性黄绿色 2.4px；外层病态绿柔光约 1.2–1.85px；四角保留较粗的仪器锁定标记。
- 色边错位：锈红和低饱和青绿两层边框常驻约 2.5–3.5px 偏移；干扰爆发时红边可再错开约 8.5px，明确呈现信号分色而不是普通霓虹描边。
- 呼吸：两个非整倍频正弦叠加，避免机械的完美循环。
- 画面不同步：常驻一条低强度横向采样错位；每 1.15–2.80 秒爆发一次 120–220ms 的三段跳帧，最大位移 18px，且只采样 X-ray 窗口内部。
- 断裂报码：14 组沿边缓慢漂移的亮/锈红数据段叠加 4 处暗色 dropout，让边缘像正在丢包而不是完整 UI 线框。
- 扫描线：不是恒亮，按高次幂包络间歇显现。
- 爬行伤痕：沿边缘缓慢移动，强化“系统表面正在长出东西”的感觉。
- 双手矩形窗：以两只手各自的拇指、食指，共四个指尖的外接框真实裁切并显示第二层。

### 4. 手势与稳定性

当前矩形窗激活契约：

1. 单帧必须同时收到至少两只手；任意一只手丢失时立即取消当前窗口，不回退成单手或三指形状。
2. 每只手只读取 MediaPipe landmark 4（拇指尖）和 8（食指尖），合计四个指尖。
3. 四点外接框的宽度至少为画面宽度 7%，高度至少为画面高度 6%，避免指尖重合时生成不可操作的小窗。
4. 外接框位置和大小以 0.36 权重跨帧平滑，兼顾响应与抖动抑制。
5. 420ms 没有新手部帧即关闭窗口，避免“幽灵窗口”停留。

三指三角形在 2026-08-10 的实现测试中证明可绘制，但真机更容易丢失第三个有效点。当前产品决策是完全撤下该输入路径，而不是隐藏入口后继续保留自动判定。

### 5. 预期 bug 与验证项

| 风险 | 触发条件 | 当前防护 | 仍需真机验证 |
|---|---|---|---|
| 四指窗口丢失 | 任一只手被遮挡、低光、两手交叉 | 明确要求两只手；420ms 超时后关闭；不猜测缺失点 | 不同肤色/光照/左右手/两手交叠 |
| 窗口抖动 | MediaPipe landmark 噪声 | 外接框位置与尺寸 0.36 平滑 | 低帧率下是否拖尾过重 |
| 矩形纹理采样偏移 | 镜像状态或 viewport 尺寸变化 | 同一归一化矩形同时生成屏幕目标区和第二层采样区 | 实际第二层截图上检查方向与镜像 |
| 撕裂越出窗口 | 多段采样宽度或偏移过大 | 撕裂源和目标都从矩形局部计算，最大位移限制为 18px | 极窄窗口、4K 和窗口缩放 |
| 光敏/眩晕 | 高频全屏闪烁 | 无全屏效果、无周期强闪、短且低亮度 glitch | 增加“降低视觉干扰”设置，允许完全关闭 |
| 低端性能 | 大分辨率纹理、频繁重绘 | 仅活动窗口重绘；无 SubViewport / screen-copy | 1080p/4K 与集显 profiling |
| 第二层内容过时 | 第二层捕获更新时机错误 | 保持现有层纹理接口 | 场景切换、暂停、分辨率变化 |

### 6. 后续升级门槛

只有满足以下条件才值得从 A 升级到 B/C：

- 真机跟踪稳定，窗口本身已经可玩，而不是用视觉掩盖输入问题；
- 叙事明确“第二层会反向污染第一层”，需要窗口内部产生动态侵蚀；
- 低端目标机上有至少 2ms 的稳定 GPU 余量；
- 已加入降低动态效果/关闭 glitch 的无障碍选项。

---

## 三、实现与测试验收清单

- [x] 电脑/手机两个按钮互斥，来源和绿色选中态一致。
- [x] 点击手机按钮立即出现连接窗口。
- [x] 只有 sidecar 实际产生帧时才进入 ready 状态，并显示实际系统相机编号。
- [x] 只保留双手拇指与食指的四指矩形窗；单手输入不会激活 X-ray。
- [x] 局部信号污染边框；常驻分色/断裂可见，短促 glitch 有确定性测试钩子。
- [x] receiver 协议、localhost UDP、四指矩形、单手拒绝、超时和 glitch 核心测试。
- [x] 本机 MediaPipe 模型创建自检；电脑摄像头真实端到端帧流通过。
- [x] 手机来源真实扫描会尝试非 0 相机槽并把“设备不可用”传回连接窗；本次测试时系统没有枚举到手机镜头，因此不虚报手机视频已通过。
- [ ] 普通玩家的 QR/WebRTC 路线：本文完成研究和接口设计，尚未部署信令/TURN，也未伪装成已经完成。
- [ ] 跨设备真机矩阵与摄像头权限测试：需要实际 iPhone/Android/Windows/macOS 设备。

## 资料来源

- Apple: [Continuity Camera: Use iPhone as a webcam for Mac](https://support.apple.com/en-la/102546)
- MDN: [`MediaDevices.getUserMedia()`](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
- VDO.Ninja: [GitHub repository](https://github.com/steveseguin/vdo.ninja)
- PHONE_CAMERA: [GitHub repository](https://github.com/andrewaltair/PHONE_CAMERA)
- aiortc: [GitHub repository](https://github.com/aiortc/aiortc) and [server example](https://github.com/aiortc/aiortc/blob/main/examples/server/server.py)
- MediaMTX: [GitHub repository](https://github.com/bluenviron/mediamtx), [publish from browsers](https://mediamtx.org/docs/publish/web-browsers), [WebRTC clients](https://mediamtx.org/docs/publish/webrtc-clients)
- Godot: [WebRTC documentation](https://docs.godotengine.org/en/4.6/tutorials/networking/webrtc.html), [webrtc-native](https://github.com/godotengine/webrtc-native), [CanvasItem drawing](https://docs.godotengine.org/en/4.6/classes/class_canvasitem.html), [CanvasItem shaders](https://docs.godotengine.org/en/4.6/tutorials/shaders/shader_reference/canvas_item_shader.html), [screen-reading shaders](https://docs.godotengine.org/en/4.4/tutorials/shaders/screen-reading_shaders.html)
- DigitallyRefined: [Android IP Camera](https://github.com/DigitallyRefined/android-ip-camera)
- Brucks, Rifkin & Johnson: [Video-call glitches trigger uncanniness and harm consequential life outcomes](https://www.nature.com/articles/s41586-025-09823-0), Nature (published online 2025-12-03; volume 650, 2026)
- Tinwell, Grimshaw & Williams: [Uncanny behaviour in survival horror games](https://intellectdiscover.com/content/journals/10.1386/jgvw.2.1.3_1), 2010
- LeBlanc: [Gothic Gaming: The Ill Body and the Haunted House in Kitty Horrorshow’s Anatomy](https://gamestudies.org/2403/articles/leblanc), Game Studies, 2024
- [Doki Doki Subversion Club! Gothic Ghosts, Uncanny Glitches, and Abject Boundaries](https://press-start.gla.ac.uk/press-start/article/view/221)
- GDC Vault: [The Art of FAITH: Horror at 192x160 Pixels](https://gdcvault.com/play/1026045/The-Art-of-FAITH-Horror)
- GDC Vault: [Shape and Shadow: Creating Horror in The Callisto Protocol](https://www.gdcvault.com/play/1029307/Shape-and-Shadow-Creating-Horror)
- rose-engine: [SIGNALIS developer article](https://blog.playstation.com/2022/07/07/signalis-brings-multilayered-psychological-sci-fi-survival-horror-to-ps4-october-27/)
- Godot Shaders: [Retro VHS Glitch for Godot 4](https://godotshaders.com/shader/retro-vhs-glitch-for-godot-4/)
