# NightCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: cd29d1f4-0c18-47cd-9c9b-eb32dc73f775

technical_contract_sha256: 72c5bea905cf48b0f721c2bceb6834b467d0108e2f088c97d597840b21a771dd  
pm_visual_manifest_sha256: 1a4dadba3e29ffddbae1a77fc341df3ac1b5580d4e0bfd14f4e27686815248f0

## One-line product

NightCue is an AI night long-exposure coach: shoot or import night test frames, keep reviewed exposure and noise findings, chat for settings, confirm diagnosis overlays, and hear field cues while you stay on the tripod.

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

- app_name: NightCue
- development_bundle_id: com.lingguang.nightcue
- product_dir: nightcue/ (symlink nightcue→product; never product/ only)
- ui_language: en-US
- Simulator device lock: iPhone 17 Pro only prefer B14CC0EA (never Pro Max 315A7C2C)
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch)
- Feishu CONTROLLER_DELIVERY: skip

## Deviations

- Operator “paid / one-time unlock for night packs” intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- NightCap Camera Long Exposure: category remake reference only; no brand, UI, assets, or licensed content.
- Positioning ≠ ScoutCue (solar/ephemeris scouting); UI ≠ HiveCue/FormCue/YarnCue twins.
- Branding assets: **not generated** this round per operator hard constraint (`branding_assets_deferred`).
- Feishu delivery tracker: skip / deferred (`feishu_row_not_yet_created`).
- Device camera / long mic / speech may mark 真机待测 in Acceptance; Simulator still exercises journey entry points on iPhone 17 Pro.
- Stage stuck → Option A soft known_issues; P1 non-blockers must not block delivery.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| nightcue-home-empty | frames/nightcue-home-empty-r1.png | grokbot ok | pass | done |
| nightcue-capture-import | frames/nightcue-capture-import-r1.png | grokbot ok | pass | done |
| nightcue-exposure-review | frames/nightcue-exposure-review-r1.png | grokbot ok | pass | done |
| nightcue-night-coach | frames/nightcue-night-coach-r1.png | grokbot ok | pass | done |
| nightcue-coach-chat | frames/nightcue-coach-chat-r1.png | grokbot ok | pass | done |
| nightcue-annotated-overlay | frames/nightcue-annotated-overlay-r1.png | grokbot ok | pass | done |
| nightcue-field-tts | frames/nightcue-field-tts-r1.png | grokbot ok | pass | done |
| nightcue-settings-privacy | frames/nightcue-settings-privacy-r1.png | grokbot ok | pass | done |

- Batch: evidence/image-batch-r1.json → evidence/image-batch-r1.result.json (GrokBot local_seed via NightCue-prefixed Cursor GenerateImage seeds)
- Palette hard lock: #1E3A8A / #EFF6FF / #FBBF24; UI chrome = night-frame rail + exposure-diagnosis overlays; no HiveCue/FormCue/YarnCue twins; no ScoutCue solar shell; no all-black shell
- No AppIcon / LaunchScreen assets this round
- visual_manifest.v1.json frozen sha256 `1a4dadba3e29ffddbae1a77fc341df3ac1b5580d4e0bfd14f4e27686815248f0`
- frozen_at `2026-10-15T08:22:45Z`
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
- design_provenance_gate: required on design.md

## lessons_candidates

- Cursor UltraLite local_seed GrokBot requires NightCue-prefixed seed PNGs (GenerateImage → seed/ + index stems); never reuse HiveCue/FormCue/YarnCue/ScoutCue seeds.
- Operator branding ban (no AppIcon/splash) stays explicit in visual_manifest assets=[] and MAP Gaps.
