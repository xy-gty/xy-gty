# CuePartner AI — 设计说明

## 视觉方向

- 排练厅氛围：暖木色舞台感、墨蓝幕布次级、粉笔白文字、琥珀提词强调  
- 大字号台词行、清晰角色色标；避免消费级「多彩卡片堆」与聊天 App 通用壳  
- 无付费墙、无金币、无 ATT；无 LineLearner 品牌痕迹

### Palette（设计授权自拟）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| stage-ink | #1B2430 | 主文字 / 幕布深底 | PM design decision for CuePartner AI | operator_external idea; original palette, not copied from LineLearner |
| chalk | #F4F0E6 | 主表面 / 台词纸 | PM design decision for CuePartner AI | operator_external idea; original palette, not copied from LineLearner |
| amber-cue | #D97706 | 主 CTA / 当前提词 | PM design decision for CuePartner AI | operator_external idea; original palette, not copied from LineLearner |
| curtain-blue | #334155 | 次级导航 / 角色条 | PM design decision for CuePartner AI | operator_external idea; original palette, not copied from LineLearner |
| soft-wood | #C4A484 | 背景氛围条 | PM design decision for CuePartner AI | operator_external idea; original palette, not copied from LineLearner |

## 导航

底部 Tab：Scenes（Home）| Rehearse（当前 Scene 快捷）| Settings  
栈内：NewScene → ImportScript → OCRReview → SceneDetail → PartnerChat / CueRehearsal / VoiceNote / Ambience  
Modal：ConsentSheet

## 首次体验

打开即 Scenes 空态（传统工作面：场景列表架），主 CTA「New scene」→ 导入一张自有脚本照片 → OCR 审阅 Keep。冷启动不是裸聊天壳。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | New scene |
| Import | Camera / Photo library |
| OCR review | Keep |
| Scene detail | Partner / Cue rehearsal |
| Partner chat | Send（同意后） |
| Turn review | Keep |
| Cue rehearsal | Play |
| Voice note | Record |
| Ambience | Use bed |
| Settings | Revoke AI consent |

confirm: Keep  
reject: Discard  
edit: Edit text

## 等待与反馈

- OCR / 对戏：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前 CueLine 高亮 + 播放指示 + 剩余 pause  
- 录音：波形/计时；权限拒绝诚实提示

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Scenes empty | home-empty | crit-home-empty |
| Import script | import-script | crit-import-script |
| OCR review | ocr-review | crit-ocr-review |
| Scene detail | scene-detail | crit-scene-detail |
| Partner chat | partner-chat | crit-partner-chat |
| Cue rehearsal TTS | cue-rehearsal | crit-cue-rehearsal |
| Voice note | voice-note | crit-voice-note |
| Settings privacy/consent | settings-privacy | crit-settings-privacy |

同布局行为差异：Partner chat 等待态引用 partner-chat 帧并注明 Progress 条（不另出帧）。Ambience 选择引用 scene-detail 并注明 Ambience sheet（不另出帧）。
