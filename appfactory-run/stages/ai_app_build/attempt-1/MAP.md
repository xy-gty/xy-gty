# RuleCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: 6c42a648-0d63-44ac-8db4-c04fd78eda6d  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: c66fef8e4c822efd842ef91b6009b49826b7a9f871f3e6e9f6acb096fe8185c7  
pm_visual_manifest_sha256: 803064a4db0d8bdaf7bd875cbd21bbcf0a8834a75676d4550391c6576d5da900  
preparation_seal_sha256: 795b7a8c42eb4c775c63c6cacc922f1ff422668805ba66e982223c7e457c64fa  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/product`
- identity product_dir: `rulecue` (`rulecue` → `product` symlink)
- branch: `rulecue/kf-20261015T111031Z-ed6f1861` (independent branch pushed to xy-gty)
- commit: `0ca4a31f94354b3456e1aa739e92496e5fbfb2bb`
- bundle_id: `com.lingguang.rulecue`
- remote: `git@github.com:xy-gty/xy-gty.git`
- push: succeeded → `origin/rulecue/kf-20261015T111031Z-ed6f1861` (evidence/git-push.log)
- palette: `#854D0E` / `#FEFCE8` / `#0891B2` (≠ StopCue `#16A34A/#F0FDF4/#DB2777`, NightCue `#1E3A8A`)
- unique UI: TableZoneCards + TurnStepBar (≠ StopCue film-sprocket / NightCue night-frame / HiveCue/FormCue/YarnCue/ScoutCue twins)
- AppIcon/LaunchScreen: not generated this round (operator hard; empty AppIcon set stub only)
- Feishu CONTROLLER_DELIVERY: skip (operator)
- free_app_only: no StoreKit / paywall / coins / ATT

## Foundation / preparation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` local SwiftPM dependency; production calls `AtomicCodableStore`, `KeychainCredentialStore`, `AIConsentGate`, `TypedNavigationStore`, `RuntimeForm`; camera via `UIImagePickerController`, photos via `PhotosPicker`
- Domain package `RuleCueDomain` from seal (entities/navigation/stores/review controls)

## Build / tests / smoke

- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` only; never Pro Max `315A7C2C` (left Booted untouched; no shutdown)
- DerivedData: attempt-local path only
- Build: **BUILD SUCCEEDED** (`build.log` / `build-clean.log`)
- Domain tests: **10/10 TEST SUCCEEDED** (`RuleCueDomainTests`, `domain.log`)
- Smoke: install + launch pid 47120 + screenshot `smoke.png` / `evidence/smoke-home.png`
- Candidate: `candidate_unaccepted` `0ca4a31f9435-9b8b99bc9e24` → `artifacts/candidates/…/receipt.json` sha256 `7bf7d7be14a27f525a3a93e2fcf2f228d4d4cd68f6fbc3a925a5a4bc4424e22e`
- Config audit: `feishu_row_not_yet_created` gap (blocker=false); `ai_key_unavailable` gap; stdout persisted

## Frame → page / component

| frame_id | page / component | runtime smoke |
|----------|------------------|---------------|
| rulecue-home-empty | SessionsHomeView + TableZoneSilhouette | smoke.png (core smoke) |
| rulecue-capture-import | CaptureImportView (Camera / PhotosPicker) | pending independent accept |
| rulecue-component-review | ComponentReviewView Keep/Discard/Edit | pending independent accept |
| rulecue-table-coach | TableCoachView (TableZoneCards + TurnStepBar) | pending independent accept |
| rulecue-coach-chat | CoachChatView + ConsentSheet + RuntimeForm | pending independent accept |
| rulecue-setup-overlay | SetupOverlayView | pending independent accept |
| rulecue-tts-host | HostTTSView + HostCueTTSPlayer | pending independent accept |
| rulecue-settings-privacy | SettingsPrivacyView + LocalLegalWebView | pending independent accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| SessionsHome | App/UI/SessionsHomeView.swift#SessionsHomeView |
| NewSession | App/UI/SessionsHomeView.swift#NewSessionView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| ComponentReview | App/UI/ComponentReviewView.swift#ComponentReviewView |
| TableCoach | App/UI/TableCoachView.swift#TableCoachView |
| CoachChat | App/UI/CoachChatView.swift#CoachChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| SetupOverlay | App/UI/SetupOverlayView.swift#SetupOverlayView |
| HostTTS | App/UI/HostTTSView.swift#HostTTSView |
| DictateRules | App/UI/DictateRulesView.swift#DictateRulesView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LegalPagesView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| TableZoneCards | App/UI/TableZoneCards.swift#TableZoneCards |
| TurnStepBar | App/UI/TurnStepBar.swift#TurnStepBar |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |
| AIConsentGate wiring | Sources/RuleCueDomain/ReviewControls.swift#AIConsentContract |

## Gaps (Option A soft known_issues — non-blocking)

- G1 privacy_url / terms_url / support_url: UNKNOWN (local_only; local HTML loads)
- G2 ai_key: UNKNOWN — outbound DeepSeek disabled until key; local coach tips honest
- G3 cloudkit: UNKNOWN
- G4 feishu_row_not_yet_created (CONTROLLER_DELIVERY skip)
- G5 operator_pricing_deferred_free_app_only
- G6 branding_assets_deferred (no AppIcon/LaunchScreen)
- G7 camera/mic/speech hardware: 真机待测; Simulator exercises entry points
- G8 independent_eight_domain_acceptance_pending

## instrumentation

- native_children.v1.json: child_slots=0 (single-slot serial on factory-prod-1)
- ultra_lite_timing: stage_execution conflict on re-start (prior binding); real build/test/smoke wall-clock recorded in logs

## SwiftUI references used

- skills/swiftui-expert-skill/SKILL.md (state ownership, NavigationStack, accessibility labels on zone cards / step bar)

## lessons_candidates

- Cursor preparation consume is `bin/cursor-package ultra-lite preparation consume` (Codex module forbidden on cursor runtime).
- Prefer full UDID `B14CC0EA-EA96-…` for iPhone 17 Pro; never occupy/shutdown Pro Max `315A7C2C`.
