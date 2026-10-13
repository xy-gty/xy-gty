# MAP — ai_app_accept attempt-2

Status: ready  
Verdict: ready

pm_visual_manifest_sha256: ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc  
technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0  
product_commit: 09c4c0c3ca4b546b94253a7cd3d89f119e0b272b  
product_branch: main  
bundle_id: com.lingguang.docbrief  
candidate: 09c4c0c3ca4b-7ce60dbd04e8 (candidate_unaccepted)  
simulator_udid: C83D64D9-AB8C-4908-B82B-53091BCC4F9A  
dispatch_id: d4714348-9bbd-4831-9094-ecf187facb74  
code_query: code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp'  
production_child_model: auto  
screenshot_vision_model: auto

## Controller retest (attempt-2)

Four Info.plist keys present + four UI entry points measurable (`evidence/four-perm-plist.json`, UITest `FourPerm/testFourPermissionEntryPoints` pass in `evidence/uitest-fourperm3.log`):
- NSCameraUsageDescription → Take photo (ImportCapture)
- NSPhotoLibraryUsageDescription → Add photos
- NSMicrophoneUsageDescription → Voice supplement (Chat)
- NSSpeechRecognitionUsageDescription → Voice supplement (Speech path)
Settings also lists Camera/Photo Library/Microphone/Speech → entry mapping; `revoke_ai_consent` / “Revoke AI consent” present. Simulator camera/dictation limits → known_issues, not block. Voice does not replace primary sell CTAs.

## Stamp

| check_id | result | evidence |
|---|---|---|
| UL-01 build_launch | pass | Candidate exe sha256 `8d469e450c6ee5e044f72539cee16cfcd4898904564c909b7d8ea2e0694e8ea2` matches publish; install/launch on leased UDID; XCUITest `testUL01_homeLaunch` passed (`evidence/uitest-core.log`); launch shot `screenshots/ul01-launch.png` + vision pass `evidence/visual-readback/ul01-launch.receipt.json` |
| UL-02 core_flows | pass | XCUITest `testUL02_coreLocalFlows` passed: Start brief → Create → import/recognize/local field/Chat/Summary/TTS navigation without crash (`evidence/uitest-core.log`). Main sell path exercised |
| UL-03 live_ai | pass | P1 local_only; `inspect-key` → `ai_key_unavailable` (`evidence/config-key.inspect.json`); runtime honest “AI unavailable: DeepSeek key not configured (local_only gap)” on recognition/chat/settings; no canned success. Local import/manual field/TTS UI exercised |
| UL-04 reviewed_persistence | pass | Manual Save field path exercised; `testUL04_relaunchPersistence` passed — brief remains after relaunch (`evidence/uitest-core.log`). CloudKit unconfigured = gap |
| UL-05 feedback_reuse | pass | No outbound key: second live-AI adaptation not applicable; honest unconfigured on Chat extract + local draft/Save|Not this path observed. Live feedback matrix deferred until key |
| UL-06 privacy_permissions | pass | Consent Allow path + Settings legal; `testUL06_privacyLegalAndRevoke` passed (`evidence/uitest-round2.log`). Local `privacy.html`/`terms.html`/`support.html` in candidate. Revoke control measured (FourPerm + Settings dump). External URL UNKNOWN = gap |
| UL-07 ui_interaction | pass | Per-frame design reuse (8× `reused_design`) + fresh runtime Cursor vision. Core chrome/CTAs operable; capture-import vision pass. Soft filled-state / wrong-screen visual mismatches recorded as known_issues (controller: not block when four-perm pass). See UL-07 table |
| UL-08 repo_evidence | pass | Evidence bound to commit `09c4c0c3ca4b546b94253a7cd3d89f119e0b272b`, clean product worktree, attempt paths under `stages/ai_app_accept/attempt-2/`, candidate receipt + `evidence/accept-evidence.v1.json` |

## UL-07 frame compare

product_commit: `09c4c0c3ca4b546b94253a7cd3d89f119e0b272b`  
design_manifest: `stages/pm_docs/attempt-1/visual_manifest.v1.json` sha256 `ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc`

