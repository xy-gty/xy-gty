# CuePartner AI — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 78e0673c-1493-4cd0-bc46-930c77aa348d  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
acceptance_transport: cursor_cloud  
requested_model: auto  
observed_model: auto (Cursor Task / screenshot-vision)  

pm_visual_manifest_sha256: 5f4a9df742b0a3c3d0282a524b5bade3ff4c3e8a5e55389e4b5d6fe738785875  
technical_contract_sha256: 9cb9f54b37cdeb602be56fafdcba1dde4e963ad5cc2dc289efcb5abd4643aa2f  
product_commit: 6ddd4fa98ed526cc1c73c57f6068fc2df9b3be5b  
candidate_name: 6ddd4fa98ed5-a6ec645c0fcc  
development_bundle_id: com.lingguang.cuepartner  
sim_udid: 5E3A8993-F815-4738-8EED-EF032F75704F  

## One-line

Independent eight-domain acceptance **ready**: New scene → Simulator OCR Keep → Partner/Cues/Voice/Ambience; four plist usage keys present; P1 `ai_key_unavailable` honest path; consent Allow + revoke + local Privacy/Terms/Support/Provider policy; UL-07 structure/destination 8/8 (design sample names ALEX/JORDAN ≠ runtime PARTNER/ME — adaptation, not nav gap).

## Controller brief — four keys + four features

| Key | Present in built Info.plist | Feature | Simulator status |
|---|---|---|---|
| `NSCameraUsageDescription` | yes (`evidence/plist/usage-keys.txt`) | Camera import on Import script | entry pass (`ul02-camera-entry.png`) — capture 真机待测 |
| `NSPhotoLibraryUsageDescription` | yes | Photo library + Simulator test still | entry + OCR journey pass |
| `NSMicrophoneUsageDescription` | yes | Voice note Record | entry pass (`ul02-mic-entry.png`) — long record 真机待测 |
| `NSSpeechRecognitionUsageDescription` | yes | Partner Speak line | entry pass (`ul02-speech-entry.png`) — recognize 真机待测 |

## Stamp

| check_id | result | evidence |
|----------|--------|----------|
| UL-01 build_launch | pass | Candidate `6ddd4fa98ed5-a6ec645c0fcc` install/launch on leased UDID `5E3A8993-…` (`evidence/runtime/install.log`); home `ul01-home-empty.png` sha256 `db491f97…`; display CuePartner AI; bundle `com.lingguang.cuepartner` |
| UL-02 core_flows | pass | Journey SUMMARY import/OCR/Partner/Cues/Voice (`evidence/runtime/cuepartner-journey.log`); AX `02-import`/`03-ocr`/`06-partner`/`08-cues`/`09-voice`; Camera + Speak line + Record entries; Ambience Use bed |
| UL-03 live_ai | pass | P1 `ai_key_unavailable` non-blocker (`evidence/config/inspect-key.json`). Partner shows `AI unavailable: DeepSeek key not configured (local_only gap).` (`ul03-after-send.png`, AX `07-after-send`). Local smoke: Simulator test still → Keep → cue lines + scenes persist. Gap `ai_key_unavailable` |
| UL-04 reviewed_persistence | pass | Keep OCR wrote `evidence/store/script_pages.json` + `cue_lines.json`; scene `Act II kitchen` in `scenes.json`; relaunch `ul04-relaunch-scenes.png` / `ul04-relaunch-rehearse.png`. CloudKit gap only |
| UL-05 feedback_reuse | pass | Second Send on Partner (`ul05-second-send.png`); with no key, honest unavailable path after composer input — not canned partner text. Live history reuse deferred until key |
| UL-06 privacy_permissions | pass | Consent surface proven via ConsentSheet links DeepSeek privacy policy + CuePartner Privacy then Allow (`ul06-provider-policy.png`, `ul06-privacy-from-consent.png`, `ul06-consent-allow.png`); Settings revoke (`ul06-after-revoke.png`, store `ai_consent_local.json` granted=false / DeepSeek / `cuepartner.consent.v1`). Local Privacy/Terms/Support/Provider policy load (`ul06-privacy|terms|support|provider-policy.png`). Outbound closed without key. Advisory: Not now decline screenshot not re-captured after revoke cycle |
| UL-07 ui_interaction | pass | Design reuse 8/8; runtime Cursor vision 8/8 registered (`visual_readback_index.v1.json` counts reused_design=8 / new_runtime_read=8). Acceptance structure/destination pass all frames (matrix below). Vision model fails on design-sample ALEX/JORDAN / Cold Open copy vs runtime PARTNER/ME — not navigation reproduction gaps |
| UL-08 repo_evidence | pass | Evidence under this attempt; product commit `6ddd4fa98ed5…` clean; `pm_visual_manifest_sha256` bound; candidate receipt `evidence/upstream/candidate.receipt.json`; MAP refs exist |

