# Run objective

# External idea (operator-selected)

**Mode:** pure Cursor Ultra-lite (p1)
**App name:** YarnCue
**Product dir:** `yarncue/` (lowercase; never call it `product/`)
**Delivery remote:** `git@github.com:xy-gty/xy-gty.git`
**Delivery push:** prefer **independent branch** (do NOT blindly lean-force overwrite `main`)
**Simulator:** iPhone 17 Pro ONLY (ban iPhone 17 and Pro Max `6C8C645A`; never shutdown/touch Pro Max)
**Feishu delivery tracker:** skip / ignore (CONTROLLER_DELIVERY skip OK)

## Positioning

Paid AI knitting / crochet coach. Snap yarn & WIP photos → stitch/row recognize; chat next row; annotated stitch diagrams; TTS hands-free coaching while both hands stay on the needles.

Position as **AI knitting/crochet coach (weave coach semantics)**. Remake positioning vs **Ravit**. Do **NOT** clone a Ravelry shell. Do **NOT** twin KnotCue rope-path carousel, ScoutCue sky-arc card stack, ClosetCue, or PitchCue dial+strip.

## Core loops

1. Snap / import yarn & WIP photos (Camera + Photos)
2. Stitch / row recognition from WIP
3. Chat "next row" coaching with the weave coach
4. Annotated stitch diagrams on the WIP photo
5. TTS hands-free next-row coaching (Speech) while both hands knit
6. Dictate pattern notes / row intent (Microphone)
7. Unlock paid pattern / coach packs (paid)

Permission extras must **extend** the core coach chain — do **not** replace sell-point loops.

## Four real permissions (required)

| Key | Use |
|---|---|
| NSCameraUsageDescription | Capture yarn / WIP photos for stitch & row recognition |
| NSPhotoLibraryUsageDescription | Import prior WIP / yarn shots into the coach flow |
| NSMicrophoneUsageDescription | Dictate pattern notes and row intent while knitting |
| NSSpeechRecognitionUsageDescription | e.g. 「下一行是什么针」→ next-row coach chat + TTS |

## Unique UI (hard)

- Yarn-ball swatch color strip (毛线球色卡条)
- Horizontal 「下一行」 step band (横向下一行步骤带)
- Ban KnotCue rope-path carousel twin
- Ban ScoutCue sky-arc + card-stack twin
- Ban ClosetCue / PitchCue layout twins
- Ban all-black shell

## Palette (hard)

- Primary: `#A21CAF` fuchsia
- Secondary: `#FDF4FF` soft fuchsia wash
- Accent: `#84CC16` lime
- Multi-color, nice-looking; ban all-black

## Branding assets

**Do NOT generate** AppIcon or LaunchScreen / splash images this round.

## Acceptance / delivery notes

- Ultra-lite Cursor p1 @ factory-prod-1 v8.3.63
- Deliver to xy-gty on an **independent branch** when possible
- Skip Feishu tracker row (CONTROLLER_DELIVERY skip OK)
- Non-core UL/AX fails with runtime evidence complete → Option A soft known_issues (no infinite retry)
- Single-slot only: do not open prod-2 / second package


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
