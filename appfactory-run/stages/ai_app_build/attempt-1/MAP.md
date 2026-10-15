# HiveCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: d9d1537a-2dda-41a4-96ee-8582fcd08068  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: 5bda6a4efb122c94a7fcd682191fc44da554b26267bb7948618b47e67403a167  
pm_visual_manifest_sha256: 4558114f089b150a156c6a189d7fdc42ee43c164ab00463cc94679548a66a7e7  
preparation_seal_sha256: 093256e089594aa6a331b67ede8cf60f79629d1bc64cb06f6c4ba81ec5b65918  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/product`
- identity product_dir: `hivecue` (`hivecue` → `product` symlink)
- branch: `hivecue/kf-20261015T053908Z` (independent branch pushed to xy-gty)
- commit: `f28af04eed6677c6febdbcdd9f88d862d1ac1b8f`
- bundle_id: `com.lingguang.hivecue`
- remote: `git@github.com:xy-gty/xy-gty.git`
- push: succeeded → `origin/hivecue/kf-20261015T053908Z` (evidence/git-push.log)
- palette: `#9F1239` / `#FDF2F8` / `#4D7C0F`
- unique UI: HexCombGrid + InspectionRail + HeatOverlayCanvas
- AppIcon/LaunchScreen: not generated this round (operator hard; empty AppIcon set stub only for actool)
- Feishu CONTROLLER_DELIVERY: skip (operator)
- free_app_only: no StoreKit / paywall / coins / ATT

## Foundation / preparation

- Consumed sealed preparation into product (HiveCueDomain + Vendor/AppRuntimeCore) via `cursor-package ultra-lite preparation consume`
- `factory.ultra_lite_foundation check` OK (AppRuntimeCore 1.0.0)
- Production calls: `AtomicCodableStore`, `AIConsentGate`, `KeychainCredentialStore`, `TypedNavigationStore`, `RuntimeForm`, `PhotoImportSession` (via PhotosPicker + ingest)

## Build / tests / smoke

- Build: `xcodebuild -scheme HiveCue -destination 'generic/platform=iOS Simulator'` → **BUILD SUCCEEDED** (`build.log`)
- Domain tests: `HiveCueDomainTests` on iPhone 17 Pro → **9/9 passed** (`domain.log`)
- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (Pro Max never used; released after smoke)
- Install/launch/smoke screenshot: `install.log` / `launch.log` / `smoke.png` (pid 8755)
- Candidate: `artifacts/candidates/f28af04eed66-625359af7ae7/` status `candidate_unaccepted` receipt_sha256 `4ef0efb0668b23fd6057db6622836cd8dfbaeacf4f6c4192f9c261d53e81ed52`

## Frame → page mapping

| frame_id | page / component | smoke note |
|----------|------------------|------------|
| hivecue-home-empty | InspectionsHomeView + HexCombGrid preview | smoke.png home empty; UL deferred |
| hivecue-capture-import | CaptureImportView (Camera / Photo library) | pending accept |
| hivecue-brood-review | BroodReviewView Keep/Discard/Edit | pending accept |
| hivecue-inspection-coach | InspectionCoachView + HexCombGrid + InspectionRail + HeatOverlay | pending accept |
| hivecue-coach-chat | CoachChatView + ConsentSheet | pending accept |
| hivecue-annotated-frame | AnnotatedFrameView + HeatOverlayCanvas | pending accept |
| hivecue-hands-free-tts | HandsFreeTTSView | pending accept |
| hivecue-settings-privacy | SettingsPrivacyView + local Legal HTML | pending accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| InspectionsHome | App/UI/InspectionsHomeView.swift#InspectionsHomeView |
| NewInspection | App/UI/InspectionsHomeView.swift#NewInspectionView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| BroodReview | App/UI/BroodReviewView.swift#BroodReviewView |
| InspectionCoach | App/UI/InspectionCoachView.swift#InspectionCoachView |
| CoachChat | App/UI/CoachChatView.swift#CoachChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| AnnotatedFrame | App/UI/AnnotatedFrameView.swift#AnnotatedFrameView |
| HandsFreeTTS | App/UI/HandsFreeTTSView.swift#HandsFreeTTSView |
| DictateFields | App/UI/DictateFieldsView.swift#DictateFieldsView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LocalLegalWebView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |
| HexCombGrid | App/UI/HexCombGrid.swift#HexCombGrid |
| InspectionRail | App/UI/InspectionRail.swift#InspectionRail |
| HeatOverlayCanvas | App/UI/HeatOverlay.swift#HeatOverlayCanvas |

## instrumentation

- timing spans: consume-prep-1, impl-scaffold-1, build-1, domain-1, smoke-1
- milestones: compile_succeeded, core_smoke_completed, candidate_published
- swiftui-expert-skill entry applied; RuntimeForm on CoachChat / DictateFields
- native_children: child_slots=0 (solo parent; no temporary workers)
- four permissions with real entry points: Camera (CaptureImport), Photos (PhotosPicker), Mic+Speech (DictateFields), TTS (HandsFree)

## Gaps

- G1 ai_key_unavailable — no Secrets.xcconfig / authorized DeepSeek key; outbound closed; local coach tip path used
- G2 legal_url_unknown — external privacy/terms/support UNKNOWN; local HTML loads
- G3 cloudkit_unconfigured
- G4 feishu_row_not_yet_created (record_match_error=0; Feishu CONTROLLER_DELIVERY skip per operator; not a build blocker)
- G5 operator_pricing_deferred_free_app_only (one-time unlock / apiary packs deferred; no coins)
- G6 independent eight-domain + per-frame visual acceptance pending (`ai_app_accept`)

## lessons_candidates

- child_slots=0 Cursor UltraLite: parent Builder owns full UI+AI+privacy without temporary workers
- iPhone 17 Pro exclusive lease honored; Pro Max left untouched
- Independent branch `hivecue/kf-20261015T053908Z` pushed to xy-gty without overwriting main
- Preparation consume must use `cursor-package ultra-lite preparation consume` on Cursor runtime (codex_package.preparation is forbidden)
