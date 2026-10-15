# RuleCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 09e73222-b1a8-4b94-9039-940edaed62fb  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: 803064a4db0d8bdaf7bd875cbd21bbcf0a8834a75676d4550391c6576d5da900  
technical_contract_sha256: c66fef8e4c822efd842ef91b6009b49826b7a9f871f3e6e9f6acb096fe8185c7  
product_commit: 0ca4a31f94354b3456e1aa739e92496e5fbfb2bb  
product_dir: rulecue/ (`rulecue` → `product` symlink)  
product_branch: rulecue/kf-20261015T111031Z-ed6f1861  
bundle_id: com.lingguang.rulecue  
remote: git@github.com:xy-gty/xy-gty.git  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/0ca4a31f9435-9b8b99bc9e24 (candidate_unaccepted)  
palette: #854D0E / #FEFCE8 / #0891B2  

CONTROLLER Option A: non-core UL-07 vision misses + legal WebView navigation flakiness + `ai_key_unavailable` + component-review Keep path not exercised → **known_issues only** (non-blocking). Core UL-01/UL-02 runtime journeys passed on leased iPhone 17 Pro; AX proves TableZoneCards + TurnStepBar.

code_query: `code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp'` (journeys from builder symbol_map + AX/UITest; no Grep-as-code-query)

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Frozen commit `0ca4a31…`; accept DerivedData rebuild **BUILD SUCCEEDED** (`evidence/logs/build.log`); install+launch `com.lingguang.rulecue` on `B14CC0EA…` (`install.log`/`launch.log`); UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-ul01.log`) **TEST SUCCEEDED**; home `evidence/runtime/rt-home-empty.png` sha256 `4e10c886…`; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | UITest `testUL02CoreFlowsAndPrivacy` (`uitest-ul02.log`) **TEST SUCCEEDED** — New session → Start capture → Capture/Import (Camera + Photos entries) → Table coach zone cards + turn step bar → Chat/Overlay/Host/Dictate → Settings Revoke. Legal UITest `uitest-legal.log`. AX `ul02-06-table-coach.ax.txt` shows `Table zone Deck/Board` + `Turn step Setup/Deal/Turn/Score`. Camera/mic/speech hardware quality → 真机待测 |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable` (blocker=false). Settings shows `AI unavailable: DeepSeek key not configured (local_only gap).` (`ul02-13-settings.ax.txt`). Honest unconfigured; not canned DeepSeek. Gap → known_issues |
| UL-04 reviewed_persistence | pass | Domain `evidence/runtime/domain-tests.log` **10/10 TEST SUCCEEDED** incl. Keep/Discard/persist/setup overlay. UITest `testUL04RelaunchPersistence` (`uitest-ul04.log`) **TEST SUCCEEDED**. Component-review Keep UI not exercised this attempt → known_issue. CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback` passed. Live second outbound adaptation deferred by `ai_key_unavailable` → known_issues |
| UL-06 privacy_permissions | pass | Settings: Sharing allowed=No, **Revoke AI consent**, Permissions Camera/Photos/Microphone/Speech Recognition copy (`ul02-13-settings.ax.txt` / `rt-settings-scrolled.ax.txt`). Local HTML bundled in `.app` (`privacy.html`/`terms.html`/`support.html`/`provider-policy.html` + root fallback in `LocalLegalWebView`). `Open local legal pages` reachable; in-app WebView deep navigation flaky in UITest → known_issue (Option A). Remote legal URLs UNKNOWN = gap. Consent sheet present (`ConsentSheet`); no outbound without key |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 (`visual_readback_index.v1.json`). Fresh runtime vision: **pass** capture-import; **fail/uncertain→known_issues** home-empty / table-coach / settings (fold/palette/routing). AX independently proves table zone cards + turn step bar + four permissions. No AppIcon/LaunchScreen (operator). visual_runtime_required items=[] |
| UL-08 repo_evidence | pass | Evidence bound to commit `0ca4a31f94354b3456e1aa739e92496e5fbfb2bb`, branch `rulecue/kf-20261015T111031Z-ed6f1861`, attempt-1 paths, candidate `0ca4a31f9435-9b8b99bc9e24`. product_dir remains `rulecue/`. No product source edits by Acceptance. Feishu CONTROLLER_DELIVERY skip |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| rulecue-home-empty | crit-home-empty | frames/rulecue-home-empty-r1.png `2fd4f171…` | reused design | `evidence/runtime/rt-home-empty.png` `4e10c886…` | runtime (**fail**) | **known_issue** — vision wants full Players silhouette + cyan accent; AX/brand RuleCue + New session + Deck/Board silhouette present |
| rulecue-capture-import | crit-capture-import | rulecue-capture-import-r1 `684bc546…` | reused | `rt-capture-import.png` `695f3d02…` | runtime (**pass**) | pass — Capture page/table + Import photos dual entry |
| rulecue-component-review | crit-component-review | rulecue-component-review-r1 `7c826835…` | reused | _(no dedicated runtime shot)_ | — | **known_issue** — Keep/Discard path not captured this attempt |
| rulecue-table-coach | crit-table-coach | rulecue-table-coach-r1 `7cd4f97b…` | reused | `rt-table-coach.png` `e6296b92…` | runtime (**uncertain**) | **known_issue** — vision uncertain; AX proves `Table zone *` + `Turn step *` |
| rulecue-coach-chat | crit-coach-chat | rulecue-coach-chat-r1 `ca5fe687…` | reused | `rt-coach-chat.png` `e6296b92…` (dup table-coach) | — | **known_issue** — screenshot routing stayed on Table coach chrome |
| rulecue-setup-overlay | crit-setup-overlay | rulecue-setup-overlay-r1 `f034b0df…` | reused | `rt-setup-overlay.png` `27abedec…` | — | **known_issue** — routing/partial surface |
| rulecue-tts-host | crit-tts-host | rulecue-tts-host-r1 `a8ef96a2…` | reused | `rt-tts-host.png` `5c66495a…` (dup dictate) | — | **known_issue** — PNG not dedicated Host TTS controls |
| rulecue-settings-privacy | crit-settings-privacy | rulecue-settings-privacy-r1 `c08d3f42…` | reused | `rt-settings-privacy.png` `76f514d1…` + scrolled `0372015e…` | runtime (**fail**) | **known_issue** — single-frame fold; AX shows Revoke + 4 permissions + Open local legal |

Index: `visual_readback_index.v1.json` (reused_design=8, new_runtime_read=5).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_home_vision_partial` — runtime vision fail on Players fold / cyan accent completeness; brand + silhouette + CTA present.
2. `ul07_table_coach_vision_uncertain` — vision uncertain; AX proves zone cards + turn step bar.
3. `ul07_coach_chat_screenshot_routing` — coach-chat PNG hash-collided with table-coach.
4. `ul07_setup_overlay_screenshot_routing` — overlay PNG not clean annotated canvas state.
5. `ul07_tts_host_screenshot_routing` — TTS PNG hash-collided with dictate.
6. `ul07_settings_vision_partial` — Settings Revoke + AI unavailable + permissions observed via AX across scrolled frames; vision wants single-frame completeness.
7. `ul07_component_review_not_exercised` — Keep/Discard runtime shot missing.
8. `legal_webview_uitest_flaky` — Local legal HTML packaged + Settings legal entry present; deep WebView navigation incomplete in harness.
9. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof.
10. `code_query_blocked:codebase_memory_mcp_missing` — infrastructure; journeys via MAP symbol_map + AX.
11. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator).
12. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测.

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
- `evidence/config/inspect-key.json`, `evidence/config/config-audit.*`
- `evidence/candidate-receipt.json` → `0ca4a31f9435-9b8b99bc9e24`
- `evidence/runtime/` (UITest logs, screenshots, AX)
- `evidence/ui-harness/` (external XCUITest; not product source)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `evidence/logs/build.log` / `install.log` / `launch.log`
- `../ai_app_build/attempt-1/MAP.md` / build.log / domain.log / candidate
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- Dismiss PhotosPicker / keyboard before Capture→Table navigation; otherwise AX dumps stay on Capture chrome.
- Table coach AX labels `Table zone <name>` and `Turn step <title>` are strong UL-07 uniqueness proofs vs StopCue film-sprocket.
- iPhone 17 Pro lease `B14CC0EA…` only; leave Pro Max Booted alone.
