# NightCue — 功能说明

confirm: Keep · reject: Discard · edit: Edit

## 实体与关联

Session 1—* NightFrame  
NightFrame 0..1 ExposureDraft → 0..* DiagnosisFinding  
NightFrame 0..* AnnotatedOverlay  
Session 0..* CoachTurn / CoachMessage  
Session 0..* FieldCue  
Session 0..* DictatedExposure  
AIConsentRecord（本地 + Keychain 元数据）

## 旅程：入口 → 操作 → 结果 → 持久

### 1. Sessions home / New session

- 入口：底部 Tab Sessions  
- 操作：New session → 填场景标签（可选）  
- 结果：创建 Session  
- 持久：AtomicCodableStore Session  

### 2. Capture / import night frame

- 入口：Session → Capture  
- 操作：Camera 拍夜景试片 **或** Photos 导入历史夜景  
- 结果：NightFrame 本地保存；进入 ExposureReview  
- 持久：NightFrame + 本地图片文件  
- 权限：Camera / Photos；拒绝时诚实空态 + Open Settings 文案  

### 3. Exposure / noise diagnosis review

- 入口：新 NightFrame 后自动  
- 操作：AI 草稿（有 key 时出站；无 key 时本地规则草稿）→ Keep / Discard / Edit  
- 结果：Keep → DiagnosisFinding；Discard 丢草稿保留 NightFrame；Edit 改标签/文案再 Keep  
- 持久：ExposureDraft / DiagnosisFinding  
- AI 读：frame_photo_descriptor、scene 标签；结构化结果：underexposed|noise|trail|highlight + note  
- 反馈：Keep 的 Finding 摘要进入下一次教练调用  

### 4. Night coach hub（night-frame rail + exposure-diagnosis overlays）

- 入口：Keep 后 / Tab Coach  
- 操作：横向夜景帧轨切换试片；叠层开关显示诊断区  
- 结果：当前帧与叠层状态恢复  
- 持久：Session.current_frame_id + overlay visibility  

### 5. Coach chat

- 入口：Ask coach  
- 操作：发送前 ConsentSheet（DeepSeek + 字段列表）；Send → CoachTurn 草稿 → Keep / Discard  
- 结果：Keep → CoachMessage 历史  
- AI 读：exposure_summary、noise_summary、trail_signs、scene_plan_summary、current_frame_label、chat_text、dictated_exposure_fields、历史 Finding/反馈  
- 无 key：诚实 notConfigured / 仅本地能力，不得伪装已发送  

### 6. Annotated exposure overlay

- 入口：NightCoach → Annotate  
- 操作：在试片上确认/微调诊断区域 → Keep marks / Discard  
- 结果：AnnotatedOverlay 确认态绑定 NightFrame  

### 7. Field-cue TTS

- 入口：Hands-free cues  
- 操作：Play / Pause / Next（AVSpeechSynthesizer）  
- 结果：朗读 ISO / shutter / focus 口令；不要求回写  

### 8. Dictate exposure fields

- 入口：Dictate  
- 操作：麦克风录音 + Speech Recognition → 填入 iso / shutter_s / aperture / notes → Save into coach  
- 结果：DictatedExposure；进入下一次 AI 调用字段  
- 权限：Microphone + Speech；拒绝时诚实提示  

### 9. Settings / consent / legal

- Revoke AI consent（取消后续出站）  
- 四权限用途文案只读展示  
- 本地 Privacy / Terms / Support 页可加载  
- 外链 URL：UNKNOWN gap  

## 错误 / 取消 / 空态 / 重启

| 情况 | 行为 |
|------|------|
| 权限拒绝 | 非崩溃空态 + 原因 + 设置引导 |
| AI 失败 / 取消 | 横幅字面原因；用户内容保留 |
| 无 key | 出站关闭；本地诊断/烟测仍可用 |
| 空 Sessions | 传统工作面空架 + New session（非裸聊天壳） |
| 重启 | TypedNavigationStore 恢复有效前缀；实体经 AtomicCodableStore |

## AI 同意门

- Provider：DeepSeek  
- disclosure_version：`nightcue.consent.v1`  
- 首次出站前必须确认；Settings 可撤销  
- 披露字段见 technical/contract.md  
