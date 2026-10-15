# MixCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 87175a47-371f-47a7-9ee8-3166b727994f  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: ac86f75a0af01b38ef8acf96bd9877461ba04f5812cd31370b5d7eef010d46bf  
technical_contract_sha256: a6a5c05c1334f671c59c636a25afe98e5c227a09bda4cd85692dcaed703fd7ac  
product_commit: 5e418cc1c0f00d290882f5b00d124df373c3734b  
product_dir: mixcue/ (`mixcue` → `product` symlink)  
product_branch: mixcue/kf-20261015T162417Z-7519c0dc  
bundle_id: com.lingguang.mixcue  
remote: git@github.com:xy-gty/xy-gty.git  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; Pro Max never shutdown/occupied)  
candidate: artifacts/candidates/5e418cc1c0f0-43e6f75b7bb6 (candidate_unaccepted)  
palette: #E11D48 / #FFF1F2 / #CA8A04  

CONTROLLER Option A: non-core UL-07 vision fail/uncertain (home garnish fold / camera system UI / consent sheet not isolated / pour garnish fold / settings fold) + first UL-02 Settings speech-alert harness soft + `ai_key_unavailable` → **known_issues only** (non-blocking; do NOT re-run vision). Core UL-01 / UL-02b sell / UL-04 / UL-06 runtime journeys passed on leased iPhone 17 Pro; AX proves `BottleRail` + `NextPourCard` + `GarnishChipRow` (≠ WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket).

