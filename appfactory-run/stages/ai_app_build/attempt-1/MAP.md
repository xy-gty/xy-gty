# ScoutCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: 22a1a1aa-1764-426f-b90d-5d2d6166d6ab  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: d3e76b0d232df6307e64e68865cfecf4d83f0a5cc8687d954fdb93efbcd2d801  
pm_visual_manifest_sha256: 8109b7525dc308cf4d9d0e4ef418350f42862f696df35c33940283b7b8794d4e  
preparation_seal_sha256: 9bee7a1ec0d03068742281addd7f16ae6fd961bc0c0eaa09b791e6cf836b9205  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/product`
- identity product_dir: `scoutcue` (delivery naming; factory run folder is `product/`)
- branch: `main`
- commit: `8d33ae437c6acc26021c90036c5f816a6f3d3033`
- bundle_id: `com.lingguang.scoutcue`
- remote: `git@github.com:xy-gty/xy-gty.git` (not pushed this stage; prefer independent branch at delivery)

## Foundation / preparation

- Consumed sealed preparation into product (ScoutCueDomain + Vendor/AppRuntimeCore)
- `factory.ultra_lite_foundation check` OK (AppRuntimeCore 1.0.0)
- Production calls: `AIConsentGate`, `AtomicCodableStore`, `KeychainCredentialStore`, `TypedNavigationStore` (via stores/navigation); photo import via PhotosPicker/Camera + file save; forms via native TextField + toolbar Done patterns

## Build / tests / smoke

- Build: `xcodebuild -project ScoutCue.xcodeproj -scheme ScoutCue` → succeeded (`build.log`)
- Domain tests: `ScoutCueDomainTests` 8/8 passed (`domain.log`) — Keep/Discard labels, consent grant/revoke, second-call feedback encoding, identity
- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7`
- Install + launch `com.lingguang.scoutcue` succeeded (pid 31499); smoke screenshot `smoke.png`
- Candidate: `candidate_unaccepted` `8d33ae437c6a-c57d1802c565`  
  receipt: `artifacts/candidates/8d33ae437c6a-c57d1802c565/receipt.json`  
  receipt_sha256: `21bdcd49e30257a8822529c89eb58653449a828d94f5645fb27643b54b0ff6b4`

## Frame → page mapping (native; visual verdict pending Acceptance)

| frame_id | page / component | smoke shot |
|----------|------------------|------------|
| home-empty | ScoutsHomeView + SoftCardStackView + SkyArcTimelineView | smoke.png (core smoke only) |
| capture-import | CaptureImportView + CameraPicker | pending Acceptance |
| scout-card | SceneReviewView / ScoutCardDetailView | pending Acceptance |
| coach-chat | CoachChatView + TurnReviewView + ConsentSheet | pending Acceptance |
| golden-overlay | GoldenOverlayView (soft pins, not measure rods) | pending Acceptance |
| tts-briefing | NextStopBriefingView + BriefingPlayer | pending Acceptance |
| dictate-note | DictateNoteView + SpeechRecognitionService | pending Acceptance |
| settings-privacy | SettingsPrivacyView + local Legal WebViews | pending Acceptance |

Branding assets deferred this round (no AppIcon/LaunchScreen generation).

## Config / gaps (local_only — not Builder blockers)

- `ai_key_unavailable` / DeepSeek key UNKNOWN — outbound AI off; local coach timing path remains
- `feishu_row_not_yet_created` (`record_match_error=0`) — gap; audit persisted
- privacy/terms/support URLs UNKNOWN — local Legal HTML pages load
- CloudKit UNKNOWN gap
- `operator_pricing_deferred_free_app_only` — no StoreKit/paywall/coins/ATT
- Device camera / mic / speech: 真机待测; Simulator entries reachable
- Feishu delivery tracker skipped per operator

## symbol_map (key)

- `ScoutsHome` → `App/UI/ScoutsHomeView.swift#ScoutsHomeView`
- `CaptureImport` → `App/UI/CaptureImportView.swift#CaptureImportView`
- `SceneReview` → `App/UI/SceneReviewView.swift#SceneReviewView`
- `ScoutCardDetail` → `App/UI/ScoutCardDetailView.swift#ScoutCardDetailView`
- `CoachChat` → `App/UI/CoachChatView.swift#CoachChatView`
- `TurnReview` → `App/UI/TurnReviewView.swift#TurnReviewView`
- `GoldenOverlay` → `App/UI/GoldenOverlayView.swift#GoldenOverlayView`
- `NextStopBriefing` → `App/UI/NextStopBriefingView.swift#NextStopBriefingView`
- `DictateNote` → `App/UI/DictateNoteView.swift#DictateNoteView`
- `Settings` / `LegalPages` → `App/AI/SettingsPrivacyView.swift#SettingsPrivacyView`
- `ConsentSheet` → `App/AI/ConsentSheet.swift#ConsentSheet`
- `SkyArcTimeline` → `App/UI/SkyArcTimelineView.swift#SkyArcTimelineView`
- `SoftCardStack` → `App/UI/SoftCardStackView.swift#SoftCardStackView`
- `AppModel` — shots/cards/plans/windows/overlays/turns/notes/briefings + consent + coach
- `DeepSeekClient.coachTiming` — outbound with consent permit re-check
- `AIConsentContract.makeGate` → `AIConsentGate`
- `ScoutCueStores.*` → `AtomicCodableStore` / `KeychainCredentialStore`

## SwiftUI guidance used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, NavigationStack path binding, accessibility labels on primary CTAs)

## Evidence refs

- `evidence/build.json`, `evidence/smoke.json`
- `evidence/config-audit.stdout.txt`, `evidence/config-audit.receipt.json`, `evidence/config-key-inspect.txt`
- `evidence/foundation-check.json`, `evidence/candidate-publish.json`
- `build.log`, `domain.log`, `install.log`, `launch-pid.log`, `smoke.png`
- `MAP.progress.md`

## Notes

- Full eight-domain / live AI / per-frame visual judgment owned by `ai_app_accept`
- package_acceptance remains `pending` / `candidate_unaccepted`
- Unique IA: sky-arc ephemeris + soft scenery card stack; ban DimCue measure twin / KnotCue rope carousel / all-black shell
