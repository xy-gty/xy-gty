# NightCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
attempt: 1  
dispatch_id: 4a6d927a-7937-481f-b0a7-8f173ac9b461  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
acceptance_runtime: cursor_cloud  

pm_visual_manifest_sha256: 1a4dadba3e29ffddbae1a77fc341df3ac1b5580d4e0bfd14f4e27686815248f0  
technical_contract_sha256: 72c5bea905cf48b0f721c2bceb6834b467d0108e2f088c97d597840b21a771dd  

## Product under test (frozen, read-only)

- path: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T075333Z-d3a0d226/product`
- branch: `nightcue/kf-20261015T075333Z`
- commit: `17f64efd1d5a8389cd47b0ebb1206304a07b49a0`
- bundle_id: `com.lingguang.nightcue`
- dirty_lines_during_accept: 0
- code_query: `code_query_blocked:codebase_memory_index_failed:FileNotFoundError:... codebase-memory-mcp` — navigation from upstream Builder MAP + runtime AX; no product edits

## Runtime environment

- simulator lease: iPhone 17 Pro `B14CC0EA-EA96-4E5A-B32A-3187A83346B7` (exclusive; Pro Max never used)
- independent build: **BUILD SUCCEEDED** → `evidence/build.log`
- domain tests: **9/9 TEST SUCCEEDED** → `evidence/domain-accept.log`
- UITest harness (outside product): `evidence/harness/NightCueAcceptUITest` — `SeededJourney` **TEST SUCCEEDED** → `evidence/runtime/uitest-seeded-final.log`
- Photos import: SwiftUI `PhotosPicker` not drivable by XCTest on this simulator locale; downstream coach/settings/TTS/annotate exercised via documented container seed `evidence/seed_simulator_state.py` after partial home→new session→capture entry run (`evidence/runtime/uitest-final-r*.log`)

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Leased Pro install/launch; bundle `com.lingguang.nightcue`; accept rebuild succeeded; `evidence/install.log`, `evidence/launch.log`, `ul07-nightcue-home-empty.png` |
| UL-02 core_flows | pass | Home/new session/capture entry (UITest); seeded session+frame+findings → Sessions stack → Night coach rail/overlays → Ask coach → local turn Keep; Annotate / Field cues / Dictate entry; `uitest-seeded-final.log`, screenshots under `evidence/screenshots/` |
| UL-03 live_ai | pass | P1 `local_only` / `ai_key_unavailable`; runtime honest copy + **local AI** rule coach turn after Send (simulator smoke + `ul03-local-ai-or-keygate.png`, `ul07-turn-review.png`); no canned outbound success; gap not domain fail |
| UL-04 reviewed_persistence | pass | Domain tests Keep/Discard/consent; seeded+UITest Keep turn; relaunch restores navigation/state (`ul04-after-relaunch.png`); CloudKit gap only |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback`; runtime local coach path uses session findings text on coach surface; live DeepSeek second-call deferred by key gap |
| UL-06 privacy_permissions | pass | Four usage strings in Settings list; Revoke AI consent tapped (`ul06-revoke-consent.png`); bundled local HTML in candidate app (`privacy.html`, `terms.html`, `support.html`, `provider-policy.html` per candidate receipt); external URL gaps |
| UL-07 ui_interaction | pass | Night-frame rail + exposure-diagnosis toggle visible on coach (`ul07-nightcue-night-coach.png`); palette #1E3A8A/#EFF6FF/#FBBF24; runtime vision receipts under `evidence/vision/*.runtime.receipt.json`; Option A soft issues where vision missed below-fold CTAs (UITest tapped them) |
| UL-08 repo_evidence | pass | Evidence bound to commit `17f64efd…`, branch, this attempt; config audit `feishu_row_not_yet_created` non-blocker; product git clean |

## UL-07 frame matrix (subset + PM design reuse)

Design readbacks: PM frozen `evidence/visual-readback/*.receipt.json` (manifest hash above). Runtime: fresh `cursor_package.vision` on accept screenshots.

| frame_id | runtime shot | runtime vision | notes |
| --- | --- | --- | --- |
| nightcue-home-empty | `ul07-nightcue-home-empty.png` sha256 `962fb906…` | fail→known_issue | Vision missed bottom “New session” (tab bar crop); UITest `cta-new-session` existed |
| nightcue-capture-import | `ul07-nightcue-capture-import.png` | — | Entry screen captured pre-import |
| nightcue-night-coach | `ul07-nightcue-night-coach.png` sha256 `9b3f3581…` | fail→known_issue | CTAs below fold in shot; UITest reached Ask coach |
| nightcue-coach-chat | `ul07-nightcue-coach-chat.png` | — | Send + local path |
| nightcue-annotated-overlay | `ul07-nightcue-annotated-overlay.png` | — | Annotate surface |
| nightcue-field-tts | `ul07-nightcue-field-tts.png` | — | Play control |
| nightcue-settings-privacy | `ul07-nightcue-settings-privacy.png` sha256 `a51e68cb…` | receipt `nightcue-settings-privacy.runtime.receipt.json` | Revoke + permission copy |

## known_issues (Option A — operator soft)

1. `accept_photos_picker_xcuitest_gap` — PHPicker limited-library UI not selectable by XCTest; import persistence proven via domain tests + accept seed script for downstream journeys.
2. `ul07_cta_below_fold_vision` — Full-screen/tab-bar crops hide CTAs in PNGs; functional taps in UITest logs.
3. `ul07_settings_legal_xcuitest_navigationlink` — Settings legal rows are NavigationLinks; bundled HTML verified via candidate app resources; manual XCTest skip logged as SKIP in harness.
4. `device_camera_mic_speech_hardware` — Simulator entry points only; operator soft per P1.

## Gaps

| id | literal | suggested_node |
| --- | --- | --- |
| G1 | `ai_key_unavailable` | ai_build (config) — replace_before_submission |
| G2 | `legal_url_unknown` (external privacy/terms/support) | delivery gap |
| G3 | `cloudkit_unconfigured` | ai_build (config) |
| G4 | `feishu_row_not_yet_created` (Feishu skip) | delivery gap, not accept blocker |
| G5 | `operator_pricing_deferred_free_app_only` | product_shape / later monetization |
| G6 | `branding_assets_deferred` (no AppIcon/LaunchScreen) | operator hard |
| G7 | known_issues above | Option A non-blockers |

## lessons_candidates

- SwiftUI PhotosPicker on iOS 26 simulator + zh-Hans limited-library sheet blocks XCTest photo selection; keep domain tests + accept seed for coach matrix.
- Coach tab vs Sessions `NavigationStack` path: Ask coach must run from Sessions stack (product_shape note for Coach-tab stack parity).
- Cursor vision on tall screenshots: tab bar occludes bottom CTAs — capture mid-scroll or accept UITest as functional proof.

## Finish

Worker finish via `bin/cursor-package ultra-lite finish` with Status ready. Controller alone advances factory milestones. Product commit unchanged.
