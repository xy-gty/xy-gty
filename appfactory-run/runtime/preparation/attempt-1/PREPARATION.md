# PitchCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: 82c33e3d-bfa6-45df-85d7-7a3f66417839  
producer_pm_attempt: 1  
technical_contract_sha256: 025f0d83d669b1d4c31dfabb13d085ddfd42cea01bc13866f511746b2143c782

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, or formal stage MAP edits. Branding assets deferred this round (`branding_assets_deferred`).

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/PitchCueDomain/Entities.swift — PracticeSession, SheetPhoto, PracticePlan, CoachTurn, AudioBed, PitchSample, AIConsentRecord
- Sources/PitchCueDomain/Navigation.swift — frozen navigation destinations
- Sources/PitchCueDomain/ReviewControls.swift — CoachingReviewBar / AIConsentContract / interface + privacy literals
- Sources/PitchCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator pricing deferred
- consent disclosure_version: pitchcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.pitchcue
