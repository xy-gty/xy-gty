# YarnCue — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
config_mode: local_only

## 一句话

YarnCue 是免费的 AI 编织/钩针教练：拍或导入纱线与 WIP 照片，识别针法与行，用 weave-coach 聊「下一行」，在 WIP 上标注示意，并用 TTS 免提播报，双手可继续握针。

## 目标用户

正在编织或钩针、需要边做边问「下一行怎么织」的爱好者；双手常占着针，需要口述备注与语音播报。

## 待完成工作

把「看不清 WIP → 猜下一针」变成：照片 → 识别审阅 → 横向下一行步骤 → 教练聊天 / 标注图 / TTS。

## 核心循环

1. 新建 Project → 相机拍或相册导入纱线/WIP  
2. 针法/行识别草稿 → Keep / Discard / Edit  
3. ProjectCoach：毛线球色卡条 + 横向「下一行」步骤带  
4. 向 weave-coach 问下一行（同意后门后出站）→ 人审 Keep  
5. 在 WIP 上确认标注示意  
6. TTS 免提播报当前/下一行；麦克风口述备注或行意图  

## 功能范围

**做：** 相机/相册、识别审阅、教练聊天、标注图、TTS、口述/语音识别、本地持久、同意门、本地法律页。  
**不做（本交付）：** StoreKit / 付费花样包 / 付费墙 / 金币 / ATT；Ravelry 式社区壳；AppIcon/LaunchScreen 生图；KnotCue/ScoutCue/ClosetCue/PitchCue 布局孪生。

## 语言与平台

- UI：en-US  
- 文档：zh-CN  
- 平台：iOS SwiftUI；验收模拟器仅 iPhone 17 Pro  
- development_bundle_id：`com.lingguang.yarncue`  
- 交付产品目录名：`yarncue/`

## 定位对照

相对 Ravit：强调 weave-coach「下一行」教练链（识别→步骤带→聊天→标注→TTS），不是目录浏览壳。禁止 Ravelry 壳孪生。

## 应用简介（可交付）

YarnCue coaches your next knitting or crochet row from your own yarn and WIP photos—recognize stitches, chat the next step, annotate the work-in-progress, and hear hands-free TTS while both hands stay on the needles.

## Commerce

free_app_only。操作者 paid packs 意图 → gap `operator_pricing_deferred_free_app_only`。
