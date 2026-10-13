# SnagCue AI — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 3  
dispatch_id: 55f75a1b-12c4-498a-9195-4d50c82e3ef4  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
acceptance_transport: cursor_cloud  
requested_model: auto  
observed_model: auto (Cursor Task / screenshot-vision)  

pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
product_commit: 47f1c118b9e5e460b0231de413df86d5ef6d8ae7  
candidate_name: 47f1c118b9e5-146049ffc8bc  
development_bundle_id: com.lingguang.snagcue  
sim_udid: 5E3A8993-F815-4738-8EED-EF032F75704F  

## One-line

Independent eight-domain acceptance **ready**: Active punch hub CTAs navigate to Capture / Snag review / Chat fill / Annotated report / TTS coach; four plist keys + camera/library/mic/speech entries proven (camera/mic/speech capture 真机待测); local AI-unavailable + consent/legal paths pass; UL-07 8/8 structure/destination pass.

## Controller brief — four keys + four features

| Key | Present in built Info.plist | Feature | Simulator status |
|---|---|---|---|
| `NSCameraUsageDescription` | yes (`evidence/plist/usage-keys.txt`) | Camera capture entry on Capture (真机待测 copy) | 真机待测 — UI + plist present |
| `NSPhotoLibraryUsageDescription` | yes | Library import CTA `Add photos` on Capture | entry pass; system picker locale cancel — known flaky |
| `NSMicrophoneUsageDescription` | yes | Punch-item `Voice note` | entry pass (`ul02-mic-entry.png`) — record 真机待测 |
| `NSSpeechRecognitionUsageDescription` | yes | Chat `Speech to text` | entry pass (`ul02-speech-entry.png`) — recognize 真机待测 |

## Stamp

| check_id | result | evidence |
|----------|--------|----------|
| UL-01 build_launch | pass | Candidate `47f1c118b9e5-146049ffc8bc` install/launch on leased UDID `5E3A8993-…` (`evidence/runtime/install.log`); home `ul01-home-empty.png` sha256 `c97cfaa0…`; display name SnagCue AI; bundle `com.lingguang.snagcue` |
| UL-02 core_flows | pass | Journey SUMMARY `capture=Capture review=Snag review chat=Chat fill annotate=Annotated report tts=TTS coach` (`evidence/runtime/snagcue-journey.log`); AX `04-after-add-photos` / `06-review` / `10-chat` / `13-annotate` / `14-tts`; create audit + Save punch |
| UL-03 live_ai | pass | P1 `ai_key_unavailable` non-blocker (`evidence/config/inspect-key.json`). Settings: `AI unavailable: DeepSeek key not configured (local_only gap).` Consent sheet before send (`ul06-consent-sheet.png`); Allow/decline exercised. Local smoke: audit + punch save. Gap `ai_key_unavailable` |
| UL-04 reviewed_persistence | pass | Punch item `Manual snagPaint touch-up L3` in `evidence/store/punch_items.json`; audit persists (`audits.json`); relaunch shots `ul04-relaunch-audits.png` / `ul04-relaunch-punch.png`. CloudKit gap only |
| UL-05 feedback_reuse | pass | Second Send on Chat fill (`ul05-second-send.png`, AX `12-second-send`); with no key, honest unavailable path observed after consent. Not canned-only |
| UL-06 privacy_permissions | pass | Consent before send; Not now then Allow; Settings revoke (`ul06-after-revoke.png`); store `ai_consent_local.json` provider DeepSeek / `snagcue.consent.v1`. Local Privacy/Terms/Support/Provider policy WebViews load (`ul06-privacy.png` etc.; AX `evidence/ax/legal/`). External URL gaps only |
| UL-07 ui_interaction | pass | Design reuse 8/8; runtime Cursor vision 8/8; acceptance structure/destination pass all frames (matrix below). Vision model noted empty-vs-filled state differences — not navigation reproduction gaps |
| UL-08 repo_evidence | pass | Evidence under this attempt; product commit `47f1c118…`; `pm_visual_manifest_sha256` bound; candidate receipt `evidence/upstream/candidate.receipt.json`; MAP refs exist |

