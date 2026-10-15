# HiveCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: 5c0b80d2-15a9-4130-add4-280d2d487ffc

technical_contract_sha256: 5bda6a4efb122c94a7fcd682191fc44da554b26267bb7948618b47e67403a167  
pm_visual_manifest_sha256: 4558114f089b150a156c6a189d7fdc42ee43c164ab00463cc94679548a66a7e7

## One-line product

HiveCue is an AI hive-inspection coach: snap brood frames, keep reviewed brood / stores / pest findings, chat next actions, mark heat overlays, and dictate notes hands-free while suited.

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

- app_name: HiveCue
- development_bundle_id: com.lingguang.hivecue
- product_dir: hivecue/
- ui_language: en-US
- Simulator device lock: iPhone 17 Pro only (never Pro Max)
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch)
- Feishu CONTROLLER_DELIVERY: skip

## Deviations

- Operator “paid / one-time unlock for apiary packs” intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- BeePlus Beekeeping Manager: category remake reference only; no brand, UI, assets, or licensed content.
- Branding assets: **not generated** this round per operator hard constraint (`branding_assets_deferred`).
- Feishu delivery tracker: skip / deferred (`feishu_row_not_yet_created`).
- Device camera / long mic / speech may mark 真机待测 in Acceptance; Simulator still exercises journey entry points on iPhone 17 Pro.
- Resume e2 after `replace_lost_worker`: reused frozen technical_contract, frames/, and visual-readback; annotated-frame bound to e2 receipt after e1 CLI failure.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| hivecue-home-empty | frames/hivecue-home-empty-r1.png | grokbot ok | pass | done |
| hivecue-capture-import | frames/hivecue-capture-import-r1.png | grokbot ok | pass | done |
| hivecue-brood-review | frames/hivecue-brood-review-r1.png | grokbot ok | pass | done |
| hivecue-inspection-coach | frames/hivecue-inspection-coach-r1.png | grokbot ok | pass | done |
| hivecue-coach-chat | frames/hivecue-coach-chat-r1.png | grokbot ok | pass | done |
| hivecue-annotated-frame | frames/hivecue-annotated-frame-r1.png | grokbot ok | pass (e2) | done |
| hivecue-hands-free-tts | frames/hivecue-hands-free-tts-r1.png | grokbot ok | pass | done |
| hivecue-settings-privacy | frames/hivecue-settings-privacy-r1.png | grokbot ok | pass | done |

- Batch: evidence/image-batch-r1.json → evidence/image-batch-r1.result.json (GrokBot)
- Palette hard lock: #9F1239 / #FDF2F8 / #4D7C0F; UI chrome = hexagonal comb grid + inspection rail + heat overlay; no FormCue/YarnCue twins; no all-black shell
- No AppIcon / LaunchScreen assets this round
- visual_manifest.v1.json frozen sha256 `4558114f089b150a156c6a189d7fdc42ee43c164ab00463cc94679548a66a7e7` frozen_at `2026-10-15T06:17:23Z`
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
- evidence/visual-readback/*.receipt.json (+ raw jsonl; annotated-frame uses e2)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- frames/prompts/*-r1.txt / frames/*-r1.png
- design_provenance_gate: required on design.md

## lessons_candidates

- Cursor UltraLite replace_lost_worker resume must reuse technical freeze + frames + completed readbacks; only re-run missing vision (annotated-frame e1 CLI fail → e2) then freeze + MAP.
- Operator branding ban (no AppIcon/splash) stays explicit in visual_manifest assets=[] and MAP Gaps.
