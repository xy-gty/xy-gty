# YarnCue — 功能说明

## 实体与关联

- Project 1—* WIPShot；Project 1—* StitchCue；Project 1—* CoachMessage / PatternNote  
- WIPShot 1—0..1 StitchRecognitionDraft；WIPShot 1—* AnnotatedOverlay  
- CoachTurn（草稿）确认后 → CoachMessage；拒绝不写入  

存储：`AtomicCodableStore`；同意与密钥侧车：`AIConsentGate` + `KeychainCredentialStore`。

## 功能清单（入口 → 操作 → 结果 → 持久）

### F1 拍/导入纱线与 WIP

- 入口：ProjectsHome / NewProject → CaptureImport  
- 操作：Camera 或 Photo library（`PhotoImportSession` / CameraCapture）  
- 结果：本地 WIPShot 文件 + 缩略预览  
- 持久：WIPShot  
- 空态/取消：保留 Project；权限拒绝诚实提示  
- 错误：解码失败横幅 + Retry  

### F2 针法/行识别审阅

- 入口：CaptureImport 完成后 → StitchReview  
- AI 读字段：wip_photo_descriptor（及可选用户备注）  
- 结构化结果：针法名、建议行号、简短依据（草稿）  
- 人审：Keep / Discard / Edit → 确认写入 StitchCue；拒绝不写入  
- 历史：已确认 StitchCue 进入 ProjectCoach 横向步骤带，并作为下次调用上下文  

### F3 ProjectCoach 工作面

- 入口：StitchReview Keep 后或从 Home 打开 Project  
- UI：YarnBallSwatchStrip（纱线色卡）+ NextRowStepBand（横向「下一行」步骤）  
- 操作：点步骤 / Ask coach / Annotate / Hands-free / Dictate  
- 持久：当前行指针、色卡色值列表  

### F4 Weave-coach 下一行聊天

- 入口：ProjectCoach → CoachChat  
- 发送前：共享 `AIConsentGate`（disclosure `yarncue.consent.v1`）  
- AI 读：recognized_stitch_summary、current_row、next_row_intent、chat_text、voice_transcript、pattern_note_text  
- 结果：CoachTurn 草稿 → Keep / Discard  
- 第二次调用：带入已确认 CoachMessage + StitchCue + 有效反馈  
- 未配置 key：诚实未配置，仅本地步骤浏览  

### F5 标注针法示意

- 入口：ProjectCoach → AnnotatedWIP  
- 操作：在 WIP 图上放置/编辑标注点；可请求 AI 建议草稿  
- 人审后写入 AnnotatedOverlay；拒绝保留原图  

### F6 TTS 免提教练

- 入口：HandsFreeTTS  
- 操作：Play / Pause / Next step；朗读当前 StitchCue / 已确认教练摘要  
- 结果：播报中步骤高亮；双手无需触摸主内容区以外控件即可 Next（大按钮）  
- 取消：Pause 停声  

### F7 口述备注 / 行意图

- 入口：DictateNote 或 CoachChat 麦克风  
- 操作：麦克风录音 + SpeechRecognition → 文本  
- 结果：写入 PatternNote 和/或填入教练输入  
- 权限拒绝：本地仍可手打备注  

### F8 设置与隐私

- Revoke AI consent 立即停发  
- 本地 Privacy / Terms / Support 页可加载  
- Provider policy 可达  
- 外链 URL：UNKNOWN gap  

## 重启恢复

App 重启后 Project / StitchCue / CoachMessage / PatternNote / AnnotatedOverlay 仍可读；导航经 `TypedNavigationStore` 恢复有效前缀。

## 明确不做

付费包解锁、社区 feed、Ravelry 壳、全黑壳、禁令布局孪生、本轮 AppIcon/LaunchScreen 生成。
