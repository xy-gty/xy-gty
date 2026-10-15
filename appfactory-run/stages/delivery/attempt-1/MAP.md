# FrameCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: e4f25707-22cc-44e7-9123-010e35399208  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: 131f8b751bcc346c32c68d2adb21acede76a733a0f3320480c5768ac22b83b6a  
technical_contract_sha256: 3bd8adb2a16343fa320ed77ae22ca4f28be2e84ca52888d949f52528126826fd  
product_commit: bd7bee1829677f58b05a55979d37eb5749bcb0a8  
product_dir: framecue/ (`framecue` → `product` symlink)  
product_branch: framecue/kf-20261015T123049Z-789bf0d3  
bundle_id: com.lingguang.framecue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/framecue/kf-20261015T123049Z-789bf0d3  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/bd7bee182967-a496f933457c (FrameCue.app.zip + receipt; accept bound same tip)  
palette: #7E22CE / #FAF5FF / #F59E0B  
unique_ui: ClapperFrameCanvas + ShotSizeChipBar (片场场记板式画幅框 + 底部景别芯片条)  
≠ twins: RuleCue table zone cards + turn step bar / StopCue film-sprocket / NightCue night-frame rail  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

FrameCue — AI director framing coach: shoot or import stills, keep reviewed composition notes, chat shot size / aspect / lens language on a clapper slate canvas with bottom shot-size chips (ECU/CU/MS/WS/EWS), mark safe-frame / thirds overlays, and hear hands-free TTS on-set cues. Palette `#7E22CE` / `#FAF5FF` / `#F59E0B`. Four permissions: Camera / Photos / Microphone / Speech Recognition.

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T123049Z-789bf0d3/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T123049Z-789bf0d3/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T123049Z-789bf0d3/stages/pm_docs/attempt-1/MAP.md`  
- Package: n/a (ai_native; no PDA)  
- Checklist: n/a (ai_native)  
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T123049Z-789bf0d3/stages/pm_docs/attempt-1/visual_manifest.v1.json`  

## Packaging artifacts

- Local zip: `artifacts/candidates/bd7bee182967-a496f933457c/FrameCue.app.zip` (present, ~6.2M)  
- Receipt sha256: `c4efeaf406b60089e21ac56b55f64945f1c401a881b8856df03a444f3af59ac0`  
- Source commit freeze: `bd7bee1829677f58b05a55979d37eb5749bcb0a8`  
- Remote tip readback: `bd7bee1829677f58b05a55979d37eb5749bcb0a8	refs/heads/framecue/kf-20261015T123049Z-789bf0d3` (match)  
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
| UL-07 ui_interaction | pass (Option A known_issues on non-core vision / routing) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped FrameCue on independent branch `framecue/kf-20261015T123049Z-789bf0d3` → `xy-gty/xy-gty` at `bd7bee1…`
- product_dir remains `framecue/` (symlink → `product`); bundle `com.lingguang.framecue`
- Build + domain 10/10 + Simulator smoke/UITest on iPhone 17 Pro `B14CC0EA…` only; Pro Max left Booted untouched
- Core UL-01/UL-02 journeys passed; AX proves `clapper_frame_canvas` + `shot_size_chip_bar` / `shot_chip_*`
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
| pm_docs | validated | 1 | 2444.0 | n/a |
| ai_app_build | validated | 1 | 716.0 | n/a |
| ai_app_accept | validated | 1 | 1246.0 | n/a |
| delivery | active→produced | 1 | null at report time | n/a |
| **total (validated stages)** | | | **4406.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed UltraLite timing (completed leaf/stage spans; incomplete retained as-is, not guessed):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution | 2415.590362 | completed |
| ai_app_build stage_execution | 674.729208 | completed |
| ai_app_accept stage_execution | 1166.107368 | completed |
| delivery stage_execution | incomplete host span at MAP write | controller-started; finished after MAP |
| delivery evidence `delivery-evidence-1` | (finish after MAP) | this attempt |
| formal `delivered` | null | controller complete only |

Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含验收运行与视觉读图窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/framecue/kf-20261015T123049Z-789bf0d3
- commits: `bd7bee1829677f58b05a55979d37eb5749bcb0a8`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/bd7bee182967-a496f933457c`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/` (MAP, build/domain/smoke logs, candidate)
- config audit: build `evidence/config-audit.stdout.txt` + accept `evidence/config/inspect-key.json`
- packaging readback: `stages/delivery/attempt-1/evidence/packaging-readback.txt`

## known_issues (non-blocking — CONTROLLER Option A; sealed in accept)

1. `ul07_home_vision_partial`
2. `ul07_capture_vision_partial`
3. `ul07_settings_vision_partial`
4. `ul07_coach_overlay_tts_screenshot_routing`
5. `ul07_composition_review_not_exercised`
6. `legal_webview_screenshots_missing`
7. `ai_key_unavailable` — expected P1 local_only
8. `branding_assets_deferred` — no AppIcon/LaunchScreen
9. `camera_mic_speech_device_quality` — Simulator entries only

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_match_error=0)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config (`ai_key_source: none`)
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`
- disk: host volume ~92% used / ~17Gi free at delivery report time (no in-use DerivedData cleared)

## Blockers

(none)

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `framecue/` symlink; never report path-only `product/` as the operator product_dir.
- AX ids `clapper_frame_canvas` / `shot_size_chip_bar` / `shot_chip_*` are the uniqueness proof vs RuleCue/StopCue/NightCue twins.
- Packaging-ready gate for this run = candidate zip + receipt + remote tip matching accept freeze.
