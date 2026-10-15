# SporeCue — design

idea_source: operator_external

## 场景时刻推导

用户在林地或步道边单手持刀/篮子，另一手举手机对菌盖、菌褶或管孔特写。需要立刻看清「最像哪个种、易混种警示、特写部位」——且每一面都必须声明非可食认证，绝不能读成“可以吃”。

- 色温：cap russet `#9A3412` 主色，apricot cream `#FFF7ED` 大底，sky blue `#0284C7` 仅点在主 CTA 与当前高亮特写条；避开 MixCue 玫瑰金、WingCue 青绿赤陶、FrameCue 紫琥珀、RuleCue 琥珀青、StopCue 绿粉、全黑克隆。
- 布局不是瓶架轨、不是叠层 field-card、不是胶片齿孔、不是安全框场记板、不是天空弧、不是桌面轮次带、不是衣橱马赛克：纵向物种置信栈 + 超大菌褶/管孔特写条 + 可食/警示 chip 轨。
- 字号：物种名 Display 大号；置信百分比 ≥20pt；特写条标签清晰；chip 15–17pt。
- 单手：Shoot/Import 与 coach 输入贴底；特写条为大触区。

## Visual direction

| Token | Value | Source | Authorization |
|-------|-------|--------|---------------|
| primary | `#9A3412` | operator goal hard rule | operator_locked |
| secondary | `#FFF7ED` | operator goal hard rule | operator_locked |
| accent | `#0284C7` | operator goal hard rule | operator_locked |
| UI species | 纵向物种置信栈 + 超大菌褶/管孔特写条 + 可食/警示 chip 轨 | operator goal hard rule | operator_locked |
| compliance banner | 非可食认证 / not an edibility certification | operator goal hard rule | operator_locked |
| ban twins | MixCue bottle-rail / WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket | operator goal hard rule | operator_locked |
| ban copy | Shroomify / Pilze 123 names | operator goal hard rule | operator_locked |

## Navigation chrome

- Top: SporeCue wordmark (russet) + Settings gear + persistent disclaimer strip on foraging surfaces
- Body: vertical species-confidence stack (ranked names + %)
- Mid: oversized gill/pore closeup bar with morphology pins
- Below bar: horizontal edible/warning informational chip rail
- Bottom: Shoot (accent) · Import · coach text/speech bar

## First experience

1. Land on Field Home empty (frame `sporecue-home-empty`)
2. Shoot or Import a gill/pore still → wait shimmer on stack
3. First outbound → AI consent (frame `sporecue-consent-ai`) if needed
4. Land ID Result with stack + closeup bar + chips under disclaimer (frame `sporecue-id-result`)
5. Ask coach lookalike → chat; Annotate → overlay; Play brief → TTS

Skip consent only when outbound not attempted. Never show canned species as success. Never put competitor names or “safe to eat” in UI strings.

## Key CTAs

| CTA | Color | Placement | Source | Authorization |
|-----|-------|-----------|--------|---------------|
| Shoot | accent `#0284C7` | bottom-leading | operator goal palette | operator_locked |
| Import | russet outline `#9A3412` | beside Shoot | operator goal palette | operator_locked |
| Identify / Save Find | accent `#0284C7` | card footer | operator goal palette | operator_locked |
| Ask coach | russet text `#9A3412` | under stack | operator goal palette | operator_locked |
| Annotate | accent `#0284C7` | under closeup bar | operator goal palette | operator_locked |
| Play brief | secondary chip `#FFF7ED` | on ID result | operator goal palette | operator_locked |
| confirm: Save Find / Keep / Use | accent `#0284C7` | review bar | technical review_controls | pm_design |
| reject: Dismiss | quiet on `#FFF7ED` | review bar | technical review_controls | pm_design |

## Feedback & waiting

- Identifying: stack slot pulse + “Reading morphology…” on cream
- Chat streaming: coach bubble grows; stack stays visible
- TTS: waveform pip on Play brief
- Errors: russet primary banner, non-blocking

## Page → frame → criterion coverage

| Page / state | frame_id | criterion_ids |
|--------------|----------|---------------|
| Field Home empty | sporecue-home-empty | CR-HOME-01 |
| Camera capture | sporecue-capture-camera | CR-CAM-01 |
| Species ID result | sporecue-id-result | CR-ID-01, CR-ID-02, CR-ID-03 |
| Lookalike chat | sporecue-lookalike-chat | CR-CHAT-01 |
| Overlay annotate | sporecue-overlay-annotate | CR-OVL-01 |
| Voice note | sporecue-voice-note | CR-MIC-01 |
| AI consent | sporecue-consent-ai | CR-CONSENT-01 |
| Settings + legal | sporecue-settings-privacy | CR-SET-01 |

## Criterion text (design self-check)

- **CR-HOME-01:** Empty Field Home shows cream canvas, vertical species-confidence stack placeholder, oversized empty gill/pore bar, chip rail placeholder, Shoot/Import CTAs, coach bar; palette russet/cream/sky; disclaimer visible; no bottle-rail/field-card/mosaic/clapper/sky-arc/table-zone/sprocket; no competitor names.
- **CR-CAM-01:** Camera capture UI for Cap / Gill / Pore subject chips with clear shutter; russet/sky chrome; not a film sprocket or clapper frame.
- **CR-ID-01:** ID result shows vertical species-confidence stack with ranked names and readable confidence.
- **CR-ID-02:** An oversized gill/pore closeup bar dominates mid-screen with morphology callout affordance.
- **CR-ID-03:** Informational edible/warning chip rail sits under a clear 「非可食认证 / not an edibility certification」 banner; no safe-to-eat claim.
- **CR-CHAT-01:** Lookalike/habitat chat shows coach thread with text + speech affordance; disclaimer strip present; no competitor names; no safe-to-eat advice.
- **CR-OVL-01:** Overlay annotate shows still with callout pins and Keep/Edit controls; disclaimer remains.
- **CR-MIC-01:** Voice note sheet shows recording state for hands-busy foraging notes.
- **CR-CONSENT-01:** AI consent discloses DeepSeek and fields before send.
- **CR-SET-01:** Settings shows revoke AI + links to local privacy/terms/support.

confirm: Save Find / Keep / Use  
reject: Dismiss / Reject
