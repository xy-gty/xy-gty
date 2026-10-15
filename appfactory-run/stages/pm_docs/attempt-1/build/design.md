# CellarCue — design

idea_source: operator_external

## 场景时刻推导

用户在酒窖或餐厅备餐时单手抱瓶、另一手举手机扫瓶贴或仓位标签。需要立刻看清「这是什么酒、放哪格、现在能不能开、配什么菜」——且每一面酒精建议都必须声明非侍酒认证、非投资建议，并带 21+。

- 色温：indigo `#3730A3` 主色，lavender mist `#EEF2FF` 大底，burnt orange `#EA580C` 仅点在主 CTA 与当前饮用窗高亮；避开 SporeCue 赤陶奶油天蓝、MixCue 玫瑰金、WingCue 青绿赤陶、FrameCue 紫琥珀、RuleCue 琥珀青、StopCue 绿粉、全黑克隆。
- 布局不是竖直瓶轨、不是物种置信栈、不是叠层 field-card、不是胶片齿孔、不是安全框场记板、不是天空弧、不是桌面轮次带：酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴。
- 字号：酒名 Display 大号；OCR 字段 ≥17pt；时间轴年份可读；bin 坐标清晰。
- 单手：Shoot/Import 与 coach 输入贴底；OCR 主卡为大触区。

## Visual direction

| Token | Value | Source | Authorization |
|-------|-------|--------|---------------|
| primary | `#3730A3` | operator goal hard rule | operator_locked |
| secondary | `#EEF2FF` | operator goal hard rule | operator_locked |
| accent | `#EA580C` | operator goal hard rule | operator_locked |
| UI species | 酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴 | operator goal hard rule | operator_locked |
| compliance banners | 非侍酒认证 / not a sommelier certification; 非投资建议 / not investment advice; 21+ | operator goal hard rule | operator_locked |
| ban twins | MixCue bottle-rail / SporeCue confidence stack / WingCue field-card / FrameCue clapper / RuleCue table-zone / StopCue sprocket | operator goal hard rule | operator_locked |
| ban copy | Vinocell name | operator goal hard rule | operator_locked |

## Navigation chrome

- Top: CellarCue wordmark (indigo) + Settings gear + persistent dual compliance strip + 21+ chip on alcohol-advice surfaces
- Body: row/bin cellar grid (R1-B3 style slots)
- Mid-upper: large label-OCR hero card
- Mid-lower: horizontal drinking-window aging timeline
- Bottom: Shoot (accent) · Import · coach text/speech bar

## First experience

1. Land on Cellar Home empty (frame `cellarcue-home-empty`)
2. Shoot or Import a label still → wait shimmer on hero card
3. First outbound → AI consent (frame `cellarcue-consent-ai`) if needed
4. Land Label Result with OCR hero + bin write + timeline under compliance + 21+ (frame `cellarcue-label-ocr`)
5. Ask coach window/pairing → chat; Make rack card → annotate; Play brief → TTS

Skip consent only when outbound not attempted. Never show canned OCR as success. Never put Vinocell or investment-return claims in UI strings.

## Key CTAs

| CTA | Color | Placement | Source | Authorization |
|-----|-------|-----------|--------|---------------|
| Shoot | accent `#EA580C` | bottom-leading | operator goal palette | operator_locked |
| Import | indigo outline `#3730A3` | beside Shoot | operator goal palette | operator_locked |
| Identify / Save Bottle | accent `#EA580C` | card footer | operator goal palette | operator_locked |
| Ask coach | indigo text `#3730A3` | under hero | operator goal palette | operator_locked |
| Make rack card | accent `#EA580C` | under timeline | operator goal palette | operator_locked |
| Play brief | secondary chip `#EEF2FF` | on label result | operator goal palette | operator_locked |
| confirm: Save Bottle / Keep / Use | accent `#EA580C` | review bar | technical review_controls | pm_design |
| reject: Dismiss | quiet on `#EEF2FF` | review bar | technical review_controls | pm_design |

## Feedback & waiting

- Identifying: hero card pulse + “Reading label…” on lavender mist
- Chat streaming: coach bubble grows; grid stays visible
- TTS: waveform pip on Play brief
- Errors: indigo primary banner, non-blocking

## Page → frame → criterion coverage

| Page / state | frame_id | criterion_ids |
|--------------|----------|---------------|
| Cellar Home empty | cellarcue-home-empty | CR-HOME-01 |
| Camera capture | cellarcue-capture-camera | CR-CAM-01 |
| Label OCR result | cellarcue-label-ocr | CR-OCR-01, CR-OCR-02, CR-OCR-03 |
| Window / pairing chat | cellarcue-window-chat | CR-CHAT-01 |
| Annotated rack card | cellarcue-rack-card | CR-RACK-01 |
| Voice / pull brief | cellarcue-voice-pull | CR-MIC-01 |
| AI consent | cellarcue-consent-ai | CR-CONSENT-01 |
| Settings + legal | cellarcue-settings-privacy | CR-SET-01 |

## Criterion text (design self-check)

- **CR-HOME-01:** Empty Cellar Home shows lavender-mist canvas, row/bin grid placeholder, empty large label-OCR hero slot, empty drinking-window timeline strip, Shoot/Import CTAs, coach bar; palette indigo/lavender/orange; dual compliance banners + 21+ visible; no bottle-rail/confidence-stack/field-card/clapper/table-zone/sprocket chrome; no Vinocell name; no investment-return claim.
- **CR-CAM-01:** Camera capture UI for Label / Cork / Bin tag subject chips with clear shutter; indigo/orange chrome; not a film sprocket or clapper frame.
- **CR-OCR-01:** Label result shows a large label-OCR hero card with producer/vintage/varietal and readable confidence.
- **CR-OCR-02:** A row/bin placement affordance writes the bottle into a cellar slot (not a vertical bottle-rail).
- **CR-OCR-03:** Drinking-window aging timeline sits under clear 「非侍酒认证 / not a sommelier certification」 and 「非投资建议 / not investment advice」 banners with 21+; no guaranteed-return claim.
- **CR-CHAT-01:** Window/pairing chat shows coach thread with text + speech affordance; compliance + 21+ strip present; no Vinocell; no investment advice tone.
- **CR-RACK-01:** Annotated rack card shows bin callouts and Keep/Edit controls; compliance remains.
- **CR-MIC-01:** Voice / pull-brief surface shows recording or TTS play state for hands-busy cellar notes.
- **CR-CONSENT-01:** AI consent discloses DeepSeek and fields before send.
- **CR-SET-01:** Settings shows revoke AI + links to local privacy/terms/support.

confirm: Save Bottle / Keep / Use  
reject: Dismiss / Reject
