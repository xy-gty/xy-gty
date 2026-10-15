# SporeCue — product

idea_source: operator_external

## Name & positioning

- **App name:** SporeCue
- **One-liner (en-US store-ready):** AI wild-mushroom field coach — shoot cap, gill, or pore, rank lookalikes, annotate morphology, hear a field brief. Not an edibility certification.
- **定位：** AI 蘑菇野外识种/采菇教练——特征标注 + 易混种对话（非可食认证）。
- **Differentiation:** not a static mushroom catalog; interactive AI cap/gill/pore ID + lookalike chat + annotated overlays + TTS field brief. Do **not** name Shroomify or Pilze 123 in App copy.

## Target user

Foragers and nature walkers who already photograph mushrooms in the field and need fast morphology-aware species hypotheses, lookalike contrast, and hands-free notes — while never treating the app as food-safety certification.

## Job to be done

Turn a still of a cap, gill, or pore into ranked species candidates with confidence, morphology callouts, informational caution chips, a lookalike chat, an annotated overlay, and a spoken field brief — always under 「非可食认证 / not an edibility certification」— then keep that find for the next hike.

## Core loop

1. Shoot (Camera) or import (Photos) a cap / gill / pore still
2. AI returns ranked species + confidence on a vertical species-confidence stack
3. Oversized gill/pore closeup bar + informational edible/warning chip rail (disclaimer always visible)
4. Chat (text/speech) habitat / features / lookalikes
5. Annotated overlay callouts → TTS field brief → Save Find (persists; next call reuses confirmed notes)

## Scope

**In**

- Camera cap/gill/pore capture; Photos hike-album import
- Structured species ID + morphology cues (DeepSeek when configured)
- Lookalike / habitat coach chat + Speech Recognition questions
- Microphone voice notes while holding knife/basket
- Annotated overlays + TTS field brief (scripts include disclaimer)
- Local persistence, consent gate, four permission flows, local legal pages
- Signature UI: 纵向物种置信栈 + 超大菌褶/管孔特写条 + 可食/警示 chip 轨
- Palette #9A3412 / #FFF7ED / #0284C7
- Hard compliance copy on every ID / edibility / foraging surface

**Out**

- StoreKit / paywall / coins / ATT (operator paid unlock → separate iap_att; this UltraLite package is free_app_only with unlimited local ID sessions)
- AppIcon / LaunchScreen generation
- MixCue / WingCue / FrameCue / RuleCue / StopCue / ClosetCue / ScoutCue visual twins
- Competitor names in App copy
- Any “safe to eat” / “confirmed edible” / certification claim
- iPhone Pro Max simulator targets

## Language & platform

- UI copy: en-US
- PM docs: zh-CN
- iOS SwiftUI; development_bundle_id `com.lingguang.sporecue`
- product_dir `sporecue/` (symlink → product)
- Simulator: iPhone 17 Pro only (prefer B14CC0EA)

## First glance (five questions)

1. **What is this?** Field home with a vertical species-confidence stack, oversized gill/pore bar, and chip rail under a clear non-certification banner.
2. **What do I do?** Shoot or Import — primary CTAs above the coach bar.
3. **Why trust it?** Morphology callouts and lookalike chips explain cues; disclaimer blocks food-safety misuse.
4. **What persists?** Saved finds, overlays, and chat remain after restart.
5. **What if AI is off?** Local capture, notes, and honest “AI not configured” — no fake species.

## Delivery blurb

SporeCue is an AI wild-mushroom field coach: capture or import a cap, gill, or pore photo, get ranked species on a vertical confidence stack with an oversized closeup bar and informational caution chips, chat lookalikes, see annotated overlays, and hear a TTS field brief — always labeled 非可食认证 / not an edibility certification. Free full value in this build.