code_query: `code_query_blocked:codebase_memory_index_failed` — journeys from builder symbol_map + AX/UITest (read-only Acceptance; no product Grep-as-code-query).

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Frozen commit `5e418cc1…`; accept DerivedData rebuild **BUILD SUCCEEDED** (`evidence/logs/build.log`); install+launch `com.lingguang.mixcue` on `B14CC0EA…` (`install.log`/`launch.log`); UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-ul01.log`) **passed**; home AX `ul01-home.ax.txt` shows BottleRail/NextPourCard/GarnishChipRow + blush/rose/gold; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | Selling-point UITest `testUL02bSellCoachAndPour` (`uitest-ul02b-ul06.log`) **passed** — Import→Spirit ID→Ask coach→RecipeChat→typed “what can I sub for Cointreau”→Open pour board→PourBoard Speak step/Next step/Save Mix. Also Shoot/Import/Identify/Voice note/Speech entries in `uitest-ul02.log` (Settings interruption soft). Unique chrome AX on home. Camera/mic/speech hardware quality → 真机待测 |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable` (blocker=false). Home shows `AI not configured — local capture still works.` Honest unconfigured; not canned DeepSeek. Gap → known_issues |
| UL-04 reviewed_persistence | pass | Domain `evidence/runtime/domain-tests.log` **10/10 TEST SUCCEEDED** incl. MixStore round-trip / reject-not-confirmed / garnish persistence / second-call context. UITest `testUL04RelaunchPersistence` (`uitest-ul06-ul04.log`) **passed**. CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedSpirits` passed. Live second outbound adaptation deferred by `ai_key_unavailable` → known_issues |
| UL-06 privacy_permissions | pass | Settings AX: Camera/Photos/Microphone/Speech Recognition rows; Revoke AI consent; Privacy/Terms/Support/Provider links (`ul02-13-settings.ax.txt`, `rt-settings-scrolled.ax.txt`). Local HTML bundled in `.app` (`privacy.html`/`terms.html`/`support.html`/`provider-policy.html`). Info.plist four usage strings present. Deep WebView screenshots incomplete → known_issue (Option A). Remote legal URLs UNKNOWN = gap. ConsentSheet DeepSeek fields not isolated this attempt (local_only + revoke path); no outbound without key |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 (`visual_readback_index.v1.json`). Fresh runtime vision: **pass** id-result / recipe-chat / voice-note; **fail→known_issues** home-empty (garnish fold) / capture-camera / consent-ai; **uncertain→known_issues** pour-board / settings-privacy. AX independently proves bottle-rail + next-pour + garnish chips + four permissions + Coach/PourBoard. No AppIcon/LaunchScreen assets (operator; empty Assets.xcassets Contents only). visual_runtime_required items=[] |
| UL-08 repo_evidence | pass | Evidence bound to commit `5e418cc1c0f00d290882f5b00d124df373c3734b`, branch `mixcue/kf-20261015T162417Z-7519c0dc`, attempt-1 paths, candidate `5e418cc1c0f0-43e6f75b7bb6` sha256 `da7337914e4c37b2…`. product_dir remains `mixcue/`. No product source edits by Acceptance. Feishu CONTROLLER_DELIVERY skip. Competitor names absent from App UI copy (system prompt only forbids naming them) |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| mixcue-home-empty | CR-HOME-01 | frames/mixcue-home-empty-r1.png `dad80bb5…` | reused design | `evidence/visual-readback/rt-mixcue-home-empty.png` `8e4bb489…` | runtime (**fail**) | **known_issue** — vision missed garnish chip fold; AX proves BottleRail + NextPourCard + GarnishChipRow + Shoot/Import |
| mixcue-capture-camera | CR-CAM-01 | mixcue-capture-camera-r1 `f364ff96…` | reused | `rt-mixcue-capture-camera.png` `e3eb03fe…` | runtime (**fail**) | **known_issue** — camera system UI / permission sheet; Shoot entry exercised |
| mixcue-id-result | CR-ID-COMBO | mixcue-id-result-r1 `416e5123…` | reused | `rt-mixcue-id-result.png` `aa48fde3…` | runtime (**pass**) | pass — Spirit ID + bottle-rail |
| mixcue-recipe-chat | CR-CHAT-01 | mixcue-recipe-chat-r1 `4c32ebc1…` | reused | `rt-mixcue-recipe-chat.png` `5bf0bd5c…` | runtime (**pass**) | pass — Coach / RecipeChat + substitute prompt |
| mixcue-pour-board | CR-POUR-COMBO | mixcue-pour-board-r1 `2da37cba…` | reused | `rt-mixcue-pour-board.png` `1c122f94…` | runtime (**uncertain**) | **known_issue** — next-pour card visible; garnish chips below fold in shot; AX/UITest exercised Speak step |
| mixcue-voice-note | CR-MIC-01 | mixcue-voice-note-r1 `b23a29b2…` | reused | `rt-mixcue-voice-note.png` `62cf09f7…` | runtime (**pass**) | pass — hands-free voice note / Start recording |
| mixcue-consent-ai | CR-CONSENT-01 | mixcue-consent-ai-r1 `0a0cbfbd…` | reused | `rt-mixcue-consent-ai.png` `531d4b2b…` | runtime (**fail**) | **known_issue** — revoke path / Settings consent state; full DeepSeek field sheet not isolated (local_only) |
| mixcue-settings-privacy | CR-SET-01 | mixcue-settings-privacy-r1 `7c2c99cd…` | reused | `rt-mixcue-settings-privacy.png` `91744e2c…` + scrolled | runtime (**uncertain**) | **known_issue** — fold; AX proves four permissions + local legal links + Revoke |

Index: `visual_readback_index.v1.json` (reused_design=8, new_runtime_read=8).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_home_vision_garnish_fold` — runtime vision fail: garnish chip row below fold; AX proves BottleRail / NextPourCard / GarnishChipRow + Shoot/Import.
2. `ul07_capture_vision_partial` — camera system UI / permission sheet vs design still criteria.
3. `ul07_pour_vision_garnish_fold` — pour-board vision uncertain on chip row; UITest reached PourBoard + Speak step.
4. `ul07_settings_consent_vision_partial` — Settings/consent vision fail/uncertain; AX proves four permissions + Revoke + local legal entries.
5. `legal_webview_screenshots_missing` — Local legal HTML packaged + Settings legal entries present; deep WebView screenshots incomplete.
6. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof.
7. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator; empty Assets.xcassets Contents only).
8. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测.
9. `ul02_settings_speech_alert_harness_soft` — first `testUL02CoreFlowsAndPrivacy` failed on Chinese speech-permission interruption invalidating Settings tap after core sell shots; recovered via `testUL02bSellCoachAndPour` + `testUL06SettingsPrivacy` (Option A soft; non-blocking).

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
- `evidence/candidate-receipt.json` → `5e418cc1c0f0-43e6f75b7bb6`
- `evidence/runtime/` (UITest logs, screenshots, AX, domain-tests.log, uitest-summary.txt)
- `evidence/ui-harness/` (external XCUITest; not product source)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `evidence/logs/build.log` / `install.log` / `launch.log`
- `evidence/evidence-hashes.json`
- `../ai_app_build/attempt-1/MAP.md` / build.log / domain.log / candidate
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- GarnishChipRow can sit below fold on home/pour screenshots; score via AX + scroll before UL-07 home/pour criteria.
- TypedNavigationStore restore of Coach/PourBoard after kill is valid UL-04; Settings gear only on BarHome — pop via `BackButton` identifier (label = previous title).
- iPhone 17 Pro lease `B14CC0EA…` only; leave Pro Max Booted alone.
- Species uniqueness proof: AX ids `BottleRail` / `NextPourCard` / `GarnishChipRow`.
