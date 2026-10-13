# SnagCue AI — ai_app_accept MAP

Status: blocked  
Verdict: blocked  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: a7bdfed3-2ab4-4e91-b223-835dd6c4cb3e  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
acceptance_transport: cursor_cloud  

pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
product_commit: 9b7db33af5cfa7b8be130af03c7de31f00c2b355  
candidate_name: eaa10b37be41-3769c8500f73 (published earlier; acceptance rebuilt/tested HEAD)  
development_bundle_id: com.lingguang.snagcue  
sim_udid: 5E3A8993-F815-4738-8EED-EF032F75704F  

## One-line

Independent eight-domain acceptance **blocked**: Active punch hub CTAs (`Add photos` / `Review snags` / `Chat fill` / `Annotate` / `Read aloud`) do not navigate to destination screens; UL-02/UL-05/UL-07 fail. Home empty + Settings/legal/local AI-unavailable messaging pass.

## Stamp

| check_id | result | evidence |
|----------|--------|----------|
| UL-01 build_launch | pass | Rebuild `** BUILD SUCCEEDED **` (`evidence/runtime/build.log`); install/launch `com.lingguang.snagcue` on leased UDID `5E3A8993-…`; home shot `evidence/screenshots/ul01-home-empty.png` / `ul07-home-empty.png` (sha256 `595fa175…`); Info.plist display name SnagCue AI |
| UL-02 core_flows | fail | Create audit works (title typed → Active punch). Hub buttons remain on `NavigationBar: Active punch` after taps (AX `evidence/ax/journey2/01-after-add-photos.txt` … `10-tts.txt`; journey logs). Capture/Review/Chat/Annotate/TTS destinations not reached. Punch list stayed empty. Gap `active_punch_hub_navigation_dead` → `ai_build` |
| UL-03 live_ai | pass | P1 `ai_key_unavailable` non-blocker (`evidence/config/inspect-key.json`). Settings shows honest `AI unavailable: DeepSeek key not configured (local_only gap).` (`ul07-settings-privacy.png`, AX `16-settings` / `11-settings`). Local smoke: audit create + persist. Outbound remains gated. Gap `ai_key_unavailable` |
| UL-04 reviewed_persistence | fail | Audit `Acceptance Walkthrough` persists across kill/relaunch (`ul04-relaunch-audits.png`; store `evidence/store/audits.json`). `snag_drafts.json` has Manual snag draft but no PunchItem Save path completed; punch list empty after relaunch. CloudKit gap only for sync. Gap `punch_item_save_unproven` → `ai_build` |
| UL-05 feedback_reuse | fail | Chat fill destination unreachable; second-call context adaptation not observed. Gap `chat_fill_unreachable` → `ai_build` |
| UL-06 privacy_permissions | pass | Settings discloses DeepSeek + `snagcue.consent.v1` field list; switch `Allow DeepSeek inference` off; local Privacy WebView opens (`ul06-legal.png`, AX `17-legal`). Provider policy / Terms / Support entries present. Consent-before-send sheet not exercised because Chat unreachable (covered by UL-02 gap). External URL gaps only |
| UL-07 ui_interaction | fail | Design reuse 8/8; runtime vision: home-empty **pass**, settings-privacy **pass**; capture/recognition/punchlist/chat/annotated/tts **fail** (shots still Active punch hub, not design destinations). Matrix below. Reproduction gap → `ai_build` |
| UL-08 repo_evidence | pass | Evidence under this attempt; product commit `9b7db33…`; `pm_visual_manifest_sha256` bound; candidate receipt copied; MAP refs exist |

## UL-07 visual matrix

