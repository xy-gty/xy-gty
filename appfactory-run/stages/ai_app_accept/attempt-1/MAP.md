# StopCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 8e636dd9-6352-4882-b633-b019e4dddd1f  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: a7635daf9f37726329ff1b54e5ea627d634a7f16e8550568c23b0df1b1593d9a  
technical_contract_sha256: 6aa7ee6083e7746fa2f67056aa5b47073685641d760c2172930253bdab5e5dd7  
product_commit: 8ff7e72ef3525166bbb448c398b3be0b23430dee  
product_dir: stopcue/ (`stopcue` → `product` symlink)  
product_branch: stopcue/kf-20261015T093242Z-0f4256a0  
bundle_id: com.lingguang.stopcue  
remote: git@github.com:xy-gty/xy-gty.git  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/8ff7e72ef352-83d81be924fa (candidate_unaccepted)  

CONTROLLER Option A: non-core UL-07 vision misses + legal WebView scroll/tap flakiness + `ai_key_unavailable` + frame-review not exercised → **known_issues only** (non-blocking). Core UL-01/UL-02 runtime journeys passed on leased iPhone 17 Pro.

code_query: `code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp'` (journeys from builder symbol_map + AX/UITest; no Grep-as-code-query)

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Frozen commit `8ff7e72…`; install+launch `com.lingguang.stopcue` on `B14CC0EA…`; UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-ul01.log`) **TEST SUCCEEDED**; home `evidence/runtime/rt-home-empty.png` sha256 `dbfe53c1…`; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | UITest `testUL02CoreFlowsAndPrivacy` (`uitest-ul02b.log`) **TEST SUCCEEDED** — New project → Capture/Import (Camera + Photos entries) → Coach/Chat/Onion/Countdown/Dictate tabs → Settings Revoke. Followup+Legal UITests `uitest-followup.log` / `uitest-legal.log`. StopCoach AX shows `film-sprocket-timeline` + Onion-skin overlay (`rt-stop-coach.ax.txt`). Camera/mic/speech hardware quality → 真机待测 (entries + usage copy present) |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable` (blocker=false). Settings/runtime shows `AI unavailable: DeepSeek key not configured (local_only gap).` (`rt-settings-privacy.ax.txt` / `rt-settings-legal.ax.txt`). Local coach tips / honest unconfigured; not canned DeepSeek. Gap → known_issues |
| UL-04 reviewed_persistence | pass | Upstream domain `evidence/runtime/domain-tests.log` **9/9 TEST SUCCEEDED** incl. Keep/Discard/persist. Runtime project list survives relaunch (`Accept Set A` / Followup). Frame-review Keep UI not exercised this attempt → known_issue. CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback` passed. Live second outbound adaptation deferred by `ai_key_unavailable` → known_issues |
| UL-06 privacy_permissions | pass | Settings: Outbound AI Blocked, **Revoke AI consent**, Permissions used (camera/photos/mic/speech copy). Scrolled Settings exposes Support / Provider policy rows (`rt-settings-scrolled.ax.txt`). Local HTML bundled (`App/Resources/Legal/*.html` + `LocalLegalWebView`). In-app WebView open flaky in UITest → known_issue (not UL-06 block under Option A). Remote legal URLs UNKNOWN = gap. Consent sheet path present in product (`ConsentSheet`); no outbound without key |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 (`visual_readback_index.v1.json`). Fresh runtime vision: **pass** home-empty + capture-import; **fail→known_issues** stop-coach / coach-chat / onion / tts / settings (screenshot routing noise / below-fold criteria). AX independently proves film-sprocket on StopCoach. No AppIcon/LaunchScreen (operator). visual_runtime_required items=[] |
| UL-08 repo_evidence | pass | Evidence bound to commit `8ff7e72ef3525166bbb448c398b3be0b23430dee`, branch `stopcue/kf-20261015T093242Z-0f4256a0`, attempt-1 paths, candidate `8ff7e72ef352-83d81be924fa`. product_dir remains `stopcue/`. No product source edits by Acceptance. Feishu CONTROLLER_DELIVERY skip |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| stopcue-home-empty | crit-home-empty | frames/stopcue-home-empty-r1.png `5f2c3cd10b56…` | reused design | `evidence/runtime/rt-home-empty.png` `dbfe53c1…` | runtime stopcue-home-empty (**pass**) | pass — empty StopCue + sprocket placeholder + New project + green/mint/magenta |
| stopcue-capture-import | crit-capture-import | stopcue-capture-import-r1 `7af0b6b9bb51…` | reused | `rt-capture-import.png` `1f17dfa8…` | runtime (**pass**) | pass — Capture frame + Import sequence frame |
| stopcue-frame-review | crit-frame-review | stopcue-frame-review-r1 `399e904df9dd…` | reused | _(no dedicated runtime shot)_ | — | **known_issue** — Keep/Discard path not captured this attempt |
| stopcue-stop-coach | crit-stop-coach | stopcue-stop-coach-r1 `dd185670412c…` | reused | `rt-stop-coach.png` `27bebd8b…` | runtime (**fail**) | **known_issue** — vision fail; AX proves `film-sprocket-timeline` + Onion-skin overlay |
| stopcue-coach-chat | crit-coach-chat | stopcue-coach-chat-r1 `068e550261a9…` | reused | `rt-coach-chat.png` `53f9169f…` | runtime (**fail**) | **known_issue** — PNG landed on New project chrome |
| stopcue-onion-overlay | crit-onion-overlay | stopcue-onion-overlay-r1 `66c0c9e66035…` | reused | `rt-onion-overlay.png` `aeba65b8…` | runtime (**fail**) | **known_issue** — PNG not onion canvas state |
| stopcue-tts-countdown | crit-tts-countdown | stopcue-tts-countdown-r1 `5011c879db30…` | reused | `rt-tts-countdown.png` `1b11431f…` | runtime (**fail**) | **known_issue** — PNG not countdown controls |
| stopcue-settings-privacy | crit-settings-privacy | stopcue-settings-privacy-r2 `158f245a4968…` | reused | `rt-settings-privacy.png` `2acc37ea…` | runtime (**fail**) | **known_issue** — vision wants full legal rows; Settings shows Revoke + `ai_key_unavailable`; scrolled AX has Support/Provider |

Index: `visual_readback_index.v1.json` (reused_design=8, new_runtime_read=7).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_stop_coach_vision_fail` — runtime vision fail despite AX film-sprocket + onion toggle; no frame regen.
2. `ul07_coach_chat_screenshot_routing` — coach-chat PNG not CoachChat surface.
3. `ul07_onion_overlay_screenshot_routing` — onion PNG not overlay canvas.
4. `ul07_tts_countdown_screenshot_routing` — countdown PNG not TTS controls.
5. `ul07_settings_vision_partial` — Settings Revoke + AI unavailable observed; full legal WebView open flaky.
6. `ul07_frame_review_not_exercised` — Keep/Discard runtime shot missing.
7. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof.
8. `legal_webview_uitest_flaky` — Local legal HTML + Settings rows present; WebView navigation incomplete in harness.
9. `code_query_blocked:codebase_memory_mcp_missing` — infrastructure; journeys via MAP symbol_map + AX.
10. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator).
11. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测.

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
- `evidence/candidate-receipt.json` → `8ff7e72ef352-83d81be924fa`
- `evidence/runtime/` (UITest logs, screenshots, AX)
- `evidence/ui-harness/` (external XCUITest; not product source)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `../ai_app_build/attempt-1/MAP.md` / build.log / domain.log / candidate
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- Dismiss PhotosPicker / keyboard before Capture→Coach navigation; otherwise AX dumps stay on Capture chrome.
- Prefer `usleep` over fractional `sleep` in XCTest harness on this toolchain.
- iPhone 17 Pro lease `B14CC0EA…` only; leave Pro Max Booted alone.
