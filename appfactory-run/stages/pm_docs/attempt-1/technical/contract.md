# HiveCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: HiveCue  
- development_bundle_id: com.lingguang.hivecue  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_product_dir: hivecue/（交付仓目录名；工厂 run 内 product_repo_dir 仍由主控绑定；交付时 symlink hivecue→product）

## Scope

- 巢脾（brood frame）照片拍摄（相机）与相册导入（历史对照）  
- AI 识别蜂子 / 储蜜 / 虫害迹象草稿 → 人审 Keep / Discard / Edit  
- 本地 Inspection / FrameShot / BroodDraft / Finding / AnnotatedOverlay / CoachTurn 持久化  
- AI 巡检教练聊天（下一步动作；发送前同意门）  
- 在巢脾照片上叠加热力 / 区域标注（heat overlay）  
- TTS 免提巡检口述笔记（戴手套 / 穿蜂衣时）  
- 麦克风口述 + 语音识别：写入巡检字段 → 教练与日志  
- 本地法律页；用户自有巢脾照片  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 one-time unlock / apiary packs 记 gap）  
- UI 硬约束：**六边形蜂巢网格** + **巡检轨（inspection rail）** + **热力叠图（heat overlay）**；禁止 FormCue / YarnCue 布局孪生；禁止全黑壳

## Entities

- Inspection（一次箱体巡检：蜂箱标签、日期、当前脾位）  
- FrameShot（相机/相册导入的巢脾照片 + 本地文件引用）  
- BroodDraft（蜂子/储蜜/虫害识别草稿，未确认）  
- Finding（确认后的识别要点：brood / stores / pest 标签 + 文案）  
- AnnotatedOverlay（巢脾照上的热力/区域标注草稿与确认态）  
- CoachTurn（教练回复草稿，未确认）  
- CoachMessage（确认后的聊天历史）  
- VoiceNote（免提 TTS 笔记段落）  
- DictatedField（口述写入的巡检字段：queen_seen / temperament / notes）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入巢脾 / 历史对照帧）  
- CameraCapture（拍摄巢脾；Simulator 可 stub 入口）  
- BroodReviewBar：confirm Keep / reject Discard / edit Edit  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- AnnotatedFrameEditor：确认热力 / 区域标注  
- HandsFreeTTSPlayer：Play / Pause / Next note（AVSpeechSynthesizer）  
- SpeechFieldCapture：麦克风 + Speech → 巡检字段 → 教练或 Inspection  
- HexCombGrid（六边形蜂巢网格 UI）  
- InspectionRail（巡检轨 UI）  
- HeatOverlayCanvas（热力叠图 UI）  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复  
- RuntimeForm：聊天 / 字段输入键盘避让

review_controls:
- confirm: Keep  
- reject: Discard  
- edit: Edit

## Navigation

InspectionsHome → NewInspection → CaptureImport → BroodReview → InspectionCoach  
InspectionCoach → CoachChat → TurnReview  
InspectionCoach → AnnotatedFrame  
InspectionCoach → HandsFreeTTS  
InspectionCoach → DictateFields  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`hivecue.consent.v1`  
- 发送字段：frame_photo_descriptor、brood_summary、stores_summary、pest_signs、inspection_plan_summary、current_frame_label、chat_text、voice_transcript、dictated_fields  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture brood-frame photos for AI hive inspection |
| NSPhotoLibraryUsageDescription | Import past frame photos to compare brood / stores / pests |
| NSMicrophoneUsageDescription | Hands-free inspection notes while suited and gloved |
| NSSpeechRecognitionUsageDescription | Dictate inspection fields (queen seen, temperament, notes) into the log |

语义粘合：拍/导入巢脾 → 识别审阅 → 巡检教练面（蜂巢网格 + 巡检轨 + 热力叠图）→ 聊天/标注/TTS 免提 → 口述字段。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Palette 硬：Primary `#9F1239`，Secondary `#FDF2F8`，Accent `#4D7C0F`；禁全黑壳  
- 禁 FormCue 间歇 chip 轨+休息环+拍立得条孪生；禁 YarnCue 毛线球条及其它 Cue 壳布局  
- 本轮 **不生成** AppIcon / LaunchScreen / splash 素材  
- 对标 BeePlus Beekeeping Manager（`uk.co.omnichrome.beeplus`）为定位对照；禁止复制 BeePlus 品牌、资产或 UI chrome

## Config gaps（P1 local_only）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```
