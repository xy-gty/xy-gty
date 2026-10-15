# HiveCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: 2ff7d96e-89a1-42ef-b833-a0449076ac38  
producer_pm_attempt: 1  
technical_contract_sha256: 5bda6a4efb122c94a7fcd682191fc44da554b26267bb7948618b47e67403a167

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, AppIcon/Launch assets, or formal stage MAP edits. Target device: iPhone 17 Pro only (Pro Max banned). Four privacy capabilities wired as literals only. Delivery product_dir: hivecue/; independent branch hint: xy-gty.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/HiveCueDomain/Entities.swift — Inspection, FrameShot, BroodDraft, Finding, AnnotatedOverlay, CoachTurn, CoachMessage, VoiceNote, DictatedField, AIConsentRecord
- Sources/HiveCueDomain/Navigation.swift — frozen navigation destinations
- Sources/HiveCueDomain/ReviewControls.swift — BroodReviewBar / TurnReview / AIConsentContract / interface + privacy literals + palette (#9F1239/#FDF2F8/#4D7C0F) + HexCombGrid/InspectionRail/HeatOverlayCanvas names
- Sources/HiveCueDomain/Stores.swift — AtomicCodableStore key names + Keychain service/account helpers
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals (hex comb grid + inspection rail + heat overlay)
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; operator one-time unlock / apiary packs deferred
- consent disclosure_version: hivecue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.hivecue; product_dir: hivecue/
