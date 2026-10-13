# SnagCue AI — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
Attempt: 2  
dispatch_id: ad7a1053-5d66-475c-a9c0-1fe7199a68ba  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
execution_seq: 2  

pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
preparation_seal_sha256: 485cbaf64ac7aebf5512252eddf4bfd2882263595c616664f5e30b42724ca9db  
preparation_consumed_ref: preparation-consumed.v1.json  

## Repair scope (from ai_app_accept attempt-1)

- Accept MAP: `stages/ai_app_accept/attempt-1/MAP.md` (map_sha256 `ccaa83545247a984fad98b49968f7610463d19307eb81529fe8b73d2fc6f103b`)
- Literal gap: Active punch hub CTAs did not navigate (UL-02/04/05/07)
- Fix: bind `NavigationStack(path:)` in `ActivePunchHub` and route hub CTAs via `path.append(SnagRoute…)` in `PunchListView`; distinct Annotated report title
- Product commit: `b85a9124f0e88b8561133dc296d2cb64fce42060` (on prior `9b7db33a…`)

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/product`
- branch: `main`
- commit: `b85a9124f0e88b8561133dc296d2cb64fce42060`
- bundle_id: `com.lingguang.snagcue`
- app_name: SnagCue AI

## Foundation / preparation

- Consumed sealed preparation (`reused_prior_consumption` / `preparation-consumed.v1.json`)
- `Vendor/AppRuntimeCore` v1.0.0; production calls `AtomicCodableStore`, `AIConsentGate`, `PhotoImportSession`, `RuntimeForm`, `TypedNavigationStore`, `KeychainCredentialStore`
- Domain package `SnagCueDomain` retained from sealed scaffolding

## Children

- schema: `appfactory.cursor_task_children.v1`
- parent_execution_seq: 2 (children inherited from execution_seq 1; product edits already committed)
- ui_business: agent `e868a096-b6ba-4916-8b9e-84a9ac2f5b72` · owned `App/UI` · receipt `evidence/children/ui-business.spawn.json`
- ai_privacy: agent `09d26fe6-5515-4d4a-97e4-9fd3b555ee27` · owned `App/AI` · receipt `evidence/children/ai-privacy.spawn.json`
- Parent owned engineering, shared stores/`AppModel`, integration, Simulator, commit, candidate publish, MAP/finish
- e1 host errored after candidate publish (PING timeout); e2 completes MAP + finish only — no product re-edit required

## Build

- command: `xcodebuild -project SnagCue.xcodeproj -scheme SnagCue -destination platform=iOS Simulator,id=5E3A8993-F815-4738-8EED-EF032F75704F -derivedDataPath <attempt>/DerivedData build`
- result: **BUILD SUCCEEDED**
- log: `evidence/candidate/build.log` (sha256 `f1f24831a439eac95855c28b629ceaeea3182fba049c8ffbbc53f605922b4d57`)
- evidence: `evidence/candidate/build.json` / `evidence/build.json`

## Domain tests

- selector: `SnagCueDomainTests`
- result: **TEST SUCCEEDED** (persist, consent gate, review labels, navigation, feedback notes)
- log: `evidence/candidate/domain.log` (sha256 `82b66adaf476f07506c4fb30e875f7c468f242af10301f447e6175ae9eb2e415`)

## Runtime smoke

- simulator lease udid: `5E3A8993-F815-4738-8EED-EF032F75704F` (iPhone 17 / iOS 26.5)
- install + launch `com.lingguang.snagcue` succeeded (pid `43649`)
- smoke screenshot: `evidence/candidate/smoke.png` (sha256 `ef748c6573740aa57fb9a9683cabf16e267cffaaab93a2ecf71183423eff4548`)
- evidence: `evidence/candidate/smoke.json` / `evidence/smoke.json`
- configuration_status: `unconfigured` (honest local_only)

## Candidate

- status: `candidate_unaccepted`
- name: `b85a9124f0e8-0d5a33c59f35`
- receipt: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/b85a9124f0e8-0d5a33c59f35/receipt.json`
- receipt_sha256: `0cee7a5226437470973a17a7b8af53019f6555ada28eec1f57167dd87afe2d27`
- package: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/b85a9124f0e8-0d5a33c59f35/SnagCue.app.zip`
- app_content_sha256: `0d5a33c59f35246bc02d1cd886a4fcf7ed57a1dc9d4562d0cb462a21b17c0653`
- implemented_scope: hub NavigationStack path binding for Add photos / Review snags / Chat fill / Annotate / Read aloud; Annotated report title; prior AI consent/local legal; domain safety tests
- unverified_items: independent eight-domain acceptance; per-frame visual; live DeepSeek outbound; full UI journey matrix → `ai_app_accept`

## Frame → page / component map

| frame_id | page / component | smoke shot |
|---|---|---|
| home-empty | `App/UI/HomeView.swift` Audits empty + Start audit | `evidence/candidate/smoke.png` (core smoke) |
| capture-import | `App/UI/CaptureView.swift` (hub → Add photos) | pending independent acceptance |
| recognition-review | `App/UI/SnagRecognitionReviewView.swift` (hub → Review snags) | pending independent acceptance |
| punchlist-filled | `App/UI/PunchListView.swift` + `RootTabView.ActivePunchHub` | pending independent acceptance |
| chat-fill | `App/UI/ChatFillView.swift` (hub → Chat fill / Ask AI) | pending independent acceptance |
| annotated-report | `App/UI/AnnotatedReportView.swift` (hub → Annotate) | pending independent acceptance |
| tts-coach | `App/UI/TTSCoachView.swift` (hub → Read aloud) | pending independent acceptance |
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
| ActivePunchHub | `App/UI/RootTabView.swift#ActivePunchHub` |
| ChatFill | `App/UI/ChatFillView.swift#ChatFillView` |
| FieldReview | `App/UI/FieldReviewView.swift` / ChatFill patch section |
| AnnotatedReport | `App/UI/AnnotatedReportView.swift#AnnotatedReportView` |
| TTSCoach | `App/UI/TTSCoachView.swift#TTSCoachView` |
| Settings | `App/AI/SettingsPrivacyView.swift#SettingsPrivacyView` |
| LegalPages | `App/AI/SettingsPrivacyView.swift#LegalPagesView` / `LocalLegalWebView` |
| ConsentSheet | `App/AI/ConsentSheet.swift#ConsentSheet` |

