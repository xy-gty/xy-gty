# StopCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: 06876bf1-89fb-43b5-99d2-7830eaa3a0a2

technical_contract_sha256: 6aa7ee6083e7746fa2f67056aa5b47073685641d760c2172930253bdab5e5dd7  
pm_visual_manifest_sha256: 67d2dbd0136b12a02e0ce2e3b79e23804e20902ee7c947865851b82be2150265

## One-line product

StopCue is an AI stop-motion coach: capture or import frame sequences, keep reviewed shot plans and timing, chat for storyboard beats, confirm onion-skin guides, and hear TTS countdown cues while you shoot.

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

- app_name: StopCue
- development_bundle_id: com.lingguang.stopcue
- product_dir: stopcue/ (symlink stopcue→product; never product/ only)
- ui_language: en-US
- Simulator device lock: iPhone 17 Pro only prefer B14CC0EA (never Pro Max 315A7C2C)
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch)
- Feishu CONTROLLER_DELIVERY: skip

## Deviations

- Operator “paid / one-time unlock for unlimited projects” intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Stop Motion Studio Pro: category remake reference only; no brand, UI, assets, or licensed content.
- Positioning ≠ NightCue (night long-exposure coach); UI ≠ NightCue night-frame rail / exposure-diagnosis overlays; ≠ CuePartner / HiveCue / FormCue / YarnCue / ScoutCue twins.
- Branding assets: **not generated** this round per operator hard constraint (`branding_assets_deferred`).
- Feishu delivery tracker: skip / deferred (`feishu_row_not_yet_created`).
- Device camera / mic / speech may mark 真机待测 in Acceptance; Simulator still exercises journey entry points on iPhone 17 Pro.
- Stage stuck → Option A soft known_issues; P1 non-blockers must not block delivery.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| stopcue-home-empty | frames/stopcue-home-empty-r1.png | grokbot ok | pass | done |
| stopcue-capture-import | frames/stopcue-capture-import-r1.png | grokbot ok | pass | done |
| stopcue-frame-review | frames/stopcue-frame-review-r1.png | grokbot ok | pass | done |
| stopcue-stop-coach | frames/stopcue-stop-coach-r1.png | grokbot ok | pass | done |
| stopcue-coach-chat | frames/stopcue-coach-chat-r1.png | grokbot ok | pass | done |
| stopcue-onion-overlay | frames/stopcue-onion-overlay-r1.png | grokbot ok | pass | done |
| stopcue-tts-countdown | frames/stopcue-tts-countdown-r1.png | grokbot ok | pass | done |
| stopcue-settings-privacy | frames/stopcue-settings-privacy-r2.png | grokbot ok | pass (r2b) | done |

- Batch: evidence/image-batch-r1.json → evidence/image-batch-r1.result.json (GrokBot local_seed via StopCue-prefixed Cursor GenerateImage seeds); settings revised via evidence/image-batch-settings-r2.json
- Palette hard lock: #16A34A / #F0FDF4 / #DB2777; UI chrome = film-sprocket timeline + onion-skin overlay preview; no NightCue night-rail/exposure overlays; no CuePartner/HiveCue/FormCue/YarnCue/ScoutCue twins; no all-black shell
- No AppIcon / LaunchScreen assets this round
- visual_manifest.v1.json frozen sha256 `67d2dbd0136b12a02e0ce2e3b79e23804e20902ee7c947865851b82be2150265`
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
- evidence/image-batch-settings-r2.json / image-batch-settings-r2.result.json
- evidence/criteria/*.txt
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- frames/prompts/*-r1.txt (+ settings-privacy-r2) / frames/*-r1.png (+ settings-privacy-r2.png)
- design_provenance_gate: ok on design.md

## lessons_candidates

- Cursor UltraLite local_seed GrokBot requires StopCue-prefixed seed PNGs (GenerateImage → seed/ + index stems); never reuse NightCue/HiveCue/FormCue/YarnCue/ScoutCue seeds.
- Settings frame needed r2 so Camera/Photos/Microphone/Speech appear as four separate rows for readback pass.
- Operator branding ban (no AppIcon/splash) stays explicit in visual_manifest assets=[] and MAP Gaps.
