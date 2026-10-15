# FrameCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
ui_language: en-US  
docs_language: zh-CN

## One-liner（交付 / 商店语气）

FrameCue is an AI director framing coach: shoot or import stills, keep reviewed composition notes, chat shot size and lens language, mark safe-frame overlays on a clapper canvas, and hear on-set TTS cues hands-free.

## Core job

拍或导入一张静帧 → AI 指出构图问题草稿 → Keep 落成构图要点 → 同一会话里在场记板画幅框内看画面、底部景别芯片切换 ECU/CU/MS/WS → 聊天景别/画幅/焦段 → 生成安全框与三分法叠图 → TTS 现场口令；双手持机时可口述「切中景」。

## 目标用户

独立导演 / 摄像助理 / 短片创作者：片场或勘景时需要快速景别与构图反馈，而不是只看专业相机画幅预览器。

## 市场定位（外部给定，不另做发现）

相对 Cadrage Director's Viewfinder（`com.distantblue.Cadrage`）重做定位：**构图/景别对话教练 + 叠图**，不是克隆 Cadrage 品牌/资产/chrome 的纯画幅预览。不孪生 RuleCue（桌区卡+步进条）/ StopCue（胶片齿孔时间线）/ NightCue（夜框轨）布局。

## 核心循环

1. Camera / Photos 拍或导入静帧  
2. AI 构图问题草稿 → Keep / Discard / Edit  
3. SlateStage：场记板画幅框 + 底部景别芯片条  
4. Coach chat 景别 / 画幅比 / 焦段语言  
5. 安全框 / 三分法 / 画幅叠图确认  
6. TTS 现场导演口令  
7. 麦克风 + 语音识别：口述景别写入聊天并刷新叠图  

## 功能范围

- 会话列表与新建 FramingSession  
- 拍照 / 相册导入 FrameStill  
- CompositionReview 人审  
- ShotSizePlan 芯片条导航（ECU/CU/MS/WS/EWS）  
- ClapperFrameCanvas 场记板式画幅框  
- Coach chat + TurnReview  
- OverlayMarks（safe-frame / rule-of-thirds / aspect）  
- Hands-free TTS  
- DictateShot  
- Settings：同意撤销、四权限文案、本地法律页  

## 明确不做（本 UltraLite 包）

- StoreKit / 付费墙 / 金币 / ATT（操作者 one-time unlock framing packs → gap `operator_pricing_deferred_free_app_only`）  
- 克隆 Cadrage UI 或第三方取景器品牌资产  
- AppIcon / LaunchScreen 本轮生成  
- 实时多机位导播台、LUT 调色、专业 RAW 管线  
- CloudKit 同步（未配置记 gap）  

## 平台与交付

- iOS SwiftUI；Simulator 验收设备：**iPhone 17 Pro ONLY**（prefer B14CC0EA；禁止 Pro Max）  
- development_bundle_id: `com.lingguang.framecue`  
- product_dir（交付）: `framecue/`（symlink `framecue→product`）  
- delivery_remote: `git@github.com:xy-gty/xy-gty.git`（独立分支优先）  
- Feishu CONTROLLER_DELIVERY: skip（operator）

## 应用简介（可交付）

FrameCue coaches on-set framing: capture a still, keep AI composition notes, switch shot sizes on a bottom chip bar inside a clapper frame canvas, mark safe-frame overlays, and take TTS director cues while your hands stay on the camera.
