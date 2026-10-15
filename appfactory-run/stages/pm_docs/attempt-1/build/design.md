# RuleCue — 视觉与导航设计

idea_source: operator_external  
confirm: Keep  
reject: Discard  
edit: Edit

## Visual direction

### Palette（操作者硬性）

| token | hex | role | source | authorization |
|-------|-----|------|--------|---------------|
| table-amber | #854D0E | Primary / 主 CTA 描边 / 品牌字 / 分区卡标题 | operator_external goal palette | operator_external idea; hard palette |
| parchment-wash | #FEFCE8 | Secondary / 主表面洗底 | operator_external goal palette | operator_external idea; hard palette |
| cue-cyan | #0891B2 | Accent / 步骤条当前步 / 叠图选中 / 通过态 | operator_external goal palette | operator_external idea; hard palette |
| ink | #422006 | 主文字（深琥珀墨，非黑壳） | PM design decision for RuleCue | operator_external idea; original supporting ink |
| card | #FFFFFF | 分区卡内表面 | PM design decision for RuleCue | operator_external idea; original supporting surface |

- Signature chrome: **table zone cards**（桌游桌面分区卡：牌堆/版图/玩家区等圆角分区卡网格）+ **turn step bar**（顶部或底部水平回合步骤条，当前步 #0891B2 高亮）  
- Ban: all-black shell; StopCue `#16A34A/#F0FDF4/#DB2777` film-sprocket timeline + onion-skin; NightCue `#1E3A8A` night-frame rail; CuePartner script axis; HiveCue hex comb; FormCue chip rail; YarnCue yarn-ball; ScoutCue solar/ephemeris shell  
- No AppIcon / LaunchScreen this round  
- Large legible English UI; native SwiftUI look  

## Navigation map

```
SessionsHome
  → NewSession → CaptureImport → ComponentReview → TableCoach
TableCoach
  → CoachChat → TurnReview
  → SetupOverlay
  → HostTTS
  → DictateRules
Settings → LegalPages | RevokeConsent
ConsentSheet (modal before outbound AI)
```

## First experience

1. Open app → SessionsHome empty (“No sessions yet”) + faint table-zone-card silhouette + cyan **+ New session**  
2. New session → CaptureImport（Camera / Photos 双入口）  
3. Capture 规则书/桌面 → ComponentReview 显示 AI 组件/阶段草稿 → Keep  
4. 进入 TableCoach：分区卡选区 + 回合步骤条  
5. 可选：Chat 问裁决、Overlay 确认标注、TTS 主持、Dictate 口述规则问题  

## Key CTA / feedback

| Surface | Primary CTA | Waiting / error |
|---------|-------------|-----------------|
| SessionsHome empty | + New session | — |
| CaptureImport | Capture page / Import photos | permission denied banner |
| ComponentReview | Keep / Discard / Edit | AI generating… / not configured |
| TableCoach | Chat / Overlay / Host / Dictate | zone select + step advance feedback |
| CoachChat | Send | consent sheet; sending… |
| SetupOverlay | Keep guide | generating marks… |
| HostTTS | Play | speech failure text |
| Settings | Revoke AI consent | immediate stop-send copy |

## Frame coverage

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| SessionsHome / empty | rulecue-home-empty | crit-home-empty |
| CaptureImport / ready | rulecue-capture-import | crit-capture-import |
| ComponentReview / draft | rulecue-component-review | crit-component-review |
| TableCoach / zones+steps | rulecue-table-coach | crit-table-coach |
| CoachChat / thread | rulecue-coach-chat | crit-coach-chat |
| SetupOverlay / annotated | rulecue-setup-overlay | crit-setup-overlay |
| HostTTS / playing | rulecue-tts-host | crit-tts-host |
| Settings / privacy | rulecue-settings-privacy | crit-settings-privacy |

同布局行为差异可引用同页帧：TurnReview 引用 coach-chat；DictateRules 引用 table-coach 并注明口述条。

## 场景时刻推导

- 桌边摆台双手占用 → TTS 主持 + 口述规则问题优先于打字  
- 已有规则书页导入：Photos → ComponentReview → 分区卡对照漏放  
- 裁决不确定：TableCoach Chat 问 “can I play this card” → Keep 写入 CoachMessage / PhaseStep tip  
