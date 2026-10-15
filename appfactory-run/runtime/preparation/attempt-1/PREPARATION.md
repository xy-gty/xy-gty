# RuleCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: af993f1f-effd-446a-9260-73fb080fbbd8  
producer_pm_attempt: 1  
technical_contract_sha256: c66fef8e4c822efd842ef91b6009b49826b7a9f871f3e6e9f6acb096fe8185c7

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/Launch assets, or formal stage MAP edits. Target device: iPhone 17 Pro only prefer B14CC0EA (Pro Max banned). Four privacy capabilities wired as literals only. Delivery product_dir: rulecue/ (symlink rulecue→product; never product/ only); deliver git@github.com:xy-gty/xy-gty.git independent branch; Feishu CONTROLLER_DELIVERY skip; Option A soft known_issues; no coins; Ultra-lite p1 factory-prod-1 single-slot.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/RuleCueDomain/Entities.swift — GameSession, TablePhoto, ComponentDraft, ComponentMap, PhaseStep, SetupOverlay, CoachTurn, CoachMessage, HostCue, SpokenQuestion, AIConsentRecord
- Sources/RuleCueDomain/Navigation.swift — frozen navigation destinations
- Sources/RuleCueDomain/ReviewControls.swift — ComponentReviewBar / TurnReview / AIConsentContract / interface + privacy literals + palette (#854D0E/#FEFCE8/#0891B2) + TableZoneCards/TurnStepBar names; allergy StopCue film-sprocket / NightCue night-frame / HiveCue/FormCue/YarnCue/ScoutCue
- Sources/RuleCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (table zone cards + turn step bar)
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; no StoreKit/paywall/coins/ATT
- consent disclosure_version: rulecue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.rulecue; product_dir: rulecue/
