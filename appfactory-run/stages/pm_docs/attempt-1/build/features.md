# BendCoach AI — 功能说明

idea_source: operator_external  
review_controls: confirm Save / reject Not this / edit Edit marks  
diagram_controls: confirm Use / reject Discard

## 核心售卖路径（必须可测）

### F1 弯管数学聊天

- **入口**：Home → 底部智能体输入条「Ask bend math…」或主 CTA Open coach  
- **操作**：输入英文问题（如 “90° stub-up on 3/4 EMT, 12 inch rise”）或点麦克风口述；STT 写入同一输入框；提交前若未同意出站则弹出 ConsentSheet  
- **结果**：流式或整段教练答复，含计算步骤摘要、关键标记点、当前单位徽章；旁注 Assistive guidance only  
- **持久**：BendQuery 挂在当前 JobSession；重启后可读历史问答  
- **空/错/取消**：空输入禁用发送；取消 consent 保留本地演示弯包提示；无 key 显示「AI not configured — demo bend pack」；网络/模型失败显示真实错误，不 canned 成功  
- **二次调用**：再次提问时带入已确认 BendMarkup / UnitPreference / 最近反馈

### F2 照片导入 / 相机拍摄 → 弯型识别审阅

- **入口**：Home → Capture photo 或 JobDetail → Add photo  
- **操作**：相机拍工地弯/标记，或相册导入；触发识别草稿  
- **结果**：BendRecognitionDraft 展示弯型候选（如 offset / saddle / 90° stub）、建议标记点；用户 Save / Not this / Edit marks  
- **持久**：Save → FieldPhoto + BendMarkup 写入 JobSession；Not this 不写入；Edit marks 改草稿后再 Save  
- **权限**：首次相机/相册系统权限；拒绝后应用内说明 + 仍可手输弯参；Simulator 旅程可测，真机细节标真机待测  
- **二次调用**：已确认标记进入后续 diagram / TTS / 聊天上下文

### F3 Diagram overlay

- **入口**：JobDetail → Generate diagram（需至少一张已确认标记或有效弯参）  
- **操作**：请求叠加图；人审 Use / Discard  
- **结果**：示意图叠在照片或空白弯纸上，标 take-up / shrink / mark 点（assistive）  
- **持久**：Use → DiagramOverlay 保存；Discard 不写  
- **无 key**：诚实未配置；可展示本地模板示意图 gap，不假装 live AI 成功

### F4 TTS 逐步现场辅导

- **入口**：JobDetail → Start coaching  
- **操作**：播放 CoachingStep 列表；Pause / Next / Replay  
- **结果**：AVSpeech 朗读步骤；当前步骤高亮；数值旁 assistive 注  
- **持久**：播放进度在会话内；步骤实体绑定 Job  
- **真机待测**：嘈杂工地音量体验不挡交付

### F5 语音入口（Mic + Speech）

- **入口**：BendMathChat 输入条 mic 按钮  
- **操作**：按住/点按说话 → STT → 填入输入框 → 用户确认发送  
- **结果**：转录可编辑；取消丢弃  
- **权限**：Microphone + Speech Recognition 用途字符串贴合 BendCoach；拒绝后仍可纯键盘  
- **Simulator**：UI 旅程可测；设备识别质量标真机待测

### F6 单位制

- **入口**：Settings → Units；首页与聊天顶栏单位徽章  
- **操作**：imperial ↔ metric；首次打开短说明「How units work in BendCoach」  
- **结果**：后续计算与显示跟 UnitPreference；历史 Job 保留记录时单位  
- **持久**：AtomicCodableStore

### F7 AI 同意与本地法律

- **入口**：首次出站前 ConsentSheet；Settings → Privacy / Terms / Support / Revoke AI consent  
- **披露**：provider DeepSeek；字段见技术契约；版本 `bendcoach.consent.v1`  
- **撤销**：立即停发出站；本地 Job/照片仍可用  
- **法律**：本地打包页可加载；外链 URL UNKNOWN = gap

## 实体关系（摘要）

JobSession 1—* BendQuery | FieldPhoto | BendMarkup | DiagramOverlay | CoachingStep  
BendRecognitionDraft →（Save）BendMarkup  
UnitPreference 全局  
AIConsentRecord 全局  
SpeechCaptureSession 会话级

## AI 读写合同

| 调用 | 读取 | 结构化结果 | 人审 | 反馈复用 |
|------|------|------------|------|----------|
| bend_math_chat | chat_text, unit_system, prior BendMarkup | 步骤摘要 + 数值 | 用户可编辑追问 | 最近确认标记与否定反馈 |
| bend_recognize | field_photo_bytes, unit_system | bend_type + markup_hints | Save/Not this/Edit | 拒绝类型不进入下次默认 |
| diagram_overlay | BendMarkup, photo | overlay geometry hints | Use/Discard | Discard 不污染历史 |
| coaching_steps | BendMarkup, diagram | ordered CoachingStep[] | 播放控制 | 跳过步骤记入会话反馈 |

## 错误 / 取消 / 空态 / 重启

- Home 空态：尚无 Job →「Start a bend job」  
- 识别失败：可重拍/手输  
- 出站关闭：全路径保留本地演示与已存 Job  
- 重启：TypedNavigationStore 恢复前缀路由；实体经 AtomicCodableStore 一致
