# StopCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: StopCue  
- development_bundle_id: com.lingguang.stopcue  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_product_dir: stopcue/（交付仓目录名；工厂 run 内 product_repo_dir 仍由主控绑定；交付时 symlink stopcue→product；禁止只留 product/）

## Scope

- 定格动画逐帧拍摄（相机）与帧序列相册导入  
- AI 分镜 / 间隔草稿 → 人审 Keep / Discard / Edit  
- 本地 Project / FrameSequence / ShotPlanDraft / TimingCue / OnionSkinGuide / CoachTurn 持久化  
- AI 定格动画教练聊天（分镜与间隔建议；发送前同意门）  
- 洋葱皮标注叠图（onion-skin annotated guides）确认  
- TTS 倒计时口令（拍摄节拍倒计时）  
- 麦克风口述 + 语音识别：写入间隔/口令字段 → 教练会话  
- 本地法律页；用户自有定格帧照片  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 one-time unlock / unlimited projects 记 gap）  
- UI 硬约束：**胶片齿孔时间轴（film-sprocket timeline）** + **洋葱皮叠层预览（onion-skin overlay preview）**；禁止 NightCue 夜景帧轨/曝光诊断叠层孪生；禁止 CuePartner 剧本轴；禁止 HiveCue / FormCue / YarnCue / ScoutCue 布局孪生；禁止全黑壳

## Entities

- Project（一次定格项目：标题、目标帧率、创建时间）  
- FrameSequence（相机/相册导入的逐帧序列 + 本地文件引用）  
- ShotPlanDraft（分镜/间隔草稿，未确认）  
- TimingCue（确认后的间隔/倒计时口令：interval_ms、countdown_text）  
- OnionSkinGuide（洋葱皮标注草稿与确认态：对齐提示、位移箭头、备注）  
- CoachTurn（教练回复草稿，未确认）  
- CoachMessage（确认后的聊天历史）  
- CountdownCue（TTS 倒计时段落）  
- DictatedInterval（口述写入的间隔/口令字段：interval_ms / cue_text / notes）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入帧序列）  
- CameraCapture（逐帧拍摄；Simulator 可 stub 入口）  
- FrameReviewBar：confirm Keep / reject Discard / edit Edit  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- OnionSkinGuideEditor：确认洋葱皮标注  
- CountdownCueTTSPlayer：Play / Pause / Next cue（AVSpeechSynthesizer）  
- SpeechIntervalCapture：麦克风 + Speech → 间隔/口令字段 → 教练或 Project  
- FilmSprocketTimeline（胶片齿孔时间轴 UI）  
- OnionSkinOverlayCanvas（洋葱皮叠层预览 UI）  
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

ProjectsHome → NewProject → CaptureImport → FrameReview → StopCoach  
StopCoach → CoachChat → TurnReview  
StopCoach → OnionSkinGuide  
StopCoach → CountdownTTS  
StopCoach → DictateInterval  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`stopcue.consent.v1`  
- 发送字段：frame_sequence_descriptor、shot_plan_summary、timing_summary、onion_skin_notes、current_frame_label、chat_text、voice_transcript、dictated_interval_fields  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture frame-by-frame stop-motion sequences for AI coaching |
| NSPhotoLibraryUsageDescription | Import frame sequences into the StopCue coach timeline |
| NSMicrophoneUsageDescription | Hands-free interval and cue edits while shooting |
| NSSpeechRecognitionUsageDescription | Dictate interval or cue edits (e.g. next frame a bit closer) into the storyboard coach |

语义粘合：拍/导入帧序列 → 帧审阅 → 定格教练面（胶片齿孔时间轴 + 洋葱皮叠层）→ 聊天/标注/TTS 倒计时 → 口述间隔字段。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Palette 硬：Primary `#16A34A`，Secondary `#F0FDF4`，Accent `#DB2777`；禁全黑壳；禁 NightCue `#1E3A8A` 夜景蓝壳  
- 禁 NightCue 夜景帧轨 + 曝光诊断叠层孪生；禁 CuePartner 剧本轴；禁 HiveCue 六边形蜂巢网格；禁 FormCue 间歇 chip 轨；禁 YarnCue 毛线球条；禁 ScoutCue 太阳/星历侦查壳  
- 本轮 **不生成** AppIcon / LaunchScreen / splash 素材  
- 对标 Stop Motion Studio Pro（`com.cateater.funapps.stopmotionstudiopro`）为定位对照；禁止复制其品牌、资产或 UI chrome

## Config gaps（P1 local_only）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```
