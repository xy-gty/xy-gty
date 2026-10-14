# CuePartner AI — 功能说明

## 1. 脚本导入与 OCR

**入口：** ScenesHome → New Scene → Import Script（Camera | Photo Library）  
**操作：** 拍摄或选择脚本页 → 本地 OCR → OCRReview  
**结果：** ScriptPage 草稿（图 + 文本）  
**持久：** Keep 后写入 AtomicCodableStore；Discard 不写入；Edit text 保存编辑后文本  
**空/错/取消：** 无页可导时空态；OCR 失败横幅 Retry；取消返回 Import  
**重启：** 已 Keep 的 ScriptPage 仍在 SceneDetail

## 2. 场景与 CueLine 整理

**入口：** SceneDetail  
**操作：** 从 OCR 文本拆角色/行，或手动增删 CueLine（角色、台词、pause_ms）  
**结果：** Scene + CueLine 列表  
**持久：** AtomicCodableStore  
**错误：** 空场景禁止进入 Partner/TTS 主路径，提示先导入一行

## 3. AI 对戏伙伴（角色切换）

**入口：** SceneDetail → Partner Chat  
**操作：** 选择 partner_role（对手角色）与 user_role；输入台词或粘贴转写；首次出站弹 ConsentSheet  
**AI 读取字段：** script_page_ocr_text、cue_lines、partner_role、user_line_text、voice_transcript、chat_text  
**结构化结果：** PartnerTurn（伙伴台词草稿 + 可选情绪/节拍提示）  
**人审：** Keep → 写入 RehearsalMessage；Discard → 不写入；可再请求  
**历史→下次调用：** 已确认 RehearsalMessage + 有效反馈进入上下文  
**无 key：** 诚实未配置，保留本地对词/TTS；不 canned 假成功  
**撤销：** Settings → Revoke AI consent 立即停发

## 4. TTS 提词与时机

**入口：** SceneDetail → Cue Rehearsal  
**操作：** Play / Pause / Next；按 CueLine.pause_ms 插入停顿  
**结果：** 当前行高亮 + 播放指示  
**离线：** 系统 AVSpeech，不依赖出站  
**错误：** 空列表禁用 Play

## 5. 可选舞台音床

**入口：** SceneDetail → Ambience  
**操作：** 选本地 preset（quiet stage / soft murmur / rain wings）或 Off  
**结果：** 排练时低音量循环；不覆盖 TTS  
**持久：** Scene.ambience_id

## 6. Voice note + 语音识别

**入口：** SceneDetail → Voice Note；Partner Chat → Speak line  
**操作：** 麦克风录音保存 VoiceNote；Speech 将说词转文字填入伙伴输入  
**Simulator：** 入口与权限文案旅程可测；真实相机/长录音可标 真机待测  
**拒绝权限：** 保留文本输入与相册导入；不假装已录音

## 7. 设置与法律

**入口：** Settings  
**内容：** 撤销同意、本地 Privacy / Terms / Support 页、权限说明入口  
**外链 URL：** UNKNOWN gap；验收以本地页可加载为准

## 实体关系

Scene 1—* ScriptPage  
Scene 1—* CueLine  
Scene 1—* RehearsalMessage  
Scene 1—* VoiceNote  
Scene 0–1 AmbiencePreset  
PartnerTurn →（Keep）RehearsalMessage  
AIConsentRecord 全局

## 错误 / 取消 / 空态 / 恢复

| 状态 | 行为 |
|------|------|
| 无 Scene | Home 空态 + New Scene |
| OCR 失败 | Retry / 手动粘贴文本 |
| AI 未配置 | 字面提示；本地 TTS/导入仍可用 |
| 用户取消同意 | 关闭 sheet，不发送 |
| 发送失败 | 横幅字面错误 + Retry；保留输入 |
| 杀进程重启 | TypedNavigationStore 前缀恢复；实体从 store 读回 |
