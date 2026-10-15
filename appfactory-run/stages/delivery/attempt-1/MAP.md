# WingCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 81116dfe-7fcc-47b6-a0d5-34f494a26bef  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: d23b6a370f07f610be3de4533409e5a8c0074ab6dfd177b57f75a14c6d05d860  
technical_contract_sha256: d0f1491a21ac0e032bbaeac9f646a5ae92bd9ae082cfb064fe62fa8a21423c17  
product_commit: 0ee8e582a11a22bc04d96259ef8955b6cc3a0f10  
product_dir: wingcue/ (`wingcue` → `product` symlink)  
product_branch: wingcue/kf-20261015T135733Z-fecade9e  
bundle_id: com.lingguang.wingcue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/wingcue/kf-20261015T135733Z-fecade9e  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/0ee8e582a11a-ab7764800c1f (WingCue.app.zip + receipt; accept bound same tip)  
palette: #0F766E / #F0FDFA / #C2410C  
unique_ui: FieldCardStack + OversizedFieldMarkChips + SilhouetteCompareBar (物种 field-card 叠层 + 超大鉴别特征 chips + 剪影对比条)  
≠ twins: ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

WingCue — AI birding field coach: shoot or import bird photos, get species ID with field-mark cards and oversized chips, clarify lookalikes in coach chat, annotate silhouette overlays, and hear TTS ID tips. Palette `#0F766E` / `#F0FDFA` / `#C2410C`. Four permissions: Camera / Photos / Microphone / Speech Recognition.

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T135733Z-fecade9e/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T135733Z-fecade9e/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T135733Z-fecade9e/stages/pm_docs/attempt-1/MAP.md`  
- Package: n/a (ai_native; no PDA)  
- Checklist: n/a (ai_native)  
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T135733Z-fecade9e/stages/pm_docs/attempt-1/visual_manifest.v1.json`  

## Packaging artifacts

- Local zip: `artifacts/candidates/0ee8e582a11a-ab7764800c1f/WingCue.app.zip` (present, ~6.3M)  
- Receipt sha256: `16fcb48e4dc8e33f8f6b44bc33d11920a1e07ab0f86d1c288d28037e95ceccd4`  
- Source commit freeze: `0ee8e582a11a22bc04d96259ef8955b6cc3a0f10`  
- Remote tip readback: `0ee8e582a11a22bc04d96259ef8955b6cc3a0f10	refs/heads/wingcue/kf-20261015T135733Z-fecade9e` (match)  
- Evidence: `evidence/packaging-readback.txt`  

## UL eight-domain stamp (from accept; not re-judged)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (P1 local_only honest `ai_key_unavailable`) |
| UL-04 reviewed_persistence | pass (Option A soft on earlier relaunch harness flake) |
| UL-05 feedback_reuse | pass (live second outbound deferred by key gap) |
| UL-06 privacy_permissions | pass (Camera/Photos/Mic/Speech + local legal HTML) |
| UL-07 ui_interaction | pass (Option A known_issues on non-core vision / routing) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped WingCue on independent branch `wingcue/kf-20261015T135733Z-fecade9e` → `xy-gty/xy-gty` at `0ee8e582…`
- product_dir remains `wingcue/` (symlink → `product`); bundle `com.lingguang.wingcue`
- Build + domain 10/10 + Simulator smoke/UITest on iPhone 17 Pro `B14CC0EA…` only; Pro Max left Booted untouched
- Core UL-01/UL-02 journeys passed; AX proves `FieldCardStack` + `OversizedFieldMarkChips` + `SilhouetteCompareBar`
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
| pm_docs | validated | 1 | 5273.0 | n/a |
| ai_app_build | validated | 1 | 864.0 | n/a |
| ai_app_accept | validated | 1 | 1703.0 | n/a |
| delivery | active→produced | 1 | null at report time | n/a |
| **total (validated stages)** | | | **7840.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed UltraLite timing (completed leaf/stage spans; incomplete retained as-is, not guessed):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs planning | 150.946336 | completed |
| pm_docs visual_capture | 616.250384 | completed |
| pm_docs stage_execution (e2) | 333.136437 | completed |
| pm_docs stage_execution (e1) / visual_readback | incomplete | retained |
| ai_app_build stage_execution | 739.358033 | completed |
| ai_app_build xcode_build | 125.437607 | completed |
| ai_app_build domain_tests | 24.660543 | completed |
| ai_app_build smoke | 75.261497 | completed |
| ai_app_build implementation `build_app` | incomplete | retained |
| ai_app_accept stage_execution | 1513.362919 | completed |
| ai_app_accept runtime_smoke | 1188.824424 | completed |
| ai_app_accept visual_readback | 718.6035 | completed |
| delivery stage_execution (e1+e2) | incomplete host span at MAP write | controller-started; finished after MAP |
| delivery evidence `delivery-evidence-1` | 7.77532 | this attempt |
| formal `delivered` | null | controller complete only |

Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含验收运行与视觉读图窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/wingcue/kf-20261015T135733Z-fecade9e
- commits: `0ee8e582a11a22bc04d96259ef8955b6cc3a0f10`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/0ee8e582a11a-ab7764800c1f`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/` (MAP, build/domain/smoke logs, candidate, git-push.log)
- config audit: build `evidence/config-audit.stdout.txt` + accept `evidence/config/inspect-key.json`
- packaging readback: `stages/delivery/attempt-1/evidence/packaging-readback.txt`

## known_issues (non-blocking — CONTROLLER Option A; sealed in accept)

1. `ul07_home_vision_false_sprocket` — Settings gear misread as StopCue sprocket; AX proves field-card stack + chips + silhouette
2. `ul07_capture_vision_partial`
3. `ul07_id_lookalike_overlay_screenshot_routing`
4. `ul07_settings_consent_vision_partial`
5. `legal_webview_screenshots_missing`
6. `ai_key_unavailable` — expected P1 local_only
7. `branding_assets_deferred` — no AppIcon/LaunchScreen
8. `camera_mic_speech_device_quality` — Simulator entries only
9. `ul04_relaunch_harness_soft` — earlier relaunch harness flake; domain 10/10 + later UL-04 path accepted under Option A

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_match_error=0)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config (`ai_key_source: none`)
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`
- disk: host volume ~93% used / ~15Gi free at delivery report time (no in-use DerivedData cleared)

## Blockers

(none)

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `wingcue/` symlink; never report path-only `product/` as the operator product_dir.
- AX ids `FieldCardStack` / `OversizedFieldMarkChips` / `SilhouetteCompareBar` are the uniqueness proof vs ClosetCue/FrameCue/ScoutCue/RuleCue/StopCue twins.
- Packaging-ready gate for this run = candidate zip + receipt + remote tip matching accept freeze `0ee8e582…`.
