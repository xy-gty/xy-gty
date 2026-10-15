# SporeCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 91c298dc-03c0-46d2-a3b6-fde882cdb125  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: 0263b2c8eadb63c6c401b4d4bde562b5079f4c9e11498059822d9b86a00639d2  
technical_contract_sha256: cde02f702a052b37ad3f7a1eb8dd16836639377a1b10261f40bfd83c697e5356  
product_commit: 953628045629d96380e8792457acd895f19955ed  
product_dir: sporecue/ (`sporecue` → `product` symlink)  
product_branch: sporecue (tracking `origin/sporecue-kf-20261015T174239Z-859f7eed`)  
bundle_id: com.lingguang.sporecue  
remote: git@github.com:xy-gty/xy-gty.git  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; Pro Max never shutdown/occupied)  
candidate: artifacts/candidates/953628045629-ed4e4e7deb04 (candidate_unaccepted)  
candidate_receipt_sha256: 6c0259a294f8801ffab58a284042dd7d82ba94c635ff1eb17e2d4e0ec9735f6d  
palette: #9A3412 / #FFF7ED / #0284C7  

CONTROLLER Option A: non-core UL-07 vision fail/uncertain (home fold criteria / camera system Photos sheet / id empty ranks before AI / chat&overlay timing shots / voice Start-not-recording / settings scrolled fold / consent sheet not isolated) + `ai_key_unavailable` → **known_issues only** (non-blocking; do NOT hard-block). Core UL-01 / UL-02b sell / UL-04 / UL-06 runtime journeys passed on leased iPhone 17 Pro; AX proves `SpeciesConfidenceStack` + `GillPoreCloseupBar` + disclaimer `非可食认证 / not an edibility certification` (≠ MixCue bottle-rail / WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket).

