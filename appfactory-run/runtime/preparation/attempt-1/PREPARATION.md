# CellarCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: 91d6163e-c9b2-45ff-b216-14d36e07a45e  
producer_pm_attempt: 1  
technical_contract_sha256: 5b0e7e1cf2ab96ca937e5fe9661287dbdb46203ee0a885a281a14e8ec8097400

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/LaunchScreen, or formal stage MAP edits. Match frozen CellarCue entities, interfaces, and navigation. Compliance disclaimer literals included; never claim sommelier certification or investment advice; 21+ on alcohol advice surfaces. NOT MixCue/SporeCue/WingCue/FrameCue/RuleCue/StopCue twins; do not name Vinocell in App copy.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/CellarCueDomain/Entities.swift — CellarRack, CellarBin, BottleEntry, LabelOCRResult, DrinkingWindow, PairingNote, RackCardAnnotation, CoachTurn, PullBrief, VoiceNote, AIConsentRecord, AppSettings, CellarCueState
- Sources/CellarCueDomain/Navigation.swift — frozen CellarCueRoute + TypedNavigationStore helper
- Sources/CellarCueDomain/ReviewControls.swift — CellarReviewControls / CellarCueCompliance / AIConsentContract / interface + privacy literals / palette + UI species
- Sources/CellarCueDomain/Stores.swift — AtomicCodableStore CellarCueState + Keychain service cellarcue.ai
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (cellar row/bin grid + large label-OCR hero card + drinking-window aging timeline)
- required disclaimers: 非侍酒认证 / not a sommelier certification; 非投资建议 / not investment advice; 21+ where alcohol advice appears
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; no StoreKit / paywall / coins / ATT
- consent disclosure_version: cellarcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.cellarcue
- product_dir: cellarcue/ (symlink cellarcue→product; deliver as cellarcue not product)
- simulator_pref_udid: B14CC0EA (iPhone 17 Pro only; never Pro Max)
- palette #3730A3 / #EEF2FF / #EA580C
- four permissions: Camera / Photos / Microphone / Speech Recognition
- Feishu CONTROLLER_DELIVERY skip; Option A soft known_issues; deliver git@github.com:xy-gty/xy-gty.git independent branch