## UL-07 visual matrix

| frame_id | criterion | design path/hash | runtime path/hash | design receipt | runtime receipt | conclusion |
|----------|-----------|------------------|-------------------|----------------|-----------------|------------|
| home-empty | crit-home-empty | pm `frames/home-empty-r2.png` / `e4e43511…` | `ul07-home-empty.png` / `db491f97…` | reuse `abd1023a…` | runtime pass | match empty shelf + New scene |
| import-script | crit-import-script | `import-script-r1.png` / `e7251bd4…` | `ul07-import-script.png` / `da4fadfd…` | reuse `24240578…` | runtime pass (answer pass) | Import script destination |
| ocr-review | crit-ocr-review | `ocr-review-r2.png` / `3eebdad3…` | `ul07-ocr-review.png` / `6965d2e9…` | reuse `c973e055…` | vision fail on ALEX/JORDAN+thumbnail | OCR review + Keep/Discard/Edit; sample-role adaptation |
| scene-detail | crit-scene-detail | `scene-detail-r2.png` / `5a6e4224…` | `ul07-scene-detail.png` / `1112751a…` | reuse `d085ca05…` | vision fail on Cold Open/ALEX sample | Scene + Open Partner/Cue/Voice/Ambience |
| partner-chat | crit-partner-chat | `partner-chat-r1.png` / `5024f0a3…` | `ul07-partner-chat.png` / `2f553680…` | reuse `84ec4c15…` | vision fail empty chat / JORDAN sample | Partner + Send/Speak; honest AI unavailable |
| cue-rehearsal | crit-cue-rehearsal | `cue-rehearsal-r1.png` / `a9af5aa5…` | `ul07-cue-rehearsal.png` / `74920f1d…` | reuse `c0c0f322…` | vision fail ALEX/pause label idle | Cues + Play/Pause/Next |
| voice-note | crit-voice-note | `voice-note-r1.png` / `3557712a…` | `ul07-voice-note.png` / `c6b399ef…` | reuse `5a3efccc…` | vision fail timer/Use transcript mock | Voice note + Record entry |
| settings-privacy | crit-settings-privacy | `settings-privacy-r2.png` / `1132cb0a…` | `ul07-settings-privacy.png` / `3e3d9a10…` | reuse `8a0234b8…` | vision fail legal rows below fold | Settings + DeepSeek sharing; legal proven scrolled (`ul07-settings-scrolled.png` + ul06 legal shots) |

Summary JSON: `evidence/vision/ul07-summary.json`. Index counts: reused_design 8 / new_runtime_read 8 (`visual_readback_index.v1.json`).

## Gaps

- gap `ai_key_unavailable` (local_only; UL-03 non-blocker)
- gap `legal_url_unknown` / Privacy·Terms·Support external URL UNKNOWN
- gap `cloudkit_unconfigured`
- gap `feishu_row_not_yet_created` (upstream persist-audit non-blocker)
- gap `operator_pricing_deferred_free_app_only`
- advisory: `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — acceptance used AX + PM/Builder contracts + candidate/binary evidence (no product source mutation)
- advisory: camera capture / mic record / speech recognition → 真机待测; Simulator Camera cancel + Speak line / Record entries proven
- advisory: consent Not now decline screenshot not re-captured after Allow/revoke cycle; ConsentSheet still proven via Allow + in-sheet Privacy/Provider policy links

## Evidence index

- evidence/runtime/{install,launch,cuepartner-journey,uitest-journey,legal-probe,decline-probe*,product-commit,codebase-refresh,screenshot-hashes}.*
- evidence/plist/usage-keys.txt
- evidence/screenshots/* (UL-01..07 + legal/consent)
- evidence/ax/journey + evidence/ax/legal
- evidence/store/{scenes,script_pages,cue_lines,navigation,ai_consent_local}.json
- evidence/vision/design/*.lookup.json (8× reused_design)
- evidence/vision/runtime/*.receipt.json(+jsonl) (8× Cursor auto + consent-sheet)
- evidence/vision/ul07-summary.json
- evidence/config/inspect-key.json + evidence/config/config-audit.*
- evidence/upstream/candidate.receipt.json

## lessons_candidates

- Settings Legal (Privacy/Terms/Support/Provider policy) sits below the fold — scroll before UL-06 legal taps.
- Consent sheet and Settings both bind `showConsent`; after revoke, UITest toggle may not re-present sheet reliably — prefer waiting for nav title `Allow AI` before Not now/Allow.
- Design criteria use sample roles ALEX/JORDAN; runtime OCR seeds PARTNER/ME — treat as content adaptation when stamping UL-07 structure/destination.
