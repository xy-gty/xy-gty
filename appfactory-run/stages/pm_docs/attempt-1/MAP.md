# RuleCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: 1df3c2d5-4682-41b9-8503-42322eed9ace

technical_contract_sha256: c66fef8e4c822efd842ef91b6009b49826b7a9f871f3e6e9f6acb096fe8185c7  
pm_visual_manifest_sha256: 803064a4db0d8bdaf7bd875cbd21bbcf0a8834a75676d4550391c6576d5da900

## One-line product

RuleCue is an AI board-game rules and setup coach: snap or import rulebook and table photos, keep reviewed components and turn steps, chat for rulings, confirm annotated zone overlays, and hear TTS table-host cues while you set up.

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

- app_name: RuleCue
- development_bundle_id: com.lingguang.rulecue
- product_dir: rulecue/ (symlink rulecue→product; never product/ only)
- ui_language: en-US
- Simulator device lock: iPhone 17 Pro only prefer B14CC0EA (never Pro Max)
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch)
- Feishu CONTROLLER_DELIVERY: skip

## Deviations

- Operator “paid / one-time unlock for unlimited game packs” intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Board Game Stats: category remake reference only (rules/setup coach ≠ play-stats); no brand, UI, assets, or licensed content.
- Positioning ≠ StopCue (stop-motion); UI ≠ StopCue film-sprocket / onion-skin; ≠ NightCue night-frame rail; ≠ HiveCue / FormCue / YarnCue / ScoutCue twins.
- Branding assets: **not generated** this round per operator hard constraint (`branding_assets_deferred`).
- Feishu delivery tracker: skip / deferred (`feishu_row_not_yet_created`).
- Device camera / mic / speech may mark 真机待测 in Acceptance; Simulator still exercises journey entry points on iPhone 17 Pro.
- Stage stuck → Option A soft known_issues; P1 non-blockers must not block delivery.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| rulecue-home-empty | frames/rulecue-home-empty-r1.png | grokbot ok | pass | done |
| rulecue-capture-import | frames/rulecue-capture-import-r1.png | grokbot ok | pass | done |
| rulecue-component-review | frames/rulecue-component-review-r1.png | grokbot ok | pass | done |
| rulecue-table-coach | frames/rulecue-table-coach-r1.png | grokbot ok | pass | done |
| rulecue-coach-chat | frames/rulecue-coach-chat-r1.png | grokbot ok | pass | done |
| rulecue-setup-overlay | frames/rulecue-setup-overlay-r1.png | grokbot ok | pass | done |
| rulecue-tts-host | frames/rulecue-tts-host-r1.png | grokbot ok | pass | done |
| rulecue-settings-privacy | frames/rulecue-settings-privacy-r1.png | grokbot ok | pass | done |

- Batch: evidence/image-batch-r1.json → evidence/image-batch-r1.result.json (GrokBot local_seed via RuleCue-prefixed Cursor GenerateImage seeds)
- Palette hard lock: #854D0E / #FEFCE8 / #0891B2; UI chrome = table zone cards + turn step bar; no StopCue film-sprocket/onion-skin; no NightCue night-rail; no HiveCue/FormCue/YarnCue/ScoutCue twins; no all-black shell
- No AppIcon / LaunchScreen assets this round
- visual_manifest.v1.json frozen sha256 `803064a4db0d8bdaf7bd875cbd21bbcf0a8834a75676d4550391c6576d5da900`
- Hard privacy Info.plist copy required for Camera / Photos / Microphone / Speech Recognition (see technical contract + acceptance)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (Feishu CONTROLLER_DELIVERY skip)
- operator_pricing_deferred_free_app_only
- branding_assets_deferred
- camera/mic/speech device capture: 真机待测 where Simulator cannot exercise hardware

## Evidence index

- evidence/preflight/pm_visuals_preflight.json
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/criteria/*.txt
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- frames/prompts/*-r1.txt / frames/*-r1.png
- design_provenance_gate: ok on design.md
- mailbox checkpoint: technical_contract_ready (producer_dispatch_id=1df3c2d5-4682-41b9-8503-42322eed9ace)

## lessons_candidates

- Cursor UltraLite local_seed GrokBot requires RuleCue-prefixed seed PNGs (GenerateImage → seed/ + index stems); never reuse StopCue/NightCue/HiveCue/FormCue/YarnCue/ScoutCue seeds.
- Settings frame must show Camera/Photos/Microphone/Speech as four separate rows for readback pass.
- Operator branding ban (no AppIcon/splash) stays explicit in visual_manifest assets=[] and MAP Gaps.
