# SporeCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: b046e141-38ca-49bb-83a1-453a5bc46b91  
producer_pm_attempt: 1  
technical_contract_sha256: cde02f702a052b37ad3f7a1eb8dd16836639377a1b10261f40bfd83c697e5356

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/LaunchScreen, or formal stage MAP edits. Match frozen SporeCue entities, interfaces, and navigation. Compliance disclaimer literals included; never imply safe to eat. NOT MixCue/WingCue/FrameCue/RuleCue/StopCue/ClosetCue/ScoutCue twins; do not name Shroomify/Pilze 123 in App copy.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/SporeCueDomain/Entities.swift — ForageSession, SpeciesCandidate, MorphologyCallout, CautionChip, OverlayAnnotation, CoachTurn, FieldBrief, VoiceNote, AIConsentRecord, AppSettings, SporeCueState
- Sources/SporeCueDomain/Navigation.swift — frozen SporeCueRoute + TypedNavigationStore helper
- Sources/SporeCueDomain/ReviewControls.swift — SporeReviewControls / SporeCueCompliance / AIConsentContract / interface + privacy literals / palette + UI species
- Sources/SporeCueDomain/Stores.swift — AtomicCodableStore SporeCueState + Keychain service sporecue.ai
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (vertical species-confidence stack + oversized gill/pore closeup bar + edible/warning chip rail)
- required disclaimer: 非可食认证 / not an edibility certification
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; no StoreKit / paywall / coins / ATT
- consent disclosure_version: sporecue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.sporecue
- product_dir: sporecue/ (symlink sporecue→product; deliver as sporecue not product)
- simulator_pref_udid: B14CC0EA (iPhone 17 Pro only; never Pro Max)
- palette #9A3412 / #FFF7ED / #0284C7
- four permissions: Camera / Photos / Microphone / Speech Recognition
- Feishu CONTROLLER_DELIVERY skip; Option A soft known_issues; deliver git@github.com:xy-gty/xy-gty.git independent branch
