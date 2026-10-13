# DocBrief AI — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: DocBrief AI  
- development_bundle_id: com.lingguang.docbrief  
- ui_language: en-US  
- docs_language: zh-CN

## Scope

- 文档 / 白板 / 小票照片导入与类型+关键字段识别审阅  
- 本地 Brief / DocumentPhoto / ExtractedField / ActionItem 持久化  
- AI 聊天抽取行动项与截止日期（发送前同意）  
- 视觉摘要卡生成（需出站；无 key 诚实未配置）  
- TTS 口述简报播报  
- 本地法律页；隐私本地优先，最小化云端保留用户照片/文档  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者「解锁无限 briefs」意图记 gap）

## Entities

- Brief  
- DocumentPhoto  
- RecognitionDraft（类型+字段草稿，未确认）  
- ExtractedField  
- ActionItem  
- SummaryCardDraft  
- AIConsentRecord  
- BriefingSession（TTS 简报会话）

## Interfaces

- PhotoImportSession（导图）  
- RecognitionReviewBar：confirm Save / reject Not this / edit Edit fields  
- BriefChat + ActionReview：Save / Not this  
- SummaryCardPreview：Use / Discard  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复  
- RuntimeForm：聊天输入键盘避让  
- AVSpeechSynthesizer（TTS briefing）

review_controls:
- confirm: Save  
- reject: Not this  
- edit: Edit fields

## Navigation

HomeTab → NewBrief → ImportCapture → RecognitionReview → BriefDetail  
BriefDetail → ChatExtract → ActionReview  
BriefDetail → SummaryCard  
BriefDetail → TTSBriefing  
Settings → LegalPages | RevokeConsent  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`docbrief.consent.v1`  
- 发送字段：document_photo_bytes、recognized_type、extracted_fields、chat_text、action_hints  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- 本地优先：照片与 Brief 默认只存本机；出站仅在同意后发送声明字段；不设计多设备云同步为本交付承诺  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Compliance / allergy

- 产品文案与摘要卡页必须含 disclaimer：识别与建议仅为整理辅助，**不是**财务/税务/法律认证或官方凭证  
- 参考 TurboScan Pro / com.novosoft.TurboScan 仅为品类对照；禁止复制品牌、UI、资产或未授权抓取

## Operator pricing intent（非本交付范围）

goal 中 paid unlock / unlimited briefs 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付保持免费可完整体验核心路径（有 key 时 live AI，无 key 时本地能力）。
