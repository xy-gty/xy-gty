# Run objective

# HiveCue

Paid AI hive-inspection coach (one-time unlock for apiary packs; no coins).

Remake vs BeePlus Beekeeping Manager (uk.co.omnichrome.beeplus).

## Core loop
Snap or import brood-frame photos → recognize brood / stores / pest signs → chat for next actions → annotated frame overlays → TTS hands-free notes while suited → dictate inspection fields.

## Hard operator rules
- product_dir: hivecue/ (never leave as product/ only — symlink hivecue→product)
- palette: primary #9F1239 · secondary #FDF2F8 · accent #4D7C0F
- UI: hexagonal comb grid + inspection rail + heat overlay; must look clearly different from FormCue/YarnCue (no twins / all-black)
- Four permissions with real flows (extend core, do not replace): Camera (frame photos), Photos (history compare), Microphone (hands-free while gloved), Speech Recognition (write inspection fields)
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only; never shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial

## Positioning
AI 蜂箱巡检教练——拍巢脾识蜂子/蜜/虫害，对话下一步，标注叠图，戴手套免提口述日志。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
