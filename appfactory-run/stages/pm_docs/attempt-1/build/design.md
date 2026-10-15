# WingCue — design

## 场景时刻推导

用户在林缘或湿地，单手握机、另一手扶望远镜，阳光刺眼、需要 3 秒内看清「这是什么、凭哪几笔特征」。因此：

- 色温偏户外青绿：primary `#0F766E`，secondary `#F0FDFA` 作大面积透气底，accent `#C2410C` 只点在主 CTA 与高显著性 chip，避免 StopCue 绿粉 / RuleCue 琥珀青 / FrameCue 紫琥珀 / 全黑克隆。
- 圆角中等（16–20pt）像野外笔记卡片，不是胶片齿孔、不是安全框场记板、不是天空弧、不是桌面轮次带。
- 字号：物种名 Display 大号；鉴别特征 chip 超大（≥22pt）可一瞥；次要说明 15pt。
- 单手：主 CTA 与 coach 输入条贴底；叠层 field-card 可上滑展开历史，默认露出顶部卡片。

## Visual direction

| Token | Value | Source | Authorization |
|-------|-------|--------|---------------|
| primary | `#0F766E` | operator goal hard rule | operator_locked |
| secondary | `#F0FDFA` | operator goal hard rule | operator_locked |
| accent | `#C2410C` | operator goal hard rule | operator_locked |
| UI species | field-card 叠层 + 超大鉴别特征 chips + 剪影对比条 | operator goal hard rule | operator_locked |
| ban twins | ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket | operator goal hard rule | operator_locked |

## Navigation chrome

- Top: compact WingCue wordmark (teal) + Settings gear
- Body: stacked species field-cards (depth shadow, mint face, teal edge)
- Mid: horizontal silhouette compare bar (two bird outlines + contrast tick)
- Bottom: Shoot (accent) · Import · coach text/speech bar

## First experience

1. Land on Field Home empty (frame `home-empty`)
2. Shoot or Import a bird → brief wait shimmer on card
3. First outbound → AI consent (frame `consent-ai`) if needed
4. Land ID Result with stacked cards + huge chips + silhouette bar (frame `id-result`)
5. Optional Clarify / Annotate / Speak tip

Skip consent only when outbound not attempted. Never show canned species as success.

## Key CTAs

| CTA | Color | Placement | Source | Authorization |
|-----|-------|-----------|--------|---------------|
| Shoot | accent `#C2410C` | bottom-leading | operator goal palette | operator_locked |
| Import | teal outline `#0F766E` | beside Shoot | operator goal palette | operator_locked |
| Identify / Save ID | accent `#C2410C` | card footer | operator goal palette | operator_locked |
| Clarify lookalikes | teal text `#0F766E` | under chips | operator goal palette | operator_locked |
| Annotate | teal `#0F766E` | under chips | operator goal palette | operator_locked |
| Speak tip | secondary chip `#F0FDFA` | trailing | operator goal palette | operator_locked |
| confirm: Save ID / Keep / Use | accent `#C2410C` | review bar | technical review_controls | pm_design |
| reject: Dismiss | quiet on `#F0FDFA` | review bar | technical review_controls | pm_design |

## Feedback & waiting

- Identifying: field-card pulse + “Reading plumage…” on mint
- Chat streaming: coach bubble grows; chips stay visible above
- TTS: waveform pip on Speak tip
- Errors: terracotta accent banner, non-blocking

## Page → frame → criterion coverage

| Page / state | frame_id | criterion_ids |
|--------------|----------|---------------|
| Field Home empty | wingcue-home-empty | CR-HOME-01 |
| Camera capture | wingcue-capture-camera | CR-CAM-01 |
| ID result with marks | wingcue-id-result | CR-ID-01, CR-ID-02 |
| Lookalike chat | wingcue-lookalike-chat | CR-CHAT-01 |
| Overlay studio | wingcue-overlay-annotate | CR-OVL-01 |
| Voice note | wingcue-voice-note | CR-MIC-01 |
| AI consent | wingcue-consent-ai | CR-CONSENT-01 |
| Settings + legal | wingcue-settings-privacy | CR-SET-01 |

## Criterion text (design self-check)

- **CR-HOME-01:** Empty Field Home shows mint canvas, stacked empty field-card hint, Shoot/Import CTAs, and bottom coach bar; palette teal/mint/terracotta; no mosaic/clapper/sky-arc/table-zone/sprocket chrome.
- **CR-CAM-01:** Camera capture UI for bird body/plumage with clear shutter; teal chrome; not a film sprocket or clapper frame.
- **CR-ID-01:** ID result shows stacked species field-cards plus oversized field-mark chips readable at a glance.
- **CR-ID-02:** A silhouette comparison bar contrasts two lookalike outlines beneath or between cards.
- **CR-CHAT-01:** Lookalike chat shows coach thread under retained chips/cards context with text + speech affordance.
- **CR-OVL-01:** Overlay studio places callout labels on the bird photo tied to field marks.
- **CR-MIC-01:** Voice note sheet shows recording control for hands-free notes.
- **CR-CONSENT-01:** Consent sheet names DeepSeek and lists send fields before any send.
- **CR-SET-01:** Settings lists permission status, revoke AI, and local Privacy/Terms/Support entries.

## Data tables (entities shown in UI)

| Table | Columns shown | Source | Authorization |
|-------|---------------|--------|---------------|
| Species field-card | commonName, scientificName, confidence | technical/contract.md entities | pm_design |
| Field-mark chips | label, bodyRegion | technical/contract.md | pm_design |
| Silhouette bar | left/right silhouetteKey | technical/contract.md LookalikePair | pm_design |
| Coach thread | role, text | CoachTurn | pm_design |
