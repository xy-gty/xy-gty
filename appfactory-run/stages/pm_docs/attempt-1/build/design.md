# NightCue — 设计说明

## 场景时刻推导

用户打开时刻：三脚架已架好，城市灯火刚亮，需要 30–60 秒看清「试片是否欠曝、噪点是否过重、光轨是否糊」，然后立刻调 ISO/快门再拍下一张。单手可达底部主 CTA；**夜景帧轨**横向轻扫切换试片；识别结果落在**曝光诊断叠层**上，像测光分区标在夜景上。色温：深蓝主色传达夜空，冰蓝洗底降压，琥珀金点缀合格/对焦通过态——与 HiveCue 酒红蜂巢、FormCue 训练红+青、YarnCue 品红+青柠、ScoutCue 日光侦查明确区分，禁全黑壳。

## 视觉方向

- 夜拍感但不克隆 NightCap；深蓝主色、冰蓝洗底、琥珀金强调  
- 标志控件：**夜景帧轨（night-frame rail）** + **曝光诊断叠层（exposure-diagnosis overlays）**  
- 大字号试片标签与 Diagnosis 标签；教练气泡清晰；叠层在夜景照上可读  
- 禁止 HiveCue 六边形蜂巢网格+巡检轨+热力叠图孪生；禁止 FormCue 间歇 chip 轨+休息环+拍立得条孪生；禁止 YarnCue 毛线球条；禁止 ScoutCue 太阳/星历侦查壳；禁止全黑壳  

### Palette（操作者硬性）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| night-navy | #1E3A8A | Primary / 主 CTA / 品牌字 / 欠曝警示区 | operator_external goal palette | operator_external idea; hard palette |
| ice-wash | #EFF6FF | Secondary / 主表面洗底 | operator_external goal palette | operator_external idea; hard palette |
| amber-cue | #FBBF24 | Accent / 合格曝光 / 帧轨选中 / 通过态 | operator_external goal palette | operator_external idea; hard palette |
| ink | #1E3A5F | 主文字（深蓝墨，非黑壳） | PM design decision for NightCue | operator_external idea; original supporting ink |
| card | #FFFFFF | 内容卡片 / 试片边框内表面 | PM design decision for NightCue | operator_external idea; original supporting surface |

## 导航

底部 Tab：Sessions（Home）| Coach（当前 Session 快捷）| Settings  
栈内：NewSession → CaptureImport → ExposureReview → NightCoach → CoachChat / AnnotatedOverlay / FieldCueTTS / DictateExposure  
Modal：ConsentSheet

## 首次体验

打开即 Sessions 空态（传统工作面：夜拍架 + 夜景帧轨位置预留），主 CTA「New session」→ 拍/导入一张夜景试片 → ExposureReview Keep。冷启动不是裸聊天壳。同意门仅在首次出站 AI 前出现。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | New session |
| Capture import | Camera / Photo library |
| Exposure review | Keep |
| Night coach | Ask coach / Field cues |
| Coach chat | Send（同意后） |
| Turn review | Keep |
| Annotated overlay | Keep marks |
| Field-cue TTS | Play |
| Dictate | Record |
| Settings | Revoke AI consent |

confirm: Keep  
reject: Discard  
edit: Edit

## 等待与反馈

- 诊断 / 教练：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前口令高亮 + 播放指示；帧轨同步  
- 录音：计时；权限拒绝诚实提示  

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Sessions empty | nightcue-home-empty | crit-home-empty |
| Capture / import | nightcue-capture-import | crit-capture-import |
| Exposure / diagnosis review | nightcue-exposure-review | crit-exposure-review |
| Night coach (rail + overlays) | nightcue-night-coach | crit-night-coach |
| Coach chat | nightcue-coach-chat | crit-coach-chat |
| Annotated exposure overlay | nightcue-annotated-overlay | crit-annotated-overlay |
| Field-cue TTS | nightcue-field-tts | crit-field-tts |
| Settings privacy/consent | nightcue-settings-privacy | crit-settings-privacy |

同布局行为差异：Dictate 引用 coach-chat 并注明麦克风录音条（不另出帧）。教练等待态引用 coach-chat + Progress（不另出帧）。

## Branding assets

本轮 **不生成** AppIcon / LaunchScreen / splash（operator 硬性）。
