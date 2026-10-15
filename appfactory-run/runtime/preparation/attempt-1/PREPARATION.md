# StopCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: b20a1a38-710a-43db-806a-3b531834098a  
producer_pm_attempt: 1  
technical_contract_sha256: 6aa7ee6083e7746fa2f67056aa5b47073685641d760c2172930253bdab5e5dd7

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/Launch assets, or formal stage MAP edits. Target device: iPhone 17 Pro only prefer B14CC0EA (Pro Max banned). Four privacy capabilities wired as literals only. Delivery product_dir: stopcue/ (symlink stopcue→product; never product/ only); deliver git@github.com:xy-gty/xy-gty.git; Feishu CONTROLLER_DELIVERY skip.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/StopCueDomain/Entities.swift — Project, FrameSequence, ShotPlanDraft, TimingCue, OnionSkinGuide, CoachTurn, CoachMessage, CountdownCue, DictatedInterval, AIConsentRecord
- Sources/StopCueDomain/Navigation.swift — frozen navigation destinations
- Sources/StopCueDomain/ReviewControls.swift — FrameReviewBar / TurnReview / AIConsentContract / interface + privacy literals + palette (#16A34A/#F0FDF4/#DB2777) + FilmSprocketTimeline/OnionSkinOverlayCanvas names; allergy NightCue/CuePartner/HiveCue/FormCue/YarnCue/ScoutCue
- Sources/StopCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (film-sprocket timeline + onion-skin overlay preview)
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator one-time unlock / unlimited projects deferred
- consent disclosure_version: stopcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.stopcue; product_dir: stopcue/
