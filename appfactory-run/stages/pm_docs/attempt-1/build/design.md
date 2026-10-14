# BendCoach AI — 设计说明

idea_source: operator_external  
ui_language: en-US  
confirm: Save  
reject: Not this  
edit: Edit marks  
diagram_confirm: Use  
diagram_reject: Discard

## 场景时刻推导

用户多半在厢式车尾板或导管架旁单手拿手机：手套、阳光、需大号数字与底部可达 CTA。因此：深石板底减少眩光反射、安全琥珀 CTA、图表用冷蓝描线、字号偏大、主操作落在拇指区；深色默认，不做奶油纸面、不做紫色渐变、不做 QuickBend 绿标克隆。

## 视觉方向

深石板工地场景、安全琥珀 CTA、冷蓝示意图线；大字号、底部拇指区；无付费墙、金币、ATT、QuickBend 品牌痕迹。

## 色表

| token | hex | use | source | authorization |
|-------|-----|-----|--------|---------------|
| bg | #1A2332 | 场景底 | product_design_decision | pm_docs_attempt-1_original |
| surface | #243044 | 卡片/列表 | product_design_decision | pm_docs_attempt-1_original |
| ink | #F2F4F7 | 主文字 | product_design_decision | pm_docs_attempt-1_original |
| muted | #9AA6B2 | 次要 | product_design_decision | pm_docs_attempt-1_original |
| cta | #E8A317 | 主按钮 / 焦点 | product_design_decision | pm_docs_attempt-1_original |
| diagram | #5B8DEF | 叠加线 | product_design_decision | pm_docs_attempt-1_original |
| ok | #3D9B6E | 成功/已保存 | product_design_decision | pm_docs_attempt-1_original |
| warn | #D97706 | assistive 注 | product_design_decision | pm_docs_attempt-1_original |

品牌名 **BendCoach AI** 在首页与导航为英雄级。

## 页面与导航

1. **Home** — 主动式：底部 Ask bend math 输入条（文字/mic/相机快捷）+ 上下文卡「Next: capture a field bend」；Jobs 列表默认可展开  
2. **BendMathChat** — 全屏聊天，单位徽章，assistive 脚注  
3. **CaptureImport** — 相机预览 / 相册按钮并列  
4. **BendReview** — 草稿弯型 + Save / Not this / Edit marks  
5. **JobDetail** — 已确认标记、照片缩略、Generate diagram / Start coaching  
6. **DiagramOverlay** — 叠加预览 + Use / Discard  
7. **TTSCoaching** — 步骤列表 + 播放控件  
8. **Settings** — Units、Privacy、Terms、Support、Revoke AI consent

## 首次体验

冷启动 → 单位制短说明（可跳过，默认 imperial）→ Home 空态 → 引导完成一次真实任务：问一个 demo 弯参 **或** 导入示例/实拍照片并 Save 一处标记（AI consent 仅在首次出站前）。不把空白表单当价值。

## 关键 CTA

- Home: Ask bend math / Capture photo  
- BendReview: Save  
- Diagram: Use  
- Coaching: Start coaching / Pause / Next

## 反馈与等待

- 识别/聊天：底部进度条 +「Reading field marks…」  
- TTS：当前步骤脉冲高亮  
- 失败：内联错误 + Retry，保留用户输入

## 示例数据表

| field | example | source | authorization |
|-------|---------|--------|---------------|
| conduit | 3/4" EMT | product_design_decision | pm_docs_attempt-1_demo_assistive |
| bend | 90° stub-up | product_design_decision | pm_docs_attempt-1_demo_assistive |
| rise | 12 in | product_design_decision | pm_docs_attempt-1_demo_assistive |
| take_up | 6 5/16 in | product_design_decision | pm_docs_attempt-1_demo_assistive |

示例数为演示用 assistive 值，非规范认证。

## Frame → criterion 覆盖

| 页面/状态 | frame_id | criterion_id |
|-----------|----------|--------------|
| Home 空态 | home-empty | crit-home-empty |
| 弯管数学聊天 | bend-math-chat | crit-bend-math-chat |
| 拍摄/导入 | capture-import | crit-capture-import |
| 弯型审阅 | bend-review | crit-bend-review |
| Job 已填 | job-detail-filled | crit-job-detail-filled |
| 示意图叠加 | diagram-overlay | crit-diagram-overlay |
| TTS 辅导 | tts-coaching | crit-tts-coaching |
| 设置·单位·隐私 | settings-units-privacy | crit-settings-units-privacy |

同布局状态引用同页帧并在 acceptance 写行为差异；不可用单张首页覆盖全流程。
