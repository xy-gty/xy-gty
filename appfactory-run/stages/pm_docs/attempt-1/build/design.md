# SnagCue AI — 设计说明

## 视觉方向

- 工业现场冷静色：混凝土灰底、安全黄强调、钢蓝次级、炭黑文字  
- 大字号、高对比、单手可点；照片卡圆角克制，不做消费级「漂亮卡片堆」  
- 无付费墙、无金币、无 ATT 弹层；无 Site Audit Pro 品牌痕迹

## 导航

底部 Tab：Audits（Home）| Active punch（当前 Audit 快捷）| Settings  
栈内：NewAudit → Capture → SnagRecognitionReview → PunchList → ChatFill / AnnotatedReport / TTSCoach  
Modal：ConsentSheet

## 首次体验

打开即 Audits 空态（传统工作面：审计列表架），主 CTA「Start audit」→ 导入一张样例式 walkthrough 照片 → 进入识别审阅。冷启动不是聊天壳。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | Start audit |
| Capture | Add photos |
| Snag review | Save |
| Punch list | Chat fill / Read aloud / Annotate |
| Chat fill | Send（同意后） |
| Report | Use |
| TTS | Play / Next |
| Settings | Revoke AI consent |

confirm: Save  
reject: Not this  
edit: Edit snag  
report confirm: Use / Discard

## 等待与反馈

- 识别/聊天/出图：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前项高亮 + 播放指示

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Audits empty | home-empty | crit-home-empty |
| Capture import | capture-import | crit-capture-import |
| Snag recognition review | recognition-review | crit-recognition-review |
| Punch list filled | punchlist-filled | crit-punchlist-filled |
| Chat fill fields | chat-fill | crit-chat-fill |
| Annotated report preview | annotated-report | crit-annotated-report |
| TTS checklist coach | tts-coach | crit-tts-coach |
| Settings privacy/consent | settings-privacy | crit-settings-privacy |

同布局行为差异：PunchList 空态引用 punchlist-filled 帧并注明仅列表为空 + Add snag CTA（不另出帧）。
