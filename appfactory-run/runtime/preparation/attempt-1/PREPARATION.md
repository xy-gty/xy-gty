# CuePartner AI — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: f6ceb2d1-7ab9-407b-b8f3-aadfb0e1e74b  
producer_pm_attempt: 1  
technical_contract_sha256: 9cb9f54b37cdeb602be56fafdcba1dde4e963ad5cc2dc289efcb5abd4643aa2f

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, or formal stage MAP edits.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/CuePartnerDomain/Entities.swift — Scene, ScriptPage, CueLine, PartnerTurn, RehearsalMessage, VoiceNote, AmbiencePreset, AIConsentRecord
- Sources/CuePartnerDomain/Navigation.swift — frozen navigation destinations
- Sources/CuePartnerDomain/ReviewControls.swift — OCRReviewBar / TurnReview / AIConsentContract / interface + privacy literals
- Sources/CuePartnerDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator pricing deferred
- consent disclosure_version: cuepartner.consent.v1; provider DeepSeek
