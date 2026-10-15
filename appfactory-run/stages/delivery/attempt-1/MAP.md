# StopCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 418ccc4f-465a-4065-b5ee-d0d2a7173d74  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
config_mode: local_only  
delivery_mode: full_app  

pm_visual_manifest_sha256: a7635daf9f37726329ff1b54e5ea627d634a7f16e8550568c23b0df1b1593d9a  
technical_contract_sha256: 6aa7ee6083e7746fa2f67056aa5b47073685641d760c2172930253bdab5e5dd7  
product_commit: 8ff7e72ef3525166bbb448c398b3be0b23430dee  
product_dir: stopcue/ (`stopcue` → `product` symlink)  
product_branch: stopcue/kf-20261015T093242Z-0f4256a0  
bundle_id: com.lingguang.stopcue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/stopcue/kf-20261015T093242Z-0f4256a0  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/8ff7e72ef352-83d81be924fa (candidate_unaccepted → accepted via independent accept)  
palette: #16A34A / #F0FDF4 / #DB2777  
unique_ui: film-sprocket timeline + onion-skin overlay  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

StopCue — AI 定格动画教练：逐帧拍/导入 → 对话分镜与间隔 → 洋葱皮标注叠图 → TTS 倒计时口令；胶片齿孔时间轴 + 洋葱皮叠层预览。

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/pm_docs/attempt-1/MAP.md`  

## UL eight-domain stamp (from accept; not re-judged)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (P1 local_only honest `ai_key_unavailable`) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second outbound deferred by key gap) |
| UL-06 privacy_permissions | pass |
| UL-07 ui_interaction | pass (Option A known_issues on non-core vision) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped StopCue on independent branch `stopcue/kf-20261015T093242Z-0f4256a0` → `xy-gty/xy-gty` at `8ff7e72…`
- product_dir remains `stopcue/` (symlink → `product`); bundle `com.lingguang.stopcue`
- Build + domain 9/9 + Simulator smoke on iPhone 17 Pro `B14CC0EA…` only
- Core runtime journeys UL-01/UL-02 passed; film-sprocket + onion-skin proven via AX
- Four permission entry points present (Camera / Photos / Mic / Speech); hardware quality 真机待测
- free_app_only; no AppIcon/LaunchScreen this round
- Feishu delivery writeback skipped per CONTROLLER_DELIVERY
- Option A soft known_issues retained for non-core UL-07 vision routing / frame-review not exercised / legal WebView harness flakiness
- Formal `delivered` milestone is controller complete/status readback only — not claimed here

## Stage cost

Copy of controller `stage_cost` (usage unknown → n/a):

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| pm_docs | validated | 1 | 2185.0 | n/a |
| ai_app_build | validated | 1 | 925.0 | n/a |
| ai_app_accept | validated | 1 | 1785.0 | n/a |
| delivery | active→finish | 1 | null at report time | n/a |
| **total (validated stages)** | | | **4895.0** | n/a |

Observed UltraLite timing (leaf work, not summed as SLA claim): implementation ~420s; integration_build ~114s; domain_tests ~90s; builder smoke ~71s; accept runtime ~976s; accept visual_readback ~872s. `delivered` milestone: null until controller complete. Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含外部读图与验收运行窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/stopcue/kf-20261015T093242Z-0f4256a0
- commits: `8ff7e72ef3525166bbb448c398b3be0b23430dee`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/8ff7e72ef352-83d81be924fa`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/evidence/` (build.log, domain.log, git-push.log, smoke)
- config audit: accept `evidence/config/config-audit.stdout.txt` + `inspect-key.json`

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_stop_coach_vision_fail` — vision fail; AX proves film-sprocket + onion
2. `ul07_coach_chat_screenshot_routing`
3. `ul07_onion_overlay_screenshot_routing`
4. `ul07_tts_countdown_screenshot_routing`
5. `ul07_settings_vision_partial` / `legal_webview_uitest_flaky`
6. `ul07_frame_review_not_exercised`
7. `ai_key_unavailable` — expected P1 local_only
8. `code_query_blocked:codebase_memory_mcp_missing` — infrastructure
9. `branding_assets_deferred` — no AppIcon/LaunchScreen
10. `camera_mic_speech_device_quality` — Simulator entries only

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_match_error=0)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`
- disk: host volume ~93% used / ~15Gi free at delivery report time (no in-use DerivedData cleared)

## Blockers

(none)

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `stopcue/` symlink; never report path-only `product/` as the operator product_dir.
