# BendCoach AI — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: BendCoach AI  
- development_bundle_id: com.lingguang.bendcoach  
- ui_language: en-US  
- docs_language: zh-CN

## Scope

- 导管弯曲（conduit bend）现场数学：纯英文聊天问答弯管量/标记点  
- 工地照片导入 / 相机拍摄 → 弯型与标记识别草稿 + 人审  
- 示意图叠加（diagram overlay）生成本地可保存的辅导图  
- TTS 逐步现场辅导播报  
- 麦克风口述 + 语音识别（STT）喂入弯管数学聊天  
- 单位制（imperial / metric）清晰切换与解释  
- 本地法律页；隐私本地优先，最小化云端保留工地照片  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者「一次性解锁 pro bend packs」意图记 gap）  
- 数值输出一律标注 assistive，**不是**规范/工程师正式判定的替代

## Entities

- JobSession（一次现场辅导会话）  
- BendQuery（聊天弯管数学问答回合）  
- FieldPhoto（相机/相册导入）  
- BendRecognitionDraft（弯型/标记草稿，未确认）  
- BendMarkup（确认后的弯型与关键尺寸）  
- DiagramOverlay（叠加示意图草稿/已保存）  
- CoachingStep（TTS 逐步辅导步骤）  
- UnitPreference（imperial|metric）  
- AIConsentRecord  
- SpeechCaptureSession（mic + STT 会话）

## Interfaces

- PhotoImportSession（导图）+ CameraCapture（拍工地弯/标记）  
- BendMathChat + RuntimeForm（键盘避让；文字/语音入口）  
- BendReviewBar：confirm Save / reject Not this / edit Edit marks  
- DiagramPreview：confirm Use / reject Discard  
- CoachingPlayer（TTS 逐步；Pause / Next）  
- UnitSystemControl（Settings + 首次说明）  
- AIConsentGate：出站前 permit；设置撤销  
- SpeechRecognitionBridge（麦克风 + STT → 聊天输入）  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复

review_controls:
- confirm: Save  
- reject: Not this  
- edit: Edit marks

## Navigation

HomeTab → BendMathChat  
HomeTab → CaptureImport → BendReview → JobDetail  
JobDetail → DiagramOverlay  
JobDetail → TTSCoaching  
BendMathChat ← SpeechCapture（mic/STT）  
Settings → Units | LegalPages | RevokeConsent  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`bendcoach.consent.v1`  
- 发送字段：chat_text、unit_system、field_photo_bytes、recognized_bend_type、markup_hints、coaching_context  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- 本地优先：工地照片与 JobSession 默认只存本机；出站仅在同意后发送声明字段；不设计多设备云同步为本交付承诺  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Permissions（四硬权限）

| 权限 | 用途文案意图（en-US） | 可测路径 |
|------|----------------------|----------|
| Camera | Capture job-site bend and markup photos for coaching | CaptureImport → 拍照 → BendReview |
| Photo Library | Import field photos to recognize bend types | CaptureImport → 选图 → BendReview |
| Microphone | Speak bend-math questions and field dictation | BendMathChat → mic |
| Speech Recognition | Turn speech into chat text for bend math | mic → STT → BendMathChat 输入 |

Simulator 不可测项标「真机待测」，不挡交付。

## Compliance / allergy

- 所有弯管数值与辅导步骤旁注：Assistive guidance only — not a substitute for code or engineer judgment.  
- 单位制 UI 必须可见（当前单位徽章 + Settings 切换 + 首次短说明）  
- 参考 QuickBend / Bret-H.-Hardman.QuickBend 仅为品类对照；禁止复制品牌、UI、资产或未授权抓取

## Operator pricing intent（非本交付范围）

goal 中 paid / one-time unlock for pro bend packs 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付保持免费可完整体验核心售卖路径（有 key 时 live AI，无 key 时本地规则/演示弯包 + 诚实未配置）。
