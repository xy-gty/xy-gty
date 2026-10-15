# NightCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: e3a9a1f0-67fa-481b-bc39-ed862af058af  
producer_pm_attempt: 1  
technical_contract_sha256: 72c5bea905cf48b0f721c2bceb6834b467d0108e2f088c97d597840b21a771dd

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/Launch assets, or formal stage MAP edits. Target device: iPhone 17 Pro only prefer B14CC0EA (Pro Max banned). Four privacy capabilities wired as literals only. Delivery product_dir: nightcue/ (symlink nightcue→product; never product/ only); deliver git@github.com:xy-gty/xy-gty.git; Feishu skip.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/NightCueDomain/Entities.swift — Session, NightFrame, ExposureDraft, DiagnosisFinding, AnnotatedOverlay, CoachTurn, CoachMessage, FieldCue, DictatedExposure, AIConsentRecord
- Sources/NightCueDomain/Navigation.swift — frozen navigation destinations
- Sources/NightCueDomain/ReviewControls.swift — ExposureReviewBar / TurnReview / AIConsentContract / interface + privacy literals + palette (#1E3A8A/#EFF6FF/#FBBF24) + NightFrameRail/ExposureDiagnosisOverlayCanvas names; allergy HiveCue/FormCue/YarnCue/ScoutCue
- Sources/NightCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (night-frame rail + exposure-diagnosis overlays)
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator one-time unlock / night packs deferred
- consent disclosure_version: nightcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.nightcue; product_dir: nightcue/