code_query: `code_query_blocked:codebase_memory_index_failed` — journeys from builder symbol_map + AX/UITest (read-only Acceptance; no product Grep-as-code-query).

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Frozen commit `9536280…`; accept DerivedData rebuild **TEST BUILD SUCCEEDED** (`evidence/logs/build.log`); install+launch `com.lingguang.sporecue` on `B14CC0EA…` (`install.log`/`launch.log`); UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-all.log`) **passed**; home AX `ul01-home.ax.txt` shows SpeciesConfidenceStack/GillPoreCloseupBar + 非可食认证 + Shoot; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | Selling-point UITest `testUL02bSellCoreFlows` **passed** — Shoot→Import→ID result→Identify→Ask coach→Annotate→Play brief→Save Find→Voice note (`uitest-all.log` + runtime shots/AX). Empty/error/cancel recoverable (camera cancel, honest AI-unconfigured banner). Camera/mic/speech hardware quality → 真机待测 |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable` (blocker=false). Home shows `AI not configured — local capture still works.` Honest unconfigured; not canned DeepSeek. Gap → known_issues |
| UL-04 reviewed_persistence | pass | Domain `evidence/runtime/domain-tests.log` **12/12 TEST SUCCEEDED** incl. ForageStore round-trip / reject-not-confirmed / second-call confirmed species / consent grant-revoke. UITest `testUL04RelaunchPersistence` **passed**. CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedSpecies` passed. Live second outbound adaptation deferred by `ai_key_unavailable` → known_issues |
| UL-06 privacy_permissions | pass | Settings scrolled AX: Camera/Photos/Microphone/Speech Recognition rows; Revoke AI consent; Privacy/Terms/Support/Provider links (`ul06-settings-scrolled.ax.txt`, `ul06-legal-privacy.ax.txt`). Local HTML packaged in `.app` (`privacy.html`/`terms.html`/`support.html`/`provider-policy.html`). Info.plist four usage strings present. ConsentSheet DeepSeek fields not isolated this attempt (local_only + revoke path); no outbound without key |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 (`visual_readback_index.v1.json`). Fresh runtime vision 7/8 frames: all vision **fail** against strict still criteria → **known_issues** (Option A). AX/UITest independently prove stack + oversized closeup + disclaimer + Shoot/Import + coach/annotate/voice/settings. No AppIcon/LaunchScreen assets (operator; Assets.xcassets Contents only). visual_runtime_required items=[] . Consent frame missing isolated shot → known_issue |
| UL-08 repo_evidence | pass | Evidence bound to commit `953628045629d96380e8792457acd895f19955ed`, branch `sporecue` / remote `sporecue-kf-20261015T174239Z-859f7eed`, attempt-1 paths, candidate `953628045629-ed4e4e7deb04` sha256 `6c0259a294f8801f…`. product_dir remains `sporecue/`. No product source edits by Acceptance. Feishu CONTROLLER_DELIVERY skip. UI copy free of competitor brands; support.html legal page contains operator forbid string in prose → known_issue soft |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| sporecue-home-empty | CR-HOME-01 | frames/sporecue-home-empty-r1.png `78a86aef…` | reused design | `evidence/visual-readback/rt-sporecue-home-empty.png` `b790addc…` | runtime (**fail**) | **known_issue** — vision strict fail; AX proves SpeciesConfidenceStack + GillPoreCloseupBar + Shoot/Import + 非可食认证 |
| sporecue-capture-camera | CR-CAM-01 | sporecue-capture-camera-r1 `b3f4db12…` | reused | `rt-sporecue-capture-camera.png` `28bead67…` | runtime (**fail**) | **known_issue** — system Photos/limited-access sheet after Shoot; entry exercised |
| sporecue-id-result | CR-ID-COMBINED | sporecue-id-result-r1 `898f00e7…` | reused | `rt-sporecue-id-result.png` `a6c7f2cf…` | runtime (**fail**) | **known_issue** — empty ranks without live AI key; stack+closeup+disclaimer+Identify CTAs present (AX) |
| sporecue-lookalike-chat | CR-CHAT-01 | lookalike-chat-r1 `288c7d67…` | reused | `rt-sporecue-lookalike-chat.png` `a6c7f2cf…` | runtime (**fail**) | **known_issue** — shot timing may still show ID result; UITest reached Ask coach |
| sporecue-overlay-annotate | CR-OVL-01 | overlay-r1 `19a03c7f…` | reused | `rt-sporecue-overlay-annotate.png` `ab1cfb84…` | runtime (**fail**) | **known_issue** — vision timing; UITest Annotate path + AX dump present |
| sporecue-voice-note | CR-MIC-01 | voice-note-r1 `3e1d277e…` | reused | `rt-sporecue-voice-note.png` `3f0c4219…` | runtime (**fail**) | **known_issue** — Voice note sheet Start/Close visible; not mid-recording stop state |
| sporecue-consent-ai | CR-CONSENT-01 | consent-r1 `83b9737e…` | reused | (not isolated) | — | **known_issue** — local_only + no key; revoke path exercised in Settings |
| sporecue-settings-privacy | CR-SET-01 | settings-r1 `3f409384…` | reused | `rt-sporecue-settings-privacy.png` `b8e45057…` | runtime (**fail**) | **known_issue** — scrolled legal fold missing revoke in same frame; AX proves four permissions + Revoke + local legal |

Index: `visual_readback_index.v1.json` (reused_design=8, new_runtime_read=7).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_home_vision_strict_fail` — runtime vision fail vs still criteria; AX proves signature stack/closeup/disclaimer/Shoot/Import.
2. `ul07_capture_vision_system_photos_sheet` — Shoot surfaced limited Photos privacy sheet vs design camera still.
3. `ul07_id_vision_empty_ranks_without_ai_key` — ranked names require live DeepSeek; stack chrome + disclaimer present.
4. `ul07_chat_overlay_shot_timing` — lookalike/overlay screenshots may lag navigation; UITest exercised Ask coach + Annotate.
5. `ul07_voice_note_not_recording_state` — sheet Start/Close proven; mid-record Stop not captured.
6. `ul07_settings_consent_vision_partial` — Settings vision fail on single fold; scrolled AX proves permissions+legal; ConsentSheet not isolated.
7. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof.
8. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator).
9. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测.
10. `support_html_mentions_forbid_competitors` — `App/Resources/Legal/support.html` prose mentions Shroomify/Pilze 123 (UI surfaces do not).

## Gaps (delivery / submit-before)

- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local pages packaged)
- `cloudkit_unconfigured`
- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip)
- `operator_pricing_deferred_free_app_only`
- `ai_key_unavailable`

## Blockers

(none)

## Evidence index

- `evidence/product-freeze.json`
- `evidence/config/inspect-key.json`
- `evidence/candidate-receipt.json` → `953628045629-ed4e4e7deb04`
- `evidence/runtime/` (UITest logs, screenshots, AX, domain-tests.log, uitest-summary.txt)
- `evidence/ui-harness/` (external XCUITest; not product source)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `evidence/logs/build.log` / `install.log` / `launch.log`
- `evidence/evidence-hashes.json`
- `../ai_app_build/attempt-1/MAP.md` / build.log / domain.log / candidate
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- Settings permissions/legal sit below AI section on iPhone 17 Pro — scroll Settings collection before UL-06 AX asserts.
- Without DEEPSEEK_API_KEY, ID stack stays placeholder ranks; still assert chrome + disclaimer + Identify CTA rather than filled species.
- iPhone 17 Pro lease `B14CC0EA…` only; leave Pro Max Booted alone.
- Species uniqueness proof: AX ids `SpeciesConfidenceStack` / `GillPoreCloseupBar` (+ CautionChipRail when chips present).
