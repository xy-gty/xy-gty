# Run objective

# CellarCue

Paid AI wine cellar label ID & drinking-window coach (one-time unlock for unlimited cellar packs; no coins).

Remake vs Vinocell – Wine cellar manager — differentiate: AI label OCR + bin placement + drinking-window/food-pairing chat + annotated cellar cards + TTS pull brief, not just a static cellar inventory. Do NOT name competitors in App copy.

## Hard compliance (non-negotiable)
- State clearly: 非侍酒认证 / not a sommelier certification; 非投资建议 / not investment advice
- 21+ related wording must land in product surfaces that touch alcohol recommendations
- Never claim certified tasting advice or guaranteed investment returns

## Core loop
Shoot or import wine labels → AI ID + write to bin/slot → chat drinking window & food pairing → generate annotated cellar-rack cards → TTS pull/pour brief.

## Hard operator rules
- product_dir: cellarcue/ (never leave as product/ only — symlink cellarcue→product; deliver directory/branch name = cellarcue, not product)
- palette: primary #3730A3 · secondary #EEF2FF · accent #EA580C (indigo + lavender mist + burnt orange; must differ from SporeCue russet/cream/sky, MixCue rose/gold, WingCue teal/mint/terracotta, FrameCue purple/amber, RuleCue amber/cyan, StopCue green/pink, and other delivered apps; ban all-black/dark-gray clones)
- UI: 酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴（must look clearly different from MixCue vertical bottle-rail, SporeCue confidence stack, WingCue field-card stack, ClosetCue mosaic, FrameCue safe-frame/clapper, ScoutCue sky-arc, RuleCue table zone, StopCue film-sprocket — no twins）
- Four permissions with real flows (extend core cellar coach, do not bolt on awkwardly / replace core loop):
  - Camera: capture wine label / cork / bin tag for ID & placement
  - Photos: import label album stills into cellar
  - Microphone: hands-free bin notes / pull brief while carrying bottles
  - Speech Recognition: spoken questions like "where is the 2015 Barolo" / "pair with lamb?" into coach chat
- Selling points must be real: photo/import label → ID + write bin → drinking-window & pairing chat → annotated rack card → TTS pull brief
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery
- Low-risk closed-loop product; pure Cursor Ultra-lite
- When disk tight: clear unused DerivedData/simulator caches (never touch in-use DerivedData)

## Idea
Build a paid AI wine-cellar coach: shoot or import labels, AI ID into bin slots, chat drinking windows and pairings, annotated rack cards, TTS pull briefs—unlock unlimited cellar packs. Disclose not a sommelier certification and not investment advice; 21+ where alcohol advice appears.

## Positioning
AI 酒窖标签识别与陈年饮用窗教练——扫瓶贴、记仓位、语音问搭配。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