## SwiftUI references used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, Button CTAs, NavigationStack path binding)
- Topic focus: navigation path identity for hub destinations; layout/safe area via `RuntimeForm` where forms apply

## Config (local_only)

- privacy_url / terms_url / support_url / ai_key / cloudkit: UNKNOWN gaps
- `record_match_error=0` / feishu row not created — `evidence/config-audit.*`; not a build blocker
- outbound AI disabled until key + consent; honest unavailable messaging implemented
- `validate-build` (local_only): ok

## Gaps

- G1: DeepSeek API key not configured (`ai_key_unavailable` / local_only gap)
- G2: External legal/support URLs UNKNOWN — local HTML pages ship instead
- G3: CloudKit sync not configured
- G4: Operator paid one-time unlock deferred (free_app_only profile)
- G5: Per-frame visual + full eight-domain runtime deferred to `ai_app_accept`
- G6: Physical-device camera capture 真机待测 (Simulator photo library path proven)

## instrumentation

- timing: `runtime/ultra-lite-timing.v1.jsonl` (e1 build/smoke + e2 evidence/MAP; e1 stage_execution errored on PING timeout after candidate)
- simulator-lease: `evidence/simulator-lease.json` udid `5E3A8993-F815-4738-8EED-EF032F75704F`; release on finish
- native_children.v1.json recorded (inherited children for execution_seq 2)
- candidate check: ok / `candidate_unaccepted`

## lessons_candidates

- After `candidate_unaccepted` publish, write MAP.md and run finish immediately — host PING timeout after publish leaves valid candidate orphaned without MAP
- Hub CTAs require a bound `NavigationStack(path:)` owning the same `NavigationPath` Binding as destination append sites; unbound stack silently drops pushes
