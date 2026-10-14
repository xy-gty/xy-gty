# PitchCue — 设计说明

## 视觉方向

- 明亮练习室氛围：lilac 表面、violet 主 CTA、mint 音高/波形强调；多色可读，禁止全黑壳  
- 教练感优先于调音器：练习条与聊天计划占主路径，圆形调音盘是可选辅层  
- 无付费墙、无金币、无 ATT；无 TonalEnergy / CuePartner 品牌痕迹

### Palette（操作者硬约束 + 设计补充）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| cue-violet | #7C3AED | Primary / 主 CTA | operator_external idea | operator_locked palette |
| cue-lilac | #F5F3FF | Secondary / 主表面 | operator_external idea | operator_locked palette |
| cue-mint | #10B981 | Accent / 音准 OK / 波形 | operator_external idea | operator_locked palette |
| ink-slate | #1E293B | 主文字 | PM design decision for PitchCue | operator_external idea; original support ink, not copied from TonalEnergy |
| soft-cloud | #FFFFFF | 卡片/拨盘内填 | PM design decision for PitchCue | operator_external idea; original support fill |

## 导航

底部 Tab：Practice（Home）| Sessions | Settings  
栈内：NewSession → CaptureImport → CoachChat → PlanReview → PracticeFloor → SessionDetail  
PracticeFloor 辅层：PitchFeedback | AudioBed sheet  
Modal：ConsentSheet

## 首次体验

打开即 Practice Home 空态（传统工作面：练习条骨架 + 空会话提示），主 CTA「New practice」→ 导入一张乐谱照片 → Ask coach 出热身草稿 → Keep → 进入 Practice floor 听倒数。冷启动不是裸聊天壳，也不是全屏调音针。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | New practice |
| Capture / Import | Camera / Photo library |
| Coach chat | Ask coach |
| Plan review | Keep |
| Practice floor | Count-in |
| Pitch feedback | Start listening |
| Session detail | Resume practice |
| Settings | Revoke AI consent |

confirm: Keep  
reject: Discard  
edit: Edit

## 等待与反馈

- AI 计划：内联 Progress + Cancel  
- 失败：横幅字面原因 + Retry  
- TTS / AudioBed：播放中 mint 波形；Stop 立即静音  
- 调音盘：偏差指针平滑；权限拒绝诚实横幅  
- 计划不足时禁用 Count-in

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Practice home empty | home-empty | crit-home-empty |
| Capture / Import | capture-import | crit-capture-import |
| Coach chat | coach-chat | crit-coach-chat |
| Plan review | plan-review | crit-plan-review |
| Practice floor (strip + waveform) | practice-floor | crit-practice-floor |
| Pitch feedback (circular dial) | pitch-feedback | crit-pitch-feedback |
| Settings privacy/consent | settings-privacy | crit-settings-privacy |

同布局行为差异：Ask coach 等待态引用 coach-chat 并注明 Progress（不另出帧）。ConsentSheet 引用 settings-privacy 并注明 modal 披露（不另出帧）。AudioBed 播放态引用 practice-floor 并注明波形动画（不另出帧）。

## 素材

本轮 **不生成** AppIcon / launch/splash（操作者硬约束 `branding_assets_deferred`）。无嵌入式 in-app image slots。
