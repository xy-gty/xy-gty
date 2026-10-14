# PitchCue — 功能说明

## 功能 1：导入乐谱 / 练习照片

- 入口：PracticeHome → New session → Capture / Import  
- 操作：Camera 拍摄或 Photo library 选图（`PhotoImportSession` / CameraCapture）  
- 结果：创建 `SheetPhoto` 绑定到新 `PracticeSession`  
- 持久：AtomicCodableStore + 本地图片文件  
- 空态：无图时主 CTA「Import sheet」；取消选择不建会话  
- 错误：权限拒绝显示系统文案 + Settings 指引；导入失败可 Retry  
- 重启：已导入照片与会话仍在

## 功能 2：AI 热身 / 练习计划聊天

- 入口：会话内 Coach chat  
- 操作：文字或 SpeechGoalCapture 说目标 → 发送前 ConsentSheet（首次）→ DeepSeek 返回计划草稿  
- AI 读取字段：sheet_photo_desc、instrument_label、user_goal、speech_transcript、prior_plan_steps、coach_question、user_feedback  
- 结构化结果：`PracticePlan` 步骤列表（标题、时长建议、提示句）+ `CoachTurn`  
- 人审：Keep 写入 / Discard 不写 / Edit 改步骤后再 Keep  
- 历史：已确认计划与用户反馈进入下一次调用上下文  
- 错误：无 key → 诚实未配置，保留本地编辑空计划；网络失败横幅 + Retry；取消发送不写实体  
- 重启：已 Keep 的计划可读

## 功能 3：TTS 倒数与口语提示

- 入口：Practice floor → Count-in / Speak tip  
- 操作：对当前步骤触发 AVSpeechSynthesizer  
- 结果：听到倒数与教练短句；不改实体除非用户另存备注  
- 空态：无计划步骤时 CTA 禁用并提示先 Keep 计划  
- 取消：停止播报立即静音

## 功能 4：Drone / Metronome 床 + 波形

- 入口：Practice floor → Audio bed  
- 操作：选 drone 音高或 metronome BPM；Play/Stop  
- 结果：本地合成音频；连续波形视图实时更新；参数写入 `AudioBed`  
- 错误：音频会话失败字面提示；不假装云端采样成功

## 功能 5：水平练习条

- 入口：Practice floor 主区  
- 操作：横向滚动/点选步骤；当前步高亮  
- 结果：导航当前 `PracticePlan` 步骤；与 TTS/AudioBed 共用当前步  
- 禁止：CuePartner 式纵向 script timeline

## 功能 6：可选麦克风音高反馈 + 圆形调音盘

- 入口：Practice floor → Pitch check  
- 操作：请求麦克风 → 圆形 TunerDial 显示音分偏差；可选节奏稳度提示  
- 结果：`PitchSample` 元数据可附到会话；不自动改计划  
- 权限拒绝：保留无 mic 的本地练习（计划/TTS/drone）  
- Simulator：入口可达；硬件长听可标 真机待测

## 功能 7：设置、同意与本地法律页

- 入口：Settings  
- 操作：Revoke AI consent；打开 Privacy / Terms / Support 本地页；查看权限用途文案  
- 结果：撤销后立即停发出站；本地功能保留  
- Provider policy：应用内可达页，独立于产品 privacy

## 实体关系

PracticeSession 1—* SheetPhoto  
PracticeSession 1—0..1 PracticePlan（确认后）  
PracticeSession 1—* CoachTurn  
PracticeSession 1—0..1 AudioBed  
PracticeSession 1—* PitchSample  
AIConsentRecord 全局单例（披露版本 pitchcue.consent.v1）

## 二次调用适配

第二次 Ask coach 必须带入：已 Keep 的 plan 步骤摘要、用户 Edit 残留、最近反馈（过快/太难等）、当前 sheet_photo_desc。验收需观测上下文差异，而非仅有缓存文件。
