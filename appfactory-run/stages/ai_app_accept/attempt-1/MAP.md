# FrameCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: dc83ce73-c856-41f9-a1bc-b18912da8f9b  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: 131f8b751bcc346c32c68d2adb21acede76a733a0f3320480c5768ac22b83b6a  
technical_contract_sha256: 3bd8adb2a16343fa320ed77ae22ca4f28be2e84ca52888d949f52528126826fd  
product_commit: bd7bee1829677f58b05a55979d37eb5749bcb0a8  
product_dir: framecue/ (`framecue` → `product` symlink)  
product_branch: framecue/kf-20261015T123049Z-789bf0d3  
bundle_id: com.lingguang.framecue  
remote: git@github.com:xy-gty/xy-gty.git  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/bd7bee182967-a496f933457c (candidate_unaccepted)  
palette: #7E22CE / #FAF5FF / #F59E0B  

CONTROLLER Option A: non-core UL-07 vision fold misses + coach/overlay/tts screenshot hash-collision + composition-review Keep path not exercised + legal WebView deep nav not captured + `ai_key_unavailable` → **known_issues only** (non-blocking). Core UL-01/UL-02 runtime journeys passed on leased iPhone 17 Pro; AX proves `clapper_frame_canvas` + `shot_size_chip_bar` / `shot_chip_*` (≠ RuleCue table zones / StopCue sprocket / NightCue rail).

