# MAP — ai_app_build attempt-1

Status: ready

pm_visual_manifest_sha256: ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc
technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0

## Product

- path: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/product`
- branch: `main`
- commit: `0ddb3670393a1fe8ba4797f1682c19aa67f9b235`
- bundle_id: `com.lingguang.docbrief`
- app_name: DocBrief AI

## Preparation / foundation

- seal: `runtime/preparation/attempt-1/sealed.v1.json` sha256 `bca0229e1f02e45f61cec0d5a058e1d963de05e9e2f8ad1caf894fbfdd7479c5`
- consume receipt: `preparation-consumed.v1.json`
- foundation: AppRuntimeCore 1.0.0 under `Vendor/AppRuntimeCore` (local SPM dependency; called from product code)
- domain module: `DocBriefDomain` (entities, storage, consent, navigation, TTS, outbound boundary)

## Children (Cursor Task)

- schema: `appfactory.cursor_task_children.v1` → `native_children.v1.json`
- ui_business agent_id `f70f820e-0e65-4e56-8383-95a766fe7bcb` owned `App/UI`
- ai_privacy agent_id `4e7ae923-9c3d-4b6e-a2ee-dae15618403c` owned `App/AI`
- children validate: ok (host_checked=false; controller journal owns final host stop)

## Build

- command: xcodebuild DocBrief scheme → iphonesimulator (leased UDID `C83D64D9-AB8C-4908-B82B-53091BCC4F9A`)
- result: succeeded
- log: `build.log`
- evidence: `evidence/build.json`

## Domain tests

- selector: `-only-testing:DocBriefDomainTests` (7 tests)
- result: succeeded
- log: `domain.log`
- covers: review labels, navigation routes, consent grant/revoke, action feedback persistence, outbound gate, brief catalog

## Runtime smoke

- install/launch: succeeded; pid in `launch.log`
- screenshot: `smoke.png`
- evidence: `evidence/smoke.json`
- configuration_status: unconfigured (no DEEPSEEK_API_KEY)

## Candidate

- status: candidate_unaccepted
- name: `0ddb3670393a-f526913024b3`
- receipt: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/artifacts/candidates/0ddb3670393a-f526913024b3/receipt.json`
- receipt_sha256: `c0d3d02197a803ff76910252214cd57e6722a534044eccc6f10ead7238264f2b`
- app_content_sha256: `f526913024b30076efa2ad3d1463cf25393f48aec238260e49f5e88c03ed3473`

## Frame → page / component (native; full visual judgment deferred)

| frame_id | page / component | runtime smoke shot |
|---|---|---|
| home-empty | `App/UI/HomeView.swift` Start brief | `smoke.png` (home empty) |
| capture-import | `App/UI/ImportCaptureView.swift` | pending accept |
| fields-review | `App/UI/RecognitionReviewView.swift` | pending accept |
| brief-detail-filled | `App/UI/BriefDetailView.swift` | pending accept |
| chat-extract | `App/UI/ChatExtractView.swift` + RuntimeForm | pending accept |
| summary-card | `App/UI/SummaryCardView.swift` | pending accept |
| tts-briefing | `App/UI/TTSBriefingView.swift` + BriefingTTS | pending accept |
| settings-privacy | `App/AI/SettingsPrivacyView.swift` + ConsentSheet | pending accept |

Assets: none declared in PM visual manifest for product embedding.

## symbol_map

| route_id | path#Symbol |
|---|---|
| HomeTab | App/UI/HomeView.swift#HomeView |
| NewBrief | App/UI/NewBriefView.swift#NewBriefView |
| ImportCapture | App/UI/ImportCaptureView.swift#ImportCaptureView |
| RecognitionReview | App/UI/RecognitionReviewView.swift#RecognitionReviewView |
| BriefDetail | App/UI/BriefDetailView.swift#BriefDetailView |
| ChatExtract | App/UI/ChatExtractView.swift#ChatExtractView |
| ActionReview | App/UI/ChatExtractView.swift (inline Save/Not this) |
| SummaryCard | App/UI/SummaryCardView.swift#SummaryCardView |
| TTSBriefing | App/UI/TTSBriefingView.swift#TTSBriefingView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/SettingsPrivacyView.swift#LegalPagesView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |

## SwiftUI references used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, navigation, keyboard via RuntimeForm)

## Gaps

- G1: `ai_key` UNKNOWN / local_only — outbound AI disabled until Secrets.xcconfig `DEEPSEEK_API_KEY` or authorized config; honest unconfigured UI
- G2: privacy/terms/support external URLs UNKNOWN — local bundle HTML pages load; external links deferred
- G3: CloudKit UNKNOWN — local AtomicCodableStore only
- G4: operator pricing intent (`unlimited briefs` unlock) deferred — free_app_only; `operator_pricing_deferred_free_app_only`
- G5: Feishu row / delivery card deferred per operator
- G6: independent eight-domain + per-frame visual acceptance not run (candidate_unaccepted by design)

## instrumentation

- timing spans: implementation, integration_build, domain_tests, runtime_smoke + milestones compile_succeeded / core_smoke_completed / candidate_published
- simulator lease: UDID `C83D64D9-AB8C-4908-B82B-53091BCC4F9A` (iPhone 17)

## lessons_candidates

- Cursor child spawn receipts need top-level `launch_ref`/`launch_sha256` for `children validate` message binding even when spawn_kwargs prompt already points at the launch file.
- P1 preparation consume on Cursor runtime must use `bin/cursor-package ultra-lite preparation consume` (codex_package.preparation is forbidden).
