# DocBrief AI — 产品说明

idea_source: operator_external  
ai_profile: ultra_lite  
config_mode: local_only  
iap_opt_in: false（UltraLite `free_app_only`：本交付不含 StoreKit / 付费墙 / 金币 / ATT）

## 产品名称

**DocBrief AI**（开发包名 `com.lingguang.docbrief`）

## 一句话

导入文档、白板或小票照片，AI 辅助识别类型与关键字段，聊天抽取行动项与截止日期，生成视觉摘要卡，再用 TTS 口述简报——本地可离线使用已保存的 Brief。

## 目标用户

需要把纸质/白板/收据材料快速整理成可跟进简报的自由职业者、小团队协调人、商务与行政人员；要的是「讲清楚下一步」，不是又一个纯扫描器。

## 待完成工作（用户任务）

1. 新建 Brief，拍或导入文档/白板/小票照片。  
2. 审阅 AI 识别的类型与关键字段草稿，确认/编辑/拒绝后写入 Brief。  
3. 用聊天抽取行动项与截止日期，人审后保存。  
4. 生成视觉摘要卡（需出站 AI；无 key 时诚实未配置）。  
5. 用 TTS 逐步口述简报要点，便于通勤或双手占用时收听。

## 核心循环

导入照片 → 人审类型/字段 → 聊天抽行动项 → 人审保存 → 摘要卡（可选）→ TTS 口述简报

## 功能范围（本交付承诺）

- 相机/相册导入文档类照片（`PhotoImportSession`）
- 类型 + 关键字段识别草稿 + 人审确认/编辑/拒绝
- Brief / DocumentPhoto / ExtractedField / ActionItem 本地持久化
- AI 聊天抽取行动与截止日期（发送前同意门）
- 视觉摘要卡生成（声明出站；无 key = 本地 gap，不假装成功）
- TTS 口述简报播报
- 合规 disclaimer：非财务/税务/法律认证
- 应用内本地隐私/条款/支持页；设置内可撤销 AI 同意
- 隐私本地优先：最小化云端保留用户照片/文档

## 明确不做

- StoreKit / 无限 briefs 付费墙 / 订阅 / 金币目录（操作者 paid 意图记为交付后 gap）
- ATT / 广告追踪
- 复制 TurboScan / Novosoft 品牌、UI、资产或未授权抓取
- CloudKit 同步（未配置 = gap）
- OCR-only 哑扫描器定位、PDF 批量扫描仪工作台
- 官方税务/财务凭证认证、电子发票开具
- 账户体系 / 多用户协作云端

## 语言与平台

- 产品文档：zh-CN  
- 应用界面主语言：en-US（操作者创意为英文定位）  
- 平台：iOS 17+ SwiftUI；开发 Bundle ID `com.lingguang.docbrief`

## 应用简介（商店向草稿）

DocBrief AI turns document, whiteboard, and receipt photos into reviewed action briefs. Spot the doc type and key fields, chat to pull deadlines, generate visual summary cards, and hear spoken briefings. Review every AI suggestion before it sticks. Guidance only—not a financial, tax, or legal certification. Works offline on saved briefs; live AI needs your configured key.
