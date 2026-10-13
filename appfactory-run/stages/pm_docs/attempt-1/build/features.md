# SnagCue AI — 功能说明

## 实体与关联

- **Audit**：一次现场巡检；含 title、site_label、created_at、status  
- **WalkthroughPhoto**：属于 Audit；本地文件路径 + 拍摄顺序  
- **SnagDraft**：AI 识别草稿；未确认前不进 PunchItem  
- **PunchItem**：已确认缺陷项；location、severity、assignee、due_date、photo_refs、notes、status  
- **ReportDraft**：标注报告图草稿；绑定 Audit + 选中 PunchItem  
- **AIConsentRecord**：同意版本 `snagcue.consent.v1` + 撤销状态  
- **CoachSession**：TTS 会话；当前 PunchItem 索引

关联：Audit 1—N WalkthroughPhoto / PunchItem / ReportDraft；SnagDraft →（确认）PunchItem。

## 核心功能路径

### F1 新建 Audit 与导入照片

- 入口：Home → New Audit / Add photos  
- 操作：命名 Audit → 相机或相册多选导入（`PhotoImportSession`）  
- 结果：本地保存 WalkthroughPhoto；进入识别队列  
- 持久：Audit + photos 写入 AtomicCodableStore；重启可见  
- 空态：Home 空列表 CTA「Start audit」  
- 取消：离开 Capture 不丢已导入本批照片（明示 Discard batch）

### F2 Snag 识别审阅

- 入口：照片导入后自动或「Detect snags」  
- 操作：出站 AI（有 key + 同意）返回 SnagDraft 列表；用户 Save / Not this / Edit snag  
- 结果：Save → PunchItem；Not this → 丢弃草稿；Edit → 改字段后再 Save  
- AI 读取：walkthrough_photo_bytes、可选既有 snag_labels  
- 结构化结果：label、approx_location_hint、severity_guess、notes_hint  
- 无 key / 拒绝同意：本地启发式占位或空列表 + 诚实「AI unavailable」；仍可手动 Add snag  
- 错误：网络/模型失败保留照片，显示可重试

### F3 聊天补全 punch 字段

- 入口：PunchList → Chat fill / 单项「Ask AI」  
- 操作：RuntimeForm 输入；AI 提议字段补丁；人审 Save / Not this  
- AI 读取：chat_text、punch_item_fields、相关 snag_labels  
- 第二次调用：带入已确认 PunchItem 与用户反馈（如「assignee is GC not painter」）  
- 持久：仅 Save 后写回 PunchItem

### F4 标注报告图

- 入口：PunchList / Audit detail → Generate annotated report  
- 操作：选中条目 → 生成带标注预览 → Use / Discard  
- AI 读取：选中照片 bytes + punch 标签  
- 无 key：诚实未配置，不写假图  
- Use：ReportDraft 持久；可分享到系统分享表（本交付不强制云端）

### F5 TTS 清单教练

- 入口：PunchList → Read aloud  
- 操作：逐项播报 location + label + severity；Next / Pause / Replay  
- 离线：仅本地已保存 PunchItem 文本；不做出站  
- 真机音频：Simulator 可测 UI；真机待测标 known_issues 若宿主限制

### F6 同意、撤销与法律页

- 首次出站前 ConsentSheet：披露 DeepSeek、字段列表、provider policy 入口、本产品 Privacy  
- Settings：Revoke AI consent（立即停发）；重新同意后再发  
- Legal：本地 Privacy / Terms / Support 页可加载；外链 URL = UNKNOWN gap

## 错误 / 取消 / 空态 / 重启

| 场景 | 行为 |
|------|------|
| 空 Home | 引导 Start audit |
| 空 PunchList | 引导 Detect snags 或 Add snag |
| 用户取消同意 | 本地导入/手写/TTS 仍可用 |
| AI 失败 | 保留用户内容 + 字面错误 |
| 重启 | Audit/PunchItem/同意状态恢复；未确认草稿可丢弃或继续 |

## AI 闭环摘要

propose（SnagDraft / field patch / report image）→ 确认卡（Save/Use）→ persist 同 store；Reject 不写；Edit 有明确字段语义；反馈进入下一次上下文。
