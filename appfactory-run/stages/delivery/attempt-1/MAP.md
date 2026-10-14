# Delivery — ScoutCue

- Status: ready
- report_status: produced
- package_acceptance: accepted
- Stage: delivery
- Attempt: 1
- dispatch_id: 1ded359b-0127-4435-8523-4c77dfbac94e
- ai_profile: ultra_lite
- ultra_lite_execution_revision: p1
- production_runtime: cursor
- requested_model: auto
- observed_model: inherit/auto (Cursor Task)
- config_mode: local_only
- delivery_mode: full_app
- milestone_chain: ai_native

pm_visual_manifest_sha256: 8109b7525dc308cf4d9d0e4ef418350f42862f696df35c33940283b7b8794d4e
technical_contract_sha256: d3e76b0d232df6307e64e68865cfecf4d83f0a5cc8687d954fdb93efbcd2d801

- Product: ScoutCue — free AI photo-scout / timing planner (scenery import → scout cards → sky-arc coach chat → golden-hour soft pins → TTS next-stop briefings → dictate notes); free_app_only (no StoreKit/paywall/ATT this round)
- Repo: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/scoutcue` (`product` → symlink; never rewrite to product/)
- Repo URL: `https://github.com/xy-gty/xy-gty` (`git@github.com:xy-gty/xy-gty.git`)
- Delivery branch: `scoutcue-ai-kf-20261014T091741Z-3d7b568c` @ `993a2aa5f6b899d26b7bb26d724c88d980adf4cd` (accepted product + `appfactory-run` context)
- Accepted product commit: `8d33ae437c6acc26021c90036c5f816a6f3d3033`
- Bundle ID: `com.lingguang.scoutcue`
- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/stages/ai_app_accept/attempt-1/MAP.md` → ready
- Package: n/a (ai_native; no PDA)
- Checklist: n/a (ai_native)
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/stages/pm_docs/attempt-1/visual_manifest.v1.json`
- Candidate: `artifacts/candidates/8d33ae437c6a-c57d1802c565` (builder `candidate_unaccepted`; factory `package_acceptance=accepted` after accept)

## Operator summary

- Shipped ScoutCue UltraLite P1 to `xy-gty/xy-gty` independent branch `scoutcue-ai-kf-20261014T091741Z-3d7b568c`; tip `993a2aa5f6b899d26b7bb26d724c88d980adf4cd`; accepted product SHA `8d33ae437c6acc26021c90036c5f816a6f3d3033`. Did **not** force-push `main` (remote main remains `0c9a469…`).
- Independent Acceptance Verdict ready: UL-01..UL-08 pass/pass(known_issues) on iPhone 17 Pro; domain tests 8/8; local legal pages load.
- Live DeepSeek outbound deferred: `ai_key_unavailable` (honest local_only UI); local coach timing / Keep/Discard paths exercised.
- Non-blocking known_issues from accept: scout-card / coach-chat / golden-overlay vision fails; dictate Errno17; Settings soft UITest; branding assets deferred.
- Feishu delivery tracker skipped per operator/CONTROLLER_DELIVERY (`feishu_row_not_yet_created`).
- Formal `delivered` milestone is for controller complete/status readback — not declared here.

## Accept stamp (consumed)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass (soft; Settings known_issue) |
| UL-03 live_ai | pass (local_only / key gap honest) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second-call deferred by key gap) |
| UL-06 privacy_permissions | pass (local pages; remote URLs gap) |
| UL-07 ui_interaction | pass (known_issues: scout-card, coach-chat, golden-overlay; dictate Errno17) |
| UL-08 repo_evidence | pass |

## Build / runtime evidence

- Build MAP: `../ai_app_build/attempt-1/MAP.md` (xcodebuild OK, domain 8/8, smoke launch)
- Accept evidence: `../ai_app_accept/attempt-1/evidence/` (UITest, screenshots, AX, visual_readback)
- Config audit: `../ai_app_accept/attempt-1/evidence/config/config-audit.stdout.txt` + `config-audit.receipt.json` (`feishu_row_not_yet_created`, non-blocker)
- Inspect key: `../ai_app_accept/attempt-1/evidence/config/inspect-key.json` → `ai_key_unavailable`
- Candidate receipt: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/artifacts/candidates/8d33ae437c6a-c57d1802c565/receipt.json`
- Push evidence: `evidence/github-push.txt` (new branch; main untouched)
- Publish context: `evidence/publish-run-context.txt` (`--no-push` then independent-branch push)

## Stage cost

Controller ledger (`stage_cost_json`); usage tokens n/a.

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 2078.0 | n/a |
| ai_app_build | validated | 1 | 945.0 | n/a |
| ai_app_accept | validated | 1 | 4516.0 | n/a |
| delivery | active→produced | 1 | null until timing finish | n/a |
| **total** | | | **7539.0** (pre-delivery ledger) | n/a |

Observed timing (monotonic; not summed as operator “savings”):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution | (ledger 2078.0) | completed |
| ai_app_build stage_execution | 892.951 | completed |
| ai_app_accept | ledger 4516.0; e3 stage_execution 107.591 | completed (earlier e1/e2 spans may remain incomplete in ledger) |
| delivery evidence `delivery_report` | 272.033 | completed |
| delivery stage_execution | (finish after MAP) | controller-started |

Equivalent scope / cold-warm / external waits differ across stages; do not treat ledger sum as a speed claim. Formal delivered timing remains controller complete readback.

## Links

- report_html: n/a (UltraLite light delivery; no large HTML)
- repo_url: https://github.com/xy-gty/xy-gty
- branch: scoutcue-ai-kf-20261014T091741Z-3d7b568c
- commits: accepted `8d33ae437c6acc26021c90036c5f816a6f3d3033`; delivery context `993a2aa5f6b899d26b7bb26d724c88d980adf4cd`
- feishu_record: n/a (operator skip tracker)

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` — Feishu tracker skipped / `record_match_error=0` (audit stdout saved)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN; local pages load
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config; outbound AI off
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only` — paid packs intent not in this UltraLite build
- `branding_assets_deferred` — no AppIcon/LaunchScreen this round (operator)
- camera / mic / speech quality → 真机待测 (Simulator entries present)
- `gh_not_logged_in` — `ensure-product-github` GaleInfra create path unused; operator remote `xy-gty` used instead (fail-soft)
- large file warning on push: accept DerivedData xcresult blob >50MB in `appfactory-run` context (GitHub warning only; branch created)

## known_issues (from accept; non-blocking)

1. `ul07_scout_card_vision_fail`
2. `ul07_coach_chat_vision_fail`
3. `ul07_golden_overlay_vision_fail`
4. `dictate_errno17`
5. `ul02_settings_soft_uitest`
6. `ai_key_unavailable`
7. `branding_assets_deferred`

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.
