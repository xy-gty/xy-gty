# FrameCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: FrameCue  
- development_bundle_id: com.lingguang.framecue  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_product_dir: framecue/（交付仓目录名；工厂 run 内 product_repo_dir 仍由主控绑定；交付后 symlink `framecue→product`）

## Scope

- 片场试拍（相机）与勘景/参考静帧相册导入  
- AI 构图问题识别草稿 → 人审 Keep / Discard / Edit  
- 本地 FramingSession / FrameStill / CompositionDraft / CompositionNote / ShotSizePlan / AspectOverlay / CoachTurn 持久化  
- AI 导演取景教练聊天：景别 / 画幅比 / 焦段语言（发送前同意门）  
- 安全框 / 三分法 / 画幅叠图生成与确认  
- TTS 现场导演口令（免提）  
- 麦克风口述 + 语音识别：景别指令写入教练聊天并刷新叠图  
- 本地法律页；用户自有静帧  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 one-time unlock framing packs 记 gap）  
- UI 硬约束：片场场记板式画幅框 + 底部景别芯片条；禁止 RuleCue / StopCue / NightCue 布局孪生；禁止全黑/深灰壳

## Entities

- FramingSession（一次取景教练会话：标题、当前景别、画幅比）  
- FrameStill（相机/相册导入静帧 + 本地文件引用）  
- CompositionDraft（构图问题草稿，未确认）  
- CompositionNote（确认后的构图要点：主体、边缘、留白、对称）  
- ShotSizePlan（景别计划：ECU/CU/MS/WS/EWS 等芯片）  
- AspectOverlay（画幅比 / 安全框 / 三分法叠图层草稿与确认态）  
- CoachTurn（教练回复草稿，未确认）  
- CoachMessage（确认后的聊天历史）  
- VoiceIntent（口述景别 / 焦段指令文本）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入勘景 / 参考静帧）  
- CameraCapture（片场试拍当前构图；Simulator 可 stub 入口）  
- CompositionReviewBar：confirm Keep / reject Discard / edit Edit  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- OverlayEditor：确认安全框 / 三分法 / 画幅叠图  
- HandsFreeTTSPlayer：Play / Pause / Next cue（AVSpeechSynthesizer）  
- SpeechIntentCapture：麦克风 + Speech → 景别指令 → 教练聊天 + 叠图刷新  
- ClapperFrameCanvas（片场场记板式画幅框 UI）  
- ShotSizeChipBar（底部景别芯片条 UI）  
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

SessionsHome → NewSession → CaptureImport → CompositionReview → SlateStage  
SlateStage → CoachChat → TurnReview  
SlateStage → OverlayMarks  
SlateStage → HandsFreeTTS  
SlateStage → DictateShot  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`framecue.consent.v1`  
- 发送字段：still_descriptor、composition_summary、shot_size_label、aspect_ratio_label、lens_language、overlay_focus、chat_text、voice_transcript  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture on-set framing trial shots for composition coaching |
| NSPhotoLibraryUsageDescription | Import scout or reference stills for aspect and framing analysis |
| NSMicrophoneUsageDescription | Hands-free on-set director cues while both hands hold the camera |
| NSSpeechRecognitionUsageDescription | Spoken shot-size instructions written into coach chat and refresh overlays |

语义粘合：拍/导入静帧 → 构图审阅 → 场记板舞台（画幅框 + 底部景别芯片）→ 聊天/叠图/TTS 免提 → 口述景别。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Palette 硬：Primary `#7E22CE`，Secondary `#FAF5FF`，Accent `#F59E0B`；禁全黑/深灰壳  
- 禁 RuleCue 桌区卡 + 回合步进条、StopCue 胶片齿孔时间线、NightCue 夜框轨孪生  
- 本轮 **不生成** AppIcon / LaunchScreen / splash 素材  
- 对标 Cadrage Director's Viewfinder（`com.distantblue.Cadrage`）为定位对照：差异化 = 构图/景别对话教练 + 叠图，不是纯专业相机画幅预览；禁止复制 Cadrage 品牌/资产/chrome

## Operator pricing intent（非本交付范围）

goal 中 Paid / one-time unlock unlimited framing packs 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付免费开放全部取景教练核心环，不实现 StoreKit。

## Simulator

iPhone 17 Pro ONLY（prefer UDID B14CC0EA）；禁止占用/关机 Pro Max，即使已 Booted。
