# PitchCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: 4179ae95-b51f-429c-859c-5eb174b28771  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: 025f0d83d669b1d4c31dfabb13d085ddfd42cea01bc13866f511746b2143c782  
pm_visual_manifest_sha256: 37f0534c682301ff11f167d2408eb2481d395f67260203b0f52e821b0ce0de22  
preparation_seal_sha256: 15a2fdf80baf872f03fe0c6a64ad5b293eefd740273de4a0865e83e1b007df6c  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T073212Z-4039fa46/product`
- branch: `main`
- commit: `0c9a46961a1b19bfe70c2b422641a07dd3d2a2e7`
- bundle_id: `com.lingguang.pitchcue`
- remote: `git@github.com:xy-gty/xy-gty.git` (not pushed this stage)

## Foundation / preparation

- Consumed sealed preparation into product (PitchCueDomain + Vendor/AppRuntimeCore)
- `factory.ultra_lite_foundation check` OK (AppRuntimeCore 1.0.0)
- Production calls: `AIConsentGate`, `AtomicCodableStore`, `KeychainCredentialStore`, `PhotoImportSession`, `RuntimeForm`, `TypedNavigationStore`

## Build / tests / smoke

- Build: `xcodebuild -project PitchCue.xcodeproj -scheme PitchCue` → succeeded (`build.log`)
- Domain tests: `PitchCueDomainTests` 8/8 passed (`domain.log`) — Keep/Discard, consent grant/revoke, second-call feedback encoding, identity
- Simulator lease: iPhone 17 Pro `8843C141-E2FE-4DEA-A58F-0A63A5C649EF` (iOS-26-4)
- Install + launch `com.lingguang.pitchcue` succeeded; smoke screenshot `smoke-home.png`
- Candidate: `candidate_unaccepted` `0c9a46961a1b-529d64745e90`  
  receipt: `artifacts/candidates/0c9a46961a1b-529d64745e90/receipt.json`  
  receipt_sha256: `4ff1d3b8abc4b7ce18dd671ac6ea675483c88b3909c1d78ac3bc2447710c2a8a`

## Frame → page mapping (native; visual verdict pending Acceptance)

| frame_id | page / component | smoke shot |
|----------|------------------|------------|
| home-empty | PracticeHomeView + PracticeStripView skeleton | smoke-home.png (core smoke only) |
| capture-import | CaptureImportView | pending Acceptance |
| coach-chat | CoachChatView + RuntimeForm | pending Acceptance |
| plan-review | PlanReviewView (Keep/Discard/Edit) | pending Acceptance |
| practice-floor | PracticeFloorView + strip + WaveformView | pending Acceptance |
| pitch-feedback | PitchFeedbackView + TunerDialView | pending Acceptance |
| settings-privacy | SettingsPrivacyView + ConsentSheet | pending Acceptance |

Branding assets deferred: solid violet placeholder AppIcon only (`branding_assets_deferred`).

## Config / gaps (local_only — not Builder blockers)

- `ai_key_unavailable` / DeepSeek key UNKNOWN — outbound AI off; local draft plan path remains
- `feishu_row_not_yet_created` (`record_match_error=0`) — gap; audit persisted
- privacy/terms/support URLs UNKNOWN — local Legal HTML pages load
- CloudKit UNKNOWN gap
- `operator_pricing_deferred_free_app_only` — no StoreKit/paywall/coins/ATT
- Device camera / long mic: 真机待测; Simulator entries reachable

## symbol_map (key)

- `AppModel` — sessions/plans/turns/beds/pitch + consent + coach
- `DeepSeekClient.coachPractice` — outbound with consent permit re-check
- `TTSCoach` / `AudioBedEngine` / `PitchDetector` / `TunerDialView` / `PracticeStripView`
- `AIConsentContract.makeGate` → `AIConsentGate`
- `PitchCueStores.*` → `AtomicCodableStore` / `KeychainCredentialStore`

## SwiftUI guidance used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, navigation stack, accessibility labels on primary CTAs)

## Evidence refs

- `evidence/build.json`, `evidence/smoke.json`
- `evidence/config-audit.stdout.txt`, `evidence/config-audit.receipt.json`
- `build.log`, `domain.log`, `install.log`, `launch.log`, `smoke-home.png`
- `MAP.progress.md`

## Notes

- Full eight-domain / live AI / per-frame visual judgment owned by `ai_app_accept`
- package_acceptance remains `pending` / `candidate_unaccepted`
