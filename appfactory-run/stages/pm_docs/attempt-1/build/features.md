# RuleCue — 功能说明书

idea_source: operator_external

## Entities

| Entity | 关联 | 持久 |
|--------|------|------|
| GameSession | 1→N TablePhoto, ComponentMap, PhaseStep, CoachMessage | AtomicCodableStore |
| TablePhoto | N→1 GameSession；本地 image refs | AtomicCodableStore + files |
| ComponentDraft | 未确认组件/阶段 | AtomicCodableStore |
| ComponentMap | 确认后的组件清单 | AtomicCodableStore |
| PhaseStep | 确认后的回合步骤 | AtomicCodableStore |
| SetupOverlay | 确认后的分区标注 | AtomicCodableStore |
| CoachTurn / CoachMessage | 草稿 → 确认后历史 | AtomicCodableStore |
| HostCue | TTS 段落 | AtomicCodableStore |
| SpokenQuestion | 口述字段 | AtomicCodableStore |
| AIConsentRecord | 披露版本 + 允许态 | Keychain + local |

## Core flows（入口 → 操作 → 结果 → 持久）

### F1 Capture / Import table & rulebook
- 入口：SessionsHome → NewSession → CaptureImport（Camera 或 Photos）
- 操作：拍规则书页 / 组件特写 / 当前桌面，或导入相册页图与过往桌面照；取消保留已有 Session
- 结果：TablePhoto 落盘；空态提示再拍/再导入
- 权限：Camera / Photos；拒绝时仅本地空会话可浏览

### F2 Component / phase review
- 入口：CaptureImport 完成后 → ComponentReview
- 操作：AI 生成 ComponentDraft（出站需同意）；Keep / Discard / Edit
- 结果：Keep → ComponentMap + PhaseStep（及可选 SetupOverlay 草稿）；Discard 不写；Edit 改草稿后再审
- 错误：无 key / 拒绝同意 → 诚实未配置/本地-only；取消不写

### F3 TableCoach workspace
- 入口：ComponentReview Keep 后 → TableCoach
- 操作：桌游桌面分区卡选区；回合步骤条推进；进入 Chat / Overlay / Host / Dictate
- 结果：当前分区与步骤状态本地持久；重启恢复 TypedNavigationStore 前缀

### F4 Coach chat
- 入口：TableCoach → CoachChat
- 操作：输入裁决/回合问题；发送前 ConsentSheet；结果 TurnReview Keep/Discard
- 结果：Keep → CoachMessage；Discard 不写；历史供第二次调用复用
- AI 读取：game_session_summary、component_map_summary、phase_steps_summary、setup_overlay_notes、current_zone_label、chat_text

### F5 Setup overlay
- 入口：TableCoach → SetupOverlay
- 操作：审阅分区框/箭头/备注；Keep guide
- 结果：SetupOverlay 持久；下次同区可见

### F6 Host TTS
- 入口：TableCoach → HostTTS
- 操作：Play / Pause / Next cue（AVSpeechSynthesizer）
- 结果：HostCue 段落本地；失败显示具体错误文案

### F7 Dictate rules question
- 入口：TableCoach → DictateRules
- 操作：麦克风 + Speech Recognition 写入 SpokenQuestion → 注入 CoachChat 并触发下一条 tip
- 结果：SpokenQuestion 持久；mic/speech 拒绝时仍可手动输入

### F8 Settings / consent / legal
- 入口：Settings
- 操作：Revoke AI consent；打开本地 privacy/terms/support；四权限用途说明
- 结果：撤销后立即停发；本地拍导入仍可用

## AI loop（ODAO）

1. Observe：TablePhoto + ComponentMap + PhaseStep + SetupOverlay + chat/voice  
2. Decide：DeepSeek 结构化草稿（组件、步骤、裁决、叠图备注）  
3. Act：用户 Keep / Discard / Edit  
4. Outcome：确认写入同一 GameSession 存储；第二次调用带入已确认结果与反馈  

## Errors / cancel / empty / restart

| 态 | 行为 |
|----|------|
| 空会话 | SessionsHome “No sessions yet” + 分区卡剪影 CTA |
| 权限拒绝 | 诚实 banner；保留手动/本地路径 |
| AI 未配置 | 出站关闭文案；同意门仍拦截发送 |
| 取消拍照/导入 | 不覆盖已有 TablePhoto |
| Discard | 不写实体 |
| 重启 | TypedNavigationStore 恢复前缀；实体 AtomicCodableStore 可读 |

## confirm / reject

confirm: Keep  
reject: Discard  
edit: Edit
