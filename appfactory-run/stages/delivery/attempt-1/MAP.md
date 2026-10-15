# CellarCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 9421fd43-d13d-4846-8aa7-c6f7bf6708d8  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: d1deb007e4d4fbe223dd1b426b3ec2a150d8c85c9c781fea812e7f7c07504497  
technical_contract_sha256: 5b0e7e1cf2ab96ca937e5fe9661287dbdb46203ee0a885a281a14e8ec8097400  
product_commit: eded2779dc48944bf1cc943f255e972d423701ed  
product_dir: cellarcue/ (`cellarcue` → `product` symlink)  
product_branch: cellarcue/kf-20261015T185351Z-25a1f937  
bundle_id: com.lingguang.cellarcue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/cellarcue/kf-20261015T185351Z-25a1f937  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/eded2779dc48-a36f3c574978 (CellarCue.app.zip + receipt; accept bound same tip)  
palette: #3730A3 / #EEF2FF / #EA580C  
unique_ui: CellarRowBinGrid + LabelOCRHeroCard + DrinkingWindowTimeline (酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴)  
≠ twins: MixCue bottle-rail / SporeCue confidence-stack / WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

CellarCue — AI wine-cellar label ID & drinking-window coach: shoot or import wine labels, AI ID into bin/slot, chat drinking window & food pairing, annotated cellar-rack cards, TTS pull/pour brief. Every alcohol-advice surface states 「非侍酒认证 / not a sommelier certification」 and 「非投资建议 / not investment advice」 plus 21+ where recommendations appear. Palette `#3730A3` / `#EEF2FF` / `#EA580C`. Four permissions: Camera / Photos / Microphone / Speech Recognition. Competitor brands absent from App UI copy.

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T185351Z-25a1f937/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T185351Z-25a1f937/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T185351Z-25a1f937/stages/pm_docs/attempt-1/MAP.md`  
- Package: n/a (ai_native; no PDA)  
- Checklist: n/a (ai_native)  
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T185351Z-25a1f937/stages/pm_docs/attempt-1/visual_manifest.v1.json`  

## Packaging artifacts

- Local zip: `artifacts/candidates/eded2779dc48-a36f3c574978/CellarCue.app.zip` (present, ~6.3M)  
- Receipt sha256: `59a5ccc703d95a11a91fba393798b53d84f5d9522e949ca4f4ca348f5eba9785`  
- Source commit freeze: `eded2779dc48944bf1cc943f255e972d423701ed`  
- Remote tip readback: `eded2779dc48944bf1cc943f255e972d423701ed	refs/heads/cellarcue/kf-20261015T185351Z-25a1f937` (match)  
- Legacy hyphen branch same tip: `refs/heads/cellarcue-kf-20261015T185351Z-25a1f937`  
- Flat `refs/heads/cellarcue` retired after tip match so nested independent branch could be created (Git cannot host both)  
- Evidence: `evidence/packaging-readback.txt`  
- Feishu skip: `evidence/feishu-controller-delivery-skip.txt` (record_id n/a, blocker=false)  

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

- Shipped CellarCue on independent branch `cellarcue/kf-20261015T185351Z-25a1f937` → `xy-gty/xy-gty` at `eded2779…`
- product_dir remains `cellarcue/` (symlink → `product`); bundle `com.lingguang.cellarcue`
- Build + domain 11/11 + Simulator smoke/UITest on iPhone 17 Pro `B14CC0EA…` only; Pro Max left Booted untouched
- Core UL-01 / UL-02 / UL-04 / UL-06 journeys passed; signature UI = row/bin grid + OCR hero + drinking-window timeline
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
| pm_docs | validated | 1 | 1050.0 | n/a |
| ai_app_build | validated | 1 | 751.0 | n/a |
| ai_app_accept | validated | 1 | 1589.0 | n/a |
| delivery | active→produced | 1 | null at report time | n/a |
| **total (validated stages)** | | | **3390.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed UltraLite timing (completed leaf/stage spans; incomplete retained as-is, not guessed):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution | 1035.286769 | completed |
| pm_docs planning | incomplete | retained running host span |
| pm_docs visual_capture | 122.592118 | completed |
| pm_docs visual_readback | 492.371051 | completed |
| ai_app_build stage_execution | 623.84399 | completed |
| ai_app_build planning | 457.912275 | completed |
| ai_app_build integration_build | 21.214042 | completed |
| ai_app_build domain_tests | 22.124567 | completed |
| ai_app_build runtime_smoke | 60.681345 | completed |
| ai_app_accept stage_execution (seq2) | 996.131008 | completed |
| ai_app_accept runtime_smoke | 643.382957 | completed |
| ai_app_accept stage_execution (seq3) | 108.480477 | completed |
| delivery stage_execution | incomplete host span at MAP write | controller-started; finished after MAP |
| delivery evidence `delivery-evidence-1` | 91.251348 | completed |
| formal `delivered` | null | controller complete only |

Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含验收运行与视觉读图窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/cellarcue/kf-20261015T185351Z-25a1f937
- commits: `eded2779dc48944bf1cc943f255e972d423701ed`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/eded2779dc48-a36f3c574978`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/` (MAP, build/domain/smoke logs, candidate)
- config audit: delivery `evidence/config-audit.stdout.txt` + receipt (gap; `ai_key_unavailable` via inspect-key)
- packaging readback: `stages/delivery/attempt-1/evidence/packaging-readback.txt`

## known_issues (non-blocking — CONTROLLER Option A; sealed in accept)

1. `CR-HOME-01` unscroll home vision fail — grid/Shoot/Import/coach below fold; runtime scroll + XCTest UL07 pass
2. Product `CellarCueUISmokeTests` Revoke row — Form scroll timing in XCTest (Settings+compliance otherwise reachable)
3. External harness UL04 kill+relaunch assertion flaky when photo seed fails — persistence covered by domain round-trip
4. WKWebView legal pages — navigation opens; WebView text not exposed to XCTest (bundle HTML verified in `.app`)
5. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof
6. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator)
7. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_id n/a blocker=false)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config (`ai_key_source: none`)
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`
- `code_query_blocked` (codebase-memory-mcp missing) — advisory only

## Blockers

(none)

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `cellarcue/` symlink; never report path-only `product/` as the operator product_dir.
- Flat builder branch `cellarcue` must be retired before nested `cellarcue/<run>` can exist on the same remote.
- Packaging-ready gate for this run = candidate zip + receipt + remote tip matching accept freeze `eded2779…`.
