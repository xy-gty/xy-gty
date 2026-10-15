# Run objective

# MixCue

Paid AI home bar cocktail coach (one-time unlock for unlimited mix packs; no coins).

Remake vs Cocktail Party / Bevnap — differentiate: AI bottle/garnish ID + substitute + pour/garnish board with TTS shake steps, not just a static recipe catalog. Do NOT name competitors in App copy.

## Core loop
Shoot or import bottle / label / garnish → AI base-spirit ID → chat for recipes and substitutes → pour method + garnish board → TTS hands-free shake/stir steps.

## Hard operator rules
- product_dir: mixcue/ (never leave as product/ only — symlink mixcue→product; do not use bare product/)
- bundle_id suggestion: com.lingguang.mixcue
- palette: primary #E11D48 · secondary #FFF1F2 · accent #CA8A04 (neon rose + blush + gold; must differ from WingCue teal/mint/terracotta, FrameCue purple/amber, RuleCue amber/cyan, StopCue green/pink, and other delivered apps; ban all-black/dark-gray clones)
- UI: 竖向瓶架轨 + 大号下一步倒法卡 + 装饰 chip 行（must look clearly different from WingCue field-card stack, ClosetCue mosaic, FrameCue safe-frame/clapper, ScoutCue sky-arc, RuleCue table zone + turn step, StopCue film-sprocket — no twins）
- Four permissions with real flows (extend core cocktail coach, do not bolt on awkwardly):
  - Camera: capture bottle face / label / garnish for ID
  - Photos: import bar-shelf album stills to complete ID
  - Microphone: hands-free notes while both hands shake/stir
  - Speech Recognition: spoken questions like "what can I sub for Cointreau" into coach chat
- Selling points must be real: bottle/label/garnish photo → base spirit ID → recipe + substitute chat → pour/garnish board → TTS shake steps
- Do NOT generate AppIcon / LaunchScreen
- Simulator: iPhone 17 Pro only (prefer B14CC0EA); NEVER shutdown/occupy Pro Max even if Booted
- Deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip
- Ultra-lite p1 @ factory v8.3.63; single-slot serial on factory-prod-1 (do not open prod-2)
- Stage stuck → Option A soft known_issues for non-core UL fails (same FrameCue/WingCue); P1 non-blockers must not block delivery
- When disk tight: clear unused DerivedData/simulator caches (never touch in-use DerivedData)

## Idea
Build a paid AI home-bar cocktail coach: shoot or import bottles/labels/garnishes, AI base-spirit ID, chat for recipes and substitutes, pour method + garnish board, TTS hands-free shake/stir steps—unlock unlimited mix packs.

## Positioning
AI 家庭吧台调酒教练——识瓶、替酒、倒法与装饰一步到位。


The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
