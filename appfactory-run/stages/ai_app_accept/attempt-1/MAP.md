# MAP — ai_app_accept attempt-1

Status: ready  
Verdict: ready

pm_visual_manifest_sha256: 46c33c0955e1c3fe98d4473026decc2e316148b4293d533c79853afa5ab8c950  
technical_contract_sha256: b43b4db81ea320561037660a574d8d0b620ca87f7d34a52fcece3c1fc6678d19  
product_commit: 009dea15a1ab2e106efcff66e16a15433ac01ba0  
product_branch: main  
bundle_id: com.lingguang.bendcoach  
candidate: 009dea15a1ab-4c27f3a2b607 (candidate_unaccepted)  
simulator_udid: 5E3A8993-F815-4738-8EED-EF032F75704F  
dispatch_id: 08430494-8c4c-4f08-a087-c94aa743d86f  
code_query: code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp'  
production_child_model: auto  
screenshot_vision_model: auto  
environment: cloud  
known_issues_ref: evidence/known_issues.md

## Stamp

| check_id | result | evidence |
|---|---|---|
| UL-01 build_launch | pass | Candidate `BendCoach.app.zip` installed on leased UDID; launch pid recorded; XCUITest `testUL01_homeLaunch` + retarget home passed (`evidence/logs/uitest-all.log`); home identity shots `evidence/screenshots/ul01-launch.png` / `runtime-home-empty.png` |
| UL-02 core_flows | pass | XCUITest `testUL02_coreLocalFlows` + Job-hub opens (`Ask bend math`, `Capture / import photo`, `Save` review, `Generate diagram`, `Start coaching`/`TTS coaching player`, Settings legal) succeeded (`evidence/logs/uitest-*.log`) |
| UL-03 live_ai | pass | P1 local_only; `evidence/config-key.inspect.json` → `ai_key_unavailable`; runtime bend-math chat shows honest local demo assistive guidance — `runtime-bend-math-chat` vision **pass**; no canned outbound success |
| UL-04 reviewed_persistence | pass | `testUL04_relaunchPersistence` PERSISTENCE hadJob=true stillThere=true; review Save path with Save/Not this/Edit marks (`runtime-bend-review`); CloudKit unconfigured = gap |
| UL-05 feedback_reuse | pass | No outbound key: second live-AI adaptation N/A; local demo + saved marks on Job hub (`runtime-job-detail-filled`). Live DeepSeek feedback deferred until key |
| UL-06 privacy_permissions | pass | `testUL06_privacyLegalAndRevoke` LEGAL_OPENS 3; Settings exposes Units + Privacy/Terms/Support/Provider policy; local HTML in candidate. External URL UNKNOWN = gap |
| UL-07 ui_interaction | pass | 8× design reuse + runtime Cursor vision. Pass: home-empty (r3), bend-math-chat, capture-import, bend-review, job-detail-filled, tts-coaching, settings soft. Soft known_issues: diagram-overlay (r3 fail — Job hub not overlay chrome), settings-units-privacy (Units/Revoke co-visibility). See UL-07 table + `evidence/known_issues.md` |
| UL-08 repo_evidence | pass | Evidence bound to commit `009dea15a1ab2e106efcff66e16a15433ac01ba0`, attempt paths under `stages/ai_app_accept/attempt-1/`, candidate receipt, upstream build/smoke copies, `evidence/accept-evidence.v1.json` |

## UL-07 frame compare

product_commit: `009dea15a1ab2e106efcff66e16a15433ac01ba0`  
design_manifest: `stages/pm_docs/attempt-1/visual_manifest.v1.json` sha256 `46c33c0955e1c3fe98d4473026decc2e316148b4293d533c79853afa5ab8c950`

