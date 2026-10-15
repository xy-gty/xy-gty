# FrameCue — 设计说明

## 场景时刻推导

用户打开时刻：片场灯下刚摆好一台机，双手握着手机或监视器支架，需要 20–40 秒看清「主体是否贴边、景别是否该切 MS、安全框是否裁到话筒」。底部景别芯片单手可达；场记板式画幅框占主视觉，像夹着一张场记板看取景，而不是胶片齿孔时间线或桌游区卡。色温：紫罗兰主色传达导演控制感，淡紫洗底降压，琥珀强调当前景别与叠图高亮——与 RuleCue 琥珀棕桌感、StopCue 绿+粉胶片感、NightCue 深蓝夜框明确区分，禁全黑监视器壳。

## 视觉方向

- 片场场记板气质，不克隆 Cadrage；紫主色、淡紫洗底、琥珀强调  
- 标志控件：**片场场记板式画幅框** + **底部景别芯片条**  
- 大字号景别标签；教练气泡清晰；叠图线在静帧上可读  
- 禁止 RuleCue 桌区卡+回合步进条、StopCue 胶片齿孔时间线、NightCue 夜框轨孪生；禁止全黑/深灰壳  

### Palette（操作者硬性）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| director-violet | #7E22CE | Primary / 主 CTA / 品牌字 / 场记板边框 | operator_external goal palette | operator_external idea; hard palette |
| soft-lilac | #FAF5FF | Secondary / 主表面洗底 | operator_external goal palette | operator_external idea; hard palette |
| slate-amber | #F59E0B | Accent / 景别芯片选中 / 叠图高亮 / TTS 指示 | operator_external goal palette | operator_external idea; hard palette |
| ink | #4C1D95 | 主文字（深紫，非黑壳） | PM design decision for FrameCue | operator_external idea; original supporting ink |
| card | #FFFFFF | 内容卡片 / 场记板内表面 | PM design decision for FrameCue | operator_external idea; original supporting surface |

## 导航

底部 Tab：Sessions（Home）| Stage（当前 Session 快捷）| Settings  
栈内：NewSession → CaptureImport → CompositionReview → SlateStage → CoachChat / OverlayMarks / HandsFreeTTS / DictateShot  
Modal：ConsentSheet

## 首次体验

打开即 Sessions 空态（传统工作面：会话架 + 场记板轮廓 + 底部芯片条位置预留），主 CTA「New session」→ 拍/导入一张静帧 → CompositionReview Keep。冷启动不是裸聊天壳。同意门仅在首次出站 AI 前出现。

## 关键 CTA

| 页面 | 主 CTA |
|------|--------|
| Home empty | New session |
| Capture import | Camera / Photo library |
| Composition review | Keep |
| Slate stage | Ask coach / Overlays / Hands-free |
| Coach chat | Send（同意后） |
| Turn review | Keep |
| Overlay marks | Keep marks |
| Hands-free TTS | Play |
| Dictate | Record |
| Settings | Revoke AI consent |

confirm: Keep  
reject: Discard  
edit: Edit

## 等待与反馈

- 识别 / 教练：内联 Progress + 可取消  
- 失败：横幅字面原因 + Retry  
- TTS：当前景别芯片高亮 + 播放指示；场记板边框琥珀脉动  
- 录音：计时；权限拒绝诚实提示  

## 帧覆盖表

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Sessions empty | framecue-home-empty | crit-home-empty |
| Capture / import | framecue-capture-import | crit-capture-import |
| Composition review | framecue-composition-review | crit-composition-review |
| Slate stage (clapper frame + shot chips) | framecue-slate-stage | crit-slate-stage |
| Coach chat | framecue-coach-chat | crit-coach-chat |
| Overlay marks (safe-frame / thirds) | framecue-overlay-marks | crit-overlay-marks |
| Hands-free TTS | framecue-hands-free-tts | crit-hands-free-tts |
| Settings privacy/consent | framecue-settings-privacy | crit-settings-privacy |

同布局行为差异：Dictate 引用 coach-chat 并注明麦克风录音条（不另出帧）。教练等待态引用 coach-chat + Progress（不另出帧）。

## Branding assets

本轮 **不生成** AppIcon / LaunchScreen / splash（operator 硬性）。
