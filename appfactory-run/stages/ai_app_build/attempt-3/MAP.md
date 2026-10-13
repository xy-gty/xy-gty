# SnagCue AI — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
Attempt: 3  
dispatch_id: a6d0452b-c58d-46e9-9f9e-f4534c3dbe9e  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: composer-2.5 (Task auto mapping)  
execution_seq: 1  

pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
preparation_seal_sha256: 485cbaf64ac7aebf5512252eddf4bfd2882263595c616664f5e30b42724ca9db  
preparation_consumed_ref: preparation-consumed.v1.json  

## Repair scope (controller-repair-brief)

- Preserve Active punch hub `NavigationStack(path:)` binding (UL-02 CTAs) — retained in `RootTabView.ActivePunchHub`
- Add four Info.plist usage keys with site-inspection copy + four usable features
- Do not regress AI consent / local legal / domain tests

## Accept report — four keys + four features

| Key | Present in built Info.plist | Feature | Simulator status |
|---|---|---|---|
| `NSCameraUsageDescription` | yes | Camera capture (`WalkthroughCameraPicker` → `importCapturedImage`) | 真机待测 (no Simulator camera; library path works) |
| `NSPhotoLibraryUsageDescription` | yes | PhotosPicker walkthrough import | pass (smoke + prior path) |
| `NSMicrophoneUsageDescription` | yes | Punch-item Voice note (`VoiceNoteRecorder`) | 真机待测 |
| `NSSpeechRecognitionUsageDescription` | yes | Chat fill Speech-to-text (`SpeechRecognitionService`) | 真机待测 |

