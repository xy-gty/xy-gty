# WingCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 1ff579b5-7841-474d-ba07-0029912e724c  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: d23b6a370f07f610be3de4533409e5a8c0074ab6dfd177b57f75a14c6d05d860  
technical_contract_sha256: d0f1491a21ac0e032bbaeac9f646a5ae92bd9ae082cfb064fe62fa8a21423c17  
product_commit: 0ee8e582a11a22bc04d96259ef8955b6cc3a0f10  
product_dir: wingcue/ (`wingcue` → `product` symlink)  
product_branch: wingcue/kf-20261015T135733Z-fecade9e  
bundle_id: com.lingguang.wingcue  
remote: git@github.com:xy-gty/xy-gty.git  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/0ee8e582a11a-ab7764800c1f (candidate_unaccepted)  
palette: #0F766E / #F0FDFA / #C2410C  

CONTROLLER Option A: UL-04 relaunch harness soft + non-core UL-07 vision fold/false-sprocket / deep legal WebView shots / ID-result & lookalike & overlay routing screenshots + `ai_key_unavailable` → **known_issues only** (non-blocking). Core UL-01/UL-02/UL-04 runtime journeys passed on leased iPhone 17 Pro; AX proves `FieldCardStack` + `OversizedFieldMarkChips` + `SilhouetteCompareBar` (≠ ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket).

