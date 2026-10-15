# StopCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: 016ece23-5fb2-4f65-b39e-f67191d8d894  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: 6aa7ee6083e7746fa2f67056aa5b47073685641d760c2172930253bdab5e5dd7  
pm_visual_manifest_sha256: a7635daf9f37726329ff1b54e5ea627d634a7f16e8550568c23b0df1b1593d9a  
preparation_seal_sha256: 948371bf4d2fd99e1552eed896ee0bab351572f09fc474338e97cc06edf58a65  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/product`
- identity product_dir: `stopcue` (`stopcue` → `product` symlink)
- branch: `stopcue/kf-20261015T093242Z-0f4256a0` (independent branch pushed to xy-gty)
- commit: `8ff7e72ef3525166bbb448c398b3be0b23430dee`
- bundle_id: `com.lingguang.stopcue`
- remote: `git@github.com:xy-gty/xy-gty.git`
- push: succeeded → `origin/stopcue/kf-20261015T093242Z-0f4256a0` (evidence/git-push.log)
- palette: `#16A34A` / `#F0FDF4` / `#DB2777` (≠ NightCue `#1E3A8A`)
- unique UI: FilmSprocketTimeline + OnionSkinOverlayCanvas (≠ NightCue/CuePartner/HiveCue/FormCue/YarnCue/ScoutCue twins)
- AppIcon/LaunchScreen: not generated this round (operator hard; empty AppIcon set stub only)
- Feishu CONTROLLER_DELIVERY: skip (operator)
- free_app_only: no StoreKit / paywall / coins / ATT

## Foundation / preparation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` local SwiftPM dependency; production calls `AtomicCodableStore`, `KeychainCredentialStore`, `AIConsentGate`, `TypedNavigationStore`; camera via `UIImagePickerController`, photos via `PhotosPicker`
- Domain package `StopCueDomain` from seal (entities/navigation/stores/review controls)

## Build / tests / smoke

- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` only; never Pro Max `315A7C2C` (left Booted untouched; no shutdown)
- DerivedData: attempt-local path only (did not touch BendCoach or other apps' DerivedData); cleared unused ModuleCache for disk
- Build: **BUILD SUCCEEDED** (`build.log`)
- Domain tests: **9/9 TEST SUCCEEDED** (`StopCueDomainTests`, `domain.log`)
- Smoke: install + launch pid 11966 + screenshot `smoke.png` / `evidence/smoke-home.png`
- Candidate: `candidate_unaccepted` `8ff7e72ef352-83d81be924fa` → `artifacts/candidates/…/receipt.json` sha256 `072d1af4995e2643f2f6bde10b3a014b08b1832a0e05c95a6e132ef9782f089b`
- Config audit: `feishu_row_not_yet_created` gap (blocker=false); stdout persisted

## Frame → page / component

| frame_id | page / component | runtime smoke |
|----------|------------------|---------------|
| stopcue-home-empty | ProjectsHomeView + FilmSprocketTimeline placeholder | smoke.png (core smoke) |
| stopcue-capture-import | CaptureImportView (Camera / PhotosPicker) | pending independent accept |
| stopcue-frame-review | FrameReviewView Keep/Discard/Edit | pending independent accept |
| stopcue-stop-coach | StopCoachView (sprocket timeline + onion overlay) | pending independent accept |
| stopcue-coach-chat | CoachChatView + ConsentSheet | pending independent accept |
| stopcue-onion-overlay | OnionSkinGuideView + OnionSkinOverlayCanvas | pending independent accept |
| stopcue-tts-countdown | CountdownTTSView + CountdownCueTTSPlayer | pending independent accept |
| stopcue-settings-privacy | SettingsPrivacyView + LocalLegalWebView | pending independent accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| ProjectsHome | App/UI/ProjectsHomeView.swift#ProjectsHomeView |
| NewProject | App/UI/ProjectsHomeView.swift#NewProjectView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| FrameReview | App/UI/FrameReviewView.swift#FrameReviewView |
| StopCoach | App/UI/StopCoachView.swift#StopCoachView |
| CoachChat | App/UI/CoachChatView.swift#CoachChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| OnionSkinGuide | App/UI/OnionSkinGuideView.swift#OnionSkinGuideView |
| CountdownTTS | App/UI/CountdownTTSView.swift#CountdownTTSView |
| DictateInterval | App/UI/DictateIntervalView.swift#DictateIntervalView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LocalLegalWebView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| FilmSprocketTimeline | App/UI/FilmSprocketTimeline.swift#FilmSprocketTimeline |
| OnionSkinOverlayCanvas | App/UI/OnionSkinOverlayCanvas.swift#OnionSkinOverlayCanvas |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |
| AIConsentGate wiring | Sources/StopCueDomain/ReviewControls.swift#AIConsentContract |

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

- ultra_lite_timing spans: implementation, integration_build, domain_tests, runtime_smoke
- native_children.v1.json: child_slots=0 (single-slot serial on factory-prod-1)

## SwiftUI references used

- skills/swiftui-expert-skill/SKILL.md (state ownership, navigation stack, accessibility identifiers on timeline/onion canvas)

## lessons_candidates

- Cursor preparation consume is `bin/cursor-package ultra-lite preparation consume` (Codex module forbidden on cursor runtime).
- Prefer full UDID `B14CC0EA-EA96-…` for iPhone 17 Pro; never occupy/shutdown Pro Max `315A7C2C`.
