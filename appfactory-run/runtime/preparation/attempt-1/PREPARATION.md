# YarnCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: 975b28b7-fc0f-4b3f-b25d-8010265d2baa  
producer_pm_attempt: 1  
technical_contract_sha256: f053d2ed94177b694d55ab0f4804c9d10fab8634d08141f95a8469f50fd6fa0f

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, or formal stage MAP edits. Branding assets deferred this round (`branding_assets_deferred` per technical contract).

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/YarnCueDomain/Entities.swift — Project, WIPShot, StitchRecognitionDraft, StitchCue, AnnotatedOverlay, CoachTurn, CoachMessage, PatternNote, AIConsentRecord
- Sources/YarnCueDomain/Navigation.swift — frozen navigation destinations
- Sources/YarnCueDomain/ReviewControls.swift — StitchReviewBar / TurnReview / AIConsentContract / interface + privacy literals
- Sources/YarnCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator pricing deferred
- consent disclosure_version: yarncue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.yarncue
