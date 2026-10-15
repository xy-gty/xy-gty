# Run objective

# SporeCue

Paid AI wild mushroom field ID / foraging coach (one-time unlock for unlimited ID packs; no coins).

Remake vs Shroomify / Pilze 123 — differentiate: AI cap/gill/pore ID + lookalike chat + annotated overlays + TTS field brief, not just a static mushroom catalog. Do NOT name competitors in App copy.

## Hard compliance (non-negotiable)
- Every product surface that touches ID, edibility, or foraging MUST clearly state: 「非可食认证 / not an edibility certification」
- NEVER imply a mushroom is safe to eat, "confirmed edible", or certified for consumption
- Warning / caution chips are informational only — not safety approval

## Core loop
Shoot or import cap / gill / pore photos → AI species ID + lookalikes → chat habitat/features → annotated overlay callouts → TTS field brief.

## Hard operator rules
- product_dir: sporecue/ (never leave as product/ only — symlink sporecue→product; deliver directory/branch name = sporecue, not product)
- bundle_id suggestion: com.lingguang.sporecue
- palette: primary #9A3412 · secondary #FFF7ED · accent #0284C7 (cap russet + apricot cream + sky blue; must differ from MixCue rose/gold, WingCue teal/mint/terracotta, FrameCue purple/amber, RuleCue amber/cyan, StopCue green/pink, and other delivered apps; ban all-black/dark-gray clones)
- UI: 纵向物种置信栈 + 超大菌褶/管孔特写条 + 可食/警示 chip 轨（must look clearly different from MixCue bottle-rail, WingCue field-card stack, ClosetCue mosaic, FrameCue safe-frame/clapper, ScoutCue sky-arc, RuleCue table zone, StopCue film-sprocket — no twins）
- Four permissions with real flows (extend core foraging ID coach, do not bolt on awkwardly):
  - Camera: field capture of cap / gill / pore close-ups for ID
  - Photos: import hike album stills to complete ID
  - Microphone: hands-free field notes while holding knife/basket
  - Speech Recognition: spoken questions like "how does this differ from death cap" into coach chat
- Selling points must be real: photo/import → AI ID + lookalikes → habitat/feature chat → annotated overlay → TTS field brief
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery
- When disk tight: clear unused DerivedData/simulator caches (never touch in-use DerivedData)

## Idea
Build a paid AI wild-mushroom field coach: shoot or import cap/gill/pore photos, AI species ID with lookalikes, chat habitat and features, annotated overlays, TTS field briefs—unlock unlimited ID packs. Always disclose not an edibility certification.

## Positioning
AI 蘑菇野外识种/采菇教练——特征标注 + 易混种对话（非可食认证）。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
