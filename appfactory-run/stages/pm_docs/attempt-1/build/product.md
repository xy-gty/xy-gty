# SnagCue AI — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
config_mode: local_only  
iap_opt_in: false（UltraLite `free_app_only`：本交付不含 StoreKit / 付费墙 / 金币 / ATT）

## 产品名称

**SnagCue AI**（开发包名 `com.lingguang.snagcue`）

## 一句话

导入现场巡检照片，AI 辅助识别缺陷/snag 并聊天补全 punch-list，生成标注报告图，再用 TTS 免提播报清单——本地可离线使用已保存的 Audit 与 PunchItem。

## 目标用户

做现场验收/整改跟进的施工、物业、独立巡检人员；需要结构化 punch-list 与照片证据，且不能把 App 当作建筑规范认证工具。

## 待完成工作（用户任务）

1. 新建 Audit，拍或导入 walkthrough 照片。  
2. 审阅 AI 识别出的 snag 草稿，确认/编辑/拒绝后写入 PunchItem。  
3. 用聊天补全位置、严重度、责任方、截止日期等字段，人审后保存。  
4. 生成标注报告图（需出站 AI；无 key 时诚实未配置）。  
5. 用 TTS 逐步播报清单项，便于双手占用时复核。

## 核心循环

导入照片 → 人审 snag → 聊天补字段 → 人审保存 → 标注报告（可选）→ TTS 清单教练

## 功能范围（本交付承诺）

- 相机/相册导入 walkthrough 照片（`PhotoImportSession`）
- snag 识别草稿结构化列表 + 人审确认/编辑/拒绝
- Audit / PunchItem / WalkthroughPhoto 本地持久化
- AI 聊天补全 punch 字段（发送前同意门）
- 标注报告图生成（声明出站；无 key = 本地 gap，不假装成功）
- TTS 免提 checklist 播报
- 合规 disclaimer：非法律/建筑规范认证
- 应用内本地隐私/条款/支持页；设置内可撤销 AI 同意

## 明确不做

- StoreKit / 一次性解锁付费墙 / 订阅 / 金币目录（操作者 paid 意图记为交付后 gap）
- ATT / 广告追踪
- 复制 Site Audit Pro / veamstudios 品牌、UI、资产或声称合规认证
- CloudKit 同步（未配置 = gap）
- 官方建筑规范判定、签字盖章式合规证明
- 账户体系 / 多用户协作云端

## 语言与平台

- 产品文档：zh-CN  
- 应用界面主语言：en-US（操作者创意为英文定位）  
- 平台：iOS 17+ SwiftUI；开发 Bundle ID `com.lingguang.snagcue`

## 应用简介（商店向草稿）

SnagCue AI turns walkthrough photos into a reviewed punch list. Spot snags, chat to fill fields, generate annotated report images, and hear checklist readouts hands-free. Review every AI suggestion before it sticks. Guidance only—not a building-code or legal certification. Works offline on saved audits; live AI needs your configured key.
