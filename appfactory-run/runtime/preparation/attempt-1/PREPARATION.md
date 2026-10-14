# ScoutCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: 58186148-d41e-42fb-b0d9-dddd8f2a8704  
producer_pm_attempt: 1  
technical_contract_sha256: d3e76b0d232df6307e64e68865cfecf4d83f0a5cc8687d954fdb93efbcd2d801

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
- Sources/ScoutCueDomain/Entities.swift — ScoutShot, SceneCard, ScoutPlan, TimingWindow, OverlayMark, CoachMessage, CoachTurn, ShootNote, BriefingClip, AIConsentRecord
- Sources/ScoutCueDomain/Navigation.swift — frozen navigation destinations
- Sources/ScoutCueDomain/ReviewControls.swift — SceneReviewBar / TurnReview / AIConsentContract / interface + privacy literals
- Sources/ScoutCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator pricing deferred
- consent disclosure_version: scoutcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.scoutcue
