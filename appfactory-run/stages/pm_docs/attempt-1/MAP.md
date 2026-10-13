# SnagCue AI — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276

## One-line product

SnagCue AI turns walkthrough photos into a reviewed punch list with AI field fill, annotated report images, and hands-free TTS checklist readouts—without claiming building-code certification.

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

- app_name: SnagCue AI
- development_bundle_id: com.lingguang.snagcue
- ui_language: en-US

## Deviations

- Operator paid / one-time unlock intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Brand reference Site Audit Pro / com.veamstudios.iaudit: category-only; no brand assets or compliance certification claims.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/home-empty-r1.png | ok | pass | done |
| capture-import | frames/capture-import-r1.png | ok | pass | done |
| recognition-review | frames/recognition-review-r1.png | ok | pass | done |
| punchlist-filled | frames/punchlist-filled-r1.png | ok | pass | done |
| chat-fill | frames/chat-fill-r1.png | ok | pass | done |
| annotated-report | frames/annotated-report-r1.png | ok | pass | done |
| tts-coach | frames/tts-coach-r1.png | ok | pass | done |
| settings-privacy | frames/settings-privacy-r1.png | ok | pass | done |

- Batch: evidence/image-batch-r1.result.json ok=true (GrokBot local_seed after Cursor GenerateImage drops)
- visual_manifest.v1.json frozen sha256 b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276
- No independent assets declared this attempt (design: frame-embedded only)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only)
- operator_pricing_deferred_free_app_only

## Evidence index

- evidence/preflight/pm_visuals_preflight.json
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json

## lessons_candidates

- Cursor vision answers that put `No …` at the start of a table cell make `readback_conclusion_token` see alias `no→fail` alongside `pass`; stamp structured `conclusion: pass` before freeze, or force a lone leading verdict line.
