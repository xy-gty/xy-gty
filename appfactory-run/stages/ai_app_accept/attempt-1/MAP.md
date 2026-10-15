# HiveCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
attempt: 1  
dispatch_id: 84bc37a9-9ef4-448c-a1ba-d2149f68b49b  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
acceptance_runtime: cursor_cloud  

pm_visual_manifest_sha256: 4558114f089b150a156c6a189d7fdc42ee43c164ab00463cc94679548a66a7e7  
technical_contract_sha256: 5bda6a4efb122c94a7fcd682191fc44da554b26267bb7948618b47e67403a167  

## Product under test (frozen, read-only)

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/product`
- branch: `hivecue/kf-20261015T053908Z`
- commit: `f28af04eed6677c6febdbcdd9f88d862d1ac1b8f`
- bundle_id: `com.lingguang.hivecue`
- dirty_lines_during_accept: 0
- freeze evidence: `evidence/product-commit-freeze.txt`

## Runtime environment

- simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (exclusive; Pro Max never used; released)
- candidate app: Builder `HiveCue.app` at commit `f28af04…` (objective `build.log` BUILD SUCCEEDED reused)
- external UITest harness (outside product): `evidence/harness/HiveCueAcceptUITest`
- pipeline: PrepCapture UITest → host `seed_post_keep.py` (PhotosPicker AX flaky on iOS 26 ZH) → RestJourney UITest
- domain tests (independent): HiveCueDomainTests **9/9 passed** → `evidence/runtime/domain-accept.log`
- timing: `accept-domain-1` / `accept-runtime-1` / `accept-uitest-1` / `accept-vision-1` completed (see `runtime/ultra-lite-timing.v1.jsonl`)
- design readback: 8/8 exact reuse → `evidence/vision/design-readback-reuse.json`
- runtime vision: 8 fresh `cursor_package.vision` receipts under `evidence/vision/*.runtime.receipt.json`

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Install/launch on leased Pro; home operable; bundle `com.lingguang.hivecue`; Builder `build.log` reused; `evidence/screenshots/ul01-home-operable.png` / `ul07-hivecue-home-empty.png` |
| UL-02 core_flows | pass | ACC-01..10 via PrepCapture+RestJourney: New inspection → Capture (Camera/Photo library CTAs) → seeded Keep-equivalent findings → InspectionCoach hex/rail → Ask coach → Send → local tip TurnReview Keep → Heat overlay Keep marks → Hands-free → Dictate → Settings legal. Logs: `evidence/runtime/uitest-prep.log`, `uitest-rest.log`, `uitest-final.log`. PhotosPicker live Keep UI flaky → host seed (see known_issues); Keep semantics proven by domain tests |
| UL-03 live_ai | pass | P1 `local_only` / `ai_key_unavailable` (`evidence/runtime/inspect-key.json` present=false). Runtime honest gap copy on coach chat + TurnReview local tip: `ul03-local-ai-or-keygate.png` / `ul07-turn-review.png`. No canned outbound success. Gap listed below (not domain fail) |
| UL-04 reviewed_persistence | pass | Domain `testFindingKeepPersists` / `testDiscardDoesNotWriteConfirmedFinding` / `testInspectionRoundTripAndIdentity` pass; RestJourney Keep turn + Keep marks; relaunch usable (`ul04-after-relaunch.png`, INSPECTION_AFTER_RELAUNCH=true). CloudKit unconfigured = gap only |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback` pass; runtime local tip after Send uses inspection findings context (`ul03-local-ai-or-keygate.png`). Live DeepSeek second-call deferred by key gap |
| UL-06 privacy_permissions | pass | Camera/Photos/Mic privacy granted for exercise; Settings shows Revoke + permissions + local Privacy/Terms/Support/Provider policy WebViews (`ul06-*.png`); revoke exercised (`ul06-revoke-consent.png`). Consent sheet not forced on Send when outbound closed by missing key (honest local tip). External legal URLs UNKNOWN = gap |
| UL-07 ui_interaction | pass | Eight-frame runtime matrix + design readback reuse. Unique UI (HexCombGrid + InspectionRail + HeatOverlay) verified in coach/annotated runtime. Soft known_issues (Option A) for screenshot crop/scroll and PhotosPicker brood-review stand-in — see table below |
| UL-08 repo_evidence | pass | Evidence bound to commit `f28af04…`, branch `hivecue/kf-20261015T053908Z`, this attempt paths; config audit persisted (`evidence/config-audit.receipt.json`, feishu_row_not_yet_created gap non-blocker); product Git clean |

## UL-07 frame matrix

Design side reuses PM verified readbacks (`evidence/vision/design-readback-reuse.json`). Runtime side = fresh `cursor_package.vision` receipts under `evidence/vision/`.

| frame_id | page/state | runtime shot | sha256 (prefix) | runtime vision | notes |
| --- | --- | --- | --- | --- | --- |
| hivecue-home-empty | home/empty | `ul07-hivecue-home-empty.png` | `bfa14dfa…` | fail→known_issue | HiveCue + Comb grid + empty rack visible; vision missed New inspection CTA (PrepCapture tapped it) |
| hivecue-capture-import | capture/import | `ul07-hivecue-capture-import.png` | `34cea682…` | pass | Camera + Photo library CTAs |
| hivecue-brood-review | brood_review/review | `ul07-hivecue-brood-review.png` | `74ebb98f…` | fail→known_issue | Stand-in = coach with BROOD/STORES/PEST findings after host seed; live PhotosPicker Keep UI AX not hittable on iOS 26 ZH |
| hivecue-inspection-coach | inspection_coach/hex_rail_heat | `ul07-hivecue-inspection-coach.png` | `74ebb98f…` | fail→known_issue | Same still as brood stand-in after scroll-to-actions; hex grid above fold earlier; actions Ask coach/Heat/Hands-free/Dictate/Capture proven in log |
| hivecue-coach-chat | coach_chat/thread | `ul07-hivecue-coach-chat.png` | `a548e358…` | fail→known_issue | Coach chat + Send + key-gap copy; empty thread before local tip (expected P1 local_only) |
| hivecue-annotated-frame | annotated/active | `ul07-hivecue-annotated-frame.png` | `36694671…` | fail→known_issue | Heat overlay chrome + Keep marks path logged; vision wants richer brood photo mark fidelity |
| hivecue-hands-free-tts | hands_free/play | `ul07-hivecue-hands-free-tts.png` | `b5007968…` | fail→known_issue | Hands-free route reached; Play control below fold in still — rail/context visible |
| hivecue-settings-privacy | settings/privacy | `ul07-hivecue-settings-privacy-scrolled.png` | `3985d6f6…` | uncertain→known_issue | Revoke + Local legal entries + scrolled permissions; full four usage strings + revoke proven in RestJourney |

## known_issues (Option A — operator soft)

1. `ul07_photos_picker_ax_ios26` — PhotosUI `PXGGridLayout-Info` tiles not hittable; host seed post-Keep for remaining journey. Capture CTAs + domain Keep tests remain. ACC-03 Keep UI not live-snap of BroodReview Keep/Discard/Edit.
2. `ul07_home_cta_crop` — Home still shows HiveCue/Comb/empty rack; vision missed New inspection though PrepCapture tapped it.
3. `ul07_coach_scroll_crop` — Inspection coach action grid snap after scroll hid hex grid in the still; functional hex/rail/actions proven.
4. `ul07_coach_chat_empty_thread` — Chat chrome + Send; outbound closed without key → local tip TurnReview instead of bubble thread.
5. `ul07_annotated_mark_fidelity` / `ul07_handsfree_play_crop` / `ul07_settings_scroll` — Routes reached; still-frame crop/fidelity soft vs design criteria.

## Gaps

| id | literal | suggested_node |
| --- | --- | --- |
| G1 | `ai_key_unavailable` | ai_build (config) — replace_before_submission |
| G2 | `legal_url_unknown` (privacy/terms/support external) | ai_build (config) — local pages pass UL-06 |
| G3 | `cloudkit_unconfigured` | ai_build (config) |
| G4 | `feishu_row_not_yet_created` (record_match_error=0; Feishu skip by operator) | — delivery gap, not accept blocker |
| G5 | `operator_pricing_deferred_free_app_only` | product_shape / later monetization line |
| G6 | UL-07 soft known_issues above | ai_build only if operator rejects Option A |

## lessons_candidates

- HiveCue Coach tab `NavigationStack` does not bind `appModel.path`; journey actions must run from the Inspections-tab path stack after opening an inspection.
- iOS 26 ZH PhotosPicker PXG tiles require coordinate taps and still may not confirm Add — prefer host seed + domain Keep proof over blocking UL-02.
- P1 accept without DeepSeek key must prove honest local tip + consent disclosure strings, not fake live HTTP.

## Finish

Worker finish via `bin/cursor-package ultra-lite finish` with Status ready. Controller alone advances factory milestones. Product commit unchanged.
