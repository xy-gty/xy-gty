# RuleCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 288af0d4-d2b8-42ff-8a6b-310a2746d803  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: 803064a4db0d8bdaf7bd875cbd21bbcf0a8834a75676d4550391c6576d5da900  
technical_contract_sha256: c66fef8e4c822efd842ef91b6009b49826b7a9f871f3e6e9f6acb096fe8185c7  
product_commit: 0ca4a31f94354b3456e1aa739e92496e5fbfb2bb  
product_dir: rulecue/ (`rulecue` → `product` symlink)  
product_branch: rulecue/kf-20261015T111031Z-ed6f1861  
bundle_id: com.lingguang.rulecue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/rulecue/kf-20261015T111031Z-ed6f1861  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/0ca4a31f9435-9b8b99bc9e24 (RuleCue.app.zip + receipt; accept bound same tip)  
palette: #854D0E / #FEFCE8 / #0891B2  
unique_ui: TableZoneCards + TurnStepBar  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

RuleCue — 桌游规则与摆台 AI 教练：拍/导入规则书与桌面 → 识别组件与阶段 → 对话答疑与回合流程 → 生成摆台分区标注 → TTS 桌边主持口令。Palette `#854D0E` / `#FEFCE8` / `#0891B2`；UI = 桌面分区卡 + 回合步骤条（≠ StopCue film-sprocket / NightCue night-frame / HiveCue/FormCue/YarnCue/ScoutCue）。

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/stages/pm_docs/attempt-1/MAP.md`  
- Package: n/a (ai_native; no PDA)  
- Checklist: n/a (ai_native)  
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/stages/pm_docs/attempt-1/visual_manifest.v1.json`  

## Packaging artifacts

- Local zip: `artifacts/candidates/0ca4a31f9435-9b8b99bc9e24/RuleCue.app.zip` (present, ~6.3M)  
- Receipt sha256: `7bf7d7be14a27f525a3a93e2fcf2f228d4d4cd68f6fbc3a925a5a4bc4424e22e`  
- Source commit freeze: `0ca4a31f94354b3456e1aa739e92496e5fbfb2bb`  
- Remote tip readback: `0ca4a31f94354b3456e1aa739e92496e5fbfb2bb	refs/heads/rulecue/kf-20261015T111031Z-ed6f1861` (match)  
- Evidence: `evidence/packaging-readback.txt`  

## UL eight-domain stamp (from accept; not re-judged)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (P1 local_only honest `ai_key_unavailable`) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second outbound deferred by key gap) |
| UL-06 privacy_permissions | pass |
| UL-07 ui_interaction | pass (Option A known_issues on non-core vision / routing) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped RuleCue on independent branch `rulecue/kf-20261015T111031Z-ed6f1861` → `xy-gty/xy-gty` at `0ca4a31…`
- product_dir remains `rulecue/` (symlink → `product`); bundle `com.lingguang.rulecue`
- Build + domain 10/10 + Simulator smoke/UITest on iPhone 17 Pro `B14CC0EA…` only; Pro Max left Booted untouched
- Core UL-01/UL-02 journeys passed; TableZoneCards + TurnStepBar proven via AX
- Four permission entry points present (Camera / Photos / Mic / Speech); hardware quality 真机待测
- free_app_only; no AppIcon/LaunchScreen this round
- Feishu delivery writeback skipped per CONTROLLER_DELIVERY
- Option A soft known_issues already sealed in accept — retained non-blocking
- Formal `delivered` milestone is controller complete/status readback only — not claimed here

## Stage cost

Copy of controller `stage_cost_json` (usage unknown → n/a):

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 912.0 | n/a |
| ai_app_build | validated | 1 | 1164.0 | n/a |
| ai_app_accept | validated | 1 | 1627.0 | n/a |
| delivery | active→produced | 1 | null at report time | n/a |
| **total (validated stages)** | | | **3703.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed UltraLite timing (completed leaf/stage spans; incomplete retained as-is, not guessed):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution | 865.818963 | completed |
| ai_app_build stage_execution | 1038.97776 | completed |
| ai_app_accept stage_execution | 1465.386937 | completed |
| delivery stage_execution | incomplete host span | controller-started; not guessed |
| delivery evidence `delivery-evidence-1` | (finish after MAP) | this attempt |
| formal `delivered` | null | controller complete only |

Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含验收运行与视觉读图窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/rulecue/kf-20261015T111031Z-ed6f1861
- commits: `0ca4a31f94354b3456e1aa739e92496e5fbfb2bb`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/0ca4a31f9435-9b8b99bc9e24`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/` (MAP, build/domain/smoke logs, candidate)
- config audit: accept `evidence/config/config-audit.stdout.txt` + `inspect-key.json`
- packaging readback: `stages/delivery/attempt-1/evidence/packaging-readback.txt`

## known_issues (non-blocking — CONTROLLER Option A; sealed in accept)

1. `ul07_home_vision_partial`
2. `ul07_table_coach_vision_uncertain`
3. `ul07_coach_chat_screenshot_routing`
4. `ul07_setup_overlay_screenshot_routing`
5. `ul07_tts_host_screenshot_routing`
6. `ul07_settings_vision_partial`
7. `ul07_component_review_not_exercised`
8. `legal_webview_uitest_flaky`
9. `ai_key_unavailable` — expected P1 local_only
10. `code_query_blocked:codebase_memory_mcp_missing` — infrastructure
11. `branding_assets_deferred` — no AppIcon/LaunchScreen
12. `camera_mic_speech_device_quality` — Simulator entries only

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_match_error=0)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config (`ai_key_source: none`)
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`
- disk: host volume ~94% used / ~13Gi free at delivery report time (no in-use DerivedData cleared)

## Blockers

(none)

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `rulecue/` symlink; never report path-only `product/` as the operator product_dir.
- Packaging-ready gate for this run = candidate zip + receipt + remote tip matching accept freeze.
