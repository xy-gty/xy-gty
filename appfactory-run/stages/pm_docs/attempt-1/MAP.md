# MixCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: a6a5c05c1334f671c59c636a25afe98e5c227a09bda4cd85692dcaed703fd7ac  
pm_visual_manifest_sha256: ac86f75a0af01b38ef8acf96bd9877461ba04f5812cd31370b5d7eef010d46bf

## One-line product

MixCue is an AI home-bar cocktail coach: shoot or import a bottle/label/garnish, lock base-spirit ID on a vertical bottle-rail, chat recipes/substitutes, advance a large next-pour card with garnish chips, and hear TTS shake/stir steps.

## Documents

- build/product.md
- build/features.md
- build/design.md
- build/acceptance.md
- technical/contract.md
- technical_contract.v1.json (frozen)
- technical_contract.binding.v1.json
- visual_manifest.v1.json (frozen)

## Identity

- app_name: MixCue
- product_dir: mixcue/ (symlink → product)
- development_bundle_id: com.lingguang.mixcue
- ui_language: en-US
- simulator: iPhone 17 Pro only (prefer B14CC0EA); never Pro Max
- palette: primary `#E11D48` · secondary `#FFF1F2` · accent `#CA8A04`
- UI species: 竖向瓶架轨 + 大号下一步倒法卡 + 装饰 chip 行
- permissions: Camera / Photos / Microphone / Speech Recognition
- NO AppIcon / LaunchScreen generation
- NOT WingCue / FrameCue / RuleCue / StopCue / ClosetCue / ScoutCue twins
- Do NOT name Cocktail Party / Bevnap in App copy

## Deviations

- Operator paid / one-time unlock intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Feishu CONTROLLER_DELIVERY skip per operator.
- Option A soft `known_issues` for non-core UL fails; P1 UNKNOWN gaps must not block delivery.
- Deliver target: `git@github.com:xy-gty/xy-gty.git` independent branch (Builder/Delivery).

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| mixcue-home-empty | frames/mixcue-home-empty-r1.png | ok | pass | done |
| mixcue-capture-camera | frames/mixcue-capture-camera-r1.png | ok | pass | done |
| mixcue-id-result | frames/mixcue-id-result-r1.png | ok | pass | done |
| mixcue-recipe-chat | frames/mixcue-recipe-chat-r1.png | ok | pass | done |
| mixcue-pour-board | frames/mixcue-pour-board-r1.png | ok | pass | done |
| mixcue-voice-note | frames/mixcue-voice-note-r1.png | ok | pass | done |
| mixcue-consent-ai | frames/mixcue-consent-ai-r1.png | ok | pass | done |
| mixcue-settings-privacy | frames/mixcue-settings-privacy-r1.png | ok | pass | done |

- Batch: evidence/image-batch-r1.result.json (GrokBot local_seed)
- visual_manifest.v1.json frozen sha256 ac86f75a0af01b38ef8acf96bd9877461ba04f5812cd31370b5d7eef010d46bf
- visual_contract_schema: appfactory.ai_ultra_lite_visuals.v1
- 8/8 design readbacks conclusion=pass; runtime_required items empty
- No independent assets declared this attempt (frame-embedded only)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only)
- operator_pricing_deferred_free_app_only

## Evidence index

- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/visual-readback/*.receipt.json (+ matching *.receipt.jsonl)
- evidence/criteria/*
- technical_contract.v1.json / technical_contract.binding.v1.json
