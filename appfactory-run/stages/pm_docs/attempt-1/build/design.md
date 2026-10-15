# YarnCue — 设计说明

## 视觉方向

- 毛线工坊感：品红主色、浅品红洗底、青柠点缀；多彩纱线色卡，禁全黑壳  
- 标志控件：**毛线球色卡条**（顶部/项目头）+ **横向「下一行」步骤带**（中部可横滑）  
- 大字号步骤与针法名；教练气泡清晰；标注点在 WIP 上可读  
- 禁止 KnotCue 绳径轮播、ScoutCue 天弧+卡片堆、ClosetCue / PitchCue dial+strip 孪生  

### Palette（操作者硬性）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| yarn-fuchsia | #A21CAF | Primary / 主 CTA / 品牌字 | operator_external goal palette | operator_external idea; hard palette |
| soft-wash | #FDF4FF | Secondary / 主表面洗底 | operator_external goal palette | operator_external idea; hard palette |
| lime-stitch | #84CC16 | Accent / 当前步骤 / 通过态 | operator_external goal palette | operator_external idea; hard palette |
| ink | #3B0764 | 主文字（深紫，非黑壳） | PM design decision for YarnCue | operator_external idea; original supporting ink |
| card | #FFFFFF | 内容卡片表面 | PM design decision for YarnCue | operator_external idea; original supporting surface |

## 导航

底部 Tab：Projects（Home）| Coach（当前 Project 快捷）| Settings  
栈内：NewProject → CaptureImport → StitchReview → ProjectCoach → CoachChat / AnnotatedWIP / HandsFreeTTS / DictateNote  
Modal：ConsentSheet

## 首次体验

打开即 Projects 空态（传统工作面：项目架 + 空色卡条位置预留），主 CTA「New project」→ 拍/导入一张 WIP → StitchReview Keep。冷启动不是裸聊天壳。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | New project |
| Capture import | Camera / Photo library |
| Stitch review | Keep |
| Project coach | Ask coach / Hands-free |
| Coach chat | Send（同意后） |
| Turn review | Keep |
| Annotated WIP | Keep marks |
| Hands-free TTS | Play |
| Dictate | Record |
| Settings | Revoke AI consent |

confirm: Keep  
reject: Discard  
edit: Edit

## 等待与反馈

- 识别 / 教练：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前步骤高亮 + 播放指示  
- 录音：计时；权限拒绝诚实提示  

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Projects empty | home-empty | crit-home-empty |
| Capture / import | capture-import | crit-capture-import |
| Stitch / row review | stitch-review | crit-stitch-review |
| Project coach (swatch + next-row band) | project-coach | crit-project-coach |
| Coach chat | coach-chat | crit-coach-chat |
| Annotated WIP | annotated-wip | crit-annotated-wip |
| Hands-free TTS | hands-free-tts | crit-hands-free-tts |
| Settings privacy/consent | settings-privacy | crit-settings-privacy |

同布局行为差异：Dictate 引用 coach-chat 并注明麦克风录音条（不另出帧）。教练等待态引用 coach-chat + Progress（不另出帧）。

## Branding assets

本轮 **不生成** AppIcon / LaunchScreen / splash（operator 硬性）。
