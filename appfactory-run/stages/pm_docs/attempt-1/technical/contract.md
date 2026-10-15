# NightCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: NightCue  
- development_bundle_id: com.lingguang.nightcue  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_product_dir: nightcue/（交付仓目录名；工厂 run 内 product_repo_dir 仍由主控绑定；交付时 symlink nightcue→product；禁止只留 product/）

## Scope

- 夜景试片拍摄（相机）与相册导入（历史夜景对照）  
- AI 曝光 / 噪点 / 拖影诊断草稿 → 人审 Keep / Discard / Edit  
- 本地 Session / NightFrame / ExposureDraft / DiagnosisFinding / AnnotatedOverlay / CoachTurn 持久化  
- AI 夜景长曝光教练聊天（参数建议；发送前同意门）  
- 在夜景试片上叠加曝光诊断标注（exposure-diagnosis overlay）  
- TTS 现场口令（手持三脚架时免提听 ISO / shutter / focus 提示）  
- 麦克风口述 + 语音识别：写入曝光参数字段 → 教练会话  
- 本地法律页；用户自有夜景照片  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 one-time unlock / night packs 记 gap）  
- UI 硬约束：**夜景帧轨（night-frame rail）** + **曝光诊断叠层（exposure-diagnosis overlays）**；禁止 HiveCue 蜂巢网格/巡检轨/热力叠图孪生；禁止 FormCue / YarnCue 布局孪生；禁止 ScoutCue 太阳/星历侦查定位；禁止全黑壳

## Entities

- Session（一次夜拍会话：地点标签、日期、目标场景）  
- NightFrame（相机/相册导入的夜景试片 + 本地文件引用）  
- ExposureDraft（曝光/噪点/拖影诊断草稿，未确认）  
- DiagnosisFinding（确认后的诊断要点：underexposed / noise / trail / highlight 标签 + 文案）  
- AnnotatedOverlay（试片上的曝光诊断标注草稿与确认态）  
- CoachTurn（教练回复草稿，未确认）  
- CoachMessage（确认后的聊天历史）  
- FieldCue（TTS 现场口令段落：ISO / shutter / aperture / focus）  
- DictatedExposure（口述写入的曝光字段：iso / shutter_s / aperture / notes）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入夜景 / 历史对照帧）  
- CameraCapture（拍摄夜景试片；Simulator 可 stub 入口）  
- ExposureReviewBar：confirm Keep / reject Discard / edit Edit  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- AnnotatedOverlayEditor：确认曝光诊断标注  
- FieldCueTTSPlayer：Play / Pause / Next cue（AVSpeechSynthesizer）  
- SpeechExposureCapture：麦克风 + Speech → 曝光字段 → 教练或 Session  
- NightFrameRail（夜景帧轨 UI）  
- ExposureDiagnosisOverlayCanvas（曝光诊断叠层 UI）  
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

SessionsHome → NewSession → CaptureImport → ExposureReview → NightCoach  
NightCoach → CoachChat → TurnReview  
NightCoach → AnnotatedOverlay  
NightCoach → FieldCueTTS  
NightCoach → DictateExposure  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`nightcue.consent.v1`  
- 发送字段：frame_photo_descriptor、exposure_summary、noise_summary、trail_signs、scene_plan_summary、current_frame_label、chat_text、voice_transcript、dictated_exposure_fields  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture night test frames for AI long-exposure coaching |
| NSPhotoLibraryUsageDescription | Import past night frames to compare exposure and noise |
| NSMicrophoneUsageDescription | Hands-free parameter Q&A while holding a tripod |
| NSSpeechRecognitionUsageDescription | Dictate exposure settings (ISO, shutter, aperture, notes) into the coach |

语义粘合：拍/导入夜景试片 → 曝光诊断审阅 → 夜景教练面（夜景帧轨 + 曝光诊断叠层）→ 聊天/标注/TTS 口令 → 口述曝光字段。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Palette 硬：Primary `#1E3A8A`，Secondary `#EFF6FF`，Accent `#FBBF24`；禁全黑壳  
- 禁 HiveCue 六边形蜂巢网格 + 巡检轨 + 热力叠图孪生；禁 FormCue 间歇 chip 轨+休息环+拍立得条孪生；禁 YarnCue 毛线球条；禁 ScoutCue 太阳/星历侦查壳  
- 本轮 **不生成** AppIcon / LaunchScreen / splash 素材  
- 对标 NightCap Camera Long Exposure（`com.interealtime.LightBoost`）为定位对照；禁止复制 NightCap 品牌、资产或 UI chrome

## Config gaps（P1 local_only）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```
