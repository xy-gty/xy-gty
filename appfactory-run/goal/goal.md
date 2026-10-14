# Run objective

# External idea (operator-selected)

**Mode:** pure Cursor Ultra-lite (p1)
**App name:** ScoutCue
**Product dir:** `scoutcue/` (lowercase; never call it `product/`)
**Delivery remote:** `git@github.com:xy-gty/xy-gty.git`
**Delivery push:** prefer **independent branch** (do NOT blindly lean-force overwrite `main`)
**Simulator:** iPhone 17 Pro ONLY (ban iPhone 17 and Pro Max `6C8C645A`)
**Feishu delivery tracker:** skip / ignore (负责人自填 deferred)

## Positioning

Paid AI photo-scout planner. Import or shoot scenery, recognize scenes, chat sun/moon timing, golden-hour overlay annotations, TTS next-stop shoot briefings.

Position as **AI photo scout / timing planner**. Do **NOT** clone DimCue measure-overlay twin. Do **NOT** clone KnotCue rope-path carousel twin.

## Core loops

1. Shoot / import scenery photos (Camera + Photos)
2. Scene recognition → scout cards
3. Chat sun/moon / golden-hour timing with the coach
4. Golden-hour overlay annotations on scenery
5. TTS next-stop shoot briefings (Speech)
6. Dictate shoot notes / intent (Microphone)
7. Unlock paid scouting packs / windows (paid)

Permission extras must not replace core scout/chat flows.

## Four real permissions (required)

| Key | Use |
|---|---|
| NSCameraUsageDescription | On-site composition capture + scene recognition for scouting |
| NSPhotoLibraryUsageDescription | Import prior scouting shots; recompute best shoot windows |
| NSMicrophoneUsageDescription | Dictate shoot notes and intent into the scout plan |
| NSSpeechRecognitionUsageDescription | e.g. 「这山脊黄金时刻」 → timed plan + coach chat |

## Unique UI (hard)

- Sky-arc ephemeris timeline
- Soft scenery card stack
- Ban DimCue measure-overlay twin
- Ban KnotCue rope-path carousel twin
- Ban all-black shell

## Palette (hard)

- Primary: `#4338CA` indigo
- Secondary: `#EEF2FF` soft indigo wash
- Accent: `#FB7185` rose
- Multi-color, nice-looking; ban all-black

## Branding assets

**Do NOT generate** AppIcon or LaunchScreen / splash images this round.

## Acceptance / delivery notes

- Ultra-lite Cursor p1
- Deliver to xy-gty on an **independent branch** when possible
- Skip Feishu tracker row
- Non-core UL/AX fails with runtime evidence complete → Option A soft known_issues (no infinite retry)


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
