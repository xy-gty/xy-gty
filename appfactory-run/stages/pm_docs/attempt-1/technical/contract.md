# PitchCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: PitchCue  
- development_bundle_id: com.lingguang.pitchcue  
- product_dir: pitchcue/（小写；工程目录名，勿称 `product/`）  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_remote: git@github.com:xy-gty/xy-gty.git  
- Simulator: iPhone 17 Pro ONLY（禁止 iPhone 17 / Pro Max）

## Scope

- 乐谱/练习照片导入（相机拍摄 + 相册导入）  
- 本地 PracticeSession / SheetPhoto / PracticePlan / CoachTurn / AudioBed / PitchSample 持久化  
- AI 热身/练习计划聊天（发送前同意门；人审 Keep / Discard / Edit）  
- TTS 倒数与口语教练提示（AVSpeechSynthesizer；不替换核心计划流）  
- 本地生成 drone / metronome 床（合成音频，非云端采样库）  
- 可选麦克风音高/节奏反馈 + 圆形调音盘 UI  
- 水平练习条（practice strip）+ 连续波形  
- 本地法律页；**本轮不生成** AppIcon / launch/splash（操作者硬约束）  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 paid/unlock packs 意图记 gap）  
- Simulator 仅 iPhone 17 Pro

## Entities

- PracticeSession（一次练习：标题、乐器标签、更新时间、本地免费全开）  
- SheetPhoto（相机/相册导入图 + 本地文件引用）  
- PracticePlan（AI 热身/练习步骤草稿或已确认）  
- CoachTurn（聊天轮次：用户/教练文本、反馈标记）  
- AudioBed（drone 或 metronome 床：音高/BPM/波形本地参数）  
- PitchSample（麦克风瞬时音高/偏差采样元数据）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入乐谱/指法练习图）  
- CameraCapture（拍摄乐谱；Simulator 可 stub 入口）  
- CoachChatForm（RuntimeForm：练习目标/问题输入）  
- CoachingReviewBar：confirm Keep / reject Discard / edit Edit  
- SpeechGoalCapture：麦克风 + Speech → 文本进入教练输入  
- TTSCoach：AVSpeechSynthesizer 倒数与提示播报  
- AudioBedEngine：本地 drone/metronome 合成 + 连续波形视图  
- TunerDial：圆形调音盘 + 可选 mic pitch feedback  
- PracticeStrip：水平练习条（步骤/小节滚动）  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore：API key 只读存在性  
- AtomicCodableStore：实体持久  
- TypedNavigationStore：路由恢复  
- RuntimeForm：键盘避让  

review_controls:
- confirm: Keep  
- reject: Discard  
- edit: Edit

## Navigation

PracticeHome → NewSession → CaptureImport → CoachChat → PlanReview → PracticeFloor → SessionDetail  
PracticeFloor → PitchFeedback（可选）| AudioBedControls  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`pitchcue.consent.v1`  
- 发送字段：sheet_photo_desc、instrument_label、user_goal、speech_transcript、prior_plan_steps、coach_question、user_feedback  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

必须写入应用专属文案并提供运行可达入口（扩展核心卖路径，不替换）：

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture sheet music or fingering photos so PitchCue can coach your practice |
| NSPhotoLibraryUsageDescription | Import existing exercise or sheet photos for practice coaching |
| NSMicrophoneUsageDescription | Listen for pitch and rhythm feedback from your instrument mic |
| NSSpeechRecognitionUsageDescription | Turn spoken practice goals into text for the AI practice coach |

语义粘合：拍/导入乐谱 → AI 热身计划聊天 → TTS 倒数 → drone/metronome 床 → 可选 mic 调音反馈。Simulator：入口与旅程可测；设备相机/长录音可标 真机待测。

## Unique UI（硬）

- Circular tuner dial（非线性时间轴）  
- Horizontal practice strip  
- Continuous audio waveform  
- 禁止 CuePartner 式 script-timeline 克隆  
- 禁止全黑壳；调色板 Primary `#7C3AED` / Secondary `#F5F3FF` / Accent `#10B981`  
- 定位 AI practice coach（＞ tuner）；禁止克隆 TonalEnergy

## Compliance / allergy

- TonalEnergy / CuePartner 仅为品类对照；禁止复制品牌、UI、资产或声称授权内容  
- 本轮禁止生成 AppIcon / splash（`branding_assets_deferred`）  
- 产品文案标明 AI/音高反馈为练习辅导，不是专业调音台或听力诊断替代

## Operator pricing intent（非本交付范围）

goal 中 paid / unlock unlimited practice packs 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付本地免费开放全部练习会话与计划入口，不实现 StoreKit。飞书交付行 skip（操作者 deferred）。
