# MAP — ai_app_build attempt-1

Status: ready

pm_visual_manifest_sha256: 46c33c0955e1c3fe98d4473026decc2e316148b4293d533c79853afa5ab8c950
technical_contract_sha256: b43b4db81ea320561037660a574d8d0b620ca87f7d34a52fcece3c1fc6678d19

## Product

- path: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T132652Z-d15977ae/product`
- branch: `main`
- commit: `009dea15a1ab2e106efcff66e16a15433ac01ba0`
- bundle_id: `com.lingguang.bendcoach`
- app_name: BendCoach AI
- remote: `xy-gty` → `git@github.com:xy-gty/xy-gty.git` (push deferred to delivery)

## Preparation / foundation

- seal: `runtime/preparation/attempt-1/sealed.v1.json` sha256 `667e46366b8d4dad81c6054d92ba2104564a4e0a69be67816ac0722a14f39983`
- consume: `bin/cursor-package ultra-lite preparation consume` → `preparation-consumed.v1.json` sha256 `262844a87ff03ea8015ab2e8f893f620cf5d578a63ddddd7b06dbb5bb5d32bcb`
- foundation: AppRuntimeCore 1.0.0 under `Vendor/AppRuntimeCore` (local SPM; called from product via BendCoachDomain + App RuntimeForm / AIConsentGate / stores)
- domain module: `BendCoachDomain` (entities, storage, consent, navigation, TTS, speech bridge, units, outbound boundary)

## Children (Cursor Task)

- `ultra_lite_execution.child_slots`: **0** (reserved slots including parent: 1)
- no `ultra-lite-worker` spawn; parent owned engineering + UI + AI/privacy files alone (capacity reservation; not `codex_capacity_unavailable` because policy child_slots=0)

## Build

- command: `xcodebuild -project BendCoach.xcodeproj -scheme BendCoach -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData build`
- result: succeeded
- log: `build.log`
- evidence: `evidence/build.json`

## Domain tests

- selector: `-only-testing:BendCoachDomainTests` (6 tests)
- result: succeeded on leased UDID `5E3A8993-F815-4738-8EED-EF032F75704F`
- log: `domain.log`
- covers: review labels Save/Not this/Edit marks + Use/Discard, navigation routes, consent grant/revoke, markup persist + reject empty, outbound gate, unit preference round-trip

## Runtime smoke

- install/launch: succeeded; pid `9232` in `launch.log`
- screenshot: `smoke.png`
- evidence: `evidence/smoke.json`
- configuration_status: unconfigured (no DEEPSEEK_API_KEY; demo bend pack path)

## Candidate

- status: candidate_unaccepted
- name: `009dea15a1ab-4c27f3a2b607`
- receipt: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T132652Z-d15977ae/artifacts/candidates/009dea15a1ab-4c27f3a2b607/receipt.json`
- receipt_sha256: `c88f148871c5e489e7ffafaeac3741c03bbf8a412d27fe3f8c1542acc20099e9`
- app_content_sha256: `4c27f3a2b60750ac9f05761897925fbdd368becf744ad5d9f31c4c5706c59be1`
- package_acceptance: pending

## Frame → page / component (native; full visual judgment deferred)

| frame_id | page / component | runtime smoke shot |
|---|---|---|
| home-empty | `App/UI/HomeView.swift` BendCoach AI hero + Ask bend math bar | `smoke.png` (core smoke) |
| bend-math-chat | `App/UI/BendMathChatView.swift` + RuntimeForm + mic | pending accept |
| capture-import | `App/UI/CaptureImportView.swift` camera/library | pending accept |
| bend-review | `App/UI/BendReviewView.swift` Save / Not this / Edit marks | pending accept |
| job-detail-filled | `App/UI/JobDetailView.swift` | pending accept |
| diagram-overlay | `App/UI/DiagramOverlayView.swift` Use / Discard | pending accept |
| tts-coaching | `App/UI/TTSCoachingView.swift` + CoachingTTS | pending accept |
| settings-units-privacy | `App/AI/SettingsPrivacyView.swift` + Units + ConsentSheet | pending accept |

Assets: none declared in PM visual manifest for product embedding.

## symbol_map

| route_id | path#Symbol |
|---|---|
| HomeTab | App/UI/HomeView.swift#HomeView |
| BendMathChat | App/UI/BendMathChatView.swift#BendMathChatView |
| CaptureImport | App/UI/CaptureImportView.swift#CaptureImportView |
| BendReview | App/UI/BendReviewView.swift#BendReviewView |
| JobDetail | App/UI/JobDetailView.swift#JobDetailView |
| DiagramOverlay | App/UI/DiagramOverlayView.swift#DiagramOverlayView |
| TTSCoaching | App/UI/TTSCoachingView.swift#TTSCoachingView |
| SpeechCapture | App/Services/SpeechCaptureHost.swift#SpeechCaptureHost |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| Units | App/UI/UnitsSettingsView.swift#UnitsSettingsView |
| LegalPages | App/AI/SettingsPrivacyView.swift#LegalPagesView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |

## SwiftUI references used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, navigation, keyboard via RuntimeForm)

## Config (local_only)

- `evidence/config-audit.receipt.json`: gap `feishu_row_not_yet_created` (blocker=false)
- `evidence/inspect-key.json`: `ai_key_unavailable` (blocker=false)
- outbound AI disabled until key; demo bend pack + local jobs remain

## Gaps

- G1: `ai_key` UNKNOWN / local_only — outbound DeepSeek disabled; honest demo bend pack
- G2: privacy/terms/support external URLs UNKNOWN — local bundle HTML loads
- G3: CloudKit UNKNOWN — local AtomicCodableStore only
- G4: operator one-time unlock / pro bend packs deferred — free_app_only; `operator_pricing_deferred_free_app_only`
- G5: Feishu row / delivery card deferred per operator
- G6: independent eight-domain + per-frame visual acceptance not run (candidate_unaccepted by design); device camera/speech quality 真机待测

## instrumentation

- timing spans: planning, implementation, domain_tests, runtime_smoke + milestones compile_succeeded / core_smoke_completed / candidate_published
- simulator lease: UDID `5E3A8993-F815-4738-8EED-EF032F75704F` (iPhone 17 / iOS 26.5); released after smoke

## lessons_candidates

- P1 preparation consume on Cursor runtime must use `bin/cursor-package ultra-lite preparation consume` (`python3 -m codex_package.preparation` raises `ultra_lite_runtime_forbidden:codex`).
- When `child_slots=0` / single reserved slot, parent must implement UI+AI alone; do not invent worker receipts.
