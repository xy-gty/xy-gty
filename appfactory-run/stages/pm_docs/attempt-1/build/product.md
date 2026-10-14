# ScoutCue — product.md

idea_source: operator_external  
ai_profile: ultra_lite  
commerce: free_app_only（operator paid packs deferred）

## 一句话

ScoutCue 是 AI 外拍侦察与光位 timing 规划器：拍/导入风景 → 识别成 Scout 卡 → 天空弧看日/月黄金窗 → 向导聊天与叠标 → TTS 下一站简报。

## 目标用户

周末与旅行中想在黄金时段拍出可用风光的进阶爱好者与半职业外拍者；需要在现场快速决定「去哪、何时、怎么站」，而不是测距工具或绳路径轮播。

## 待完成工作（Job）

在外拍前/现场，把已有或刚拍的风景变成可执行的 timed scout plan：窗口、叠标、下一站口述简报。

## 核心循环

1. 拍摄或导入风景  
2. 场景识别 → Scout 卡片（人审 Keep / Discard / Edit）  
3. 天空弧上浏览日/月与黄金窗  
4. 与向导聊 timing；确认后写入计划  
5. 在图上加黄金时段软叠标  
6. TTS 播报下一站简报；麦克风口述备注进计划  

## 功能范围

- Camera + Photos 导入  
- 场景识别卡 + 本地持久  
- Coach chat（sun/moon / golden-hour）  
- Golden-hour overlay annotations（软标注，非测距尺）  
- TTS next-stop briefings  
- Mic + Speech 口述意图  
- Sky-arc timeline + soft card stack IA  

## 明确不做

- StoreKit / 付费墙 / 金币 / ATT（独立商业化链）  
- DimCue 测距叠层 twin / KnotCue 绳路径轮播 twin / 全黑壳  
- AppIcon / LaunchScreen 生图（本轮）  
- 声称官方天文台或专业测光仪器  

## 语言与平台

- UI：en-US  
- 手册：zh-CN  
- iOS SwiftUI；交付目录名 `scoutcue/`；开发包名 `com.lingguang.scoutcue`  
- Simulator：iPhone 17 Pro ONLY  

## 应用简介（交付可用）

ScoutCue helps you scout scenery and plan golden-hour timing. Import or shoot a landscape, get a scout card, chat sun and moon windows on a sky-arc timeline, mark soft golden-hour overlays, and hear the next-stop shoot briefing—free local planning with optional AI coach when configured.

## First glance

1. 打开即见软风景卡片堆 + 顶部天空弧（空态示意今日窗口），不是聊天空白页。  
2. 主 CTA：Capture / Import scenery。  
3. 次要：Open coach / See windows（有卡后）。  
4. 品牌色 indigo `#4338CA` + wash `#EEF2FF` + rose accent `#FB7185`。  
5. 首拍路径：导入一张样例风景 → Keep 成 Scout 卡 → 天空弧高亮黄金窗。
