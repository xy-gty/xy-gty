# SnagCue AI — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: SnagCue AI  
- development_bundle_id: com.lingguang.snagcue  
- ui_language: en-US  
- docs_language: zh-CN

## Scope

- 现场巡检照片导入与缺陷/snag 识别审阅  
- 本地 Audit / PunchItem 持久化  
- AI 聊天补全 punch-list 字段（发送前同意）  
- 标注报告图生成（需出站；无 key 诚实未配置）  
- 清单 TTS 免提播报  
- 本地法律页；不声称建筑/法规合规认证  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者「一次性解锁」意图记 gap）

## Entities

- Audit  
- WalkthroughPhoto  
- SnagDraft（识别草稿，未确认）  
- PunchItem  
- ReportDraft  
- AIConsentRecord  
- CoachSession（TTS 清单会话）

## Interfaces

- PhotoImportSession（导图）  
- SnagReviewBar：confirm Save / reject Not this / edit Edit snag  
- PunchChat + FieldReview：Save / Not this  
- AnnotatedReportPreview：Use / Discard  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复  
- RuntimeForm：聊天输入键盘避让  
- AVSpeechSynthesizer（TTS checklist）

review_controls:
- confirm: Save  
- reject: Not this  
- edit: Edit snag

## Navigation

HomeTab → NewAudit → Capture → SnagRecognitionReview → PunchList  
PunchList → ChatFill → FieldReview  
PunchList → AnnotatedReport  
PunchList → TTSCoach  
Settings → LegalPages | RevokeConsent  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`snagcue.consent.v1`  
- 发送字段：walkthrough_photo_bytes、punch_item_fields、chat_text、snag_labels  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Compliance / allergy

- 产品文案与报告页必须含 disclaimer：识别与建议仅为现场记录辅助，**不是**法律/建筑规范认证或合规证明  
- 参考 Site Audit Pro / com.veamstudios.iaudit 仅为品类对照；禁止复制品牌、UI、资产或声称同类认证

## Operator pricing intent（非本交付范围）

goal 中 paid / one-time unlock 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付保持免费可完整体验核心路径（有 key 时 live AI，无 key 时本地能力）。
