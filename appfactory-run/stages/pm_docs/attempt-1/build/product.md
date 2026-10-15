# HiveCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
ui_language: en-US  
docs_language: zh-CN

## One-liner（交付 / 商店语气）

HiveCue is an AI hive-inspection coach: snap brood frames, keep reviewed brood / stores / pest findings, chat next actions, mark heat overlays, and dictate notes hands-free while suited.

## Core job

掀盖看脾时拍一张巢脾 → AI 给出蜂子/储蜜/虫害草稿 → Keep 落成 Finding → 同一巡检里用蜂巢网格与巡检轨推进各脾位 → 需要时聊天问下一步、在热力叠图上确认标注、TTS 免提念笔记；戴手套时可口述巡检字段。

## 目标用户

管理少量至中等规模蜂箱、需要箱旁快速记录与 AI 下一步建议的 iPhone 养蜂人（双手常戴手套 / 穿蜂衣）。

## 市场定位（外部给定，不另做发现）

相对 BeePlus Beekeeping Manager（`uk.co.omnichrome.beeplus`）重做定位：**AI 巢脾巡检教练**，不是克隆 BeePlus 品牌/资产/chrome。不孪生 FormCue / YarnCue 布局。

## 核心循环

1. Camera / Photos 拍或导入巢脾  
2. AI 蜂子 / 储蜜 / 虫害草稿 → Keep / Discard / Edit  
3. InspectionCoach：蜂巢网格 + 巡检轨 + 热力叠图  
4. Coach chat 问下一步动作  
5. 标注叠图确认  
6. TTS 免提巡检笔记  
7. 麦克风 + 语音识别：口述巡检字段  

## 功能范围

- 巡检列表与新建 Inspection  
- 拍照 / 相册导入 FrameShot  
- BroodReview 人审  
- HexCombGrid 脾位导航  
- InspectionRail 当前脾位推进  
- Heat overlay 标注  
- Coach chat + TurnReview  
- Hands-free TTS  
- DictateFields  
- Settings：同意撤销、四权限文案、本地法律页  

## 明确不做（本 UltraLite 包）

- StoreKit / 付费墙 / 金币 / ATT（操作者 one-time unlock / apiary packs → gap `operator_pricing_deferred_free_app_only`）  
- 克隆 BeePlus UI 或第三方养蜂品牌资产  
- AppIcon / LaunchScreen 本轮生成  
- 兽医诊断、用药处方、HealthKit 临床数据  
- CloudKit 同步（未配置记 gap）  

## 平台与交付

- iOS SwiftUI；Simulator 验收设备：**iPhone 17 Pro ONLY**  
- development_bundle_id: `com.lingguang.hivecue`  
- product_dir（交付）: `hivecue/`（symlink hivecue→product）  
- delivery_remote: `git@github.com:xy-gty/xy-gty.git`（独立分支优先）  
- Feishu CONTROLLER_DELIVERY: skip（operator）

## 应用简介（可交付）

HiveCue coaches hive inspections: capture a brood frame, keep AI brood / stores / pest notes, navigate frames on a hex comb grid with an inspection rail, confirm heat overlays, and dictate fields while your gloves stay on.
