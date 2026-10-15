# NightCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: e7b2b568-4833-4d29-a7f3-fd5a337fcd0a  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: 72c5bea905cf48b0f721c2bceb6834b467d0108e2f088c97d597840b21a771dd  
pm_visual_manifest_sha256: 1a4dadba3e29ffddbae1a77fc341df3ac1b5580d4e0bfd14f4e27686815248f0  
preparation_seal_sha256: c7adb9d63225bafeaa070ff628b265cdfa00c7cc83747088a5b17f2e7f2d160d  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T075333Z-d3a0d226/product`
- identity product_dir: `nightcue` (`nightcue` → `product` symlink)
- branch: `nightcue/kf-20261015T075333Z` (independent branch pushed to xy-gty)
- commit: `17f64efd1d5a8389cd47b0ebb1206304a07b49a0`
- bundle_id: `com.lingguang.nightcue`
- remote: `git@github.com:xy-gty/xy-gty.git`
- push: succeeded → `origin/nightcue/kf-20261015T075333Z` (evidence/git-push.log)
- palette: `#1E3A8A` / `#EFF6FF` / `#FBBF24`
- unique UI: NightFrameRail + ExposureDiagnosisOverlayCanvas (≠ HiveCue/FormCue/YarnCue twins; ≠ ScoutCue)
- AppIcon/LaunchScreen: not generated this round (operator hard; empty AppIcon set stub only for actool)
- Feishu CONTROLLER_DELIVERY: skip (operator)
- free_app_only: no StoreKit / paywall / coins / ATT

## Foundation / preparation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` local SwiftPM dependency; production calls `AtomicCodableStore`, `KeychainCredentialStore`, `AIConsentGate`, `TypedNavigationStore`, `PhotoImportSession` (import path via PhotosPicker + CameraPicker)
- Domain package `NightCueDomain` from seal (entities/navigation/stores/review controls)

## Build / tests / smoke

- Simulator lease: iPhone 17 Pro `8843C141-E2FE-4DEA-A58F-0A63A5C649EF` (preferred prefix `B14CC0EA` alone → `udid_not_available:not_listed`; full preferred `B14CC0EA-EA96-…` was Booted by another run; never Pro Max `315A7C2C`)
- Build: **BUILD SUCCEEDED** (`build.log`)
- Domain tests: **9/9 TEST SUCCEEDED** (`NightCueDomainTests`, `domain.log`)
- Smoke: install + launch pid 60640 + screenshot `smoke.png` / `evidence/smoke-home.png`
- Candidate: `candidate_unaccepted` `17f64efd1d5a-9c657b80f631` → `artifacts/candidates/…/receipt.json` sha256 `313048479cd0f2dced39a6355a3b606b83893474d06fc10fbdad7ba16784c1e5`
- Config audit: `feishu_row_not_yet_created` gap (blocker=false); stdout persisted

## Frame → page / component

| frame_id | page / component | runtime smoke |
|----------|------------------|---------------|
| nightcue-home-empty | SessionsHomeView + NightFrameRail placeholder | smoke-home.png (core smoke) |
| nightcue-capture-import | CaptureImportView (Camera / PhotosPicker) | pending independent accept |
| nightcue-exposure-review | ExposureReviewView + draft overlays | pending independent accept |
| nightcue-night-coach | NightCoachView (rail + overlays toggle) | pending independent accept |
| nightcue-coach-chat | CoachChatView + ConsentSheet | pending independent accept |
| nightcue-annotated-overlay | AnnotatedOverlayView | pending independent accept |
| nightcue-field-tts | FieldCueTTSView + FieldCueTTSPlayer | pending independent accept |
| nightcue-settings-privacy | SettingsPrivacyView + LocalLegalWebView | pending independent accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| SessionsHome | App/UI/SessionsHomeView.swift#SessionsHomeView |
| NewSession | App/UI/SessionsHomeView.swift#NewSessionView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| ExposureReview | App/UI/ExposureReviewView.swift#ExposureReviewView |
| NightCoach | App/UI/NightCoachView.swift#NightCoachView |
| CoachChat | App/UI/CoachChatView.swift#CoachChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| AnnotatedOverlay | App/UI/AnnotatedOverlayView.swift#AnnotatedOverlayView |
| FieldCueTTS | App/UI/FieldCueTTSView.swift#FieldCueTTSView |
| DictateExposure | App/UI/DictateExposureView.swift#DictateExposureView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LocalLegalWebView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| NightFrameRail | App/UI/NightFrameRail.swift#NightFrameRail |
| ExposureDiagnosisOverlayCanvas | App/UI/ExposureDiagnosisOverlay.swift#ExposureDiagnosisOverlayCanvas |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |
| AIConsentGate wiring | Sources/NightCueDomain/ReviewControls.swift#AIConsentContract |

## Gaps (Option A soft known_issues — non-blocking)

- G1 privacy_url / terms_url / support_url: UNKNOWN (local_only; local HTML loads)
- G2 ai_key: UNKNOWN — outbound DeepSeek disabled until key; local diagnosis/coach tips honest
- G3 cloudkit: UNKNOWN
- G4 feishu_row_not_yet_created (CONTROLLER_DELIVERY skip)
- G5 operator_pricing_deferred_free_app_only
- G6 branding_assets_deferred (no AppIcon/LaunchScreen)
- G7 camera/mic/speech hardware: 真机待测; Simulator exercises entry points
- G8 code_query_blocked:codebase_memory_index_failed (codebase-memory-mcp missing) — built from seal + PM docs

## instrumentation

- ultra_lite_timing spans: implementation, integration_build, domain_tests, runtime_smoke
- native_children.v1.json: child_slots=0 (single-slot serial)

## SwiftUI references used

- skills/swiftui-expert-skill/SKILL.md (state ownership, navigation stack, accessibility identifiers on rail/overlays)

## lessons_candidates

- Preferred simulator UDID must be full UUID (`B14CC0EA-EA96-…`); short prefix fails `udid_not_available:not_listed`.
- Cursor preparation consume is `bin/cursor-package ultra-lite preparation consume` (Codex module forbidden on cursor runtime).
