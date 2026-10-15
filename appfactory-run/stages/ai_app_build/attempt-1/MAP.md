# MAP — ai_app_build attempt-1

Status: ready

dispatch_id: 59eaa24c-6d26-48c7-8b52-9df84593f079
run_id: kf-20261015T174239Z-859f7eed
ai_profile: ultra_lite
ultra_lite_execution_revision: p1
pm_visual_manifest_sha256: 0263b2c8eadb63c6c401b4d4bde562b5079f4c9e11498059822d9b86a00639d2
technical_contract_sha256: cde02f702a052b37ad3f7a1eb8dd16836639377a1b10261f40bfd83c697e5356
preparation_seal_sha256: 18f26f1601f171a8128d4c648a103c9a542b1987f966bd4998fd1dd7e681b2ea
preparation_consumed_sha256: 1e2925726e32e0ab0563eb5fba0161e6472befd6abe953a7f36e032a0f30e0b2
foundation_version: 1.0.0

## Product

- app_name: SporeCue
- product_dir: sporecue/ (symlink → product)
- development_bundle_id: com.lingguang.sporecue
- palette: #9A3412 / #FFF7ED / #0284C7
- signature UI: vertical species-confidence stack + oversized gill/pore closeup bar + edible/warning chip rail
- hard compliance: every ID/edibility/foraging surface shows 「非可食认证 / not an edibility certification」; never implies safe to eat
- permissions: Camera / Photos / Microphone / Speech Recognition
- no AppIcon / LaunchScreen
- no competitor names (Shroomify / Pilze 123) in App copy
- NOT MixCue/WingCue/FrameCue/RuleCue/StopCue/ClosetCue/ScoutCue twins

## Repo

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T174239Z-859f7eed/product`
- deliver_alias: sporecue → product
- branch: sporecue (pushed `sporecue-kf-20261015T174239Z-859f7eed`)
- remote: git@github.com:xy-gty/xy-gty.git
- commit: `953628045629d96380e8792457acd895f19955ed`
- Feishu CONTROLLER_DELIVERY: skip

## Preparation / foundation

- consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- receipt: `preparation-consumed.v1.json`
- Vendor/AppRuntimeCore installed as local package dependency (unchanged sealed members)
- production call sites:
```
App/Services/AppModel.swift:AIConsentGate
App/Services/AppModel.swift:TypedNavigationStore
```
- ForageStore wraps AtomicCodableStore<SporeCueState>
- TypedNavigationStore<SporeCueRoute> for path restore
- AIConsentGate via AIConsentContract.makeGate
- KeychainCredentialStore service `sporecue.ai`

## Frame → page mapping

| frame_id | page / component | runtime screenshot |
|---|---|---|
| sporecue-home-empty | FieldHomeView | evidence/screenshots/home-empty.png / candidate-smoke.png |
| sporecue-id-result | IDResultView (stack + closeup + chips) | evidence/screenshots/id-result.png |
| sporecue-lookalike-chat | LookalikeChatView | pending independent acceptance |
| sporecue-overlay-annotate | OverlayAnnotateView | pending independent acceptance |
| sporecue-voice-note | VoiceNoteView | exercised via sheet entry in UI |
| sporecue-consent-ai | ConsentSheet | pending live AI key path |
| sporecue-settings-privacy | SettingsPrivacyView + local Legal | UI smoke Settings + revoke |

## Build / tests / smoke

- simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (never Pro Max)
- build: succeeded (`build.log`)
- domain tests: SporeCueDomainTests 12/12 passed (`domain.log`)
- UI smoke: testFieldHomeSignatureAndSettings passed (`ui-smoke.log`)
- install/launch: succeeded pid observed; smoke screenshot captured
- candidate: `artifacts/candidates/953628045629-ed4e4e7deb04/` status=candidate_unaccepted
- receipt_sha256: 6c0259a294f8801ffab58a284042dd7d82ba94c635ff1eb17e2d4e0ec9735f6d

## Core selling-point flows exercised

1. Field home signature UI + disclaimer + Shoot/Import + coach bar (runtime screenshot + UI smoke)
2. Settings revoke AI surface (UI smoke)
3. Seeded ID result: ranked species-confidence stack + oversized gill/pore closeup + Annotate (id-result.png)
4. Persistence restore of confirmed/identified finds on home (home-with-find.png)
5. Domain tests: confirm/reject labels, consent gate grant/revoke, chip informationalOnly, field brief disclaimer, forage store round-trip, feedback context encode

## Config / gaps (P1 local_only — non-blocking)

- config_mode: local_only
- ai_key: UNKNOWN / unconfigured — outbound disabled; honest banner shown
- privacy_url / terms_url / support_url / cloudkit: UNKNOWN gaps
- record_match_error=0 feishu_row_not_yet_created — persist-audit saved; not a blocker
- Feishu CONTROLLER_DELIVERY skip (operator)

## known_issues (Option A soft)

- Live DeepSeek species ID / coach replies require DEEPSEEK_API_KEY (honest unconfigured path verified)
- PhotosPicker accessibility identifier flaky across iOS versions; Import still visible as label
- Closeup bar photo decode from seeded path may show russet fallback when file bytes are minimal — Capture/Import path writes real JPEGs
- Full eight-domain acceptance / per-frame visual judgment deferred to ai_app_accept
- child_slots=0 — no native children; single-slot serial Builder

## symbol_map (key)

- SporeCueApp / RootNavigationView / FieldHomeView / IDResultView
- SpeciesConfidenceStackView / GillPoreCloseupBarView / CautionChipRailView
- AppModel / DeepSeekClient / ForageStore / ChipRailBuilder / OverlayAnnotator / FieldBriefBuilder
- AIConsentGate / ConsentSheet / SettingsPrivacyView / LocalLegalWebView
- SpeechRecognitionService / VoiceNoteRecorder / TTSPlayer / CameraPicker

## SwiftUI references used

- skills/swiftui-expert-skill/SKILL.md (state ownership, navigation, accessibility)

## Children

- child_slots: 0 — no ultra-lite-worker Tasks reserved/spawned

## Verdict

ready — candidate_unaccepted local Simulator App published; independent acceptance still pending.
