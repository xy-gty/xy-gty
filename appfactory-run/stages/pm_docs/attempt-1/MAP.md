# YarnCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: 9ba15c2c-3db1-4817-a9c4-367452364f43

technical_contract_sha256: f053d2ed94177b694d55ab0f4804c9d10fab8634d08141f95a8469f50fd6fa0f  
pm_visual_manifest_sha256: 12cf6f34ae151bb7f403ab95cc7f3099bfae39f8e457adcc8afddc38399b4ab5

## One-line product

YarnCue is a free AI knitting/crochet weave coach: snap or import yarn & WIP photos, review stitch/row drafts with Keep/Discard, chat next-row coaching, annotate the WIP, and hear hands-free TTS — product_dir `yarncue/`; iPhone 17 Pro only.

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

- app_name: YarnCue
- development_bundle_id: com.lingguang.yarncue
- ui_language: en-US
- product_dir: yarncue/
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch preferred)
- simulator: iPhone 17 Pro ONLY (ban Pro Max)
- palette: primary #A21CAF / secondary #FDF4FF / accent #84CC16

## Deviations

- Operator “paid pattern / coach packs” **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Feishu CONTROLLER_DELIVERY: skip (operator) — `feishu_row_skipped_by_operator`.
- No AppIcon / LaunchScreen generation this attempt.
- Device camera / mic capture may mark 真机待测 in Acceptance; Simulator still exercises journey entry points.
- Single-slot prod-1 only; ban opening prod-2.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/home-empty-r1.png | ok | pass | done |
| capture-import | frames/capture-import-r1.png | ok | pass | done |
| coach-chat | frames/coach-chat-r1.png | ok | pass | done |
| project-coach | frames/project-coach-r1.png | ok | pass | done |
| stitch-review | frames/stitch-review-r1.png | ok | pass | done |
| annotated-wip | frames/annotated-wip-r1.png | ok | pass | done |
| hands-free-tts | frames/hands-free-tts-r1.png | ok | pass | done |
| settings-privacy | frames/settings-privacy-r1.png | ok | pass | done |

- visual_manifest.v1.json frozen_at 2026-10-15T02:15:42Z sha256 `12cf6f34ae151bb7f403ab95cc7f3099bfae39f8e457adcc8afddc38399b4ab5`
- annotated-wip-r1.png LOCKED sha256=`9ace33afd688ae88e20a773718ba209f464bde2fa711e27e25634bf2f99c73d3` — never overwritten this attempt
- Contaminated CuePartner home-empty / DuctCue coach-chat / garment capture-import quarantined under `frames/_quarantine_wrong_product_20261015/`; YarnCue replacements vision-pass on e6 (2026-10-15)
- yarncue-coach-chat-r1.png present (same YarnCue weave-coach Keep/Discard as coach-chat-r1)
- design_provenance_gate: ok
- No independent AppIcon/Launch assets declared this attempt
- Hard privacy Info.plist copy required for Camera / Photo Library / Microphone / Speech Recognition

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_skipped_by_operator
- operator_pricing_deferred_free_app_only
- camera/mic device capture: 真机待测 where Simulator cannot exercise hardware
- four permissions must stay complete through build/accept

## Evidence index

- evidence/preflight/pm_visuals_preflight.json
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-batch-r2-subset.json / image-batch-r2-subset.result.json
- evidence/criteria/*.txt
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- evidence/visual-readback/_quarantine_coach_chat_ductcue/
- evidence/visual-readback/_quarantine_capture_uncertain/
- evidence/visual-readback/_quarantine_home_empty/
- frames/*-r1.png (+ *.receipt.json + prompts/)
- frames/_quarantine_wrong_product_20261015/
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- runtime/yarncue-init/CONTROLLER_FRAMES_FIXED_20261015.md
- runtime/yarncue-init/vision-logs/*.e6.out

## lessons_candidates

- Generic stems (`home-empty-r1`, `coach-chat-r1`) collide with other-app `local_seed` inventory (CuePartner/DuctCue); quarantine wrong-product PNGs and re-seed YarnCue frames before freeze.
- `stitch-review` / `hands-free-tts` postprocess receipts need `crop_box` consistent with `source_size`, or drop postprocess when output is already 640x1392.
- replace_lost_worker e6 after e5 Connection stalled; finish home-empty / coach-chat / capture-import vision then freeze — do not overwrite locked annotated-wip.
