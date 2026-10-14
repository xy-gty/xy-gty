# PitchCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
config_mode: local_only  
iap_opt_in: false（UltraLite `free_app_only`：本交付不含 StoreKit / 付费墙 / 金币 / ATT）

## 产品名称

**PitchCue**（开发包名 `com.lingguang.pitchcue`；工程目录 `pitchcue/`）

## 一句话

导入乐谱或指法练习照片，用 AI 教练聊出热身计划，TTS 倒数与提示，本地 drone/metronome 床陪练，可选麦克风圆形调音盘反馈——定位练习教练，不是调音器克隆。

## 目标用户

需要结构化热身与陪练节奏的器乐练习者（弦乐/管乐/键盘等）；要计划与反馈闭环，而不只是盯着调音针。

## 待完成工作（用户任务）

1. 新建练习会话，拍摄或导入乐谱/练习照片。  
2. 与教练聊天设定目标，审阅热身/练习计划草稿，Keep / Edit / Discard。  
3. 用 TTS 听倒数与口语提示；启动本地 drone 或 metronome 床并看连续波形。  
4. 沿水平练习条推进步骤；可选打开麦克风圆形调音盘看音高偏差。  
5. 重启后仍可读已确认计划与会话历史；反馈进入下一次教练调用。

## 核心循环

导入乐谱图 → AI 热身计划（人审）→ TTS 倒数 → drone/metronome 陪练 → 可选 mic 音高反馈 → 保存会话

## 功能范围（本交付承诺）

- 相机/相册导入乐谱与练习照片（`PhotoImportSession`）
- 练习会话 / 计划 / 聊天轮次本地持久化
- AI 热身与练习计划聊天（发送前同意门；人审确认后才写入）
- TTS 倒数与口语教练提示
- 本地合成 drone / metronome 床 + 连续波形
- 水平练习条 + 圆形调音盘；可选 mic 音高/节奏反馈
- 应用内本地隐私/条款/支持页；设置内可撤销 AI 同意
- Simulator 锁定 iPhone 17 Pro

## 明确不做

- StoreKit / 解锁练习包付费墙 / 订阅 / 金币目录（操作者 paid 意图记为交付后 gap）
- ATT / 广告追踪
- 克隆 TonalEnergy 调音壳或 CuePartner script-timeline UI
- 全黑壳 UI
- 本轮 AppIcon / launch/splash 生图（操作者硬约束）
- CloudKit 同步（未配置 = gap）
- 专业测听诊断、听力医疗声明
- 账户体系 / 多用户云端协作

## 语言与平台

- 产品文档：zh-CN  
- 应用界面主语言：en-US（操作者创意为英文定位）  
- 平台：iOS 17+ SwiftUI；开发 Bundle ID `com.lingguang.pitchcue`  
- 交付远端：`git@github.com:xy-gty/xy-gty.git`；飞书交付行 skip

## 应用简介（商店向草稿）

PitchCue is an AI practice coach for instrumentalists. Import sheet photos, chat warm-up plans, hear TTS count-ins, play local drone or metronome beds, and optionally check pitch on a circular dial—review every AI plan before it sticks. Coaching aid only, not a medical or pro tuner replacement.
