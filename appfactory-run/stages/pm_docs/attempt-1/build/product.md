# CellarCue — product

idea_source: operator_external

## Name & positioning

- **App name:** CellarCue
- **One-liner (en-US store-ready):** AI wine-cellar coach — shoot or import labels, place bottles in bins, chat drinking windows and pairings, hear a pull brief. Not a sommelier certification. Not investment advice. 21+.
- **定位：** AI 酒窖标签识别与陈年饮用窗教练——扫瓶贴、记仓位、语音问搭配。
- **Differentiation:** not a static cellar inventory; interactive AI label OCR + bin placement + drinking-window/food-pairing chat + annotated rack cards + TTS pull brief. Do **not** name Vinocell in App copy.

## Target user

Home collectors who already photograph bottles and need fast label ID, bin placement, drinking-window coaching, and hands-free pull briefs — while never treating the app as sommelier certification or investment advice.

## Job to be done

Turn a label still into a bin-placed bottle with OCR fields, a drinking-window aging timeline, pairing chat, an annotated rack card, and a spoken pull brief — always under 「非侍酒认证 / not a sommelier certification」 and 「非投资建议 / not investment advice」, with 21+ on alcohol-advice surfaces — then keep that cellar thicker next open.

## Core loop

1. Shoot (Camera) or import (Photos) a wine label / cork / bin tag
2. AI label OCR + write into row/bin slot
3. Large label-OCR hero card + drinking-window aging timeline
4. Chat (text/speech) drinking window & food pairing
5. Annotated cellar-rack card → TTS pull/pour brief → Save Bottle (persists; next call reuses confirmed notes)

## Scope

**In**

- Camera label/cork/bin-tag capture; Photos album import
- Structured label OCR + bin placement (DeepSeek when configured)
- Drinking-window / pairing coach chat + Speech Recognition questions
- Microphone bin notes while carrying bottles
- Annotated rack cards + TTS pull brief (scripts include compliance + 21+)
- Local persistence, consent gate, four permission flows, local legal pages
- Signature UI: 酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴
- Palette #3730A3 / #EEF2FF / #EA580C
- Hard compliance copy on every alcohol-advice surface

**Out**

- StoreKit / paywall / coins / ATT (operator paid unlock → separate iap_att; this UltraLite package is free_app_only with unlimited local cellar bins)
- AppIcon / LaunchScreen generation
- MixCue / SporeCue / WingCue / FrameCue / RuleCue / StopCue visual twins
- Vinocell (or other competitor) names in App copy
- Any sommelier certification claim or investment-return guarantee
- iPhone Pro Max simulator targets

## Language & platform

- UI copy: en-US
- PM docs: zh-CN
- iOS SwiftUI; development_bundle_id `com.lingguang.cellarcue`
- product_dir `cellarcue/` (symlink → product)
- Simulator: iPhone 17 Pro only (prefer B14CC0EA)

## First glance (five questions)

1. **What is this?** Cellar home with a row/bin grid, a large label-OCR hero slot, and a drinking-window timeline strip under clear compliance banners.
2. **What do I do?** Shoot or Import — primary CTAs above the coach bar.
3. **Why trust it?** OCR fields and aging timeline explain the bottle; disclaimers block sommelier/investment misuse; 21+ on advice surfaces.
4. **What persists?** Saved bottles, bins, chat, and rack cards remain after restart.
5. **What if AI is off?** Local capture, notes, and honest “AI not configured” — no fake IDs.

## Delivery blurb

CellarCue is an AI wine-cellar coach: capture or import a label, place it in a bin, chat drinking windows and pairings on an aging timeline, see annotated rack cards, and hear a TTS pull brief — always labeled 非侍酒认证 / not a sommelier certification and 非投资建议 / not investment advice, with 21+ where alcohol advice appears. Free full value in this build.