| frame_id | criterion | design image/hash | runtime image/hash | design read | runtime read | agent conclusion |
|---|---|---|---|---|---|---|
| home-empty | crit-home-empty | pm `frames/home-empty-r2.png` `1f9c3386dc622898…` | `screenshots/runtime-home-empty.png` `79aec95fb1998ef2…` | reused_design | `…/runtime-home-empty.r3.receipt.json` **pass** | BendCoach AI empty home + Start a bend job / Open coach + Imperial |
| bend-math-chat | crit-bend-math-chat | `frames/bend-math-chat-r2.png` `6b72c7ac7ed03f13…` | `screenshots/runtime-bend-math-chat.png` `d871becfa8f0c688…` | reused_design | `…/runtime-bend-math-chat.receipt.json` pass | match (chat + assistive + units) |
| capture-import | crit-capture-import | `frames/capture-import-r1.png` `ff1b02f111fd5ed4…` | `screenshots/runtime-capture-import.png` `1d5770f252178c01…` | reused_design | `…/runtime-capture-import.r2.receipt.json` pass | Capture photo + Import from library |
| bend-review | crit-bend-review | `frames/bend-review-r2.png` `0a24fc5d218d8a55…` | `screenshots/runtime-bend-review.png` `c8cdf854d8350e9a…` | reused_design | `…/runtime-bend-review.r2.receipt.json` pass | Save / Not this / Edit marks |
| job-detail-filled | crit-job-detail-filled | `frames/job-detail-filled-r1.png` `a4abb15d0d9ad16a…` | `screenshots/runtime-job-detail-filled.png` `b48cd83938c92e9d…` | reused_design | `…/runtime-job-detail-filled.receipt.json` pass | Saved marks + diagram/coaching paths |
| diagram-overlay | crit-diagram-overlay | `frames/diagram-overlay-r2.png` `3ecdc321c154965c…` | `screenshots/runtime-diagram-overlay.png` `f7194c52dcbd245a…` | reused_design | `…/runtime-diagram-overlay.r3.receipt.json` fail | soft / known_issues (KI-ul07-diagram-overlay): Job hub still, not overlay+Use/Discard+assistive numbers |
| tts-coaching | crit-tts-coaching | `frames/tts-coaching-r1.png` `11c11eb14fbcad89…` | `screenshots/runtime-tts-coaching.png` `13417dfc2d2abd96…` | reused_design | `…/runtime-tts-coaching.receipt.json` pass | Pause/Replay/Next + steps |
| settings-units-privacy | crit-settings-units-privacy | `frames/settings-units-privacy-r2.png` `f291d5646214a3f1…` | `screenshots/runtime-settings-units-privacy.png` `2c78df0ec04ec442…` | reused_design | `…/runtime-settings-units-privacy.r3.receipt.json` | soft / known_issues (KI-ul07-settings-units): legal present; Units/Revoke not co-visible |

visual_runtime_required: job-detail-filled → runtime pass; diagram-overlay → soft known_issues / r3 fail (controller option A — not delivery blocker).

## known_issues

See `evidence/known_issues.md`. Non-core soft UL-07 visual deltas only:

1. `KI-ul07-diagram-overlay` — diagram Use/Discard overlay chrome + assistive numbers not on sealed still (r3 fail)
2. `KI-ul07-settings-units` — Units/Revoke not co-visible on settings still

home-empty r3 **pass** (cleared from known_issues).

## Gaps

1. `ul07_visual_reproduction:home-empty` — cleared (r3 pass)  
2. `ul07_visual_reproduction:diagram-overlay` — known_issues (KI-ul07-diagram-overlay); non-core; not delivery blocker  
3. `ul07_settings_revoke_units_co_visibility` — known_issues (KI-ul07-settings-units); non-core; not delivery blocker  
4. `ai_key_unavailable` — no Secrets.xcconfig / authorized key; outbound closed; honest local demo. gap (not UL-03 fail)  
5. `legal_url_unknown` — external privacy/terms/support URLs UNKNOWN; local HTML loads. gap  
6. `cloudkit_unconfigured` — local AtomicCodableStore only. gap  
7. `feishu_row_not_yet_created` — audit `record_match_error=0` (`evidence/config-audit.receipt.json`). gap  
8. `operator_pricing_deferred_free_app_only` — inherited. gap  
9. `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — acceptance used PM/Builder maps + runtime. gap/infra  
10. `device_camera_speech_quality_真机待测` — simulator stub / speech quality device-only. gap (does not block alone)

## Screenshots

- `evidence/screenshots/ul01-launch.png`  
- `evidence/screenshots/runtime-home-empty.png`  
- `evidence/screenshots/runtime-bend-math-chat.png`  
- `evidence/screenshots/runtime-capture-import.png`  
- `evidence/screenshots/runtime-bend-review.png`  
- `evidence/screenshots/runtime-job-detail-filled.png`  
- `evidence/screenshots/runtime-diagram-overlay.png`  
- `evidence/screenshots/runtime-tts-coaching.png`  
- `evidence/screenshots/runtime-settings-units-privacy.png`

## Instrumentation

- timing: stage_execution (controller-started) + runtime_smoke `accept-runtime` + visual_readback `accept-visual` via `factory.ultra_lite_timing`  
- uitest harness (outside product): `uitest-harness/`  
- vision: `python3 -m cursor_package.vision` model auto  
- design reads: `factory.ultra_lite_visual_readback lookup --record-reuse` ×8; runtime `register-new` ×8  
- controller option A: soft UL-07 → known_issues; seal ready for delivery → xy-gty  

## lessons_candidates

- Job hub exposes stable button labels (`Ask bend math`, `Capture / import photo`, `Review bend marks`, `Generate diagram`, `Diagram preview`, `Start coaching`, `TTS coaching player`).  
- Soft UL-07 visual still mismatches are deliverable as known_issues when UL-01–06/08 and sell-path UITests pass (controller option A).
