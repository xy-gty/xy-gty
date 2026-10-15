# RuleCue — 早期技术契约（P1）

schema_ref: appfactory.ultra_lite_technical.v1  
config_mode: local_only  
foundation: AppRuntimeCore 1.0.0

## Identity

- app_name: RuleCue  
- development_bundle_id: com.lingguang.rulecue  
- ui_language: en-US  
- docs_language: zh-CN  
- delivery_product_dir: rulecue/（交付仓目录名；工厂 run 内 product_repo_dir 仍由主控绑定；交付时 symlink rulecue→product；禁止只留 product/）

## Scope

- 规则书页 / 桌面布局拍照（相机）与相册导入（含 PDF 页图 / 过往桌面照对比）  
- AI 组件 / 阶段识别草稿 → 人审 Keep / Discard / Edit  
- 本地 GameSession / TablePhoto / ComponentMap / PhaseStep / SetupOverlay / CoachTurn 持久化  
- AI 桌游规则与摆台教练聊天（裁决与回合流程；发送前同意门）  
- 标注摆台 / 分区叠图（annotated setup/zone overlays）确认  
- TTS 桌面主持口令（边摆边讲）  
- 麦克风口述 + 语音识别：规则问题写入教练会话并触发下一条 tip  
- 本地法律页；用户自有规则书/桌面照片  
- **不含** StoreKit/付费墙/金币/ATT（free_app_only；操作者 one-time unlock / unlimited game packs 记 gap）  
- UI 硬约束：**桌游桌面分区卡（table zone cards）** + **回合步骤条（turn step bar）**；禁止 StopCue film-sprocket / 洋葱皮；禁止 NightCue night-frame rail；禁止 HiveCue / FormCue / YarnCue / ScoutCue 布局孪生；禁止全黑壳

## Entities

- GameSession（一局：游戏名、玩家数、当前阶段、创建时间）  
- TablePhoto（相机/相册导入的规则书页或桌面照 + 本地文件引用）  
- ComponentDraft（未确认的组件/阶段识别草稿）  
- ComponentMap（确认后的组件清单：牌堆、版图区、指示物等）  
- PhaseStep（确认后的回合步骤：order、title、hint）  
- SetupOverlay（摆台标注草稿与确认态：分区框、箭头、备注）  
- CoachTurn（教练回复草稿，未确认）  
- CoachMessage（确认后的聊天历史）  
- HostCue（TTS 桌面主持段落）  
- SpokenQuestion（口述写入的规则问题文本）  
- AIConsentRecord

## Interfaces

- PhotoImportSession（相册导入规则书页 / 桌面照）  
- CameraCapture（拍规则书页、组件特写、当前桌面；Simulator 可 stub 入口）  
- ComponentReviewBar：confirm Keep / reject Discard / edit Edit  
- CoachChat + TurnReview：confirm Keep / reject Discard  
- SetupOverlayEditor：确认分区标注  
- HostCueTTSPlayer：Play / Pause / Next cue（AVSpeechSynthesizer）  
- SpeechRulesCapture：麦克风 + Speech → 教练 chat 文本 → tip  
- TableZoneCards（桌游桌面分区卡 UI）  
- TurnStepBar（回合步骤条 UI）  
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

SessionsHome → NewSession → CaptureImport → ComponentReview → TableCoach  
TableCoach → CoachChat → TurnReview  
TableCoach → SetupOverlay  
TableCoach → HostTTS  
TableCoach → DictateRules  
Settings → LegalPages | RevokeConsent | PrivacyPermissions copy  
ConsentSheet（modal，出站前）

## Storage / AI 边界

- 默认出站关闭，直至 Secrets.xcconfig `DEEPSEEK_API_KEY` 或授权配置存在  
- 同意披露版本：`rulecue.consent.v1`  
- 发送字段：game_session_summary、component_map_summary、phase_steps_summary、setup_overlay_notes、current_zone_label、chat_text、voice_transcript、spoken_question  
- Provider：DeepSeek（产品内 AI；与工厂 Cursor auto 无关）  
- privacy_url / terms_url / support_url / cloudkit / ai_key：UNKNOWN（gap）  
- 不要求 Builder verify existing authorized configuration  

## Privacy capabilities（首发 Info.plist + 可测入口）

| key | 用途 |
|-----|------|
| NSCameraUsageDescription | Capture rulebook pages, component close-ups, and current table layout for AI setup coaching |
| NSPhotoLibraryUsageDescription | Import rulebook page images or past table photos to compare setups |
| NSMicrophoneUsageDescription | Hands-free rules questions while setting up the table |
| NSSpeechRecognitionUsageDescription | Write spoken rules questions into the coach chat and trigger the next tip |

语义粘合：拍/导入规则书与桌面 → 组件审阅 → 桌面教练面（分区卡 + 回合步骤条）→ 聊天/标注/TTS 主持 → 口述规则问题。Simulator：入口与旅程可测；设备相机/录音可标 真机待测。

## Visual / allergy

- Palette 硬：Primary `#854D0E`，Secondary `#FEFCE8`，Accent `#0891B2`；禁全黑壳；禁 StopCue `#16A34A/#F0FDF4/#DB2777`；禁 NightCue `#1E3A8A`  
- 禁 StopCue film-sprocket timeline + onion-skin；禁 NightCue night-frame rail；禁 HiveCue 六边形蜂巢；禁 FormCue 间歇 chip 轨；禁 YarnCue 毛线球条；禁 ScoutCue 太阳/星历侦查壳  
- 本轮 **不生成** AppIcon / LaunchScreen / splash 素材  
- 对标 Board Game Stats（`nl.vissering.BoardGameStats`）为定位对照（规则/摆台教练 ≠ 对局统计）；禁止复制其品牌、资产或 UI chrome

## Config gaps（P1 local_only）

```text
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```
