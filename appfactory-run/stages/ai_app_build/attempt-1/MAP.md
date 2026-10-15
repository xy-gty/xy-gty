# MAP — ai_app_build attempt-1 CellarCue

Status: ready

pm_visual_manifest_sha256: d1deb007e4d4fbe223dd1b426b3ec2a150d8c85c9c781fea812e7f7c07504497  
technical_contract_sha256: 5b0e7e1cf2ab96ca937e5fe9661287dbdb46203ee0a885a281a14e8ec8097400  
preparation_seal_sha256: aee8d36f04b7e7c2b7e52f01068dc273f622275e1eae5ff3c184c16c98efa237  
preparation_consumed_sha256: 20b8b860f392c366ae8f5661915a70685961c28b2863e05c2a05a787e4ad7069  
foundation_version: 1.0.0  
ultra_lite_execution_revision: p1  
candidate: eded2779dc48-a36f3c574978 (candidate_unaccepted)  
candidate_receipt_sha256: 59a5ccc703d95a11a91fba393798b53d84f5d9522e949ca4f4ca348f5eba9785

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T185351Z-25a1f937/product` (symlink `cellarcue` → `product`)
- branch: `cellarcue`
- commit: `eded2779dc48944bf1cc943f255e972d423701ed`
- remote: `git@github.com:xy-gty/xy-gty.git` branch `cellarcue`
- bundle_id: `com.lingguang.cellarcue`
- Feishu CONTROLLER_DELIVERY: skip (operator rule)

## Build / tests / smoke

| Step | Result | Evidence |
|------|--------|----------|
| xcodebuild Debug iphonesimulator | succeeded | `build.log` |
| CellarCueDomainTests (11) | succeeded 0 failures | `domain.log` |
| simctl install/launch B14CC0EA | succeeded pid 33463 | `install.log` `launch.log` |
| smoke screenshot | observed | `smoke-home.png` |
| candidate publish | candidate_unaccepted | `artifacts/candidates/eded2779dc48-a36f3c574978/` |

Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (never Pro Max).

## Preparation & foundation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` intact; production calls: `AIConsentGate`, `AtomicCodableStore` (via `CellarStore`), `KeychainCredentialStore`, `TypedNavigationStore`
- Domain extended after consume: `CellarStore`, `CellarComplianceCopy`, device/allergy literals

## Frame → page / component → smoke

| frame_id | page / component | runtime shot |
|----------|------------------|--------------|
| cellarcue-home-empty | `CellarHomeView` + `CellarRowBinGridView` + `LabelOCRHeroCardView` + `DrinkingWindowTimelineView` + `ComplianceBanner` | `smoke-home.png` (home empty; grid/timeline below fold) |
| cellarcue-capture-camera | `CameraPicker` sheet + subject chips via captureSubject | pending independent accept |
| cellarcue-label-ocr | `LabelResultView` | pending independent accept |
| cellarcue-window-chat | `WindowChatView` | pending independent accept |
| cellarcue-rack-card | `RackCardView` | pending independent accept |
| cellarcue-voice-pull | `VoiceNoteView` / `PullBriefView` | pending independent accept |
| cellarcue-consent-ai | `ConsentSheet` | pending independent accept |
| cellarcue-settings-privacy | `SettingsPrivacyView` + local Legal HTML | pending independent accept |

Native adaptation: lavender `#EEF2FF` canvas, indigo `#3730A3`, accent `#EA580C`; signature UI is row/bin grid + large OCR hero + aging timeline (not MixCue/SporeCue/WingCue/FrameCue/RuleCue/StopCue twins). No Vinocell in App copy. No AppIcon/LaunchScreen.

## symbol_map

- `AppModel` — capture/import, OCR identify, coach, rack card, TTS, consent, persistence
- `CellarStore` / `CellarCueState` — AtomicCodableStore restart restore
- `DeepSeekClient` — LabelOCR + window/pairing (blocked until key + consent)
- `ComplianceBanner` / `CellarComplianceCopy` — dual disclaimers + 21+
- `CellarRowBinGridView` / `LabelOCRHeroCardView` / `DrinkingWindowTimelineView` — signature UI
- `AIConsentGate` via `AIConsentContract.makeGate` — grant/revoke/permit
- Permissions: Camera/Photos/Mic/Speech usage strings in `project.yml` + `PrivacyUsageCopy`

## SwiftUI guidance used

- `skills/swiftui-expert-skill/SKILL.md` (entry; NavigationStack + ObservableObject ownership)

## Children

- `child_slots: 0` / reserved slots including parent: 1 → no `ultra-lite-worker` spawn; parent-only implementation (not `codex_capacity_unavailable` — capacity matched reservation).

## Gaps (P1 local_only / Option A soft)

| Gap | Kind | Notes |
|-----|------|-------|
| ai_key_unavailable | gap | DeepSeek key absent; honest unconfigured banner; outbound disabled |
| privacy_url / terms_url / support_url UNKNOWN | gap | local Legal HTML loads; remote URLs replace_before_submission |
| cloudkit UNKNOWN | gap | local persistence only |
| feishu_row_not_yet_created | gap | CONTROLLER_DELIVERY skip |
| independent eight-domain accept | pending | Acceptance stage owns live AI / per-frame visual / full privacy matrix |

known_issues (Option A soft, non-core): UI smoke XCTest not executed this attempt (domain tests + manual install/launch/screenshot used for Builder smoke); full scroll of home grid on smoke shot below fold.

## lessons_candidates

- Cursor P1 consume must use `bin/cursor-package ultra-lite preparation consume` (Codex module raises `ultra_lite_runtime_forbidden:codex`).
