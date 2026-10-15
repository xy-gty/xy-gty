# YarnCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: YarnCue  
- development_bundle_id: com.lingguang.yarncue  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_product_dir: yarncue/（交付仓目录名；工厂 run 内 product_repo_dir 仍由主控绑定）

## Scope

- 毛线 / WIP 照片拍摄（相机）与相册导入  
- 针法 / 行识别草稿 → 人审 Keep / Discard / Edit  
- 本地 Project / WIPShot / StitchCue / CoachTurn / PatternNote 持久化  
- AI weave-coach「下一行」聊天（发送前同意门）  
- 在 WIP 照片上标注针法示意（本地叠加 + AI 建议草稿经人审）  
- TTS 免提下一行教练播报（双手留在针上）  
- 麦克风口述花样备注 / 行意图 + 语音识别喂入教练聊天  
- 本地法律页；用户自有作品照片，不附带第三方版权花样库  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 paid pattern/coach packs 记 gap）  
- UI 硬约束：毛线球色卡条 + 横向「下一行」步骤带；禁止 KnotCue/ScoutCue/ClosetCue/PitchCue 布局孪生；禁止全黑壳

## Entities

- Project（一件编织进行中：标题、纱线色卡、当前行）  
- WIPShot（相机/相册导入的纱线或 WIP 照片 + 本地文件引用）  
- StitchRecognitionDraft（针法/行识别草稿，未确认）  
- StitchCue（确认后的针法/行步骤：步骤序号、针法名、行号、备注）  
- AnnotatedOverlay（WIP 照片上的标注点/区域草稿与确认态）  
- CoachTurn（教练回复草稿，未确认）  
- CoachMessage（确认后的聊天历史）  
- PatternNote（口述/手写备注文本）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入纱线/WIP 照片）  
- CameraCapture（拍摄纱线/WIP；Simulator 可 stub 入口）  
- StitchReviewBar：confirm Keep / reject Discard / edit Edit  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- AnnotatedDiagramEditor：确认叠加标注  
- HandsFreeTTSPlayer：Play / Pause / Next step（AVSpeechSynthesizer）  
- SpeechNoteCapture：麦克风 + Speech → 文本进入教练输入 / PatternNote  
- YarnBallSwatchStrip（项目色卡条 UI）  
- NextRowStepBand（横向「下一行」步骤带 UI）  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复  
- RuntimeForm：聊天输入键盘避让

review_controls:
- confirm: Keep  
- reject: Discard  
- edit: Edit

## Navigation

ProjectsHome → NewProject → CaptureImport → StitchReview → ProjectCoach  
ProjectCoach → CoachChat → TurnReview  
ProjectCoach → AnnotatedWIP  
ProjectCoach → HandsFreeTTS  
ProjectCoach → DictateNote  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`yarncue.consent.v1`  
- 发送字段：wip_photo_descriptor、recognized_stitch_summary、current_row、next_row_intent、pattern_note_text、chat_text、voice_transcript  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture yarn / WIP photos for stitch & row recognition |
| NSPhotoLibraryUsageDescription | Import prior WIP / yarn shots into the coach flow |
| NSMicrophoneUsageDescription | Dictate pattern notes and row intent while knitting |
| NSSpeechRecognitionUsageDescription | e.g. ask what the next row is → next-row coach chat + TTS |

语义粘合：拍/导入 WIP → 针法行识别审阅 → 项目教练面（色卡条 + 横向下一行带）→ 聊天/标注图/TTS 免提 → 口述备注。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Palette 硬：Primary `#A21CAF`，Secondary `#FDF4FF`，Accent `#84CC16`；多彩；禁全黑壳  
- 禁 KnotCue 绳径轮播孪生、ScoutCue 天弧+卡片堆、ClosetCue / PitchCue dial+strip 孪生  
- 本轮 **不生成** AppIcon / LaunchScreen / splash 素材  
- 对标 Ravit 为定位对照；禁止复制 Ravelry 壳或第三方品牌资产

## Operator pricing intent（非本交付范围）

goal 中 Unlock paid pattern / coach packs 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付免费开放全部教练核心环，不实现 StoreKit。
