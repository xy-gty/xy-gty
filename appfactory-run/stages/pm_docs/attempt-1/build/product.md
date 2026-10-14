# BendCoach AI — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
config_mode: local_only  
iap_opt_in: false（UltraLite `free_app_only`：本交付不含 StoreKit / 付费墙 / 金币 / ATT）

## 产品名称

**BendCoach AI**（开发包名 `com.lingguang.bendcoach`）

## 一句话

面向电工的导管弯曲现场教练：用英文聊天算弯管量，导入或拍摄工地照片识别弯型与标记，生成示意图叠加，再用 TTS 逐步口述现场辅导——数值一律标注为辅助建议。

## 目标用户

在工地或厢式车旁需要快速核对 90° / offset / saddle 等弯管标记与步骤的电气安装工与学徒；要的是「敢下手弯」的可审阅辅导，不是又一个品牌计算器壳。

## 待完成工作（用户任务）

1. 打开教练首页，用文字或语音问弯管数学（当前单位制清晰可见）。  
2. 拍或导入工地弯管/标记照片，审阅 AI 弯型草稿后确认写入 Job。  
3. 生成 diagram overlay，人审 Use/Discard 后保存。  
4. 播放 TTS 逐步现场辅导；可暂停/下一步。  
5. 在设置切换 imperial/metric，阅读本地隐私页并管理 AI 同意。

## 核心循环

弯管数学聊天 → 照片导入/识别 → 人审标记 → 示意图叠加 → TTS 逐步辅导

## 功能范围（本交付承诺）

- 弯管数学聊天（DeepSeek 出站；无 key 时本地演示弯包 + 诚实未配置）  
- 相机拍摄 + 相册导入工地照片（四权限齐备）  
- 麦克风口述 + 语音识别写入聊天  
- 弯型/标记识别草稿 + Save / Not this / Edit marks  
- Diagram overlay 生成与本地保存  
- TTS 逐步辅导  
- 单位制切换与解释  
- Assistive-not-code disclaimer  
- 应用内本地隐私/条款/支持页；设置内撤销 AI 同意  
- 隐私本地优先：最小化云端保留工地照片

## 明确不做

- StoreKit / 一次性解锁 pro bend packs 付费墙 / 订阅 / 金币目录（操作者 paid 意图记为交付后 gap）  
- ATT / 广告追踪  
- 复制 QuickBend 品牌、UI、资产或未授权抓取  
- CloudKit 同步（未配置 = gap）  
- 宣称替代规范表、工程师盖章或官方认证  
- 账户体系 / 多用户协作云端

## 语言与平台

- 产品文档：zh-CN  
- 应用界面主语言：en-US（操作者创意为英文定位）  
- 平台：iOS 17+ SwiftUI；开发 Bundle ID `com.lingguang.bendcoach`

## 应用简介（商店向草稿）

BendCoach AI is a field conduit-bending coach for electricians. Ask bend math in plain English, import job-site photos to review bend marks, generate diagram overlays, and hear step-by-step TTS coaching. Numbers are assistive only—not a substitute for code or engineer judgment. Switch imperial/metric anytime. Works offline on saved jobs; live AI needs your configured key.
