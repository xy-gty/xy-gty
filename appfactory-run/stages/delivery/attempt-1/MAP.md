# MixCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 8a16ec6a-4ec4-4915-a003-f5dd507f1db8  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: ac86f75a0af01b38ef8acf96bd9877461ba04f5812cd31370b5d7eef010d46bf  
technical_contract_sha256: a6a5c05c1334f671c59c636a25afe98e5c227a09bda4cd85692dcaed703fd7ac  
product_commit: 5e418cc1c0f00d290882f5b00d124df373c3734b  
product_dir: mixcue/ (`mixcue` → `product` symlink)  
product_branch: mixcue/kf-20261015T162417Z-7519c0dc  
bundle_id: com.lingguang.mixcue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/mixcue/kf-20261015T162417Z-7519c0dc  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/5e418cc1c0f0-43e6f75b7bb6 (MixCue.app.zip + receipt; accept bound same tip)  
palette: #E11D48 / #FFF1F2 / #CA8A04  
unique_ui: BottleRail + NextPourCard + GarnishChipRow (竖向瓶架轨 + 大号下一步倒法卡 + 装饰 chip 行)  
≠ twins: WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

MixCue — AI home bar cocktail coach: shoot or import bottle / label / garnish, get base-spirit ID, chat recipes and substitutes, run a pour/garnish board with TTS shake steps. Palette `#E11D48` / `#FFF1F2` / `#CA8A04`. Four permissions: Camera / Photos / Microphone / Speech Recognition. Competitor names absent from App UI copy.

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T162417Z-7519c0dc/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T162417Z-7519c0dc/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T162417Z-7519c0dc/stages/pm_docs/attempt-1/MAP.md`  
- Package: n/a (ai_native; no PDA)  
- Checklist: n/a (ai_native)  
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T162417Z-7519c0dc/stages/pm_docs/attempt-1/visual_manifest.v1.json`  

## Packaging artifacts

- Local zip: `artifacts/candidates/5e418cc1c0f0-43e6f75b7bb6/MixCue.app.zip` (present, ~6.2M)  
- Receipt sha256: `da7337914e4c37b2e2ef269826f7edddf9df25c64782247c929b4c937f0186c2`  
- Source commit freeze: `5e418cc1c0f00d290882f5b00d124df373c3734b`  
- Remote tip readback: `5e418cc1c0f00d290882f5b00d124df373c3734b	refs/heads/mixcue/kf-20261015T162417Z-7519c0dc` (match)  
- Evidence: `evidence/packaging-readback.txt`  

## UL eight-domain stamp (from accept; not re-judged)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (P1 local_only honest `ai_key_unavailable`) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second outbound deferred by key gap) |
| UL-06 privacy_permissions | pass (Camera/Photos/Mic/Speech + local legal HTML) |
| UL-07 ui_interaction | pass (Option A known_issues on non-core vision / fold) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped MixCue on independent branch `mixcue/kf-20261015T162417Z-7519c0dc` → `xy-gty/xy-gty` at `5e418cc1…`
- product_dir remains `mixcue/` (symlink → `product`); bundle `com.lingguang.mixcue`
- Build + domain 10/10 + Simulator smoke/UITest on iPhone 17 Pro `B14CC0EA…` only; Pro Max left Booted untouched
- Core UL-01 / UL-02b sell / UL-04 / UL-06 runtime journeys passed; AX proves `BottleRail` + `NextPourCard` + `GarnishChipRow`
- Four permission entry points present; hardware quality 真机待测
- free_app_only; no AppIcon/LaunchScreen this round
- Feishu delivery writeback skipped per CONTROLLER_DELIVERY
- Option A soft known_issues already sealed in accept — retained non-blocking
- Formal `delivered` milestone is controller complete/status readback only — not claimed here

## Stage cost

Copy of controller `stage_cost_json` (usage unknown → n/a):

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 1213.0 | n/a |
| ai_app_build | validated | 1 | 900.0 | n/a |
| ai_app_accept | validated | 1 | 1927.0 | n/a |
| delivery | active→produced | 1 | null at report time | n/a |
| **total (validated stages)** | | | **4040.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed UltraLite timing (completed leaf/stage spans; incomplete retained as-is, not guessed):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution | 1124.709278 | completed |
| pm_docs planning | 188.503279 | completed |
| pm_docs visual_capture | 259.842497 | completed |
| pm_docs visual_readback | 451.590664 | completed |
| pm_docs evidence | 23.763516 | completed |
| ai_app_build stage_execution | 862.36621 | completed |
| ai_app_build implementation `build-main` | 491.373767 | completed |
| ai_app_build integration_build `xcodebuild` | 147.09239 | completed |
| ai_app_build domain_tests | 105.089178 | completed |
| ai_app_build runtime_smoke | 82.126975 | completed |
| ai_app_accept stage_execution | 1916.600085 | completed |
| delivery stage_execution | incomplete host span at MAP write | controller-started; finished after MAP |
| delivery evidence `delivery-evidence-1` | (finish after MAP) | this attempt |
| formal `delivered` | null | controller complete only |

Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含验收运行与视觉读图窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/mixcue/kf-20261015T162417Z-7519c0dc
- commits: `5e418cc1c0f00d290882f5b00d124df373c3734b`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/5e418cc1c0f0-43e6f75b7bb6`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/` (MAP, build/domain/smoke logs, candidate, git-push.log)
- config audit: build `evidence/config-audit.stdout.txt` + accept `evidence/config/inspect-key.json`
- packaging readback: `stages/delivery/attempt-1/evidence/packaging-readback.txt`

## known_issues (non-blocking — CONTROLLER Option A; sealed in accept)

1. `ul07_home_vision_garnish_fold` — runtime vision fail: garnish chip row below fold; AX proves BottleRail / NextPourCard / GarnishChipRow + Shoot/Import
2. `ul07_capture_vision_partial` — camera system UI / permission sheet vs design still criteria
3. `ul07_pour_vision_garnish_fold` — pour-board vision uncertain on chip row; UITest reached PourBoard + Speak step
4. `ul07_settings_consent_vision_partial` — Settings/consent vision fail/uncertain; AX proves four permissions + Revoke + local legal entries
5. `legal_webview_screenshots_missing` — Local legal HTML packaged + Settings legal entries present; deep WebView screenshots incomplete
6. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof
7. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator; empty Assets.xcassets Contents only)
8. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测
9. `ul02_settings_speech_alert_harness_soft` — first UL-02 Settings speech-alert harness soft; recovered via UL-02b sell + UL-06 (Option A soft; non-blocking)

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_match_error=0)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config (`ai_key_source: none`)
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`

## Blockers

(none)

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `mixcue/` symlink; never report path-only `product/` as the operator product_dir.
- AX ids `BottleRail` / `NextPourCard` / `GarnishChipRow` are the uniqueness proof vs WingCue/ClosetCue/FrameCue/ScoutCue/RuleCue/StopCue twins.
- Packaging-ready gate for this run = candidate zip + receipt + remote tip matching accept freeze `5e418cc1…`.
