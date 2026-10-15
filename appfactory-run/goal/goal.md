# Run objective

# WingCue

Paid AI birding field coach (one-time unlock for unlimited ID packs; no coins).

Remake vs Sibley Birds 2nd Edition — differentiate: AI field ID coach with field marks + TTS, not just a static paid field guide.

## Core loop
Shoot or import bird photos → AI species ID + field marks → chat to clarify lookalikes → generate annotated overlay callouts → TTS read species name / ID tips.

## Hard operator rules
- product_dir: wingcue/ (never leave as product/ only — symlink wingcue→product)
- palette: primary #0F766E · secondary #F0FDFA · accent #C2410C (teal + mint + terracotta; must differ from StopCue green/pink, RuleCue amber/cyan, FrameCue purple/amber, and other delivered apps; ban all-black/dark-gray clones)
- UI: 物种 field-card 叠层 + 超大鉴别特征 chips + 剪影对比条（must look clearly different from ClosetCue mosaic, FrameCue safe-frame / clapper, ScoutCue sky-arc, RuleCue table zone + turn step, StopCue film-sprocket — no twins）
- Four permissions with real flows (extend core, do not replace):
  - Camera: field capture of bird body / plumage close-ups for ID
  - Photos: import trip album stills to complete ID
  - Microphone: hands-free notes / optional call recording while holding binoculars
  - Speech Recognition: spoken questions like "which warbler has the white wing bars" into coach chat
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery
- When disk tight: clear unused DerivedData/simulator caches (never touch in-use DerivedData)

## Idea
Build a paid AI birding field coach: shoot or import bird photos, AI species ID with field marks, chat to clarify lookalikes, generate annotated overlays, TTS species name and tips—unlock unlimited ID packs.

## Positioning
AI 观鸟野外教练——拍鸟识种、标出鉴别特征、语音讲解易混种。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