| frame_id | criterion | design path/hash | runtime path/hash | design receipt | runtime receipt | conclusion |
|----------|-----------|------------------|-------------------|----------------|-----------------|------------|
| home-empty | crit-home-empty | pm `frames/home-empty-r1.png` / `670c4034…` | `ul07-home-empty.png` / `595fa175…` | reuse `620be16e…` | runtime pass | match |
| capture-import | crit-capture-import | `capture-import-r1.png` / `ff1b02f1…` | `ul07-capture-import.png` / `c70e2935…` | reuse `73066e09…` | runtime fail | hub not Capture — reproduction gap |
| recognition-review | crit-recognition-review | `recognition-review-r1.png` / `756d472d…` | `ul07-recognition-review.png` / `c70e2935…` | reuse `954aa66a…` | runtime fail | hub not Review — reproduction gap |
| punchlist-filled | crit-punchlist-filled | `punchlist-filled-r1.png` / `a4abb15d…` | `ul07-punchlist-filled.png` / `5f1dd962…` | reuse `ca320a59…` | runtime fail | empty punch hub — reproduction gap |
| chat-fill | crit-chat-fill | `chat-fill-r1.png` / `08b7e417…` | `ul07-chat-fill.png` / `5f1dd962…` | reuse `2f533862…` | runtime fail | hub not Chat — reproduction gap |
| annotated-report | crit-annotated-report | `annotated-report-r1.png` / `e6737120…` | `ul07-annotated-report.png` / `292620cb…` | reuse `2944d158…` | runtime fail | hub not Report — reproduction gap |
| tts-coach | crit-tts-coach | `tts-coach-r1.png` / `11c11eb1…` | `ul07-tts-coach.png` / `fa743561…` | reuse `77d89bf7…` | runtime fail | hub not TTS — reproduction gap |
| settings-privacy | crit-settings-privacy | `settings-privacy-r1.png` / `c0d0e606…` | `ul07-settings-privacy.png` / `f018d5b2…` | reuse `cfdcd48f…` | runtime pass | match (AI sharing + legal entries) |

Summary JSON: `evidence/vision/ul07-summary.json`.

## Gaps

- gap `active_punch_hub_navigation_dead` (Add photos / Review snags / Chat fill / Annotate / Read aloud no-op) · dimension UL-02/UL-07 · `suggested_node: ai_build`
- gap `punch_item_save_unproven` / empty punch list · UL-04 · `suggested_node: ai_build`
- gap `chat_fill_unreachable` · UL-05 · `suggested_node: ai_build`
- gap `ul07_destination_frames_unreproduced` (6/8 runtime fail) · UL-07 · `suggested_node: ai_build`
- gap `ai_key_unavailable` (local_only; UL-03 non-blocker)
- gap `legal_url_unknown` / Privacy·Terms·Support URL UNKNOWN
- gap `cloudkit_unconfigured`
- gap `feishu_row_not_yet_created` (persist-audit non-blocker)
- gap `operator_pricing_deferred_free_app_only`
- advisory: `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — acceptance used AX + PM/Builder contracts + candidate/binary evidence (no product source Read)
- advisory: physical-device camera 真机待测; Simulator photo import path not proven because Capture unreachable

## Evidence index

- evidence/runtime/build.log, install.log, launch.log, uitest-journey.log, uitest-journey2.log, snagcue-journey*.log
- evidence/screenshots/* (UL-01..07 + legal/revoke)
- evidence/ax/journey1, evidence/ax/journey2
- evidence/store/{audits,snag_drafts}.json
- evidence/vision/design/*.lookup.json (8× reused_design)
- evidence/vision/runtime/*.receipt.json(+jsonl) (8× Cursor auto)
- evidence/vision/ul07-summary.json
- evidence/config/inspect-key.json + evidence/config-audit.* 
- evidence/upstream/candidate.receipt.json, build.json, smoke.json, domain.log

## lessons_candidates

- Builder candidate smoke on Home alone did not catch Active punch hub NavigationPath wiring; Acceptance must exercise each hub CTA to a changed navigation title before stamping UL-02/UL-07.
- XCUITest `waitTitle` must ignore same-screen button labels (`Add photos`, `Annotate`) or it false-positives destination detection.
