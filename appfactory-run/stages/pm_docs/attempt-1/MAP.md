# SporeCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: cde02f702a052b37ad3f7a1eb8dd16836639377a1b10261f40bfd83c697e5356  
pm_visual_manifest_sha256: 0263b2c8eadb63c6c401b4d4bde562b5079f4c9e11498059822d9b86a00639d2

## One-line product

SporeCue is an AI wild-mushroom field coach: shoot or import a cap/gill/pore still, rank species on a vertical confidence stack with an oversized closeup bar and informational caution chips, chat lookalikes, annotate overlays, and hear a TTS field brief — always 非可食认证 / not an edibility certification.

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

- app_name: SporeCue
- product_dir: sporecue/ (symlink → product; deliver as sporecue not product)
- development_bundle_id: com.lingguang.sporecue
- ui_language: en-US
- simulator: iPhone 17 Pro only (prefer B14CC0EA); never Pro Max
- palette: primary `#9A3412` · secondary `#FFF7ED` · accent `#0284C7`
- UI species: 纵向物种置信栈 + 超大菌褶/管孔特写条 + 可食/警示 chip 轨
- permissions: Camera / Photos / Microphone / Speech Recognition
- NO AppIcon / LaunchScreen generation
- NOT MixCue / WingCue / FrameCue / RuleCue / StopCue / ClosetCue / ScoutCue twins
- Do NOT name Shroomify / Pilze 123 in App copy
- Hard compliance: every ID/edibility/foraging surface states 非可食认证 / not an edibility certification; NEVER imply safe to eat

## Deviations

- Operator paid / one-time unlock intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Feishu CONTROLLER_DELIVERY skip per operator.
- Option A soft `known_issues` for non-core UL fails; P1 UNKNOWN gaps must not block delivery.
- Deliver target: `git@github.com:xy-gty/xy-gty.git` independent branch (Builder/Delivery).

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| sporecue-home-empty | frames/sporecue-home-empty-r1.png | ok | pass | done |
| sporecue-capture-camera | frames/sporecue-capture-camera-r1.png | ok | pass | done |
| sporecue-id-result | frames/sporecue-id-result-r1.png | ok | pass | done |
| sporecue-lookalike-chat | frames/sporecue-lookalike-chat-r1.png | ok | pass | done |
| sporecue-overlay-annotate | frames/sporecue-overlay-annotate-r1.png | ok | pass | done |
| sporecue-voice-note | frames/sporecue-voice-note-r1.png | ok | pass | done |
| sporecue-consent-ai | frames/sporecue-consent-ai-r1.png | ok | pass | done |
| sporecue-settings-privacy | frames/sporecue-settings-privacy-r1.png | ok | pass | done |

- Batch: evidence/image-batch-r1.result.json (GrokBot local_seed; Cursor GenerateImage seeds)
- visual_manifest.v1.json frozen sha256 0263b2c8eadb63c6c401b4d4bde562b5079f4c9e11498059822d9b86a00639d2
- visual_contract_schema: appfactory.ai_ultra_lite_visuals.v1
- 8/8 design readbacks allow freeze (answers contain pass); runtime_required items empty
- No independent assets declared this attempt (frame-embedded only)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only)
- operator_pricing_deferred_free_app_only

## Evidence index

- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-generator-audit.jsonl
- evidence/visual-readback/*.receipt.json (+ matching *.receipt.jsonl)
- evidence/criteria/*
- technical_contract.v1.json / technical_contract.binding.v1.json
