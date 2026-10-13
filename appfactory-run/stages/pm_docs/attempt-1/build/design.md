# DocBrief AI — 设计说明

## 视觉方向

- 清爽文书工作台：暖纸色底、墨青主色、琥珀强调 CTA、炭黑正文  
- 大字号、高对比、单手可点；照片与摘要卡圆角克制，不做扫描器「透视矫正酷炫」风格  
- 无付费墙、无金币、无 ATT 弹层；无 TurboScan 品牌痕迹

## 色表

| token | hex | use | source | authorization |
|-------|-----|-----|--------|---------------|
| paper | #F3EDE3 | 背景 | product_design_decision | pm_docs_attempt-1_original |
| ink | #1C2430 | 正文 | product_design_decision | pm_docs_attempt-1_original |
| teal | #1F6F6B | 主品牌 / 导航 | product_design_decision | pm_docs_attempt-1_original |
| amber | #D97706 | 主 CTA | product_design_decision | pm_docs_attempt-1_original |
| mist | #E8E2D8 | 分隔 / 卡片底 | product_design_decision | pm_docs_attempt-1_original |

## 导航

底部 Tab：Briefs（Home）| Active brief（当前 Brief 快捷）| Settings  
栈内：NewBrief → ImportCapture → RecognitionReview → BriefDetail → ChatExtract / SummaryCard / TTSBriefing  
Modal：ConsentSheet

## 首次体验

打开即 Briefs 空态（传统工作面：简报列表架），主 CTA「Start brief」→ 导入一张文档/小票样例照片 → 进入类型与字段审阅。冷启动不是聊天壳。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | Start brief |
| Import capture | Add photos |
| Recognition review | Save |
| Brief detail | Chat extract / Speak briefing / Summary card |
| Chat extract | Send（同意后） |
| Summary card | Use |
| TTS | Play / Next |
| Settings | Revoke AI consent |

confirm: Save  
reject: Not this  
edit: Edit fields  
summary confirm: Use / Discard

## 等待与反馈

- 识别/聊天/出图：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前段高亮 + 播放指示

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Briefs empty | home-empty | crit-home-empty |
| Import capture | capture-import | crit-capture-import |
| Type/field recognition review | fields-review | crit-fields-review |
| Brief detail filled | brief-detail-filled | crit-brief-detail-filled |
| Chat extract actions | chat-extract | crit-chat-extract |
| Summary card preview | summary-card | crit-summary-card |
| TTS spoken briefing | tts-briefing | crit-tts-briefing |
| Settings privacy/consent | settings-privacy | crit-settings-privacy |

同布局行为差异：BriefDetail 空态引用 brief-detail-filled 帧并注明仅列表为空 + Add field CTA（不另出帧）。
**r2 纠正**：禁止 SnagCue local_seed stems（punchlist/annotated-report/chat-fill/tts-coach 等巡检模板）。frame_id 使用 DocBrief 语义；生图不得出现 SnagCue AI、Audits、Punch、walkthrough、snag、rebar、site inspection 文案或 chrome。