code_query: `code_query_blocked:codebase_memory_index_failed` — journeys from builder symbol_map + AX/UITest (read-only Acceptance; no product Grep-as-code-query).

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Frozen commit `0ee8e582…`; accept DerivedData rebuild **BUILD SUCCEEDED** (`evidence/logs/build.log`); install+launch `com.lingguang.wingcue` on `B14CC0EA…` (`install.log`/`launch.log`); UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-ul01.log`) **passed**; home AX `ul01-home.ax.txt` shows FieldCardStack/OversizedFieldMarkChips/SilhouetteCompareBar; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | UITest `testUL02CoreFlowsAndPrivacy` (`uitest-ul02.log` / `uitest-all.log`) **passed** — Shoot→camera entry, Import→picker, ID/Identify/lookalike/annotate/TTS/voice-note/settings. Unique chrome AX on home. Camera/mic/speech hardware quality → 真机待测 |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable` (blocker=false). Home/settings show `AI not configured — local capture still works.` / outbound blocked until consent. Honest unconfigured; not canned DeepSeek. Gap → known_issues |
| UL-04 reviewed_persistence | pass (known_issues) | Domain `evidence/runtime/domain-tests.log` **10/10 TEST SUCCEEDED** incl. Save/Dismiss/reject/persist/overlay. UITest `testUL04RelaunchPersistence` (`uitest-ul04.log`) **passed** — relaunch restored Settings via TypedNavigationStore then Back→FieldHome. CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedMarks` passed. Live second outbound adaptation deferred by `ai_key_unavailable` → known_issues |
| UL-06 privacy_permissions | pass | Settings AX: Camera/Photos/Microphone/Speech rows; Review AI consent; Privacy/Terms/Support/Provider links (`ul02-13-settings.ax.txt`, `rt-settings-scrolled.ax.txt`). Local HTML bundled in `.app` (`privacy.html`/`terms.html`/`support.html`/`provider-policy.html`). Info.plist four usage strings present. Deep WebView screenshots incomplete → known_issue (Option A). Remote legal URLs UNKNOWN = gap |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 (`visual_readback_index.v1.json`). Fresh runtime vision: **pass** voice-note; **fail→known_issues** home (Settings gear misread as sprocket) / capture / id-result / lookalike / overlay / consent / settings fold. AX independently proves field-card stack + oversized chips + silhouette bar + four permissions. No AppIcon/LaunchScreen assets (operator; empty AppIcon set stub). visual_runtime_required items=[] |
| UL-08 repo_evidence | pass | Evidence bound to commit `0ee8e582a11a22bc04d96259ef8955b6cc3a0f10`, branch `wingcue/kf-20261015T135733Z-fecade9e`, attempt-1 paths, candidate `0ee8e582a11a-ab7764800c1f`. product_dir remains `wingcue/`. No product source edits by Acceptance. Feishu CONTROLLER_DELIVERY skip |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| wingcue-home-empty | CR-HOME-01 | frames/wingcue-home-empty-r1.png `bb739e9c…` | reused design | `evidence/runtime/rt-home-empty.png` `135b1be2…` | runtime (**fail**) | **known_issue** — vision false-flag Settings gear as sprocket; AX proves FieldCardStack + chips + silhouette + Shoot/Import + mint/teal/terracotta |
| wingcue-capture-camera | CR-CAM-01 | wingcue-capture-camera-r1 `40052a3a…` | reused | `rt-capture-camera.png` `82a83e11…` | runtime (**fail**) | **known_issue** — camera system UI / permission sheet; Shoot entry exercised |
| wingcue-id-result | CR-ID-01 | wingcue-id-result-r1 `37264ed5…` | reused | `rt-id-result.png` `9b0fe989…` | runtime (**fail**) | **known_issue** — import routing did not land full ID chrome in frame; domain ID/save tests pass |
| wingcue-lookalike-chat | CR-CHAT-01 | wingcue-lookalike-chat-r1 `c210dbfe…` | reused | `rt-lookalike-chat.png` `5dc0a0e8…` | runtime (**fail**) | **known_issue** — chat entry exercised; full coach chrome not isolated in shot |
| wingcue-overlay-annotate | CR-OVL-01 | wingcue-overlay-annotate-r1 `ea0b6c4f…` | reused | `rt-overlay-annotate.png` `4a8867e7…` | runtime (**fail**) | **known_issue** — overlay path tapped; screenshot still home chrome |
| wingcue-voice-note | CR-MIC-01 | wingcue-voice-note-r1 `e5d52566…` | reused | `rt-voice-note.png` `35173625…` | runtime (**pass**) | pass — mic / voice-note surface visible |
| wingcue-consent-ai | CR-CONSENT-01 | wingcue-consent-ai-r1 `ab324166…` | reused | `rt-consent-ai.png` `17a8b416…` | runtime (**fail**) | **known_issue** — hash-collided with settings-scrolled; AX shows Review AI consent + outbound blocked |
| wingcue-settings-privacy | CR-SET-01 | wingcue-settings-privacy-r1 `2811c85b…` | reused | `rt-settings-privacy.png` `797793bc…` + scrolled `17a8b416…` | runtime (**fail**) | **known_issue** — fold; AX proves four permissions + local legal links + AI unavailable |

Index: `visual_readback_index.v1.json` (reused_design=8, new_runtime_read=8).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_home_vision_false_sprocket` — runtime vision fail: Settings gear misread as StopCue sprocket; AX proves FieldCardStack / OversizedFieldMarkChips / SilhouetteCompareBar + Shoot/Import.
2. `ul07_capture_vision_partial` — camera system UI / permission sheet vs design still criteria.
3. `ul07_id_lookalike_overlay_screenshot_routing` — ID/chat/overlay PNGs did not isolate full designed chrome after import.
4. `ul07_settings_consent_vision_partial` — Settings/consent vision fail + consent/settings-scrolled hash collision (`17a8b416…`).
5. `legal_webview_screenshots_missing` — Local legal HTML packaged + Settings legal entries present; deep WebView screenshots incomplete.
6. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof.
7. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator; empty AppIcon set stub only).
8. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测.

9. `ul04_relaunch_harness_soft` — earlier UITest `testUL04RelaunchPersistence` harness flake ("Home missing after relaunch"); domain 10/10 + later UL-04 path (TypedNavigationStore restore → Back→FieldHome) accepted under Option A soft; non-blocking.

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
- `evidence/candidate-receipt.json` → `0ee8e582a11a-ab7764800c1f`
- `evidence/runtime/` (UITest logs, screenshots, AX, domain-tests.log)
- `evidence/ui-harness/` (external XCUITest; not product source)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `evidence/logs/build.log` / `install.log` / `launch.log`
- `../ai_app_build/attempt-1/MAP.md` / build.log / domain.log / candidate
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- Settings gear must not be scored as StopCue film-sprocket chrome in UL-07 criteria wording.
- TypedNavigationStore restore of Settings after kill is valid UL-04 persistence; Back returns FieldHome.
- iPhone 17 Pro lease `B14CC0EA…` only; leave Pro Max Booted alone.
- Species uniqueness proof: AX ids `FieldCardStack` / `OversizedFieldMarkChips` / `SilhouetteCompareBar`.
