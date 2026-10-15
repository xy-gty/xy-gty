# HiveCue — 设计说明

## 场景时刻推导

用户打开时刻：箱旁刚掀盖，手套粘蜜、面罩起雾，需要 30–60 秒看清「蜂子是否封盖、储蜜带、是否有虫害迹象」，然后立刻推进下一脾位。单手可达底部主 CTA；六边形蜂巢网格让脾位像真实巢房排布；巡检轨横向轻扫换下一帧；识别结果落在热力叠图上，像红外热区标在巢脾上。色温：酒红主色传达花蜜与警示，浅粉洗底降压，叶绿点缀合格/储蜜通过态——与 FormCue 训练红+青、YarnCue 品红+青柠明确区分，禁全黑壳。

## 视觉方向

- 蜂场感但不克隆 BeePlus；酒红主色、浅粉洗底、叶绿强调  
- 标志控件：**六边形蜂巢网格** + **巡检轨** + **热力叠图**  
- 大字号脾位标签与 Finding 标签；教练气泡清晰；热区在巢脾照上可读  
- 禁止 FormCue 间歇 chip 轨+休息环+拍立得条孪生；禁止 YarnCue 毛线球条及其它 Cue 壳；禁止全黑壳  

### Palette（操作者硬性）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| hive-wine | #9F1239 | Primary / 主 CTA / 品牌字 / 警示热区 | operator_external goal palette | operator_external idea; hard palette |
| blossom-wash | #FDF2F8 | Secondary / 主表面洗底 | operator_external goal palette | operator_external idea; hard palette |
| nectar-green | #4D7C0F | Accent / 合格储蜜 / 网格选中 / 通过态 | operator_external goal palette | operator_external idea; hard palette |
| ink | #881337 | 主文字（酒红褐，非黑壳） | PM design decision for HiveCue | operator_external idea; original supporting ink |
| card | #FFFFFF | 内容卡片 / 巢脾边框内表面 | PM design decision for HiveCue | operator_external idea; original supporting surface |

## 导航

底部 Tab：Inspections（Home）| Coach（当前 Inspection 快捷）| Settings  
栈内：NewInspection → CaptureImport → BroodReview → InspectionCoach → CoachChat / AnnotatedFrame / HandsFreeTTS / DictateFields  
Modal：ConsentSheet

## 首次体验

打开即 Inspections 空态（传统工作面：巡检架 + 蜂巢网格位置预留），主 CTA「New inspection」→ 拍/导入一张巢脾 → BroodReview Keep。冷启动不是裸聊天壳。同意门仅在首次出站 AI 前出现。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | New inspection |
| Capture import | Camera / Photo library |
| Brood review | Keep |
| Inspection coach | Ask coach / Hands-free |
| Coach chat | Send（同意后） |
| Turn review | Keep |
| Annotated frame | Keep marks |
| Hands-free TTS | Play |
| Dictate | Record |
| Settings | Revoke AI consent |

confirm: Keep  
reject: Discard  
edit: Edit

## 等待与反馈

- 识别 / 教练：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前轨位高亮 + 播放指示；网格同步  
- 录音：计时；权限拒绝诚实提示  

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Inspections empty | hivecue-home-empty | crit-home-empty |
| Capture / import | hivecue-capture-import | crit-capture-import |
| Brood / recognition review | hivecue-brood-review | crit-brood-review |
| Inspection coach (hex grid + rail + heat) | hivecue-inspection-coach | crit-inspection-coach |
| Coach chat | hivecue-coach-chat | crit-coach-chat |
| Annotated frame (heat overlay) | hivecue-annotated-frame | crit-annotated-frame |
| Hands-free TTS | hivecue-hands-free-tts | crit-hands-free-tts |
| Settings privacy/consent | hivecue-settings-privacy | crit-settings-privacy |

同布局行为差异：Dictate 引用 coach-chat 并注明麦克风录音条（不另出帧）。教练等待态引用 coach-chat + Progress（不另出帧）。

## Branding assets

本轮 **不生成** AppIcon / LaunchScreen / splash（operator 硬性）。
