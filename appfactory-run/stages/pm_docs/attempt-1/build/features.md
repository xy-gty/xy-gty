# DocBrief AI — 功能说明

## 实体与关联

- **Brief**：一次简报会话；含 title、source_type_hint、created_at、status  
- **DocumentPhoto**：属于 Brief；本地文件路径 + 导入顺序  
- **RecognitionDraft**：AI 识别草稿（类型 + 字段）；未确认前不进 ExtractedField  
- **ExtractedField**：已确认字段；key、value、confidence_hint  
- **ActionItem**：已确认行动项；title、due_date、owner_hint、status、source_refs  
- **SummaryCardDraft**：视觉摘要卡草稿；绑定 Brief + 选中字段/行动项  
- **AIConsentRecord**：同意版本 `docbrief.consent.v1` + 撤销状态  
- **BriefingSession**：TTS 会话；当前段落/ActionItem 索引

关联：Brief 1—N DocumentPhoto / ExtractedField / ActionItem / SummaryCardDraft；RecognitionDraft →（确认）ExtractedField。

## 核心功能路径

### F1 新建 Brief 与导入照片

- 入口：Home → New brief / Add photos  
- 操作：命名 Brief → 相机或相册多选导入（`PhotoImportSession`）  
- 结果：本地保存 DocumentPhoto；进入识别队列  
- 持久：Brief + photos 写入 AtomicCodableStore；重启可见  
- 空态：Home 空列表 CTA「Start brief」  
- 取消：离开 ImportCapture 不丢已导入本批照片（明示 Discard batch）

### F2 类型与关键字段审阅

- 入口：照片导入后自动或「Recognize」  
- 操作：出站 AI（有 key + 同意）返回 RecognitionDraft；用户 Save / Not this / Edit fields  
- 结果：Save → ExtractedField + Brief.source_type；Not this → 丢弃草稿；Edit → 改字段后再 Save  
- AI 读取：document_photo_bytes、可选既有 recognized_type  
- 结构化结果：doc_type（document|whiteboard|receipt|other）、fields[{key,value}]、notes_hint  
- 无 key / 拒绝同意：本地启发式占位或空字段 + 诚实「AI unavailable」；仍可手动 Add field  
- 错误：网络/模型失败保留照片，显示可重试

### F3 聊天抽取行动项与截止日期

- 入口：BriefDetail → Chat extract / 单项「Ask AI」  
- 操作：RuntimeForm 输入；AI 提议 ActionItem 补丁；人审 Save / Not this  
- AI 读取：chat_text、extracted_fields、action_hints、recognized_type  
- 第二次调用：带入已确认 ActionItem 与用户反馈（如「deadline is Friday not Thursday」）  
- 持久：仅 Save 后写回 ActionItem

### F4 视觉摘要卡

- 入口：BriefDetail → Generate summary card  
- 操作：选中字段/行动项 → 生成摘要卡预览 → Use / Discard  
- AI 读取：选中照片 bytes + 字段标签 + action titles  
- 无 key：诚实未配置，不写假图  
- Use：SummaryCardDraft 持久；可分享到系统分享表（本交付不强制云端）

### F5 TTS 口述简报

- 入口：BriefDetail → Speak briefing  
- 操作：逐段播报类型摘要 + 关键字段 + 行动项/截止日期；Next / Pause / Replay  
- 离线：仅本地已保存文本；不做出站  
- 真机音频：Simulator 可测 UI；真机待测标 known_issues 若宿主限制

### F6 同意、撤销与法律页

- 首次出站前 ConsentSheet：披露 DeepSeek、字段列表、provider policy 入口、本产品 Privacy  
- Settings：Revoke AI consent（立即停发）；重新同意后再发  
- Legal：本地 Privacy / Terms / Support 页可加载；外链 URL = UNKNOWN gap

## 错误 / 取消 / 空态 / 重启

| 场景 | 行为 |
|------|------|
| 空 Home | 引导 Start brief |
| 空 BriefDetail | 引导 Recognize 或 Add field / Add action |
| 用户取消同意 | 本地导入/手写/TTS 仍可用 |
| AI 失败 | 保留用户内容 + 字面错误 |
| 重启 | Brief/字段/行动项/同意状态恢复；未确认草稿可丢弃或继续 |

## AI 闭环摘要

propose（RecognitionDraft / ActionItem patch / summary card）→ 确认卡（Save/Use）→ persist 同 store；Reject 不写；Edit 有明确字段语义；反馈进入下一次上下文。
