# CuePartner AI — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: CuePartner AI  
- development_bundle_id: com.lingguang.cuepartner  
- ui_language: en-US  
- docs_language: zh-CN

## Scope

- 脚本照片导入（相机拍摄草稿页 + 相册导入）与 OCR 审阅  
- 本地 Scene / ScriptPage / CueLine / VoiceNote 持久化  
- AI 对戏伙伴聊天（角色切换、发送前同意门）  
- TTS 提词行播报与节拍/停顿时机  
- 可选舞台环境音床（本地音频资源；可关）  
- 麦克风 Voice note + 语音识别转文字喂入对戏伙伴（Simulator 可走入口；真机录制可标 真机待测）  
- 本地法律页；用户自带脚本，不附带版权剧本  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 paid/unlock 意图记 gap）

## Entities

- Scene（一场戏：标题、角色表、锁定状态本地免费全开）  
- ScriptPage（相机/相册导入页 + OCR 文本草稿）  
- CueLine（角色、台词文本、节拍/停顿毫秒）  
- PartnerTurn（对戏草稿回复，未确认）  
- RehearsalMessage（确认后的聊天历史）  
- VoiceNote（本地录音元数据 + 可选转写文本）  
- AmbiencePreset（本地音床 id，可选）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入脚本照片）  
- CameraCapture（拍摄脚本草稿页；Simulator 可 stub 入口）  
- OCRReviewBar：confirm Keep / reject Discard / edit Edit text  
- ScenePartnerChat + TurnReview：confirm Keep / reject Discard  
- CueTTSPlayer：Play / Pause / Next cue（含 timing）  
- SpeechLineCapture：麦克风 + Speech framework → 文本进入 partner 输入  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复  
- RuntimeForm：聊天输入键盘避让  
- AVSpeechSynthesizer（cue TTS）  
- AmbiencePlayer（可选本地音床）

review_controls:
- confirm: Keep  
- reject: Discard  
- edit: Edit text

## Navigation

ScenesHome → NewScene → ImportScript → OCRReview → SceneDetail  
SceneDetail → PartnerChat → TurnReview  
SceneDetail → CueRehearsal（TTS + timing）  
SceneDetail → VoiceNoteCapture  
SceneDetail → AmbiencePicker（optional）  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`cuepartner.consent.v1`  
- 发送字段：script_page_ocr_text、cue_lines、partner_role、user_line_text、voice_transcript、chat_text  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

必须写入应用专属文案并提供运行可达入口（扩展核心卖路径，不替换）：

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture handwritten or printed script draft pages for OCR |
| NSPhotoLibraryUsageDescription | Import script photos so CuePartner can OCR your own pages |
| NSMicrophoneUsageDescription | Record rehearsal or line voice notes for practice |
| NSSpeechRecognitionUsageDescription | Turn spoken lines into text for the AI scene partner |

语义粘合：相机拍稿 → 相册导入 OCR → 对戏聊天（角色切换）→ TTS 提词+时机 → 可选音床；麦克风 Voice note 与语音识别喂入对戏。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Compliance / allergy

- 不附带、不声称授权任何版权剧本；仅处理用户自带文本/照片  
- 参考 LineLearner / com.alldayapps.linelearner 仅为品类对照；禁止复制品牌、UI、资产或声称授权剧本库  
- 产品文案标明 AI 对戏为排练辅助，不是官方剧本/导演指导

## Operator pricing intent（非本交付范围）

goal 中 paid / unlock unlimited scenes and character voices 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付本地免费开放全部场景与角色声线入口（TTS 系统声），不实现 StoreKit。
