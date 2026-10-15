# NightCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
ui_language: en-US  
docs_language: zh-CN

## One-liner（交付 / 商店语气）

NightCue is an AI night long-exposure coach: shoot or import night test frames, keep reviewed exposure and noise findings, chat for settings, confirm diagnosis overlays, and hear field cues while you stay on the tripod.

## Core job

夜拍现场拍一张试片 → AI 给出曝光/噪点/拖影草稿 → Keep 落成 DiagnosisFinding → 同一会话里用夜景帧轨推进各试片 → 需要时聊天问参数、在曝光诊断叠层上确认标注、TTS 现场口令；手持三脚架时可口述曝光字段。

## 目标用户

在城市天际线、星空、光轨等场景做长曝光、需要现场快速诊断与参数建议的 iPhone 夜拍爱好者（双手常扶三脚架 / 遥控器）。

## 市场定位（外部给定，不另做发现）

相对 NightCap Camera Long Exposure（`com.interealtime.LightBoost`）重做定位：**AI 夜景长曝光教练**，不是克隆 NightCap 品牌/资产/chrome。不孪生 HiveCue / FormCue / YarnCue 布局。定位 ≠ ScoutCue（太阳/星历侦查）。

## 核心循环

1. Camera / Photos 拍或导入夜景试片  
2. AI 曝光 / 噪点 / 拖影草稿 → Keep / Discard / Edit  
3. NightCoach：夜景帧轨 + 曝光诊断叠层  
4. Coach chat 问参数（ISO / shutter / focus）  
5. 标注叠图确认  
6. TTS 现场口令  
7. 麦克风 + 语音识别：口述曝光字段  

## 功能范围

- 会话列表与新建 Session  
- 拍照 / 相册导入 NightFrame  
- ExposureReview 人审  
- NightFrameRail 试片推进  
- Exposure-diagnosis overlay 标注  
- Coach chat + TurnReview  
- Field-cue TTS  
- DictateExposure  
- Settings：同意撤销、四权限文案、本地法律页  

## 明确不做（本 UltraLite 包）

- StoreKit / 付费墙 / 金币 / ATT（操作者 one-time unlock / night packs → gap `operator_pricing_deferred_free_app_only`）  
- 克隆 NightCap UI 或第三方相机品牌资产  
- ScoutCue 式太阳/星历侦查主路径  
- AppIcon / LaunchScreen 本轮生成  
- CloudKit 同步（未配置记 gap）  

## 平台与交付

- iOS SwiftUI；Simulator 验收设备：**iPhone 17 Pro ONLY**（prefer UDID B14CC0EA；禁止占用 Pro Max 315A7C2C）  
- development_bundle_id: `com.lingguang.nightcue`  
- product_dir（交付）: `nightcue/`（symlink nightcue→product；禁止只留 product/）  
- delivery_remote: `git@github.com:xy-gty/xy-gty.git`（独立分支优先）  
- Feishu CONTROLLER_DELIVERY: skip（operator）

## 应用简介（可交付）

NightCue coaches night long exposures: capture a test frame, keep AI exposure and noise notes, advance frames on a night-frame rail with diagnosis overlays, confirm annotated marks, and dictate ISO or shutter while your hands stay on the tripod.
