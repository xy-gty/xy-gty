# Run objective

# FrameCue

Paid AI director framing coach (one-time unlock for unlimited framing packs; no coins).

Remake vs Cadrage Director's Viewfinder (com.distantblue.Cadrage) — differentiate: composition/shot-size chat coach + overlays, not just pro camera aspect preview.

## Core loop
Shoot or import stills → recognize subjects and composition issues → chat shot size / aspect / lens language → generate safe-frame / rule-of-thirds / aspect overlays → TTS on-set director cues.

## Hard operator rules
- product_dir: framecue/ (never leave as product/ only — symlink framecue→product)
- palette: primary #7E22CE · secondary #FAF5FF · accent #F59E0B (must differ from RuleCue #854D0E/#FEFCE8/#0891B2, StopCue #16A34A/#F0FDF4/#DB2777, NightCue #1E3A8A, and other delivered apps; ban all-black/dark-gray clones)
- UI: 片场场记板式画幅框 + 底部景别芯片条（must look clearly different from StopCue film-sprocket timeline, RuleCue table zone cards + turn step bar, NightCue night-frame rail — no twins）
- Four permissions with real flows (extend core, do not replace):
  - Camera: on-set framing trial shots, capture current composition frame
  - Photos: import scout/reference stills for aspect analysis
  - Microphone: hands-free on-set cues (e.g. switch to medium shot)
  - Speech Recognition: spoken shot-size instructions written into coach chat and refresh overlays
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery
- When disk tight: clear unused DerivedData/simulator caches (never touch in-use DerivedData)

## Idea
Build a paid AI director framing coach: shoot or import stills, recognize composition issues, chat shot size/aspect/lens language, generate safe-frame and rule-of-thirds overlays, TTS on-set cues—unlock unlimited framing packs.

## Positioning
导演取景/构图 AI 教练——拍或导入画面，对话景别与焦段，生成画幅标注叠图，TTS 现场口令。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
