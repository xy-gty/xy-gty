# SnagCue AI — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
Attempt: 1  
dispatch_id: 4d8a6e3c-b616-4e50-aca1-e22ca49fef6d  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  

pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
preparation_seal_sha256: 485cbaf64ac7aebf5512252eddf4bfd2882263595c616664f5e30b42724ca9db  
preparation_consumed_ref: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/product`
- branch: `main`
- commit: `9b7db33af5cfa7b8be130af03c7de31f00c2b355`  
- candidate_commit: `eaa10b37be41471ca881596b01881e00a4c311b9` (published candidate_unaccepted)
- bundle_id: `com.lingguang.snagcue`
- app_name: SnagCue AI

## Foundation / preparation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` v1.0.0 integrity checked; production code calls `AtomicCodableStore`, `AIConsentGate`, `PhotoImportSession`, `RuntimeForm`, `TypedNavigationStore`, `KeychainCredentialStore`
- Domain package `SnagCueDomain` expanded from sealed scaffolding entities

## Children

- schema: `appfactory.cursor_task_children.v1`
- ui_business: agent `6bb666c2-deb3-4a5e-8c5f-13eb433b09ce` · owned `App/UI` · receipt `evidence/children/ui-business.spawn.json`
- ai_privacy: agent `cec1fe86-ee20-42c4-8be5-3b3e183d1b40` · owned `App/AI` · receipt `evidence/children/ai-privacy.spawn.json`
- Parent owned engineering, shared stores/`AppModel`, integration, Simulator, commit
- Post-finish: `AppModel` routes outbound AI via `AIPrivacyTransport` + consent Keychain mirror from [child_ai_privacy](cec1fe86-ee20-42c4-8be5-3b3e183d1b40); UI polish from [child_ui_business](6bb666c2-deb3-4a5e-8c5f-13eb433b09ce) retained

## Build

- command: `xcodebuild -project SnagCue.xcodeproj -scheme SnagCue -destination platform=iOS Simulator,id=5E3A8993-F815-4738-8EED-EF032F75704F -derivedDataPath <attempt>/DerivedData build`
- result: **BUILD SUCCEEDED**
- log: `evidence/candidate/build.log`
- evidence: `evidence/candidate/build.json`

## Domain tests

- selector: `SnagCueDomainTests` (6 tests)
- result: **TEST SUCCEEDED** (persist, consent gate, review labels, navigation, feedback notes)
- log: `evidence/candidate/domain.log`

## Runtime smoke

- simulator lease udid: `5E3A8993-F815-4738-8EED-EF032F75704F` (iPhone 17 / iOS 26.5)
- install + launch `com.lingguang.snagcue` succeeded (pid recorded in launch.log)
- smoke screenshot: `evidence/candidate/smoke.png` (home empty / Start audit)
- evidence: `evidence/candidate/smoke.json`

## Candidate

- status: `candidate_unaccepted`
- receipt: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/eaa10b37be41-3769c8500f73/receipt.json`
- package: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/eaa10b37be41-3769c8500f73/SnagCue.app.zip`

## Frame → page / component map

| frame_id | page / component | smoke shot |
|---|---|---|
| home-empty | `App/UI/HomeView.swift` Audits empty + Start audit | `evidence/candidate/smoke.png` (core smoke) |
| capture-import | `App/UI/CaptureView.swift` | pending independent acceptance |
| recognition-review | `App/UI/SnagRecognitionReviewView.swift` | pending independent acceptance |
| punchlist-filled | `App/UI/PunchListView.swift` | pending independent acceptance |
| chat-fill | `App/UI/ChatFillView.swift` | pending independent acceptance |
| annotated-report | `App/UI/AnnotatedReportView.swift` | pending independent acceptance |
| tts-coach | `App/UI/TTSCoachView.swift` | pending independent acceptance |
| settings-privacy | `App/AI/SettingsPrivacyView.swift` + ConsentSheet | pending independent acceptance |

Native adaptation: industrial concrete/steel/safety palette; no Site Audit Pro branding; free_app_only (no StoreKit/ATT).

## symbol_map

| route_id | symbol |
|---|---|
| HomeTab | `App/UI/HomeView.swift#HomeView` |
| NewAudit | `App/UI/NewAuditView.swift#NewAuditView` |
| Capture | `App/UI/CaptureView.swift#CaptureView` |
| SnagRecognitionReview | `App/UI/SnagRecognitionReviewView.swift#SnagRecognitionReviewView` |
| PunchList | `App/UI/PunchListView.swift#PunchListView` |
| ChatFill | `App/UI/ChatFillView.swift#ChatFillView` |
| FieldReview | `App/UI/FieldReviewView.swift` / ChatFill patch section |
| AnnotatedReport | `App/UI/AnnotatedReportView.swift#AnnotatedReportView` |
| TTSCoach | `App/UI/TTSCoachView.swift#TTSCoachView` |
| Settings | `App/AI/SettingsPrivacyView.swift#SettingsPrivacyView` |
| LegalPages | `App/AI/SettingsPrivacyView.swift#LegalPagesView` / `LocalLegalWebView` |
| ConsentSheet | `App/AI/ConsentSheet.swift#ConsentSheet` |

## SwiftUI references used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, Button CTAs, navigation)
- Topic focus: state/data flow, layout/safe area via `RuntimeForm` keyboard inset

## Config (local_only)

- privacy_url / terms_url / support_url / ai_key / cloudkit: UNKNOWN gaps
- `record_match_error=0` / feishu row not created — persisted audit stdout; not a build blocker
- outbound AI disabled until key + consent; honest unavailable messaging implemented

## Gaps

- G1: DeepSeek API key not configured (`ai_key_unavailable` / local_only gap)
- G2: External legal/support URLs UNKNOWN — local HTML pages ship instead
- G3: CloudKit sync not configured
- G4: Operator paid one-time unlock deferred (free_app_only profile)
- G5: Per-frame visual + full eight-domain runtime deferred to `ai_app_accept`
- G6: Physical-device camera capture 真机待测 (Simulator photo library path proven)

## instrumentation

- timing: `runtime/ultra-lite-timing.v1.jsonl` (implementation / integration_build / domain_tests spans)
- simulator-lease acquired for smoke; release on finish
- native_children.v1.json recorded

## lessons_candidates

- Cursor preparation consume must use `bin/cursor-package ultra-lite preparation consume` (codex module forbidden on cursor runtime)
- Candidate smoke evidence requires structured `simulator`/`install`/`launch`/`observation` blocks with pid + runtime