## UL-07 visual matrix

| frame_id | criterion | design path/hash | runtime path/hash | design receipt | runtime receipt | conclusion |
|----------|-----------|------------------|-------------------|----------------|-----------------|------------|
| home-empty | crit-home-empty | pm `frames/home-empty-r1.png` / `670c4034…` | `ul07-home-empty.png` / `c97cfaa0…` | reuse `620be16e…` | runtime pass | match |
| capture-import | crit-capture-import | `capture-import-r1.png` / `ff1b02f1…` | `ul07-capture-import.png` / `67627e60…` | reuse `73066e09…` | runtime pass | Capture destination |
| recognition-review | crit-recognition-review | `recognition-review-r1.png` / `756d472d…` | `ul07-recognition-review.png` / `f36de6b6…` | reuse `954aa66a…` | runtime pass | Snag review (empty drafts state) |
| punchlist-filled | crit-punchlist-filled | `punchlist-filled-r1.png` / `a4abb15d…` | `ul07-punchlist-filled.png` / `4b552fe1…` | reuse `ca320a59…` | runtime pass | hub + saved Manual snag |
| chat-fill | crit-chat-fill | `chat-fill-r1.png` / `08b7e417…` | `ul07-chat-fill.png` / `425063fc…` | reuse `2f533862…` | runtime pass | Chat fill destination |
| annotated-report | crit-annotated-report | `annotated-report-r1.png` / `e6737120…` | `ul07-annotated-report.png` / `adff26d1…` | reuse `2944d158…` | runtime pass | Annotated report |
| tts-coach | crit-tts-coach | `tts-coach-r1.png` / `11c11eb1…` | `ul07-tts-coach.png` / `ff3b2174…` | reuse `77d89bf7…` | runtime pass | TTS coach |
| settings-privacy | crit-settings-privacy | `settings-privacy-r1.png` / `c0d0e606…` | `ul07-settings-privacy.png` / `f87893d2…` | reuse `cfdcd48f…` | runtime pass | Settings + DeepSeek sharing |

Summary JSON: `evidence/vision/ul07-summary.json`. Index counts: reused_design 8 / new_runtime_read 8 (`visual_readback_index.v1.json`).

## Gaps

- gap `ai_key_unavailable` (local_only; UL-03 non-blocker)
- gap `legal_url_unknown` / Privacy·Terms·Support external URL UNKNOWN
- gap `cloudkit_unconfigured`
- gap `feishu_row_not_yet_created` (persist-audit non-blocker)
- gap `operator_pricing_deferred_free_app_only`
- advisory: `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — acceptance used AX + PM/Builder contracts + candidate/binary evidence (no product source Read)
- advisory: camera capture / mic record / speech recognition → 真机待测; Simulator photo-picker locale cancel after library CTA proven

## Evidence index

- evidence/runtime/{install,launch,snagcue-journey,uitest-journey6,legal-probe,product-commit,codebase-refresh}.*
- evidence/plist/usage-keys.txt
- evidence/screenshots/* (UL-01..07 + legal/consent)
- evidence/ax/journey + evidence/ax/legal
- evidence/store/{audits,punch_items,snag_drafts,ai_consent_local}.json
- evidence/vision/design/*.lookup.json (8× reused_design)
- evidence/vision/runtime/*.receipt.json(+jsonl) (8× Cursor auto)
- evidence/vision/ul07-summary.json
- evidence/config/inspect-key.json + evidence/config-audit.*
- evidence/upstream/candidate.receipt.json

## lessons_candidates

- Hub CTA acceptance must pop NavigationStack Back to Active punch before the next CTA; tab re-select alone leaves Capture/destination on stack.
- Create audit must tap the explicit `Create audit` button (never keyboard Done); photo library probes must dismiss Chinese `取消` sheets before hub navigation.
- XCUITest destination titles must use navigationBar identifiers only (`Capture`, `Snag review`, …), never hub button labels.
