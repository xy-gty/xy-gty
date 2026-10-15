# MixCue — private engineering preparation

Status: ready

task_kind: ultra_lite_preparation  
dispatch_id: c62f28ea-0f50-4415-96b3-4d6e21f1cd34  
producer_pm_attempt: 1  
technical_contract_sha256: a6a5c05c1334f671c59c636a25afe98e5c227a09bda4cd85692dcaed703fd7ac

## Scope

Shared domain/interfaces/storage scaffolding only. No product UI, Simulator, or formal stage MAP edits. Match frozen MixCue entities, interfaces, and navigation. No AppIcon/LaunchScreen; no Cocktail Party/Bevnap copy; not WingCue/FrameCue/RuleCue/StopCue/ClosetCue/ScoutCue twins.

## Foundation

- Installed via `python3 -m factory.ultra_lite_foundation install --product-root workspace`
- `workspace/Vendor/AppRuntimeCore` integrity checked by finish helper
- preparation_cache ensure: cache hit (`1225d7e5c639ba857c29161baa51ebbdb27dad675c6d2207c8000e813e3a8e8f`); shared baseline not recompiled
- Domain package compile scratch left outside workspace inventory (`domain-build-scratch/`)
- host-compile artifacts left outside workspace inventory (`host-compile/`)

## Source inventory (workspace/)

- Package.swift — SwiftPM package depending on local AppRuntimeCore
- Sources/MixCueDomain/Entities.swift — MixSession, SpiritCandidate, PourStep, GarnishChip, RecipeCard, CoachTurn, VoiceNote, AIConsentRecord, AppSettings, MixCueState
- Sources/MixCueDomain/Navigation.swift — frozen MixCueRoute + TypedNavigationStore helper
- Sources/MixCueDomain/ReviewControls.swift — MixReviewControls / AIConsentContract / interface + privacy literals / palette + UI species
- Sources/MixCueDomain/Stores.swift — AtomicCodableStore MixCueState + Keychain service mixcue.ai
- Vendor/AppRuntimeCore/** — public foundation library

## Notes

- UI design deferred to Builder after final visuals
- privacy/terms/support/ai_key/cloudkit remain UNKNOWN gaps from technical contract
- free_app_only; no StoreKit / paywall / coins / ATT
- consent disclosure_version: mixcue.consent.v1; provider DeepSeek
- development_bundle_id: com.lingguang.mixcue
- product_dir: mixcue; simulator_pref_udid: B14CC0EA (iPhone 17 Pro only)
- palette #E11D48 / #FFF1F2 / #CA8A04; UI species vertical bottle-rail + large next-pour card + garnish chip row
- four permissions: Camera / Photos / Microphone / Speech Recognition
