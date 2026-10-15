# WingCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: d0f1491a21ac0e032bbaeac9f646a5ae92bd9ae082cfb064fe62fa8a21423c17  
pm_visual_manifest_sha256: d23b6a370f07f610be3de4533409e5a8c0074ab6dfd177b57f75a14c6d05d860

## One-line product

WingCue is an AI birding field coach: shoot or import a bird still, lock field marks on stacked field-cards with oversized chips and a silhouette contrast bar, clarify lookalikes by text/speech, annotate overlays, and hear TTS tips.

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

- app_name: WingCue
- product_dir: wingcue/ (symlink → product)
- development_bundle_id: com.lingguang.wingcue
- ui_language: en-US
- simulator: iPhone 17 Pro only (prefer B14CC0EA); never Pro Max
- palette: primary `#0F766E` · secondary `#F0FDFA` · accent `#C2410C`
- UI species: field-card 叠层 + 超大鉴别特征 chips + 剪影对比条
- permissions: Camera / Photos / Microphone / Speech Recognition
- NO AppIcon / LaunchScreen generation
- NOT ClosetCue / FrameCue / ScoutCue / RuleCue / StopCue twins

## Deviations

- Operator paid / one-time unlock intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Feishu CONTROLLER_DELIVERY skip per operator.
- Option A soft `known_issues` for non-core UL fails; P1 UNKNOWN gaps must not block delivery.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| wingcue-home-empty | frames/wingcue-home-empty-r1.png | ok | pass | done |
| wingcue-capture-camera | frames/wingcue-capture-camera-r1.png | ok | pass | done |
| wingcue-id-result | frames/wingcue-id-result-r1.png | ok | pass | done |
| wingcue-lookalike-chat | frames/wingcue-lookalike-chat-r1.png | ok | pass | done |
| wingcue-overlay-annotate | frames/wingcue-overlay-annotate-r1.png | ok | pass | done |
| wingcue-voice-note | frames/wingcue-voice-note-r1.png | ok | pass | done |
| wingcue-consent-ai | frames/wingcue-consent-ai-r1.png | ok | pass | done |
| wingcue-settings-privacy | frames/wingcue-settings-privacy-r1.png | ok | pass | done |

- Batch: evidence/image-batch-r1.result.json (GrokBot)
- visual_manifest.v1.json frozen_at 2026-10-15T15:22:57Z sha256 d23b6a370f07f610be3de4533409e5a8c0074ab6dfd177b57f75a14c6d05d860
- visual_contract_schema: appfactory.ai_ultra_lite_visuals.v1
- 8/8 design readbacks conclusion=pass; runtime_required items empty
- No independent assets declared this attempt (frame-embedded only)
- Overlay raw stream restored to match receipt `raw_sha256` before freeze (incomplete stream parked; vision not re-run)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only)
- operator_pricing_deferred_free_app_only

## Evidence index

- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/visual-readback/*.receipt.json (+ matching *.receipt.jsonl)
- evidence/visual-runtime-required.v1.json
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- criteria/ (design self-check criterion files)

## lessons_candidates

- When a vision receipt’s `raw_sha256` points at a prior jsonl renamed aside, restore that byte-identical stream to `raw_ref` before freeze; do not re-run vision if conclusion already pass.
