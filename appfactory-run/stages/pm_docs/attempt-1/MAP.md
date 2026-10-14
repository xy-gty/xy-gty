# CuePartner AI — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: 970d9596-6bef-41a7-be47-4153ae249ff6

technical_contract_sha256: 9cb9f54b37cdeb602be56fafdcba1dde4e963ad5cc2dc289efcb5abd4643aa2f  
pm_visual_manifest_sha256: 5f4a9df742b0a3c3d0282a524b5bade3ff4c3e8a5e55389e4b5d6fe738785875

## One-line product

CuePartner AI is a free local rehearsal partner: import your own script photos for OCR, chat as a scene partner with role switching, TTS cue lines with timing, optional stage ambience, plus camera/library/mic/speech entries—without shipping copyrighted scripts or LineLearner branding.

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

- app_name: CuePartner AI
- development_bundle_id: com.lingguang.cuepartner
- ui_language: en-US

## Deviations

- Operator “paid / unlock unlimited scenes and character voices” intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`. Scenes and local voices are unrestricted in-app.
- LineLearner / com.alldayapps.linelearner: category reference only; no brand, UI, assets, or licensed scripts.
- Device camera capture / mic record may mark 真机待测 in Acceptance; Simulator still exercises journey entry points.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/home-empty-r2.png | ok | pass | done |
| import-script | frames/import-script-r1.png | ok | pass | done |
| ocr-review | frames/ocr-review-r2.png | ok | pass | done |
| scene-detail | frames/scene-detail-r2.png | ok | pass | done |
| partner-chat | frames/partner-chat-r1.png | ok | pass | done |
| cue-rehearsal | frames/cue-rehearsal-r1.png | ok | pass | done |
| voice-note | frames/voice-note-r1.png | ok | pass | done |
| settings-privacy | frames/settings-privacy-r2.png | ok | pass | done |

- Batches: evidence/image-batch-r1.json (partial) + evidence/image-batch-r2.json / image-batch-r2-scene.json (CuePartner r2 via Cursor GenerateImage → GrokBot local_seed)
- visual_manifest.v1.json frozen sha256 5f4a9df742b0a3c3d0282a524b5bade3ff4c3e8a5e55389e4b5d6fe738785875 frozen_at 2026-10-14T03:25:33Z
- No independent assets declared (frame-embedded only)
- Hard privacy Info.plist copy required for Camera / Photo Library / Microphone / Speech Recognition (see technical contract + acceptance)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only; Feishu deferred by controller)
- operator_pricing_deferred_free_app_only
- camera/mic device capture: 真机待测 where Simulator cannot exercise hardware

## Evidence index

- evidence/preflight/
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-batch-r2.json / image-batch-r2.result.json
- evidence/image-batch-r2-scene.json / image-batch-r2-scene.result.json
- evidence/criteria/*.txt
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- frames/prompts/* / frames/*-r1.png / frames/*-r2.png

## lessons_candidates

- GrokBot `local_seed` can vomit other-app seeds sharing stem names (SnagCue → CuePartner). Prefer CuePartner-named GenerateImage drops + r2 stems; never preserve contaminated “ok” receipts.
- Stale `*.receipt.json.first-write.v1.json` from failed e8 attempts mark fresh e9 receipts as `rewritten`; archive mismatched seals before freeze.
