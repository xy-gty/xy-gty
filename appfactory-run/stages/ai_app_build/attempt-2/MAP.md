# MAP — ai_app_build attempt-2

Status: ready

pm_visual_manifest_sha256: ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc
technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0

## Repair (operator-authorized round 1)

Controller four-perm / four-feature hard rule after accept attempt-1.

### Four Info.plist keys → four entry points
- NSCameraUsageDescription → Take photo (ImportCapture / `beginTakePhoto` / accessibility `take_photo`)
- NSPhotoLibraryUsageDescription → Add photos (PhotosPicker on ImportCapture)
- NSMicrophoneUsageDescription → Voice supplement (Chat extract / TTS; `voice_supplement_chat` / `voice_supplement_tts`)
- NSSpeechRecognitionUsageDescription → Voice supplement (same; on-device Speech → Save / Not this)

### Product commit
- path: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/product`
- branch: `main`
- commit: `09c4c0c3ca4b546b94253a7cd3d89f119e0b272b`
- bundle_id: `com.lingguang.docbrief`
- app_name: DocBrief AI

## Preparation / foundation
- seal: `runtime/preparation/attempt-1/sealed.v1.json` sha256 `bca0229e1f02e45f61cec0d5a058e1d963de05e9e2f8ad1caf894fbfdd7479c5`
- consume receipt: `preparation-consumed.v1.json` sha256 `5fa322c9494b8bd73d0b2f3ba0d5c8f49093230c79e050d2ccfbcf72d2e92a1f` (reused_prior_consumption)
- foundation: AppRuntimeCore 1.0.0 under `Vendor/AppRuntimeCore` (local SPM; called from product)
- call sites: ConsentFacade/AIConsentGate, AtomicCodableStore, PhotoImportSession, RuntimeForm (ChatExtract), TypedNavigationStore, KeychainCredentialStore

## Children (Cursor Task)
- schema: `appfactory.cursor_task_children.v1` → `native_children.v1.json`
- ui_business agent_id `11f86132-050c-452d-adf8-b3df9cc9cbea` owned `App/UI`
- ai_privacy agent_id `1474b48c-54ac-49b0-881a-7dc2f3edb3ea` owned `App/AI`
- children validate: ok (host_checked=false; controller journal owns final host stop)
- parent owned: `project.yml`, `App/Services/*` (camera/voice APIs), integration/build/smoke/commit

## Build
- command: xcodebuild DocBrief → iphonesimulator (leased UDID `C83D64D9-AB8C-4908-B82B-53091BCC4F9A`)
- result: succeeded
- log: `build.log`
- evidence: `evidence/build.json`

## Domain tests
- selector: `-only-testing:DocBriefDomainTests` (7 tests)
- result: succeeded
- log: `domain.log`

## Runtime smoke
- install/launch: succeeded; pid 72653 in `launch.log`
- screenshot: `smoke.png`
- evidence: `evidence/smoke.json`
- configuration_status: unconfigured (no DEEPSEEK_API_KEY)

## Candidate
- status: candidate_unaccepted
- name: `09c4c0c3ca4b-7ce60dbd04e8`
- receipt: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/artifacts/candidates/09c4c0c3ca4b-7ce60dbd04e8/receipt.json`
- receipt_sha256: `409ba966531d44d89d1ab4619a4b5c8b9d8ff9e9079a7317104e93de7abcb391`
- app_content_sha256: `7ce60dbd04e8816079811001e5f81ce9a0be85008b89c13491c3fbe46d757420`

## Frame → page / component (native; full visual judgment deferred)

| frame_id | page / component | runtime smoke shot |
|---|---|---|
| home-empty | `App/UI/HomeView.swift` Start brief | `smoke.png` |
| capture-import | `App/UI/ImportCaptureView.swift` Take photo + Add photos | pending accept |
| fields-review | `App/UI/RecognitionReviewView.swift` | pending accept |
| brief-detail-filled | `App/UI/BriefDetailView.swift` | pending accept |
| chat-extract | `App/UI/ChatExtractView.swift` + Voice supplement | pending accept |
| summary-card | `App/UI/SummaryCardView.swift` | pending accept |
| tts-briefing | `App/UI/TTSBriefingView.swift` + Voice supplement | pending accept |
| settings-privacy | `App/AI/SettingsPrivacyView.swift` Revoke AI consent | pending accept |

## symbol_map

| route_id | path#Symbol |
|---|---|
| ImportCapture | App/UI/ImportCaptureView.swift#ImportCaptureView |
| ChatExtract | App/UI/ChatExtractView.swift#ChatExtractView |
| TTSBriefing | App/UI/TTSBriefingView.swift#TTSBriefingView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| CameraAPI | App/Services/AppModel.swift#beginTakePhoto |
| VoiceAPI | App/Services/AppModel.swift#startVoiceSupplement |

## SwiftUI references used
- `skills/swiftui-expert-skill/SKILL.md` (state ownership, navigation, RuntimeForm keyboard)

## Gaps / known_issues
- G1: `ai_key_unavailable` — outbound AI disabled until Secrets.xcconfig / authorized config
- G2: legal URL UNKNOWN — local HTML loads; external deferred
- G3: CloudKit UNKNOWN — local AtomicCodableStore only
- G4: Feishu row not yet created (`record_match_error=0` soft)
- G5: `operator_pricing_deferred_free_app_only`
- G6: device camera on Simulator = synthetic DocumentPhoto (`camera_simulator`); device camera known_issue for true hardware
- G7: UL-07 soft visual mismatches may remain as known_issues (not core vs four-perm)

## lessons_candidates
- Cursor child receipts need top-level `launch_ref`/`launch_sha256` for `child_bound` validate; spawn-return alone is not enough if `record` already has spawn_kwargs.