Semantic glue: camera/library photos → snag recognition → chat punch-list fill (speech helps fill fields) → annotated report → TTS readout; mic attaches voice notes onto punch items.

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/product`
- branch: `main`
- commit: `47f1c118b9e5e460b0231de413df86d5ef6d8ae7`
- bundle_id: `com.lingguang.snagcue`
- app_name: SnagCue AI

## Foundation / preparation

- Consumed sealed preparation (`reused_prior_consumption` / `preparation-consumed.v1.json`)
- `Vendor/AppRuntimeCore` v1.0.0; production calls `AtomicCodableStore`, `AIConsentGate`, `PhotoImportSession`, `RuntimeForm`, `TypedNavigationStore`, `KeychainCredentialStore`
- Domain package `SnagCueDomain` retained

## Children

- schema: `appfactory.cursor_task_children.v1`
- parent_execution_seq: 1
- ui_business: agent `b9de0a7d-0964-44f2-a856-4c71a07c9eb8` · owned `App/UI` · receipt `evidence/children/ui-business.spawn.json`
- ai_privacy: agent `ab1466cd-fe3b-48ea-a38c-74bc62ddc659` · owned `App/AI` · receipt `evidence/children/ai-privacy.spawn.json`
- Parent owned `project.yml`, `App/Services/AppModel`, xcodegen, Simulator, commit, candidate, MAP/finish
- requested_model: auto (observed composer-2.5)

## Build

- command: `xcodebuild -project SnagCue.xcodeproj -scheme SnagCue -destination platform=iOS Simulator,id=5E3A8993-F815-4738-8EED-EF032F75704F -derivedDataPath <attempt>/DerivedData build`
- result: **BUILD SUCCEEDED**
- log: `evidence/candidate/build.log` (sha256 `d3f13248567092b3f2b4d5b986158b4c30aca355b3625e0e217203e1fd46f089`)
- evidence: `evidence/candidate/build.json` / `evidence/build.json`

## Domain tests

- selector: `SnagCueDomainTests`
- result: **TEST SUCCEEDED** (persist, consent gate, review labels, navigation, feedback notes)
- log: `evidence/candidate/domain.log` (sha256 `a9de5079915375b64de9bcc4ba9b5adfde7f184c43bad1f6a4f5a6247fb80cc1`)

## Runtime smoke

- simulator lease udid: `5E3A8993-F815-4738-8EED-EF032F75704F` (iPhone 17 / iOS 26.5)
- install + launch `com.lingguang.snagcue` succeeded (pid `61052`)
- smoke screenshot: `evidence/candidate/smoke.png` (sha256 `ff025e024310af37710426bf6be709867d0a06f2e9771c08e8c00426973cf596`)
- evidence: `evidence/candidate/smoke.json` / `evidence/smoke.json`
- configuration_status: `unconfigured` (honest local_only)

## Candidate

- status: `candidate_unaccepted`
- name: `47f1c118b9e5-146049ffc8bc`
- receipt: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/47f1c118b9e5-146049ffc8bc/receipt.json`
- receipt_sha256: `fc68f1f82ba9b32a940fd7d7d947eebf94fd07d82d9a14b184e9f074c8fc5c6b`
- package: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/47f1c118b9e5-146049ffc8bc/SnagCue.app.zip`
- app_content_sha256: `146049ffc8bc9660dad0dc37ff17041b5036e2976fe60a09ded20b3c4caab231`
- implemented_scope: four plist keys + camera/library/mic/speech features; hub NavigationStack preserved; consent/legal/domain tests retained
- unverified_items: independent eight-domain acceptance; per-frame visual; live DeepSeek; physical-device camera/mic/speech matrix → `ai_app_accept`

## Frame → page / component map

| frame_id | page / component | smoke shot |
|---|---|---|
| home-empty | `App/UI/HomeView.swift` | `evidence/candidate/smoke.png` (core smoke) |
| capture-import | `App/UI/CaptureView.swift` (+ camera picker) | pending independent acceptance |
| recognition-review | `App/UI/SnagRecognitionReviewView.swift` | pending independent acceptance |
| punchlist-filled | `App/UI/PunchListView.swift` (+ voice note) | pending independent acceptance |
| chat-fill | `App/UI/ChatFillView.swift` (+ speech-to-text) | pending independent acceptance |
| annotated-report | `App/UI/AnnotatedReportView.swift` | pending independent acceptance |
| tts-coach | `App/UI/TTSCoachView.swift` | pending independent acceptance |
| settings-privacy | `App/AI/SettingsPrivacyView.swift` (+ device permissions section) | pending independent acceptance |

## Gaps

- G1: `ai_key_unavailable` / local_only DeepSeek key — outbound honest blocked; non-blocker
- G2: legal URL / CloudKit / Feishu row UNKNOWN gaps — non-blocker per P1
- G3: physical camera / mic / speech recognition → 真机待测 on Simulator
- G4: independent eight-domain + per-frame visual → `ai_app_accept`
- G5: pricing / Feishu delivery deferred (operator)
- G6: none additional for construction

## instrumentation

- timing spans: `a3-impl`, `a3-build`, `a3-domain`, `a3-smoke` via `factory.ultra_lite_timing`
- milestones: `compile_succeeded`, `core_smoke_completed`, `candidate_published`
- simulator lease acquire/release for run `kf-20261013T095600Z-1e00eb7a`

## symbol_map

| route_id | path#Symbol |
|---|---|
| HomeTab | `App/UI/HomeView.swift#HomeView` |
| NewAudit | `App/UI/NewAuditView.swift#NewAuditView` |
| Capture | `App/UI/CaptureView.swift#CaptureView` / `WalkthroughCameraPicker` |
| SnagRecognitionReview | `App/UI/SnagRecognitionReviewView.swift#SnagRecognitionReviewView` |
| PunchList | `App/UI/PunchListView.swift#PunchListView` |
| ChatFill | `App/UI/ChatFillView.swift#ChatFillView` |
| FieldReview | `App/UI/FieldReviewView.swift#FieldReviewView` |
| AnnotatedReport | `App/UI/AnnotatedReportView.swift#AnnotatedReportView` |
| TTSCoach | `App/UI/TTSCoachView.swift#TTSCoachView` |
| Settings | `App/AI/SettingsPrivacyView.swift#SettingsPrivacyView` |
| LegalPages | `App/AI/SettingsPrivacyView.swift#LegalPagesView` / `LocalLegalWebView` |
| ConsentSheet | `App/AI/ConsentSheet.swift#ConsentSheet` |
| VoiceNote | `App/AI/VoiceNoteRecorder.swift#VoiceNoteRecorder` |
| SpeechSTT | `App/AI/SpeechRecognitionService.swift#SpeechRecognitionService` |
| AppModel | `App/Services/AppModel.swift#AppModel` |

## lessons_candidates

- Cursor child `rebuild` can stamp truncated launch.md and inject `message` into spawn_kwargs; for Cursor validate, keep spawn keys exactly `{subagent_type,model,description,prompt}` and avoid rebuild after a clean record.
- Simulator camera/mic/speech should be labeled 真机待测 while keeping library import + UI entry points for acceptance.
