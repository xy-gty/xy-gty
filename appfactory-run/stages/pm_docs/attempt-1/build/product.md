# RuleCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
ui_language: en-US  
docs_language: zh-CN

## One-liner（交付 / 商店语气）

RuleCue is an AI board-game rules and setup coach: snap or import rulebook and table photos, keep reviewed components and turn steps, chat for rulings, confirm annotated zone overlays, and hear TTS table-host cues while you set up.

## Core job

桌游开局前拍/导入规则书与桌面 → AI 识别组件与回合阶段草稿 → Keep 落成 ComponentMap / PhaseStep / SetupOverlay → 同一局里用桌面分区卡与回合步骤条推进 → 需要时聊天问裁决、在分区叠图上确认标注、TTS 边摆边讲；双手摆台时可口述规则问题写入教练会话。

## 目标用户

用 iPhone 在实体桌边摆台、需要规则裁决与摆台步骤提示的桌游玩家 / 桌主（双手常扶组件与规则书）。

## 市场定位（外部给定，不另做发现）

相对 Board Game Stats（`nl.vissering.BoardGameStats`）重做定位：**规则与摆台 AI 教练**，不是对局统计。不孪生 StopCue film-sprocket / 洋葱皮，不孪生 NightCue night-frame rail，不孪生 HiveCue / FormCue / YarnCue / ScoutCue 布局。

## 核心循环

1. Camera / Photos 拍或导入规则书页与桌面照  
2. AI 组件 / 阶段草稿 → Keep / Discard / Edit  
3. TableCoach：桌游桌面分区卡 + 回合步骤条  
4. Coach chat 问裁决与回合流程  
5. 摆台分区标注确认  
6. TTS 桌面主持口令  
7. 麦克风 + 语音识别：口述规则问题 → 教练 chat → 下一条 tip  

## 功能范围

- 对局会话列表与新建 GameSession  
- 拍照 / 相册导入 TablePhoto  
- ComponentReview 人审  
- TableZoneCards 分区推进  
- TurnStepBar 回合步骤  
- Setup overlay 标注  
- Coach chat + TurnReview  
- Host TTS  
- DictateRules 口述  
- Settings：同意撤销 / 本地法律页 / 四权限说明  

## 明确不做

- StoreKit / 付费墙 / 金币 / ATT（UltraLite free_app_only；操作者 paid unlock 记 gap）  
- AppIcon / LaunchScreen 本轮不生成  
- 对局胜负统计、记分板（留给 Board Game Stats 品类）  
- 在线多人同步桌 / CloudKit 同步（CloudKit UNKNOWN gap）  

## 语言与平台

- UI：en-US（大字号可读）  
- 文档：zh-CN  
- iOS SwiftUI；Simulator 锁定 iPhone 17 Pro（prefer B14CC0EA）；禁止占用 Pro Max  

## First glance

1. 冷启动看见什么？SessionsHome 空态 + 淡色桌面分区卡剪影 + amber **+ New session**（传统桌面工作面，不是聊天壳）。  
2. 第一个真实任务？拍/导入规则书或桌面 → ComponentReview Keep。  
3. AI 从哪召唤？TableCoach 上的 Chat / Overlay / Host / Dictate（从分区卡或步骤条对象进入）。  
4. 结果落在哪？同一 GameSession 的 ComponentMap / PhaseStep / SetupOverlay / CoachMessage。  
5. 与孪生品如何一眼不同？桌游桌面分区卡 + 回合步骤条；色表 #854D0E/#FEFCE8/#0891B2；绝无胶片齿孔、夜景帧轨、蜂巢/chip/毛线/星历壳。  

## 市场四问（操作者锁定创意，不作内部发现）

| 问 | 答 |
|----|-----|
| 用户是谁 | 实体桌游玩家/桌主，开局前需要规则与摆台协助 |
| 需求是什么 | 规则书难查、摆台易漏、双手占用时需要口头问答与步骤口令 |
| App 做什么 | 拍/导入 → 识别组件与阶段 → 分区卡/步骤条推进 → 聊天裁决 → 叠图与 TTS |
| 价值是什么 | 更快正确开局，减少翻书与漏放；本地会话可重启续摆 |

idea_source: operator_external — 不编造机会论证或受众漏斗数字。
