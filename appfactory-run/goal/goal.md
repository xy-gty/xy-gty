# Run objective

# RuleCue

Paid AI board-game rules & setup coach (one-time unlock for unlimited game packs; no coins).

Remake vs Board Game Stats (nl.vissering.BoardGameStats) — differentiate: rules/setup coach, not play-stats.

## Core loop
Snap or import rulebook pages and table photos → recognize components/phases → chat for rulings and turn flow → generate annotated setup/zone overlays → TTS table-host cues.

## Hard operator rules
- product_dir: rulecue/ (never leave as product/ only — symlink rulecue→product)
- palette: primary #854D0E · secondary #FEFCE8 · accent #0891B2 (must differ from StopCue #16A34A/#F0FDF4/#DB2777, NightCue #1E3A8A, and other delivered apps; ban all-black/dark-gray clones)
- UI: 桌游桌面分区卡 + 回合步骤条（must look clearly different from StopCue film-sprocket timeline, NightCue night-frame rail, HiveCue/FormCue/YarnCue/ScoutCue — no twins）
- Four permissions with real flows (extend core, do not replace):
  - Camera: capture rulebook pages, component close-ups, current table layout
  - Photos: import rulebook PDF pages / past-table photos for compare
  - Microphone: hands-free ask while setting up (e.g. can I play this card)
  - Speech Recognition: spoken rules questions written into coach chat and trigger next tip
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery
- When disk tight: clear unused DerivedData/simulator caches (never touch in-use DerivedData)

## Idea
Build a paid AI board-game rules & setup coach: snap or import rulebook and table photos, recognize components and phases, chat for rulings, generate annotated setup overlays, TTS table-host cues—unlock unlimited game packs.

## Positioning
桌游规则与摆台 AI 教练——拍规则书/桌面，对话答疑，生成摆台标注图，TTS 边摆边讲。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
