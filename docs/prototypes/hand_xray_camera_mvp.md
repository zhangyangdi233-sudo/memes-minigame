# 双手指尖 X-ray 摄像头 MVP

## 机制与主线契合

第一层继续使用现有的实时 3D “现实”画面；第二层是玩家刚刚看到的手机/社交界面。玩家放下手机后，用两只手的拇指尖和食指尖在镜头前围出一个矩形，矩形内部重新显露刚才的手机层。这样，“语言污染”不只修改文本，也会让媒介层残留在现实中：玩家用自己的手主动选择哪一块现实值得被另一层解释或污染。

## MVP 范围

- 本地 Python MediaPipe Hand Landmarker 同时跟踪两只手、每只手 21 个关键点。
- 默认只选择电脑摄像头；只有玩家明确切换到“手机摄像头（备用）”时，才寻找 macOS 连续互通相机或第三方虚拟摄像头。
- UDP 只发送归一化关键点，不发送、保存或上传摄像头画面。
- 四个指尖（双手拇指尖、食指尖）的包围盒形成稳定 X-ray 区域。
- Godot 在从手机层切到现实层前缓存当前合成画面，并只在指尖矩形中裁切显示。
- 每次启动先明确询问是否启用镜头；设置中提供“电脑摄像头”和“连接手机”两个直接入口，并保留一个许可总开关。
- X-ray 边框有克制的呼吸辉光、扫描线和沿框微光点，不干扰四个指尖锚点。
- 无镜头时可用 sidecar 的 `--simulate` 走完全相同的数据协议验证。

## 明确不做

- 不把摄像头原始画面显示在游戏里。
- 不录制、不存档、不联网传输视频帧。
- 不做任意透视四边形、遮挡深度或手部语义手势分类；本轮只验证矩形窗口。
- 不为发布包内嵌 Python 运行时或完成 macOS 签名/公证；本轮目标是 Godot 编辑器中的实际可运行验证。
- 不制作手机端 companion App、二维码配对或自定义视频传输协议；手机备用必须先由操作系统/虚拟摄像头软件暴露为标准摄像头。
- 不改写两层现有美术和玩法内容，也不把用户提供的截图当作静态游戏层。

## 运行边界

编辑器版通过项目内 `.venv` 启动 sidecar。macOS 首次打开摄像头时，系统权限归属于该 Python 可执行文件。未来导出独立应用时，应把追踪改为原生 GDExtension 或正式嵌入并签名 helper，同时在 macOS 导出预设中填写摄像头用途说明。

## 本地运行

```bash
cd /Users/zhang/Documents/游戏/babel-meme-game
bash tools/hand_tracking/setup_macos.sh
/Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot --path .
```

进入流程：启动授权页保留“电脑摄像头（默认）”，只有电脑没有镜头时才选“手机摄像头（备用）” → 选择“允许并打开摄像头”或“暂不使用” → 开始/继续游戏 → 在手机层浏览想要保留的画面 → “放下手机” → 将双手拇指尖与食指尖放进镜头并围出矩形。按 `Tab` 或画面底部按钮可在手机层与现实层之间切换；设置中的“打开电脑摄像头并开启 X-ray”与“连接手机摄像头并开启 X-ray”两个按钮可直接切换来源，“允许访问摄像头”是总开关；主菜单/设置中的退出按钮可退出。X-ray 边框使用轻微呼吸光、稀疏扫描线和沿框微光点，不改变指尖定位几何。

本机枚举结果：`camera index 0 = MacBook Pro 相机`，`camera index 1 = iPhone17,1 连续互通相机`，两者均通过 `1280×720` 单帧读取测试。sidecar 在 macOS 上使用 `system_profiler SPCameraDataType` 的设备型号区分电脑与手机，因此不会因为手机恰好在线就把它误当作默认电脑镜头。

测试：

```bash
/Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_hand_xray.gd
BABEL_TEST_CAMERA_RUNTIME=1 /Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/test_hand_tracking_runtime.gd
```

官方模型文件位于 `tools/hand_tracking/models/hand_landmarker.task`，本次下载文件的 SHA-256 为 `fbc2a30080c3c557093b5ddfc334698132eb341044ccee322ccf8bcf3607cde1`。

## 可迁移接口

- Python → Godot：localhost UDP，默认 `127.0.0.1:7001`，`schema_version = 1`，每帧最多两只手、每只手 21 个归一化关键点。
- Godot 接收：`HandTrackingReceiver.frame_received(hands, timestamp_msec)`；错误与权限状态由 `status_changed(status)` 回传。
- 合成层：`HandXRayOverlay.set_layer_texture(texture)`、`set_tracking_enabled(enabled)`、`ingest_hands(hands)`。
- 第二层提供方：当前由 `_capture_phone_layer_for_xray()` 在手机层切换前生成 `ImageTexture`；未来可无缝替换为独立 `SubViewport` 的实时纹理。
