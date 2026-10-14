# ScoutCue — design.md

## Visual direction

- Soft scenery **card stack**（圆角、轻阴影、叠放，非绳路径轮播）  
- **Sky-arc** ephemeris timeline：浅弧 + 时段节点（sunrise / golden / blue / moon）  
- Multi-color atmosphere（晨雾山脊、暖金侧光）；**ban all-black shell**  
- Ban DimCue measure-overlay twin；ban KnotCue rope-path carousel twin  
- confirm: Keep · reject: Discard  

### Palette table

| role | hex | color name | source | authorization |
|------|-----|------------|--------|---------------|
| primary | `#4338CA` | indigo | operator goal palette (locked) | operator_external goal lock |
| secondary | `#EEF2FF` | soft indigo wash | operator goal palette (locked) | operator_external goal lock |
| accent | `#FB7185` | rose | operator goal palette (locked) | operator_external goal lock |

## Navigation chrome

- Top：品牌 ScoutCue + 迷你天空弧条  
- Body：软卡片堆或详情  
- Bottom / trailing：Capture · Coach · Overlay · Brief · Note · Settings  

## First experience

1. Home 空态看见天空弧与空卡片堆提示  
2. Import 一张风景 → Scene review 标签草稿  
3. Keep → 详情：天空弧高亮 golden hour + 主 CTA Coach / Overlay  

## Frame coverage

| page / state | frame_id | criterion_id |
|--------------|----------|--------------|
| Home empty + sky-arc + soft stack | home-empty | CR-home-empty |
| Capture / Import chooser | capture-import | CR-capture-import |
| Scene review labels | scout-card | CR-scout-card |
| Coach chat timing | coach-chat | CR-coach-chat |
| Golden overlay marks | golden-overlay | CR-golden-overlay |
| TTS next-stop briefing | tts-briefing | CR-tts-briefing |
| Dictate note | dictate-note | CR-dictate-note |
| Settings privacy / consent | settings-privacy | CR-settings-privacy |

## Page notes

### home-empty
Soft empty card stack mid-screen; sky-arc with labeled nodes; primary Capture / Import; indigo/wash/rose; no black shell; no measure rulers; no rope carousel.

### capture-import
Two large actions: Take photo · Choose from library; camera/photos privacy rationale one-liners; soft wash background.

### scout-card
Recognized scenery card with labels (ridge / side-light / west-facing); Keep / Discard / Edit labels; mini sky-arc strip.

### coach-chat
Chat bubbles about golden hour / moonrise; consent chip if first send; Keep / Discard on draft reply.

### golden-overlay
Landscape photo with soft rose/indigo annotation pins (not measuring rods); Save overlay / Discard.

### tts-briefing
Next-stop card + Play / Pause / Next; waveform or speaker glyph; briefing text legible.

### dictate-note
Mic affordance + live transcript line into plan note; Cancel / Save note.

### settings-privacy
AI consent status, Revoke, local Privacy/Terms/Support, permission copy list.

## Waiting / feedback

- Recognition：卡片骨架 shimmer  
- Coach：气泡 typing + 可取消  
- TTS：播放中高亮当前句  
- 权限拒绝：保留本地卡与天空弧，禁用对应入口并说明  

## Branding assets

Do **not** generate AppIcon or LaunchScreen this round.
