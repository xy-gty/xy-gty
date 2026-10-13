# DocBrief AI — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0  
pm_visual_manifest_sha256: ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc

## One-line product

DocBrief AI turns document, whiteboard, and receipt photos into reviewed action briefs with AI field recognition, chat-extracted deadlines, visual summary cards, and spoken TTS briefings—without claiming financial, tax, or legal certification.

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

- app_name: DocBrief AI
- development_bundle_id: com.lingguang.docbrief
- ui_language: en-US

## Deviations

- Operator paid unlock / unlimited briefs intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Brand reference TurboScan Pro / com.novosoft.TurboScan: category-only; no brand assets, UI copy, or unauthorized scraping.
- Feishu registration / delivery card deferred per operator instruction.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/home-empty-r2.png | ok | pass | done |
| capture-import | frames/capture-import-r2.png | ok | pass | done |
| fields-review | frames/fields-review-r2.png | ok | pass | done |
| brief-detail-filled | frames/brief-detail-filled-r2.png | ok | pass | done |
| chat-extract | frames/chat-extract-r2.png | ok | pass | done |
| summary-card | frames/summary-card-r2.png | ok | pass | done |
| tts-briefing | frames/tts-briefing-r2.png | ok | pass | done |
| settings-privacy | frames/settings-privacy-r2.png | ok | pass | done |

- Batch: evidence/image-batch-r2.result.json ok=true (GrokBot after DocBrief Cursor GenerateImage drops; r1 SnagCue local_seed stems rejected by readback)
- visual_manifest.v1.json frozen sha256 ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc
- No independent assets declared this attempt (design: frame-embedded only)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only; identity-skeleton planned / feishu_client_unavailable)
- operator_pricing_deferred_free_app_only

## Evidence index

- evidence/preflight/pm-visuals-preflight.json
- evidence/image-batch-r1.json / image-batch-r1.result.json (partial; SnagCue seed mismatch)
- evidence/image-batch-r1b.json / image-batch-r1b.result.json (seed-stem remap; superseded)
- evidence/image-batch-r2.json / image-batch-r2.result.json
- evidence/visual-readback/*-r2.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json

## lessons_candidates

- Local GrokBot `local_seed` only resolves known stems; DocBrief must use new *-r2 stems with Cursor GenerateImage drops/seeds—never reuse SnagCue punchlist/annotated-report stems or readback will fail brand checks.
