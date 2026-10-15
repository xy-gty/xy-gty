# MixCue — design

## 场景时刻推导

用户在家庭吧台前，双手忙着摇壶或搅拌，手机只能斜靠台面或单手点一下，需要立刻看清「下一注倒什么、装饰何时上」。因此：

- 色温偏霓虹玫瑰吧台：primary `#E11D48`，secondary `#FFF1F2` 作大面积透气底，accent `#CA8A04` 只点在主 CTA 与当前倒法卡高亮，避开 WingCue 青绿/赤陶、FrameCue 紫琥珀、RuleCue 琥珀青、StopCue 绿粉、全黑克隆。
- 布局不是叠层 field-card、不是胶片齿孔、不是安全框场记板、不是天空弧、不是桌面轮次带、不是衣橱马赛克：左侧竖向瓶架轨，右侧/中部大号下一步倒法卡，底部装饰 chip 行。
- 字号：基酒名 Display 大号；倒法卡指令 ≥22pt 可一瞥；chip 15–17pt。
- 单手：主 CTA 与 coach 输入条贴底；倒法卡大触区推进 Next step。

## Visual direction

| Token | Value | Source | Authorization |
|-------|-------|--------|---------------|
| primary | `#E11D48` | operator goal hard rule | operator_locked |
| secondary | `#FFF1F2` | operator goal hard rule | operator_locked |
| accent | `#CA8A04` | operator goal hard rule | operator_locked |
| UI species | 竖向瓶架轨 + 大号下一步倒法卡 + 装饰 chip 行 | operator goal hard rule | operator_locked |
| ban twins | WingCue field-card stack / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket | operator goal hard rule | operator_locked |
| ban copy | Cocktail Party / Bevnap names | operator goal hard rule | operator_locked |

## Navigation chrome

- Top: compact MixCue wordmark (rose) + Settings gear
- Leading body: vertical bottle-rail (slots for identified spirits / empty hints)
- Center: large next-pour card (gold accent edge when active)
- Bottom: garnish chip row + Shoot (accent) · Import · coach text/speech bar

## First experience

1. Land on Bar Home empty (frame `home-empty`)
2. Shoot or Import a bottle → brief wait shimmer on pour-card placeholder
3. First outbound → AI consent (frame `consent-ai`) if needed
4. Land ID Result with bottle-rail slots filled (frame `id-result`)
5. Ask coach → recipe chat; Open pour board → large next-pour card + garnish chips; Speak step

Skip consent only when outbound not attempted. Never show canned spirits as success. Never put competitor brand names in UI strings.

## Key CTAs

| CTA | Color | Placement | Source | Authorization |
|-----|-------|-----------|--------|---------------|
| Shoot | accent `#CA8A04` | bottom-leading | operator goal palette | operator_locked |
| Import | rose outline `#E11D48` | beside Shoot | operator goal palette | operator_locked |
| Identify / Save Mix | accent `#CA8A04` | card footer | operator goal palette | operator_locked |
| Ask coach | rose text `#E11D48` | under rail | operator goal palette | operator_locked |
| Open pour board | rose `#E11D48` | under rail | operator goal palette | operator_locked |
| Speak step | secondary chip `#FFF1F2` | on pour card | operator goal palette | operator_locked |
| confirm: Save Mix / Keep / Use | accent `#CA8A04` | review bar | technical review_controls | pm_design |
| reject: Dismiss | quiet on `#FFF1F2` | review bar | technical review_controls | pm_design |

## Feedback & waiting

- Identifying: bottle-rail slot pulse + “Reading label…” on blush
- Chat streaming: coach bubble grows; rail stays visible
- TTS: waveform pip on Speak step
- Errors: rose primary banner, non-blocking

## Page → frame → criterion coverage

| Page / state | frame_id | criterion_ids |
|--------------|----------|---------------|
| Bar Home empty | mixcue-home-empty | CR-HOME-01 |
| Camera capture | mixcue-capture-camera | CR-CAM-01 |
| Spirit ID result | mixcue-id-result | CR-ID-01, CR-ID-02 |
| Recipe / substitute chat | mixcue-recipe-chat | CR-CHAT-01 |
| Pour board | mixcue-pour-board | CR-POUR-01, CR-POUR-02 |
| Voice note | mixcue-voice-note | CR-MIC-01 |
| AI consent | mixcue-consent-ai | CR-CONSENT-01 |
| Settings + legal | mixcue-settings-privacy | CR-SET-01 |

## Criterion text (design self-check)

- **CR-HOME-01:** Empty Bar Home shows blush canvas, vertical bottle-rail hint, large empty next-pour card, garnish chip row placeholder, Shoot/Import CTAs, and bottom coach bar; palette rose/blush/gold; no field-card stack/mosaic/clapper/sky-arc/table-zone/sprocket chrome; no competitor names.
- **CR-CAM-01:** Camera capture UI for bottle face / label / garnish with clear shutter; rose chrome; not a film sprocket or clapper frame.
- **CR-ID-01:** ID result shows vertical bottle-rail with spirit candidate slots and readable label cues.
- **CR-ID-02:** A large next-pour card (or clear CTA to open pour board) sits beside/below the rail as the primary action surface.
- **CR-CHAT-01:** Recipe/substitute chat shows coach thread with text + speech affordance; no competitor product names in sample copy.
- **CR-POUR-01:** Pour board centers a large next-pour instruction card with gold accent.
- **CR-POUR-02:** A horizontal garnish chip row sits under the pour card with placeable chip states.
- **CR-MIC-01:** Voice note sheet shows recording control for hands-free notes while shaking.
- **CR-CONSENT-01:** Consent sheet names DeepSeek and lists send fields before any send.
- **CR-SET-01:** Settings lists permission status, revoke AI, and local Privacy/Terms/Support entries.

## Data tables (entities shown in UI)

| Table | Columns shown | Source | Authorization |
|-------|---------------|--------|---------------|
| Bottle-rail slot | displayName, baseSpirit, confidence | technical/contract.md SpiritCandidate | pm_design |
| Next-pour card | ordinal, action, instruction, amountMl | PourStep | pm_design |
| Garnish chips | name, placed | GarnishChip | pm_design |
| Coach thread | role, text | CoachTurn | pm_design |
