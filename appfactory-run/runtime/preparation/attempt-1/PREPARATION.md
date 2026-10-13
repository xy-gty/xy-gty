# SnagCue AI — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: 839fca32-c885-4769-b798-751bc0dad9ff  
producer_pm_attempt: 1  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, or formal stage MAP edits.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/SnagCueDomain/Entities.swift — Audit, WalkthroughPhoto, SnagDraft, PunchItem, ReportDraft, AIConsentRecord, CoachSession
- Sources/SnagCueDomain/Navigation.swift — frozen navigation destinations
- Sources/SnagCueDomain/ReviewControls.swift — SnagReviewBar / PunchFieldReview / AnnotatedReportPreview + AI consent + ChecklistTTS literals
- Sources/SnagCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator pricing deferred
