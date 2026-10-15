# StopCue — 视觉与导航设计

idea_source: operator_external  
confirm: Keep  
reject: Discard  
edit: Edit

## Visual direction

### Palette（操作者硬性）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| sprocket-green | #16A34A | Primary / 主 CTA / 品牌字 / 齿孔高亮 | operator_external goal palette | operator_external idea; hard palette |
| mint-wash | #F0FDF4 | Secondary / 主表面洗底 | operator_external goal palette | operator_external idea; hard palette |
| magenta-cue | #DB2777 | Accent / 洋葱皮选中 / 倒计时强调 / 通过态 | operator_external goal palette | operator_external idea; hard palette |
| ink | #14532D | 主文字（深绿墨，非黑壳） | PM design decision for StopCue | operator_external idea; original supporting ink |
| card | #FFFFFF | 内容卡片 / 帧边框内表面 | PM design decision for StopCue | operator_external idea; original supporting surface |

- Signature chrome: **film-sprocket timeline**（胶片齿孔时间轴：左右齿孔装饰的水平帧条）+ **onion-skin overlay preview**（半透明上一帧叠在当前帧上的对齐预览）  
- Ban: all-black shell; NightCue `#1E3A8A` night-frame rail + exposure-diagnosis overlays; CuePartner script axis; HiveCue hex comb; FormCue chip rail; YarnCue yarn-ball; ScoutCue solar/ephemeris shell  
- No AppIcon / LaunchScreen this round  
- Large legible English UI; native SwiftUI look  

## Navigation map

```
ProjectsHome
  → NewProject → CaptureImport → FrameReview → StopCoach
StopCoach
  → CoachChat → TurnReview
  → OnionSkinGuide
  → CountdownTTS
  → DictateInterval
Settings → LegalPages | RevokeConsent
ConsentSheet (modal before outbound AI)
```

## First experience

1. Open app → ProjectsHome empty (“No projects yet”) + film-sprocket silhouette placeholder + magenta **+ New project**  
2. New project → CaptureImport（Camera / Photos 双入口）  
3. Capture 几帧 → FrameReview 显示 AI shot-plan 草稿 → Keep  
4. 进入 StopCoach：胶片齿孔时间轴选帧 + 洋葱皮叠层开关  
5. 可选：Chat 问下一拍、Onion 确认标注、TTS 倒计时、Dictate 口述间隔  

## Key CTA / feedback

| Surface | Primary CTA | Waiting / error |
|---------|-------------|-----------------|
| ProjectsHome empty | + New project | — |
| CaptureImport | Capture frame / Import sequence | permission denied banner |
| FrameReview | Keep / Discard / Edit | AI generating… / not configured |
| StopCoach | Chat / Onion / Countdown / Dictate | overlay toggle feedback |
| CoachChat | Send | consent sheet; sending… |
| OnionSkinGuide | Keep guide | generating marks… |
| CountdownTTS | Play | speech failure text |
| Settings | Revoke AI consent | immediate stop-send copy |

## Frame coverage

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| ProjectsHome / empty | stopcue-home-empty | crit-home-empty |
| CaptureImport / ready | stopcue-capture-import | crit-capture-import |
| FrameReview / draft | stopcue-frame-review | crit-frame-review |
| StopCoach / timeline+onion | stopcue-stop-coach | crit-stop-coach |
| CoachChat / thread | stopcue-coach-chat | crit-coach-chat |
| OnionSkinGuide / annotated | stopcue-onion-overlay | crit-onion-overlay |
| CountdownTTS / playing | stopcue-tts-countdown | crit-tts-countdown |
| Settings / privacy | stopcue-settings-privacy | crit-settings-privacy |

同布局行为差异可引用同页帧：TurnReview 引用 coach-chat；DictateInterval 引用 stop-coach 并注明口述条。

## 场景时刻推导

- 桌面布景逐帧拍：双手占用 → TTS 倒计时 + 口述间隔优先于打字  
- 已有帧序列导入：Photos → FrameReview → 洋葱皮对齐下一拍  
- 分镜不确定：StopCoach Chat 问 “next frame a bit closer” 类建议 → Keep 写入 TimingCue/OnionSkinGuide  
