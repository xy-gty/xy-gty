# MixCue — product

idea_source: operator_external

## Name & positioning

- **App name:** MixCue
- **One-liner (en-US store-ready):** AI home-bar cocktail coach — shoot a bottle, lock the base spirit, get pour steps and garnish chips, hear the shake tip.
- **定位：** AI 家庭吧台调酒教练——识瓶、替酒、倒法与装饰一步到位。
- **Differentiation:** not a static recipe catalog; interactive AI bottle/garnish ID + substitute chat + pour/garnish board with TTS shake/stir steps. Do **not** name Cocktail Party or Bevnap in App copy.

## Target user

Home bartenders who already photograph bottles and garnishes and need fast spirit ID, substitute advice, and hands-free pour/shake coaching while both hands are busy.

## Job to be done

Turn a still of a bottle, label, or garnish into a confirmed base spirit, a workable recipe with substitutes, and a step-by-step pour board with spoken shake/stir cues — then keep that mix for the next night.

## Core loop

1. Shoot (Camera) or import (Photos) a bottle / label / garnish still
2. AI returns ranked base-spirit candidates + label cues on the vertical bottle-rail
3. Chat (text/speech) for recipes and substitutes
4. Open pour board: large next-pour card + garnish chip row; TTS reads shake/stir steps
5. Save Mix → session persists; next ID/chat reuses confirmed spirits/feedback

## Scope

**In**

- Camera bottle/label/garnish capture; Photos bar-shelf album import
- Structured base-spirit ID + label cues (DeepSeek when configured)
- Recipe / substitute coach chat + Speech Recognition questions
- Microphone voice notes while shaking/stirring
- Pour board (next-pour card + garnish chips) + TTS steps
- Local persistence, consent gate, four permission flows, local legal pages
- Signature UI: 竖向瓶架轨 + 大号下一步倒法卡 + 装饰 chip 行
- Palette #E11D48 / #FFF1F2 / #CA8A04

**Out**

- StoreKit / paywall / coins / ATT (operator paid unlock → separate iap_att; this UltraLite package is free_app_only with unlimited local mix sessions)
- AppIcon / LaunchScreen generation
- WingCue / FrameCue / RuleCue / StopCue / ClosetCue / ScoutCue visual twins
- Competitor names in App copy
- iPhone Pro Max simulator targets

## Language & platform

- UI copy: en-US
- PM docs: zh-CN
- iOS SwiftUI; development_bundle_id `com.lingguang.mixcue`
- product_dir `mixcue/` (symlink → product)
- Simulator: iPhone 17 Pro only (prefer B14CC0EA)

## First glance (five questions)

1. **What is this?** Bar home with a vertical bottle-rail and a large next-pour card waiting for a still.
2. **What do I do?** Shoot or Import — primary CTAs above the coach bar.
3. **Why trust it?** Label cues and the pour card explain the next move, not a black-box recipe dump.
4. **What persists?** Saved mixes, pour boards, and chat remain after restart.
5. **What if AI is off?** Local capture, notes, and honest “AI not configured” — no fake spirits.

## Delivery blurb

MixCue is an AI home-bar cocktail coach: capture or import a bottle, label, or garnish, get base-spirit candidates on a vertical bottle-rail, chat through recipes and substitutes (including spoken questions), advance a large next-pour card with garnish chips, and hear TTS shake/stir steps — free full value in this build.
