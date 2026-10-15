# WingCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: a3d63b86-182d-4aff-8850-f3c19ff78dfa  
producer_pm_attempt: 1  
technical_contract_sha256: d0f1491a21ac0e032bbaeac9f646a5ae92bd9ae082cfb064fe62fa8a21423c17

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/LaunchScreen assets, or formal stage MAP edits. Target device: iPhone 17 Pro only prefer B14CC0EA (Pro Max banned). Four privacy capabilities wired as literals only (Camera/Photos/Mic/Speech). Delivery product_dir: wingcue/ (symlink wingcue→product); Feishu CONTROLLER_DELIVERY skip; Option A soft known_issues. NOT ClosetCue/FrameCue/ScoutCue/RuleCue/StopCue twins.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/WingCueDomain/Entities.swift — IDSession, SpeciesCandidate, FieldMark, LookalikePair, CoachTurn, AnnotatedOverlay, VoiceNote, AIConsentRecord, AppSettings, WingCueState
- Sources/WingCueDomain/Navigation.swift — frozen WingCueRoute + TypedNavigationStore alias
- Sources/WingCueDomain/Stores.swift — SightingStore / AtomicCodableStore keys + Keychain service wingcue.ai
- Sources/WingCueDomain/Interfaces.swift — interface literals, review controls, consent contract, palette (#0F766E/#F0FDFA/#C2410C), UI species field-card stack + oversized chips + silhouette bar, allergy twins
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (field-card 叠层 + 超大鉴别特征 chips + 剪影对比条)
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; no StoreKit / paywall / coins / ATT
- consent disclosure_version: wingcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.wingcue; product_dir: wingcue/
