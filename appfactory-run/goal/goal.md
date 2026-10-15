# Run objective

# NightCue

Paid AI night-long-exposure coach (one-time unlock for unlimited night packs; no coins).

Remake vs NightCap Camera Long Exposure (com.interealtime.LightBoost).

## Core loop
Import or shoot night frames → diagnose exposure/noise issues → chat for settings → generate annotated overlays → TTS field cues → dictate exposure writes into coach.

## Hard operator rules
- product_dir: nightcue/ (never leave as product/ only — symlink nightcue→product)
- palette: primary #1E3A8A · secondary #EFF6FF · accent #FBBF24 (must differ from delivered apps; ban all-black clones)
- UI: night-frame rail + exposure-diagnosis overlay layers; must look clearly different from HiveCue/FormCue/YarnCue (no twins)
- Positioning ≠ ScoutCue (solar/ephemeris scouting)
- Four permissions with real flows (extend core, do not replace): Camera (night test frames), Photos (history night compare), Microphone (hands-free param Q&A), Speech Recognition (write exposure into coach)
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max (UDID 315A7C2C or any Pro Max) even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues; P1 non-blockers must not block delivery
- When disk tight: clear DerivedData/simulator caches proactively (never touch in-use DerivedData)

## Idea
Build a paid AI night-long-exposure coach: import or shoot night frames, recognize exposure/noise issues, chat for settings, generate annotated overlays, TTS field cues—unlock unlimited night packs.

## Positioning
AI 夜景长曝光教练——拍/导入夜景试片→诊断曝光与噪点→对话参数→标注叠图→TTS 现场口令。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
