# CuePartner AI — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
config_mode: local_only  
iap_opt_in: false（UltraLite `free_app_only`：本交付不含 StoreKit / 付费墙 / 金币 / ATT）

## 产品名称

**CuePartner AI**（开发包名 `com.lingguang.cuepartner`）

## 一句话

导入自有脚本照片做 OCR，与 AI 对戏伙伴按角色切换排练，用带节拍的 TTS 提词，可选舞台音床——本地保存场景与台词，不附带版权剧本。

## 目标用户

需要私下对词、背词、排练的演员与戏剧学生；希望手机端有「对手演员」与提词器，而不是通用聊天壳。

## 待完成工作（用户任务）

1. 新建 Scene，用相机拍或相册导入脚本页，OCR 后审阅保留。  
2. 整理角色与 CueLine，进入对戏聊天并切换伙伴扮演的角色。  
3. 用 TTS 按 timing 播报提词行；可选开启舞台音床。  
4. 录 Voice note 或语音识别说词，把转写文本喂入对戏伙伴（真机能力可标待测）。  
5. 人审确认 AI 回复后写入排练历史；重启后可继续。

## 核心循环

导入脚本页 → OCR 人审 → 对戏（角色切换）→ TTS 提词+时机 →（可选）音床 / Voice note → 确认写入历史

## 功能范围（本交付承诺）

- 相机拍摄脚本草稿页 + 相册导入（`PhotoImportSession` / Camera）
- OCR 文本草稿 + 人审 Keep / Discard / Edit text
- Scene / ScriptPage / CueLine / RehearsalMessage / VoiceNote 本地持久化
- AI 对戏伙伴聊天、角色切换、发送前同意门
- TTS cue 播报与节拍/停顿
- 可选本地舞台音床
- 麦克风 Voice note + Speech → 文本进入伙伴输入
- Info.plist 四项隐私文案（Camera / Photo Library / Microphone / Speech Recognition）
- 应用内本地隐私/条款/支持页；设置内可撤销 AI 同意
- 用户自带脚本；不附带版权剧本库

## 明确不做

- StoreKit / 付费解锁无限场景与角色声线 / 订阅 / 金币（操作者 paid/unlock 意图记交付后 gap）
- ATT / 广告追踪
- 复制 LineLearner 品牌、UI、资产或声称授权剧本
- CloudKit 同步（未配置 = gap）
- 出厂附带版权剧本或「官方剧本库」

## 语言与平台

- 产品文档：zh-CN  
- 应用界面主语言：en-US  
- 平台：iOS 17+ SwiftUI；开发 Bundle ID `com.lingguang.cuepartner`

## 应用简介（商店向草稿）

CuePartner AI is your AI rehearsal partner. Import your own script photos, OCR the pages, chat as a scene partner with role switching, hear timed cue lines, and optionally add stage ambience. Review every AI turn before it sticks. You bring the script—we never ship copyrighted plays. Offline on saved scenes; live AI needs your configured key.
