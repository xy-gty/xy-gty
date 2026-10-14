# MAP — ai_app_build attempt-1 (CuePartner AI)

Status: ready

dispatch_id: 41eafa77-4725-4280-85b3-344f3798cf63  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
requested_model: auto  

pm_visual_manifest_sha256: 5f4a9df742b0a3c3d0282a524b5bade3ff4c3e8a5e55389e4b5d6fe738785875  
technical_contract_sha256: 9cb9f54b37cdeb602be56fafdcba1dde4e963ad5cc2dc289efcb5abd4643aa2f  
preparation_seal_sha256: f2b91e41fe51732752a58a525141a56351a66f003e294f00ec6049808a1fbdae  
preparation_consumed_sha256: 7010cfbc71f968575df6ad2942785a4ba82c17f02b13f994cf170a9852c5ceef  
foundation_version: 1.0.0  
AppRuntimeCore calls: AppModel (AtomicCodableStore, AIConsentGate, KeychainCredentialStore, PhotoImportSession, TypedNavigationStore), NewSceneView/OCRReviewView/PartnerChatView (RuntimeForm), AIPrivacyTransport (AIConsentGate.permit/perform/validate)

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T125947Z-a3157139/product`
- branch: `main`
- commit: `6ddd4fa98ed526cc1c73c57f6068fc2df9b3be5b`
- bundle_id: `com.lingguang.cuepartner` (frozen technical contract)
- display: CuePartner AI

## Children

- child_slots: 0 (dispatch reserved 1 parent slot only)
- native_children.v1.json: empty children list — parent implemented UI/business + AI/privacy without spawning ultra-lite-worker Tasks
- note: not `codex_capacity_unavailable`; policy frozen `child_slots=0`

## Code query

- `code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp'`
- Construction proceeded from sealed preparation domain sources + PM build docs (absolute Read)

## Config (local_only)

- inspect-key: `ai_key_unavailable` (present=false, blocker=false) — evidence/inspect-key.stdout.txt
- persist-audit: evidence/config-audit.receipt.json (record_match_error absent / feishu row gap, not blocker)
- outbound AI disabled until Secrets.xcconfig / Keychain key; honest unconfigured UI

## Build / tests / smoke

- build: succeeded — `stages/ai_app_build/attempt-1/build.log`
- domain tests: CuePartnerDomainTests **7 passed** — `stages/ai_app_build/attempt-1/domain.log`
- simulator lease udid: `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (iPhone 17 Pro / iOS 26.5)
- install/launch: succeeded — pid 48764 — install.log / launch.log
- smoke screenshot: `stages/ai_app_build/attempt-1/smoke-home.png` sha256 `e938f1be903d05bb7f7fecbb1c2879e8b3b261dd839e56cb79a797e2c8feb5eb`
- candidate: `artifacts/candidates/6ddd4fa98ed5-a6ec645c0fcc/` status=`candidate_unaccepted` receipt_sha256=`eadeb0cd0bfd68fb13a6d33dd25892a5dfb54dd39f81a8c7e28857091ff29548`

## Frame → page mapping (native; full visual Acceptance pending)

| frame_id | page / component | smoke / note |
|----------|------------------|--------------|
| home-empty | ScenesHomeView | smoke-home.png (core smoke) |
| import-script | ImportScriptView | pending independent Acceptance |
| ocr-review | OCRReviewView | pending independent Acceptance |
| scene-detail | SceneDetailView / RehearseHubView | pending independent Acceptance |
| partner-chat | PartnerChatView + ConsentSheet | pending independent Acceptance |
| cue-rehearsal | CueRehearsalView + CueTTSPlayer | pending independent Acceptance |
| voice-note | VoiceNoteView | Simulator limited; 真机待测 |
| settings-privacy | SettingsPrivacyView + LegalPagesView | pending independent Acceptance |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| ScenesHome | App/UI/ScenesHomeView.swift#ScenesHomeView |
| NewScene | App/UI/NewSceneView.swift#NewSceneView |
| ImportScript | App/UI/ImportScriptView.swift#ImportScriptView |
| OCRReview | App/UI/OCRReviewView.swift#OCRReviewView |
| SceneDetail | App/UI/SceneDetailView.swift#SceneDetailView |
| PartnerChat | App/UI/PartnerChatView.swift#PartnerChatView |
| TurnReview | App/UI/TurnReviewView.swift#TurnReviewView |
| CueRehearsal | App/UI/CueRehearsalView.swift#CueRehearsalView |
| VoiceNoteCapture | App/UI/VoiceNoteView.swift#VoiceNoteView |
| AmbiencePicker | App/UI/AmbiencePickerView.swift#AmbiencePickerView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/SettingsPrivacyView.swift#LegalPagesView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |

## SwiftUI references used

- `skills/swiftui-expert-skill/SKILL.md` (entry; state ownership / RuntimeForm focus / NavigationStack)
- No Instruments trace recorded (not required for Builder smoke)

## instrumentation

- ultra_lite_timing spans: consume-prep-1, implement-app-1, build-1, domain-1, smoke-1
- milestones: compile_succeeded, core_smoke_completed, candidate_published
- evidence/build.json + evidence/smoke.json frozen into candidate receipt

## Gaps

- G1: `ai_key_unavailable` / DeepSeek key UNKNOWN (local_only) — live partner HTTP deferred; honest unconfigured path implemented
- G2: privacy/terms/support external URLs UNKNOWN — local HTML pages load; replace_before_submission
- G3: CloudKit UNKNOWN — local AtomicCodableStore only
- G4: Feishu config row not created (`audit_output_unclassified` / gap) — not blocker
- G5: Device camera + long microphone recording 真机待测; Simulator test still + voice placeholder journey present
- G6: Independent eight-domain Acceptance + per-frame visual judgment pending (candidate_unaccepted)

## lessons_candidates

- SwiftUI.Scene vs domain Scene requires `CuePartnerDomain.Scene` qualification in App targets
- Cursor UltraLite preparation consume must use `bin/cursor-package ultra-lite preparation consume` (codex module raises ultra_lite_runtime_forbidden:codex)
