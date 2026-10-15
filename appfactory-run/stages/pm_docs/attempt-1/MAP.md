# CellarCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only

technical_contract_sha256: 5b0e7e1cf2ab96ca937e5fe9661287dbdb46203ee0a885a281a14e8ec8097400  
pm_visual_manifest_sha256: d1deb007e4d4fbe223dd1b426b3ec2a150d8c85c9c781fea812e7f7c07504497

## One-line product

CellarCue is an AI wine-cellar coach: shoot or import labels, place bottles in a row/bin grid, chat drinking windows and pairings on an aging timeline, annotate rack cards, and hear a TTS pull brief — always 非侍酒认证 / not a sommelier certification and 非投资建议 / not investment advice, with 21+ where alcohol advice appears.

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

- app_name: CellarCue
- product_dir: cellarcue/ (symlink → product; deliver as cellarcue not product)
- development_bundle_id: com.lingguang.cellarcue
- ui_language: en-US
- simulator: iPhone 17 Pro only (prefer B14CC0EA); never Pro Max
- palette: primary `#3730A3` · secondary `#EEF2FF` · accent `#EA580C`
- UI species: 酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴
- permissions: Camera / Photos / Microphone / Speech Recognition
- NO AppIcon / LaunchScreen generation
- NOT MixCue / SporeCue / WingCue / FrameCue / RuleCue / StopCue twins
- Do NOT name Vinocell in App copy
- Hard compliance: every alcohol-advice surface states 非侍酒认证 / not a sommelier certification and 非投资建议 / not investment advice; 21+ on those surfaces; never claim certified tasting or guaranteed investment returns

## Deviations

- Operator paid / one-time unlock intent **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`.
- Feishu CONTROLLER_DELIVERY skip per operator.
- Option A soft `known_issues` for non-core UL fails; P1 UNKNOWN gaps must not block delivery.
- Deliver target: `git@github.com:xy-gty/xy-gty.git` independent branch (Builder/Delivery).

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| cellarcue-home-empty | frames/cellarcue-home-empty-r1.png | ok | pass | done |
| cellarcue-capture-camera | frames/cellarcue-capture-camera-r1.png | ok | pass | done |
| cellarcue-label-ocr | frames/cellarcue-label-ocr-r1.png | ok | pass | done |
| cellarcue-window-chat | frames/cellarcue-window-chat-r1.png | ok | pass | done |
| cellarcue-rack-card | frames/cellarcue-rack-card-r2.png | ok | pass | done |
| cellarcue-voice-pull | frames/cellarcue-voice-pull-r1.png | ok | pass | done |
| cellarcue-consent-ai | frames/cellarcue-consent-ai-r1.png | ok | pass | done |
| cellarcue-settings-privacy | frames/cellarcue-settings-privacy-r1.png | ok | pass | done |

- Batch: evidence/image-batch-r1.result.json (+ r2 subset for rack-card); GrokBot local_seed; Cursor GenerateImage seeds
- visual_manifest.v1.json frozen sha256 d1deb007e4d4fbe223dd1b426b3ec2a150d8c85c9c781fea812e7f7c07504497
- visual_contract_schema: appfactory.ai_ultra_lite_visuals.v1
- 8/8 design readbacks allow freeze; rack-card revised to r2 for Keep/Edit controls
- No independent assets declared this attempt (frame-embedded only)

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created (expected under local_only)
- operator_pricing_deferred_free_app_only

## Evidence index

- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-batch-r2-subset.json / image-batch-r2-subset.result.json
- evidence/image-generator-audit.jsonl
- evidence/visual-readback/*.receipt.json (+ matching *.receipt.jsonl)
- evidence/criteria/*
- technical_contract.v1.json / technical_contract.binding.v1.json
