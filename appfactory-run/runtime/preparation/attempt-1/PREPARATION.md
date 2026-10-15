# FrameCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: ee20184e-0bfe-4a4b-b4cd-2fbbff2b211d  
producer_pm_attempt: 1  
technical_contract_sha256: 3bd8adb2a16343fa320ed77ae22ca4f28be2e84ca52888d949f52528126826fd

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/Launch assets, or formal stage MAP edits. Target device: iPhone 17 Pro only prefer B14CC0EA (Pro Max banned). Four privacy capabilities wired as literals only (Camera/Photos/Mic/Speech). Delivery product_dir: framecue/ (symlink framecue→product; never product/ only); Feishu CONTROLLER_DELIVERY skip; Option A soft known_issues; no coins; Ultra-lite p1 factory-prod-1 single-slot. NOT RuleCue/StopCue/NightCue twins.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/FrameCueDomain/Entities.swift — FramingSession, FrameStill, CompositionDraft, CompositionNote, ShotSizePlan, AspectOverlay, CoachTurn, CoachMessage, VoiceIntent, AIConsentRecord
- Sources/FrameCueDomain/Navigation.swift — frozen navigation destinations
- Sources/FrameCueDomain/ReviewControls.swift — CompositionReviewBar / TurnReview / OverlayEditor / AIConsentContract / interface + privacy literals + palette (#7E22CE/#FAF5FF/#F59E0B) + ClapperFrameCanvas/ShotSizeChipBar names; allergy RuleCue table-zone / StopCue film-sprocket / NightCue night-frame
- Sources/FrameCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (clapper frame canvas + bottom shot-size chip bar)
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; no StoreKit/paywall/coins/ATT
- consent disclosure_version: framecue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.framecue; product_dir: framecue/
- NO AppIcon/LaunchScreen this round
