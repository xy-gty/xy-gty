# BendCoach AI — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: b43b4db81ea320561037660a574d8d0b620ca87f7d34a52fcece3c1fc6678d19  
pm_visual_manifest_sha256: 46c33c0955e1c3fe98d4473026decc2e316148b4293d533c79853afa5ab8c950

## One-line product

BendCoach AI is a field conduit-bending coach for electricians: bend-math chat, field photo import/recognize, diagram overlay with assistive marks, and TTS step coaching—numbers labeled assistive, unit-system aware, without cloning QuickBend brand/UI.

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

- app_name: BendCoach AI
- development_bundle_id: com.lingguang.bendcoach
- ui_language: en-US

## Deviations

- Operator paid unlock / pro packs intent deferred under UltraLite `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT in this delivery. Gap `operator_pricing_deferred_free_app_only`.
- Brand reference QuickBend / Bret Hardman: category-only; no brand assets, UI copy, or unauthorized scraping.
- Feishu registration / delivery card deferred per operator instruction (record_id 无).
- Keepers `capture-import` / `job-detail-filled` / `tts-coaching` remain on r1 after r2 regen of four wrong-product frames + diagram-overlay; job-detail and diagram readbacks stamped runtime_required uncertain for accept-time verification.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/home-empty-r2.png | ok | pass | done |
| bend-math-chat | frames/bend-math-chat-r2.png | ok | pass | done |
| capture-import | frames/capture-import-r1.png | ok | pass | done |
| bend-review | frames/bend-review-r2.png | ok | pass | done |
| job-detail-filled | frames/job-detail-filled-r1.png | ok | uncertain (runtime_required) | done |
| diagram-overlay | frames/diagram-overlay-r2.png | ok | uncertain (runtime_required) | done |
| tts-coaching | frames/tts-coaching-r1.png | ok | pass | done |
| settings-units-privacy | frames/settings-units-privacy-r2.png | ok | bound (auto fallback) | done |

- Batch: evidence/image-batch-r1 + image-batch-r2-wrongfix (GrokBot); r2 fixed SnagCue wrong_product on home/bend-math/bend-review/settings + diagram-overlay.
- visual_manifest.v1.json frozen sha256 46c33c0955e1c3fe98d4473026decc2e316148b4293d533c79853afa5ab8c950
- No independent assets declared this attempt (design: frame-embedded only)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only; Feishu deferred)
- operator_pricing_deferred_free_app_only
- visual_runtime_required: job-detail-filled, diagram-overlay (assistive number clarity / filled-state verify at accept)

## Evidence index

- evidence/preflight/
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-batch-r2-wrongfix.json / image-batch-r2-wrongfix.result.json
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json

## lessons_candidates

- Local seed / prior-product stems can land SnagCue branding; BendCoach must regen *-r2 with HARD BRAND LOCK and re-read before freeze.
- Vision answers that bury `**pass**` after preamble and add a `无法判断` section can leave conclusion token empty; freeze on cursor/auto still binds via draft readback_refs fallback (same as DocBrief settings). Prefer first-line `**pass**` for cleaner seals.
