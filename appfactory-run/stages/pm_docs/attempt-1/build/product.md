# WingCue — product

idea_source: operator_external

## Name & positioning

- **App name:** WingCue
- **One-liner (en-US store-ready):** AI birding field coach — shoot or import a bird, lock field marks, clarify lookalikes, hear the tip.
- **定位：** AI 观鸟野外教练——拍鸟识种、标出鉴别特征、语音讲解易混种。
- **vs Sibley Birds 2nd Edition:** not a static paid field guide; interactive AI ID coach with field marks, lookalike chat, annotated overlays, and TTS.

## Target user

Birders and casual nature walkers who already photograph birds and need fast, mark-based ID help in the field (one-handed, binoculars up).

## Job to be done

Turn a still of a bird into a confirmed species ID with visible field marks, lookalike contrast, and spoken tips — then keep that sighting for the next walk.

## Core loop

1. Shoot (Camera) or import (Photos) a bird still
2. AI returns ranked species + oversized field-mark chips on stacked field-cards
3. Compare silhouettes on the contrast bar; chat (text/speech) to resolve lookalikes
4. Generate annotated overlay callouts; TTS reads name / tips
5. Save ID → sighting persists; next ID call reuses confirmed marks/feedback

## Scope

**In**

- Camera plumage/body capture; Photos album import
- Structured species ID + field marks (DeepSeek when configured)
- Lookalike coach chat + Speech Recognition questions
- Microphone voice notes
- Annotated overlays + TTS
- Local persistence, consent gate, four permission flows, local legal pages
- Signature UI: field-card 叠层 + 超大鉴别特征 chips + 剪影对比条
- Palette #0F766E / #F0FDFA / #C2410C

**Out**

- StoreKit / paywall / coins / ATT (operator paid unlock → separate iap_att; this UltraLite package is free_app_only with unlimited local ID packs)
- AppIcon / LaunchScreen generation
- ClosetCue / FrameCue / ScoutCue / RuleCue / StopCue visual twins
- iPhone Pro Max simulator targets

## Language & platform

- UI copy: en-US
- PM docs: zh-CN
- iOS SwiftUI; development_bundle_id `com.lingguang.wingcue`
- product_dir `wingcue/` (symlink → product)
- Simulator: iPhone 17 Pro only (prefer B14CC0EA)

## First glance (five questions)

1. **What is this?** Field home with teal mint cards waiting for a bird still.
2. **What do I do?** Shoot or Import — primary CTAs above the coach bar.
3. **Why trust it?** Field marks and silhouette bar explain the guess, not a black-box label.
4. **What persists?** Saved IDs and overlays remain after restart.
5. **What if AI is off?** Local capture, notes, and honest “AI not configured” — no fake species.

## Delivery blurb

WingCue is an AI birding field coach: capture or import a bird photo, get species candidates with oversized field-mark chips on stacked field-cards, compare silhouettes, chat through lookalikes (including spoken questions), pin annotated overlays, and hear TTS tips — free full value in this build.
