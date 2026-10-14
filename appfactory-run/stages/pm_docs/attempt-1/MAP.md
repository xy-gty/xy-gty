# PitchCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: c8ca2d4f-e11c-4b15-9411-2a9f77ebc775

technical_contract_sha256: 025f0d83d669b1d4c31dfabb13d085ddfd42cea01bc13866f511746b2143c782  
pm_visual_manifest_sha256: 37f0534c682301ff11f167d2408eb2481d395f67260203b0f52e821b0ce0de22

## One-line product

PitchCue is a free AI practice coach for instrumentalists: import sheet photos, review DeepSeek warm-up plans before Keep, hear TTS count-ins, play local drone/metronome beds on a horizontal practice strip with continuous waveform, and optionally check pitch on a circular dial—without TonalEnergy/CuePartner clones or in-band monetization.

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

- app_name: PitchCue
- development_bundle_id: com.lingguang.pitchcue
- product_dir: pitchcue/
- ui_language: en-US
- Simulator device lock: iPhone 17 Pro only
- delivery_remote: git@github.com:xy-gty/xy-gty.git

## Deviations

- Operator “paid / unlock unlimited practice packs” intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- TonalEnergy / CuePartner: category reference only; no brand, UI, assets, or licensed content.
- Branding assets: **not generated** this round per operator hard constraint (`branding_assets_deferred`).
- Feishu delivery tracker: skip / deferred (`feishu_row_not_yet_created`).
- Device camera capture / long mic listen may mark 真机待测 in Acceptance; Simulator still exercises journey entry points on iPhone 17 Pro.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/home-empty-r2.png | grokbot ok | pass | done |
| capture-import | frames/capture-import-r2.png | grokbot ok | pass | done |
| coach-chat | frames/coach-chat-r2.png | grokbot ok | pass | done |
| plan-review | frames/plan-review-r2.png | grokbot ok | pass | done |
| practice-floor | frames/practice-floor-r2.png | grokbot ok | pass | done |
| pitch-feedback | frames/pitch-feedback-r2.png | grokbot ok | pass | done |
| settings-privacy | frames/settings-privacy-r2.png | grokbot ok | pass | done |

- Batches: evidence/image-batch-r1.json (contaminated CuePartner/DuctCue local_seed + seed_missing subset) → quarantined; evidence/image-batch-r2.json PitchCue-only seeds via GenerateImage drops → freeze binds r2
- No AppIcon / launch-splash assets this round
- visual_manifest.v1.json frozen sha256 `37f0534c682301ff11f167d2408eb2481d395f67260203b0f52e821b0ce0de22` frozen_at `2026-10-14T08:11:20Z`
- Hard privacy Info.plist copy required for Camera / Photo Library / Microphone / Speech Recognition (see technical contract + acceptance)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (identity-skeleton planned; Feishu client unavailable / operator skip tracker)
- operator_pricing_deferred_free_app_only
- branding_assets_deferred
- camera/mic device capture: 真机待测 where Simulator cannot exercise hardware

## Evidence index

- evidence/preflight.json
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-batch-r2.json / image-batch-r2.result.json
- evidence/quarantine/*CONTAMINATED*
- evidence/criteria/*.txt
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- assets/exclusive/*-r2.png (PitchCue seed copies)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- frames/prompts/*-r2.txt / frames/*-r2.png
- design_provenance_gate: ok

## lessons_candidates

- Cursor UltraLite GrokBot `local_seed` reuses stem names across apps; PitchCue must drop PitchCue-only seeds (or unique stems) before batch, and quarantine contaminated r1 CuePartner/DuctCue hits.
- Operator branding ban (no AppIcon/splash) should stay explicit in visual_manifest assets=[] and MAP Gaps.
