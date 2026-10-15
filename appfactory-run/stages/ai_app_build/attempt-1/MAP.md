# YarnCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: 543cf837-eed0-4218-bd1f-2d4591f37de4  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: f053d2ed94177b694d55ab0f4804c9d10fab8634d08141f95a8469f50fd6fa0f  
pm_visual_manifest_sha256: 12cf6f34ae151bb7f403ab95cc7f3099bfae39f8e457adcc8afddc38399b4ab5  
preparation_seal_sha256: b214061da27ceb5a12c0745e10b15c3318270d4629f2ab119e2556d40aaa3605  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/product`
- identity product_dir: `yarncue` (delivery naming; factory run folder is `product/`)
- branch: `yarncue/kf-20261014T130415Z` (independent branch for xy-gty delivery)
- commit: `4770b6a8073711e044ddfce4575e49c535768ce1`
- bundle_id: `com.lingguang.yarncue`
- remote: `git@github.com:xy-gty/xy-gty.git` (push deferred to delivery; prefer this independent branch)
- palette: `#A21CAF` / `#FDF4FF` / `#84CC16`
- AppIcon/LaunchScreen: not generated this round (operator hard)

## Foundation / preparation

- Consumed sealed preparation into product (YarnCueDomain + Vendor/AppRuntimeCore)
- `factory.ultra_lite_foundation check` OK (AppRuntimeCore 1.0.0)
- Production calls: `AtomicCodableStore`, `AIConsentGate`, `KeychainCredentialStore`, `TypedNavigationStore`, `RuntimeForm`, `PhotoImportSession` (PhotosPicker path)

## Build / tests / smoke

- Build: `xcodebuild -scheme YarnCue -destination 'generic/platform=iOS Simulator'` → **BUILD SUCCEEDED** (`build.log`)
- Domain tests: `YarnCueDomainTests` on iPhone 17 Pro → **8/8 passed** (`domain.log`)
- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (Pro Max never used)
- Install/launch/smoke screenshot: `install.log` / `launch.log` / `smoke.png`
- Candidate: `artifacts/candidates/4770b6a80737-bc768aee891c/` status `candidate_unaccepted` receipt `d829744193ed099659765b989945b8414b1479b48b1bc0720add943eca5245c4`

## Frame → page mapping

| frame_id | page / component | smoke note |
|----------|------------------|------------|
| home-empty | ProjectsHomeView + YarnBallSwatchStrip | smoke.png home empty; UL-07 deferred |
| capture-import | CaptureImportView (Camera / Photo library) | pending accept |
| stitch-review | StitchReviewView Keep/Discard/Edit | pending accept |
| project-coach | ProjectCoachView + NextRowStepBand | pending accept |
| coach-chat | CoachChatView + ConsentSheet | pending accept |
| annotated-wip | AnnotatedWIPView | pending accept |
| hands-free-tts | HandsFreeTTSView | pending accept |
| settings-privacy | SettingsPrivacyView + local Legal HTML | pending accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| ProjectsHome | App/UI/ProjectsHomeView.swift#ProjectsHomeView |
| NewProject | App/UI/ProjectsHomeView.swift#NewProjectView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| StitchReview | App/UI/StitchReviewView.swift#StitchReviewView |
| ProjectCoach | App/UI/ProjectCoachView.swift#ProjectCoachView |
| CoachChat | App/UI/CoachChatView.swift#CoachChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| AnnotatedWIP | App/UI/AnnotatedWIPView.swift#AnnotatedWIPView |
| HandsFreeTTS | App/UI/HandsFreeTTSView.swift#HandsFreeTTSView |
| DictateNote | App/UI/DictateNoteView.swift#DictateNoteView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LocalLegalWebView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |

## instrumentation

- timing spans: impl-1, build-1, domain-1, smoke-1
- milestones: compile_succeeded, core_smoke_completed, candidate_published
- swiftui-expert-skill entry read; RuntimeForm / state ownership applied on NewProject / CoachChat / Dictate

## Gaps

- G1 ai_key_unavailable — no Secrets.xcconfig / authorized DeepSeek key; outbound closed; local coach tip path used
- G2 legal_url_unknown — external privacy/terms/support UNKNOWN; local HTML loads
- G3 cloudkit_unconfigured
- G4 feishu_row_not_yet_created (record_match_error=0; not a build blocker)
- G5 operator_pricing_deferred_free_app_only
- G6 independent eight-domain + per-frame visual acceptance pending (`ai_app_accept`)

## lessons_candidates

- child_slots=0 Cursor UltraLite: parent Builder owns full UI+AI+privacy without temporary workers
- iPhone 17 Pro exclusive lease honored; Pro Max left Shutdown
