# MixCue — ai_app_build MAP

Status: ready  
Verdict: ready  
Stage: ai_app_build  
attempt: 1  
dispatch_id: bf79b15b-a267-4435-a567-f9992c38d701  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
child_slots: 0  

technical_contract_sha256: a6a5c05c1334f671c59c636a25afe98e5c227a09bda4cd85692dcaed703fd7ac  
pm_visual_manifest_sha256: ac86f75a0af01b38ef8acf96bd9877461ba04f5812cd31370b5d7eef010d46bf  
preparation_seal_sha256: bd32baadb2adae47b88a1eb2ab986452bc35ecdd62fb42a1b46f4bc3ebe87ba2  
preparation_consumed: preparation-consumed.v1.json  

## Product

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T162417Z-7519c0dc/product`
- identity product_dir: `mixcue` (`mixcue` → `product` symlink)
- branch: `mixcue/kf-20261015T162417Z-7519c0dc` (independent branch pushed to xy-gty)
- push: succeeded → `origin/mixcue/kf-20261015T162417Z-7519c0dc` (evidence/git-push.log)
- commit: `5e418cc1c0f00d290882f5b00d124df373c3734b`
- bundle_id: `com.lingguang.mixcue`
- remote target: `git@github.com:xy-gty/xy-gty.git`
- palette: `#E11D48` / `#FFF1F2` / `#CA8A04`
- unique UI: BottleRailView + NextPourCardView + GarnishChipRowView (≠ WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket)
- AppIcon/LaunchScreen: not generated (operator hard; empty Assets.xcassets only, ASSETCATALOG_COMPILER_APPICON_NAME="")
- Feishu CONTROLLER_DELIVERY: skip (operator)
- free_app_only: no StoreKit / paywall / coins / ATT
- competitor names Cocktail Party / Bevnap: absent from App copy

## Foundation / preparation

- Consumed sealed preparation via `bin/cursor-package ultra-lite preparation consume`
- `Vendor/AppRuntimeCore` local SwiftPM dependency; production calls `AtomicCodableStore`, `KeychainCredentialStore`, `AIConsentGate`, `TypedNavigationStore`; camera via `UIImagePickerController`, photos via `PhotosPicker` (+ PhotoImportSession available in foundation)
- Domain package `MixCueDomain` from seal + Builder MixStore / PourBoardBuilder extensions
- Foundation binding version 1.0.0 members match bound hashes

## Build / tests / smoke

- Simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` only; NEVER Pro Max
- DerivedData: attempt-local `stages/ai_app_build/attempt-1/DerivedData`
- Build: **BUILD SUCCEEDED** (`build.log` / `evidence/xcodebuild.log`)
- Domain tests: **10/10 TEST SUCCEEDED** (`MixCueDomainTests`, `domain.log`)
- Smoke: install + launch + screenshot `smoke.png` (Bar Home empty: bottle-rail + next-pour card + Shoot/Import + coach bar; honest AI-unconfigured banner)
- Candidate: `candidate_unaccepted` `5e418cc1c0f0-43e6f75b7bb6` → `artifacts/candidates/5e418cc1c0f0-43e6f75b7bb6/receipt.json` sha256 `da7337914e4c37b2e2ef269826f7edddf9df25c64782247c929b4c937f0186c2`
- Config audit: gap soft (`audit_output_unclassified` / feishu row not created); `ai_key` UNKNOWN; blocker=false; stdout persisted

## Frame → page / component

| frame_id | page / component | runtime smoke |
|----------|------------------|---------------|
| mixcue-home-empty | BarHomeView + BottleRail + NextPourCard + GarnishChipRow | smoke.png (core smoke) |
| mixcue-capture-camera | CameraPicker (UIImagePickerController) | pending independent accept |
| mixcue-id-result | IDResultView bottle-rail + label cues | pending independent accept |
| mixcue-recipe-chat | RecipeChatView + speech ingress | pending independent accept |
| mixcue-pour-board | PourBoardView next-pour + garnish chips + TTS | pending independent accept |
| mixcue-voice-note | VoiceNoteView mic recorder | pending independent accept |
| mixcue-consent-ai | ConsentSheet DeepSeek fields | pending independent accept |
| mixcue-settings-privacy | SettingsPrivacyView + LocalLegalWebView | pending independent accept |

## symbol_map

| route_id | path#Symbol |
|----------|-------------|
| BarHome | App/UI/BarHomeView.swift#BarHomeView |
| IDResult | App/UI/IDResultView.swift#IDResultView |
| RecipeChat | App/UI/RecipeChatView.swift#RecipeChatView |
| PourBoard | App/UI/PourBoardView.swift#PourBoardView |
| VoiceNote | App/UI/VoiceNoteView.swift#VoiceNoteView |
| Settings | App/AI/SettingsPrivacyView.swift#SettingsPrivacyView |
| LegalPages | App/AI/LocalLegalWebView.swift#LocalLegalWebView |
| ConsentSheet | App/AI/ConsentSheet.swift#ConsentSheet |
| BottleRail | App/UI/MixCueTheme.swift#BottleRailView |
| NextPourCard | App/UI/MixCueTheme.swift#NextPourCardView |
| GarnishChipRow | App/UI/MixCueTheme.swift#GarnishChipRowView |
| AppModel | App/Services/AppModel.swift#AppModel |
| DeepSeekClient | App/AI/DeepSeekClient.swift#DeepSeekClient |
| PourBoardBuilder | Sources/MixCueDomain/ReviewControls.swift#PourBoardBuilder |
| MixStore | Sources/MixCueDomain/Stores.swift#MixStore |
| AIConsentGate wiring | Sources/MixCueDomain/ReviewControls.swift#AIConsentContract |

## SwiftUI references used

- `skills/swiftui-expert-skill/SKILL.md` (state ownership, NavigationStack path binding, sheet presentation)

## Gaps (Option A soft / P1 local_only)

- privacy_url / terms_url / support_url: UNKNOWN → replace_before_submission
- ai_key: UNKNOWN (honest unconfigured outbound; local capture/TTS/pour board work)
- cloudkit: UNKNOWN
- feishu_row_not_yet_created / config audit unclassified: non-blocker
- Full eight-domain live AI / per-frame visual judgment: deferred to independent ai_app_accept
- known_issues (Option A soft): garnish chip row may sit below fold on empty home until scroll; covered on pour board route

## lessons_candidates

- Candidate publish evidence refs and dispatch_ref must be stage-attempt-relative (`codex_dispatch.md`, `build.json`, `smoke.json`); absolute DerivedData app path works when stage-rooted copy `MixCue.app` is used.
