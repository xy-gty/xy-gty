# ScoutCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0  
product_dir_hint: scoutcue/（交付仓目录名；本 attempt 不写产品源码）

## Identity

- app_name: ScoutCue  
- development_bundle_id: com.lingguang.scoutcue  
- ui_language: en-US  
- docs_language: zh-CN

## Scope

- 现场拍摄 / 相册导入风景照片（Camera + Photos）  
- 场景识别 → 本地 Scout 卡片（可编辑/确认后持久）  
- AI 向导聊天：日/月与黄金时段 timing（发送前同意门）  
- 黄金时段叠加标注（软标注叠在风景图上；非测距/绳路径 twin）  
- TTS 下一站拍摄简报（Speech 播报）  
- 麦克风口述拍摄意图 → Speech 转写写入计划备注  
- 天空弧（sky-arc）星历时间轴 + 软风景卡片堆（独特 IA）  
- 本地法律页；free_app_only（无 StoreKit/付费墙/金币/ATT）  
- **不含** DimCue 测距叠层 twin、KnotCue 绳路径轮播 twin、全黑壳

## Entities

- ScoutShot（导入/拍摄图元数据 + 本地文件引用）  
- SceneCard（识别草稿/已确认：地点标签、光质、朝向提示）  
- ScoutPlan（一次外拍计划：窗口列表、备注）  
- TimingWindow（日升/日落/黄金/蓝调等窗口）  
- OverlayMark（黄金时段标注点：相对图坐标 + 文案）  
- CoachMessage（向导聊天草稿）  
- CoachTurn（确认后的聊天历史）  
- ShootNote（口述备注 + 转写）  
- BriefingClip（TTS 下一站简报文本队列）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入风景）  
- CameraCapture（现场构图拍摄；Simulator 可 stub 入口）  
- SceneReviewBar：confirm Keep / reject Discard / edit Edit labels  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- OverlayEditor：Add mark / Save overlay / Discard  
- BriefingPlayer：Play / Pause / Next stop（AVSpeechSynthesizer）  
- SpeechNoteCapture：麦克风 + Speech → 写入 ShootNote / plan note  
- SkyArcTimeline（只读星历弧 + 当前窗口高亮）  
- SoftCardStack（主页软卡片堆导航）  
- AIConsentGate：出站前 permit；设置撤销  
- KeychainCredentialStore / AtomicCodableStore / TypedNavigationStore / RuntimeForm

review_controls:
- confirm: Keep  
- reject: Discard  
- edit: Edit labels

## Navigation

ScoutsHome（soft card stack + sky-arc）  
→ CaptureImport → SceneReview → ScoutCardDetail  
ScoutCardDetail → CoachChat → TurnReview  
ScoutCardDetail → GoldenOverlay  
ScoutCardDetail → NextStopBriefing  
ScoutCardDetail → DictateNote  
Settings → LegalPages | RevokeConsent | Permissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`scoutcue.consent.v1`  
- 发送字段：scene_labels、shot_meta、plan_windows、user_chat_text、voice_transcript、overlay_notes  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | On-site composition capture + scene recognition for scouting |
| NSPhotoLibraryUsageDescription | Import prior scouting shots; recompute best shoot windows |
| NSMicrophoneUsageDescription | Dictate shoot notes and intent into the scout plan |
| NSSpeechRecognitionUsageDescription | Turn spoken intent such as golden-hour ridge timing into a timed plan and coach chat |

语义粘合：拍/导风景 → 识别成 Scout 卡 → 天空弧 timing → 向导聊天 → 黄金叠标 → TTS 下一站 → 口述备注。Simulator：旅程入口可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Primary `#4338CA` indigo · Secondary `#EEF2FF` soft wash · Accent `#FB7185` rose  
- Multi-color；禁止全黑壳  
- Sky-arc ephemeris timeline + soft scenery card stack 为硬独特面  
- 禁止 DimCue measure-overlay twin / KnotCue rope-path carousel twin  
- 本轮不生成 AppIcon / LaunchScreen

## Operator pricing intent（非本交付范围）

goal 中 Paid / Unlock paid scouting packs 记为 `operator_pricing_deferred_free_app_only` / `replace_before_submission`；本 UltraLite 交付本地免费开放全部 Scout 卡与 timing 窗口，不实现 StoreKit。
