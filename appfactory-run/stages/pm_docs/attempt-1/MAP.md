# FrameCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: a61dbdb2-21da-4c62-b224-c6d94958069c

technical_contract_sha256: 3bd8adb2a16343fa320ed77ae22ca4f28be2e84ca52888d949f52528126826fd  
pm_visual_manifest_sha256: 131f8b751bcc346c32c68d2adb21acede76a733a0f3320480c5768ac22b83b6a

## One-line product

FrameCue is a free AI director framing coach: shoot or import stills, keep reviewed composition notes, chat shot size and lens language, mark safe-frame overlays on a clapper canvas, and hear on-set TTS cues — product_dir `framecue/`; iPhone 17 Pro only.

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

- app_name: FrameCue
- development_bundle_id: com.lingguang.framecue
- ui_language: en-US
- product_dir: framecue/ (symlink framecue→product)
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch preferred)
- simulator: iPhone 17 Pro ONLY prefer B14CC0EA — NEVER Pro Max
- palette: primary #7E22CE / secondary #FAF5FF / accent #F59E0B

## Deviations

- Operator “paid / one-time unlock unlimited framing packs” **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Feishu CONTROLLER_DELIVERY: skip (operator) — `feishu_row_skipped_by_operator`.
- No AppIcon / LaunchScreen generation this attempt.
- Device camera / mic capture may mark 真机待测 in Acceptance; Simulator still exercises journey entry points.
- Single-slot prod-1 only; ban opening prod-2.
- Option A soft known_issues for non-core UL fails; P1 non-blockers must not block delivery.
- composition-review r1 vision fail (Apply vs Keep) → regenerated r2 with Keep; r1 PNG/receipt retained.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| framecue-home-empty | frames/framecue-home-empty-r1.png | ok | pass | done |
| framecue-capture-import | frames/framecue-capture-import-r1.png | ok | pass | done |
| framecue-composition-review | frames/framecue-composition-review-r2.png | ok | pass | done |
| framecue-slate-stage | frames/framecue-slate-stage-r1.png | ok | pass | done |
| framecue-coach-chat | frames/framecue-coach-chat-r1.png | ok | pass | done |
| framecue-overlay-marks | frames/framecue-overlay-marks-r1.png | ok | pass | done |
| framecue-hands-free-tts | frames/framecue-hands-free-tts-r1.png | ok | pass | done |
| framecue-settings-privacy | frames/framecue-settings-privacy-r1.png | ok | pass | done |

- visual_manifest.v1.json frozen sha256 `131f8b751bcc346c32c68d2adb21acede76a733a0f3320480c5768ac22b83b6a`
- design_provenance_gate: ok
- No independent AppIcon/Launch assets declared this attempt
- Hard privacy Info.plist copy required for Camera / Photo Library / Microphone / Speech Recognition
- Unique UI frozen: 片场场记板式画幅框 + 底部景别芯片条（not RuleCue/StopCue/NightCue twins）

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_skipped_by_operator / feishu_row_not_yet_created (identity-skeleton planned; client unavailable)
- operator_pricing_deferred_free_app_only
- camera/mic device capture: 真机待测 where Simulator cannot exercise hardware
- four permissions must stay complete through build/accept

## Evidence index

- evidence/preflight/pm_visuals_preflight.json
- evidence/image-batch-r1.json (+ r1.result seed_missing; r2.result ok after Cursor GenerateImage → seed)
- evidence/image-batch-r3.json (composition-review r2)
- evidence/visual-readback/*.receipt.json (+ *.receipt.jsonl)
- evidence/visual-freeze.log
- visual_readback_index.v1.json

## lessons_candidates

- Cursor UltraLite local_seed MCP needs unique `framecue-*` stems + GenerateImage drop into seed before batch ok.
- Vision fails on wrong CTA labels (Apply vs Keep); revise prompt/image rN and re-read.