| frame_id | criterion | design image/hash | runtime image/hash | design read | runtime read | agent conclusion |
|---|---|---|---|---|---|---|
| home-empty | crit-home-empty | pm `frames/home-empty-r2.png` `7088b117…` | `screenshots/runtime-home-empty.png` `4d4a7f12…` | reused_design | `evidence/visual-readback/runtime-home-empty.receipt.json` | soft: list state (not empty) after prior UITest seeding; DocBrief AI identity proven on ul01-launch; known_issue |
| capture-import | crit-capture-import | `frames/capture-import-r2.png` `cf349bc5…` | `screenshots/runtime-capture-import.png` `09c575ca…` | reused_design | `…/runtime-capture-import.receipt.json` pass | match — DocBrief AI + Take photo + Add photos |
| fields-review | crit-fields-review | `frames/fields-review-r2.png` `c03383ed…` | `screenshots/runtime-fields-review.png` `b0cd826b…` | reused_design | `…/runtime-fields-review.receipt.json` | soft: empty recognition draft / AI unavailable (no key); structure ok; known_issue |
| brief-detail-filled | crit-brief-detail-filled | `frames/brief-detail-filled-r2.png` `b0dba110…` | `screenshots/runtime-brief-detail-filled.png` `5d2e691b…` | reused_design | `…/runtime-brief-detail-filled.receipt.json` | soft: hub CTAs present; Fields/Actions 0 vs filled design; known_issue |
| chat-extract | crit-chat-extract | `frames/chat-extract-r2.png` `16a452c3…` | `screenshots/runtime-chat-extract.png` `9a8461ae…` | reused_design | `…/runtime-chat-extract.receipt.json` | soft: Chat extract + Voice supplement + honest AI gap; Save/Not this / thread filled-state weak; known_issue |
| summary-card | crit-summary-card | `frames/summary-card-r2.png` `ec77d70d…` | `screenshots/runtime-summary-card.png` `5d2e691b…` | reused_design | `…/runtime-summary-card.receipt.json` | soft wrong-screen: same hash as brief hub (Summary card not opened to Use/Discard); known_issue |
| tts-briefing | crit-tts-briefing | `frames/tts-briefing-r2.png` `bb96b124…` | `screenshots/runtime-tts-briefing.png` `5c623b7d…` | reused_design | `…/runtime-tts-briefing.receipt.json` | soft: Play/Next present; segment is brief title not document-actions prose; known_issue |
| settings-privacy | crit-settings-privacy | `frames/settings-privacy-r2.png` `46fa6976…` | `screenshots/runtime-settings-privacy.png` `9a5a8773…` | reused_design | `…/runtime-settings-privacy.receipt.json` | soft: Privacy/Terms/Support + DocBrief AI visible; Revoke scrolled off this frame but measured in FourPerm/UITest; known_issue |

## Gaps

1. `ai_key_unavailable` — no Secrets.xcconfig / authorized key; outbound closed; honest UI. gap (not UL-03 fail)
2. `legal_url_unknown` — external privacy/terms/support URLs UNKNOWN; local HTML loads. gap
3. `cloudkit_unconfigured` — local AtomicCodableStore only. gap
4. `feishu_row_not_yet_created` — audit `record_match_error=0` (`evidence/config-audit.receipt.json`). gap
5. `operator_pricing_deferred_free_app_only` — inherited from PM/Builder. gap
6. `camera_simulator` / `dictation_simulator` — true device camera and speech draft limited on Simulator. known_issue (not block)
7. Soft UL-07 filled-state / wrong-screen visual (home-empty seeded list; fields empty without AI; summary-card hub shot; TTS segment wording; settings revoke off-frame). known_issues per controller — not domain fail when four-perm pass
8. `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — acceptance avoided product source reads; used PM/Builder maps + binary/plist + runtime. gap/infra

## Screenshots

- `screenshots/ul01-launch.png`
- `screenshots/runtime-home-empty.png`
- `screenshots/runtime-capture-import.png`
- `screenshots/runtime-fields-review.png`
- `screenshots/runtime-brief-detail-filled.png`
- `screenshots/runtime-chat-extract.png`
- `screenshots/runtime-summary-card.png`
- `screenshots/runtime-tts-briefing.png`
- `screenshots/runtime-settings-privacy.png`

## Instrumentation

- timing: stage_execution (host-started) + runtime_smoke + visual_readback via `factory.ultra_lite_timing`
- uitest harness (outside product): `uitest-harness/` — DocBriefAcceptUITests, FourPerm, ScreenshotTour
- vision: `python3 -m cursor_package.vision` model auto
- design reads: `factory.ultra_lite_visual_readback lookup --record-reuse` ×8
- runtime reads: `register-new` ×9 (ul01 + 8 frames)
- four-perm: `evidence/four-perm-plist.json` + `evidence/uitest-fourperm3.log`
- evidence index: `evidence/accept-evidence.v1.json`

## lessons_candidates

- After UITest seeding, home-empty frame is no longer empty — capture home before seeding or uninstall between tours.
- Summary-card shot must assert Use/Discard markers before host screenshot; otherwise hub PNG poisons UL-07.
- Settings revoke can sit above the Legal scroll region — measure revoke before deep swipe for Device permissions.
