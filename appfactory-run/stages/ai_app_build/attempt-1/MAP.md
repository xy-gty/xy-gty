# FrameCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: 5660f5a2-98ef-470d-871d-95da1789aa7e  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: 3bd8adb2a16343fa320ed77ae22ca4f28be2e84ca52888d949f52528126826fd  
pm_visual_manifest_sha256: 131f8b751bcc346c32c68d2adb21acede76a733a0f3320480c5768ac22b83b6a  
preparation_seal_sha256: 36b394f70759bb905c84c83c477b73da554195fe4c721af6717d559f72204862  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T123049Z-789bf0d3/product`
- identity product_dir: `framecue` (`framecue` → `product` symlink)
- branch: `framecue/kf-20261015T123049Z-789bf0d3` (independent branch pushed to xy-gty)
- push: succeeded → `origin/framecue/kf-20261015T123049Z-789bf0d3` (evidence/git-push.log)
- commit: `bd7bee1829677f58b05a55979d37eb5749bcb0a8`
- bundle_id: `com.lingguang.framecue`
- remote target: `git@github.com:xy-gty/xy-gty.git`
- palette: `#7E22CE` / `#FAF5FF` / `#F59E0B` (≠ RuleCue `#854D0E/#FEFCE8/#0891B2`, StopCue `#16A34A/#F0FDF4/#DB2777`, NightCue `#1E3A8A`)
- unique UI: ClapperFrameCanvas + ShotSizeChipBar (≠ RuleCue table zone cards + turn step bar / StopCue film-sprocket / NightCue night-frame rail)
- AppIcon/LaunchScreen: not generated this round (operator hard; empty AppIcon set stub only)
- Feishu CONTROLLER_DELIVERY: skip (operator)
- free_app_only: no StoreKit / paywall / coins / ATT

## Foundation / preparation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` local SwiftPM dependency; production calls `AtomicCodableStore`, `KeychainCredentialStore`, `AIConsentGate`, `TypedNavigationStore`, `RuntimeForm`; camera via `UIImagePickerController`, photos via `PhotosPicker`
- Domain package `FrameCueDomain` from seal (entities/navigation/stores/review controls)
- Foundation check: AppRuntimeCore 1.0.0 members match bound hashes

## Build / tests / smoke

- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` only; NEVER Pro Max
- DerivedData: attempt-local `stages/ai_app_build/attempt-1/DerivedData`
- Build: **BUILD SUCCEEDED** (`build.log`)
- Domain tests: **10/10 TEST SUCCEEDED** (`FrameCueDomainTests`, `domain.log`)
- Smoke: install + launch pid 90992 + screenshot `smoke.png`
- Candidate: `candidate_unaccepted` `bd7bee182967-a496f933457c` → `artifacts/candidates/bd7bee182967-a496f933457c/receipt.json` sha256 `c4efeaf406b60089e21ac56b55f64945f1c401a881b8856df03a444f3af59ac0`
- Config audit: `feishu_row_not_yet_created` gap (blocker=false); `ai_key_unavailable` gap; stdout persisted

## Frame → page / component

| frame_id | page / component | runtime smoke |
|----------|------------------|---------------|
| framecue-home-empty | SessionsHomeView + ClapperFrameCanvas + ShotSizeChipBar hint | smoke.png (core smoke) |
| framecue-capture-import | CaptureImportView (Camera / PhotosPicker) | pending independent accept |
| framecue-composition-review | CompositionReviewView Keep/Discard/Edit | pending independent accept |
| framecue-slate-stage | SlateStageView (ClapperFrameCanvas + ShotSizeChipBar) | pending independent accept |
| framecue-coach-chat | CoachChatView + ConsentSheet + RuntimeForm | pending independent accept |
| framecue-overlay-marks | OverlayMarksView safe-frame / thirds | pending independent accept |
| framecue-hands-free-tts | HandsFreeTTSView + HandsFreeTTSPlayer | pending independent accept |
| framecue-settings-privacy | SettingsPrivacyView + LocalLegalWebView | pending independent accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| SessionsHome | App/UI/SessionsHomeView.swift#SessionsHomeView |
| NewSession | App/UI/NewSessionView.swift#NewSessionView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| CompositionReview | App/UI/CompositionReviewView.swift#CompositionReviewView |
| SlateStage | App/UI/SlateStageView.swift#SlateStageView |
| CoachChat | App/UI/CoachChatView.swift#CoachChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| OverlayMarks | App/UI/OverlayMarksView.swift#OverlayMarksView |
| HandsFreeTTS | App/UI/HandsFreeTTSView.swift#HandsFreeTTSView |
| DictateShot | App/UI/DictateShotView.swift#DictateShotView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LegalPageView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| ClapperFrameCanvas | App/UI/FrameCueTheme.swift#ClapperFrameCanvas |
| ShotSizeChipBar | App/UI/FrameCueTheme.swift#ShotSizeChipBar |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |
| AIConsentGate wiring | Sources/FrameCueDomain/ReviewControls.swift#AIConsentContract |

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

- native_children: child_slots=0 (solo Builder; no ultra-lite-worker spawn)
- ultra_lite_timing spans: implementation, integration_build, domain_tests, runtime_smoke
- foundation call sites: AppModel stores/consent/navigation; CoachChatView RuntimeForm; DeepSeekClient behind AIConsentGate.permit

## SwiftUI references used

- skills/swiftui-expert-skill/SKILL.md (state ownership, NavigationStack, accessibility identifiers on clapper canvas / shot chips)

## lessons_candidates

- Cursor preparation consume is `bin/cursor-package ultra-lite preparation consume` (Codex module forbidden on cursor runtime).
- Prefer full UDID `B14CC0EA-EA96-…` for iPhone 17 Pro; never occupy/shutdown Pro Max.
- FrameCue anti-twin: clapper slate + bottom shot chips must not reuse RuleCue zone cards / step bar chrome.
