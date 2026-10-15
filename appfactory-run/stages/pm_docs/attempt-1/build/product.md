# StopCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
ui_language: en-US  
docs_language: zh-CN

## One-liner（交付 / 商店语气）

StopCue is an AI stop-motion coach: capture or import frame sequences, keep reviewed shot plans and timing, chat for storyboard beats, confirm onion-skin guides, and hear TTS countdown cues while you shoot.

## Core job

定格现场拍/导入一串帧 → AI 给出分镜与间隔草稿 → Keep 落成 TimingCue / OnionSkinGuide → 同一项目里用胶片齿孔时间轴推进各帧 → 需要时聊天问分镜、在洋葱皮叠层上确认标注、TTS 倒计时口令；拍摄中可口述间隔/口令字段。

## 目标用户

用 iPhone 做定格动画、需要现场分镜建议与拍摄节拍提示的创作者（双手常扶相机/桌面布景）。

## 市场定位（外部给定，不另做发现）

相对 Stop Motion Studio Pro（`com.cateater.funapps.stopmotionstudiopro`）重做定位：**AI 定格动画教练**，不是克隆 Studio Pro 品牌/资产/chrome。不孪生 NightCue 夜景帧轨/曝光诊断叠层，不孪生 CuePartner / HiveCue / FormCue / YarnCue / ScoutCue 布局。

## 核心循环

1. Camera / Photos 拍或导入帧序列  
2. AI 分镜 / 间隔草稿 → Keep / Discard / Edit  
3. StopCoach：胶片齿孔时间轴 + 洋葱皮叠层预览  
4. Coach chat 问分镜与间隔  
5. 洋葱皮标注确认  
6. TTS 倒计时口令  
7. 麦克风 + 语音识别：口述间隔/口令字段  

## 功能范围

- 项目列表与新建 Project  
- 拍照 / 相册导入 FrameSequence  
- FrameReview 人审  
- FilmSprocketTimeline 帧推进  
- Onion-skin overlay 标注  
- Coach chat + TurnReview  
- Countdown TTS  
- DictateInterval  
- Settings：同意撤销、四权限文案、本地法律页  

## 明确不做（本 UltraLite 包）

- StoreKit / 付费墙 / 金币 / ATT（操作者 one-time unlock / unlimited projects → gap `operator_pricing_deferred_free_app_only`）  
- 克隆 Stop Motion Studio Pro UI 或第三方相机品牌资产  
- NightCue 式夜景曝光诊断主路径  
- AppIcon / LaunchScreen 本轮生成  
- CloudKit 同步（未配置记 gap）  

## 平台与交付

- iOS SwiftUI；Simulator 验收设备：**iPhone 17 Pro ONLY**（prefer UDID B14CC0EA；禁止占用 Pro Max 315A7C2C）  
- development_bundle_id: `com.lingguang.stopcue`  
- product_dir（交付）: `stopcue/`（symlink stopcue→product；禁止只留 product/）  
- delivery_remote: `git@github.com:xy-gty/xy-gty.git`（独立分支优先）  
- Feishu CONTROLLER_DELIVERY: skip（operator）

## 应用简介（可交付）

StopCue coaches stop-motion shoots: capture a frame sequence, keep AI shot-plan and timing notes, advance frames on a film-sprocket timeline with onion-skin overlays, confirm annotated guides, and dictate interval cues while your hands stay on the set.