code_query: journeys from builder symbol_map + AX/UITest (read-only Acceptance; no product Grep-as-code-query).

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Frozen commit `bd7bee1…`; accept DerivedData rebuild **BUILD SUCCEEDED** (`evidence/logs/build.log`); install+launch `com.lingguang.framecue` on `B14CC0EA…` (`install.log`/`launch.log`); UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-ul01.log`) **TEST SUCCEEDED**; home `evidence/runtime/rt-home-empty.png` sha256 `72b46252…`; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | UITest `testUL02CoreFlowsAndPrivacy` (`uitest-ul02.log`) **TEST SUCCEEDED** — New session (scroll) → Create & capture → Capture/Import (Camera + Photo library) → Stage clapper + shot chips → Ask coach / Overlays / Hands-free / Dictate → Settings Revoke. AX `ul02-06-slate-stage.ax.txt` shows `clapper_frame_canvas` + `shot_size_chip_bar` + ECU/CU/MS/WS/EWS. Camera/mic/speech hardware quality → 真机待测 |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable` (blocker=false). Settings shows `AI unavailable: DeepSeek key not configured (local_only gap).` (`ul02-13-settings.ax.txt`). Honest unconfigured; not canned DeepSeek. Gap → known_issues |
| UL-04 reviewed_persistence | pass | Domain `evidence/runtime/domain-tests.log` **10/10 TEST SUCCEEDED** incl. Keep/Discard/persist/overlay. UITest `testUL04RelaunchPersistence` (`uitest-ul04.log`) **TEST SUCCEEDED**. Composition-review Keep UI not exercised this attempt → known_issue. CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback` passed. Live second outbound adaptation deferred by `ai_key_unavailable` → known_issues |
| UL-06 privacy_permissions | pass | Settings: Provider DeepSeek, **Revoke AI consent**, Permissions Camera/Photos/Microphone/Speech Recognition (`rt-settings-scrolled.ax.txt`). Local HTML bundled in `.app` (`privacy.html`/`terms.html`/`support.html`/`provider-policy.html`). Legal NavigationLinks present; deep WebView screenshots not captured this attempt → known_issue (Option A). Remote legal URLs UNKNOWN = gap. ConsentSheet present; no outbound without key |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 (`visual_readback_index.v1.json`). Fresh runtime vision: **pass** slate-stage; **fail→known_issues** home-empty / capture-import / settings (fold below viewport). AX independently proves clapper canvas + shot chip bar + four permissions + Camera/Photo library. No AppIcon/LaunchScreen assets (operator; empty AppIcon set stub). visual_runtime_required items=[] |
| UL-08 repo_evidence | pass | Evidence bound to commit `bd7bee1829677f58b05a55979d37eb5749bcb0a8`, branch `framecue/kf-20261015T123049Z-789bf0d3`, attempt-1 paths, candidate `bd7bee182967-a496f933457c`. product_dir remains `framecue/`. No product source edits by Acceptance. Feishu CONTROLLER_DELIVERY skip |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| framecue-home-empty | crit-home-empty | frames/framecue-home-empty-r1.png `522cb8e9…` | reused design | `evidence/runtime/rt-home-empty.png` `72b46252…` | runtime (**fail**) | **known_issue** — vision wants chip bar + New session in-frame; AX after scroll + brand FrameCue + clapper present |
| framecue-capture-import | crit-capture-import | framecue-capture-import-r1 `6f9d6909…` | reused | `rt-capture-import.png` `da8bc123…` | runtime (**fail**) | **known_issue** — Camera visible; Photo library below fold (AX proves both) |
| framecue-composition-review | crit-composition-review | framecue-composition-review-r2 `a4264c3b…` | reused | _(no dedicated Keep runtime shot)_ | — | **known_issue** — Keep/Discard path not captured this attempt |
| framecue-slate-stage | crit-slate-stage | framecue-slate-stage-r1 `cda3df39…` | reused | `rt-slate-stage.png` `9c93a21b…` | runtime (**pass**) | pass — clapper canvas + bottom ECU..EWS chips, MS selected; not sprocket/zone/rail |
| framecue-coach-chat | crit-coach-chat | framecue-coach-chat-r1 `b7d41cd8…` | reused | `rt-coach-chat.png` `692d7bac…` | — | **known_issue** — PNG hash-collided with overlay/tts (Stage chrome) |
| framecue-overlay-marks | crit-overlay-marks | framecue-overlay-marks-r1 `1f678a20…` | reused | `rt-overlay-marks.png` `692d7bac…` | — | **known_issue** — same hash collision |
| framecue-hands-free-tts | crit-hands-free-tts | framecue-hands-free-tts-r1 `97e9db7e…` | reused | `rt-hands-free-tts.png` `692d7bac…` | — | **known_issue** — same hash collision |
| framecue-settings-privacy | crit-settings-privacy | framecue-settings-privacy-r1 `27297696…` | reused | `rt-settings-privacy.png` `76371279…` + scrolled `114048e7…` | runtime (**fail**) | **known_issue** — single-frame fold; AX shows Revoke + 4 permissions + local legal links |

Index: `visual_readback_index.v1.json` (reused_design=8, new_runtime_read=4).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_home_vision_partial` — runtime vision fail on chip bar / New session fold; brand + clapper + CTA present after scroll (AX).
2. `ul07_capture_vision_partial` — Photo library below fold in single frame; AX proves Camera + Photo library.
3. `ul07_settings_vision_partial` — Settings Revoke + AI unavailable + permissions observed via AX across scrolled frames; vision wants single-frame legal rows.
4. `ul07_coach_overlay_tts_screenshot_routing` — coach/overlay/tts PNG hashes collided (`692d7bac…`).
5. `ul07_composition_review_not_exercised` — Keep/Discard runtime shot missing.
6. `legal_webview_screenshots_missing` — Local legal HTML packaged + Settings legal entries present; deep WebView screenshots incomplete.
7. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof.
8. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator; empty AppIcon set stub only).
9. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测.

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
- `evidence/candidate-receipt.json` → `bd7bee182967-a496f933457c`
- `evidence/runtime/` (UITest logs, screenshots, AX)
- `evidence/ui-harness/` (external XCUITest; not product source)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `evidence/logs/build.log` / `install.log` / `launch.log`
- `../ai_app_build/attempt-1/MAP.md` / build.log / domain.log / candidate
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- Scroll Sessions home before tapping `new_session_cta` — CTA sits below the fold on iPhone 17 Pro.
- Stage AX identifiers `clapper_frame_canvas` / `shot_size_chip_bar` / `shot_chip_*` are strong UL-07 uniqueness proofs vs RuleCue/StopCue/NightCue twins.
- iPhone 17 Pro lease `B14CC0EA…` only; leave Pro Max Booted alone.
