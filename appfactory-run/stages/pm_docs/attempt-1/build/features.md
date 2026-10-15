# StopCue — 功能说明书

idea_source: operator_external

## Entities

| Entity | 关联 | 持久 |
|--------|------|------|
| Project | 1→N FrameSequence, TimingCue, CoachMessage | AtomicCodableStore |
| FrameSequence | N→1 Project；本地 image refs | AtomicCodableStore + files |
| ShotPlanDraft | 未确认分镜/间隔 | AtomicCodableStore |
| TimingCue | 确认后的间隔/倒计时 | AtomicCodableStore |
| OnionSkinGuide | 确认后的洋葱皮标注 | AtomicCodableStore |
| CoachTurn / CoachMessage | 草稿 → 确认后历史 | AtomicCodableStore |
| CountdownCue | TTS 段落 | AtomicCodableStore |
| DictatedInterval | 口述字段 | AtomicCodableStore |
| AIConsentRecord | 披露版本 + 允许态 | Keychain + local |

## Core flows（入口 → 操作 → 结果 → 持久）

### F1 Capture / Import frames
- 入口：ProjectsHome → NewProject → CaptureImport（Camera 或 Photos）
- 操作：逐帧拍摄或选择相册序列；取消保留已有 Project
- 结果：FrameSequence 落盘；空态提示再拍/再导入
- 权限：Camera / Photos；拒绝时仅本地空序列可浏览

### F2 Frame review
- 入口：CaptureImport 完成后 → FrameReview
- 操作：AI 生成 ShotPlanDraft（出站需同意）；Keep / Discard / Edit
- 结果：Keep → TimingCue + 可选 OnionSkinGuide 草稿；Discard 不写；Edit 改草稿后再审
- 错误：无 key / 拒绝同意 → 诚实未配置/本地-only；取消不写

### F3 StopCoach workspace
- 入口：FrameReview Keep 后 → StopCoach
- 操作：胶片齿孔时间轴选帧；洋葱皮叠层开关；进入 Chat / Onion / TTS / Dictate
- 结果：当前帧标签与叠层状态本地持久；重启恢复 TypedNavigationStore 前缀

### F4 Coach chat
- 入口：StopCoach → CoachChat
- 操作：输入分镜/间隔问题；发送前 ConsentSheet；结果 TurnReview Keep/Discard
- AI 读取字段：frame_sequence_descriptor、shot_plan_summary、timing_summary、onion_skin_notes、current_frame_label、chat_text
- Keep → CoachMessage；第二次调用带入已确认历史与反馈

### F5 Onion-skin annotated guide
- 入口：StopCoach → OnionSkinGuide
- 操作：预览半透明上一帧叠层 + AI 标注草稿 → Keep/Discard/Edit
- 结果：Keep 写入 OnionSkinGuide；用于下一帧对齐

### F6 TTS countdown cues
- 入口：StopCoach → CountdownTTS
- 操作：Play / Pause / Next；AVSpeechSynthesizer 读倒计时口令
- 结果：CountdownCue 进度本地；失败显示具体错误、不静默

### F7 Dictate interval / cue
- 入口：StopCoach → DictateInterval
- 操作：麦克风 + Speech Recognition；例 “next frame a bit closer” / “interval 400ms”
- 结果：DictatedInterval 写入；可送入教练（需同意）或仅本地字段
- 权限：Microphone / Speech；拒绝保留手动输入

### F8 Settings / privacy / legal
- 入口：Settings
- 操作：撤销 AI 同意（立即停发）；打开本地 Privacy / Terms / Support；四权限用途说明
- 外链 URL：UNKNOWN gap；本地页可加载为准

## AI 闭环

1. 构造上下文自 Project/FrameSequence/已确认 TimingCue/OnionSkinGuide/CoachMessage  
2. ConsentGate permit（disclosure `stopcue.consent.v1`）后出站 DeepSeek  
3. 结构化草稿 → 人审 Keep/Discard/Edit  
4. Keep 才写入同一实体存储；重启可读；第二次调用复用已确认内容  

## 错误 / 空态 / 取消 / 重启

- 空项目列表：CTA New project  
- 无帧序列：CaptureImport 引导  
- AI 未配置 / 同意拒绝：本地摄影与时间轴仍可用  
- 取消拍摄/导入：不覆盖既有序列  
- 损坏存储：AtomicCodableStore 保留旧数据并显示具体失败  
