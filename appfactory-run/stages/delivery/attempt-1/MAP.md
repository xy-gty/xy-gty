# HiveCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 6d69a225-0e3c-48e3-bbb5-bb98956f9309  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
delivery_mode: full_app  
milestone_chain: ai_native  
config_mode: local_only  

pm_visual_manifest_sha256: 4558114f089b150a156c6a189d7fdc42ee43c164ab00463cc94679548a66a7e7  
technical_contract_sha256: 5bda6a4efb122c94a7fcd682191fc44da554b26267bb7948618b47e67403a167  
product_commit: f28af04eed6677c6febdbcdd9f88d862d1ac1b8f  
product_dir: hivecue/  
product_branch: hivecue/kf-20261015T053908Z  
bundle_id: com.lingguang.hivecue  

## Product

HiveCue — AI hive-inspection coach: snap or import brood-frame photos → Keep/Discard brood / stores / pest findings → InspectionCoach with HexCombGrid + InspectionRail + HeatOverlay → Ask coach / annotated heat marks / hands-free TTS / dictate fields → Settings privacy. free_app_only this round (one-time unlock / apiary packs deferred; no coins/StoreKit/ATT).

## Repo / push readback

- Local: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/product` (`hivecue` → symlink)
- Remote: `git@github.com:xy-gty/xy-gty.git`
- Branch: `hivecue/kf-20261015T053908Z` (independent; not main)
- Commit: `f28af04eed6677c6febdbcdd9f88d862d1ac1b8f`
- ls-remote: `f28af04eed6677c6febdbcdd9f88d862d1ac1b8f	refs/heads/hivecue/kf-20261015T053908Z`
- URL: https://github.com/xy-gty/xy-gty/tree/hivecue/kf-20261015T053908Z
- Evidence: `evidence/git-push-readback.txt` (tip already on remote from build; no re-push)

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_accept/attempt-1/MAP.md` → Verdict ready
- Factory status: `package_acceptance=accepted`
- Build MAP: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_build/attempt-1/MAP.md` → ready
- PM MAP: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/pm_docs/attempt-1/MAP.md` → ready
- Candidate: `artifacts/candidates/f28af04eed66-625359af7ae7/` (builder `candidate_unaccepted` at source_commit `f28af04…`; accept bound same tip)
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/pm_docs/attempt-1/visual_manifest.v1.json`
- Package: n/a (ai_native; no PDA)
- Checklist: n/a (ai_native)

## Independent eight-domain (from accept MAP)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (honest `ai_key_unavailable` local_only) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second-call deferred by key gap) |
| UL-06 privacy_permissions | pass (local legal; remote URLs gap) |
| UL-07 ui_interaction | pass (Option A known_issues: PhotosPicker AX, home CTA crop, coach scroll, empty chat thread, annotated/hands-free/settings crop) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped HiveCue on independent branch `hivecue/kf-20261015T053908Z` → xy-gty/xy-gty @ `f28af04eed6677c6febdbcdd9f88d862d1ac1b8f`. Did not overwrite `main`.
- Independent Acceptance Verdict ready on iPhone 17 Pro: UL-01..UL-08 pass (Option A soft known_issues); domain tests 9/9; BUILD SUCCEEDED reused.
- Core coach chain: New inspection → Capture (Camera/Photo library) → Keep findings → InspectionCoach hex/rail → Ask coach (local tip) → Heat overlay Keep marks → Hands-free / Dictate → Settings legal.
- Live DeepSeek outbound closed without key; honest local tip + consent disclosure strings.
- Feishu delivery tracker skipped per operator CONTROLLER_DELIVERY.
- Formal `delivered` milestone is controller complete/status readback — not declared here.

## replace_before_submission

| item | literal |
| --- | --- |
| AI key | `ai_key_unavailable` (no Secrets.xcconfig / authorized config; ai_key_source: none) |
| Legal remote URLs | `legal_url_unknown` (local Privacy/Terms/Support/Provider pages load) |
| CloudKit | `cloudkit_unconfigured` |
| Feishu App row | `feishu_row_not_yet_created` (operator skip; `record_match_error=0`; audit persisted) |
| Pricing | `operator_pricing_deferred_free_app_only` |
| Branding | `branding_assets_deferred` (no AppIcon/LaunchScreen this round) |
| Device | camera / long-mic / speech quality → 真机待测 |

## Stage cost

Copied from dispatch `stage_cost_json` (controller ledger; usage unknown → n/a). Do not invent tokens or claim savings across unequal cold/warm waits.

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 2388.0 | n/a |
| ai_app_build | validated | 1 | 1488.0 | n/a |
| ai_app_accept | validated | 1 | 3681.0 | n/a |
| delivery | active→produced | 1 | null until timing finish | n/a |
| **total** | | | **7557.0** (pre-delivery ledger) | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed timing (report; incomplete stage_execution spans retained as-is):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution (seq 2) | ~203.9 | completed (earlier incomplete host span retained) |
| ai_app_build stage_execution | ~1458.6 | completed |
| ai_app_accept stage_execution | ~3603.3 | completed |
| accept-runtime-1 / accept-vision-1 | ~2488.2 / ~722.7 | completed |
| delivery evidence `delivery-evidence-1` | (finish after MAP) | this attempt |
| delivery stage_execution | incomplete host span | controller-started; not guessed |
| formal `delivered` | null | controller complete only |

## Links

- report_html: n/a (UltraLite light delivery; no large HTML)
- repo_url: https://github.com/xy-gty/xy-gty/tree/hivecue/kf-20261015T053908Z
- commits: `f28af04eed6677c6febdbcdd9f88d862d1ac1b8f`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- accept_map: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_accept/attempt-1/MAP.md`
- build_map: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_build/attempt-1/MAP.md`
- candidate: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/artifacts/candidates/f28af04eed66-625359af7ae7/`
- config: `stages/ai_app_accept/attempt-1/evidence/config-audit.receipt.json`, `config-audit.stdout.txt`
- visual manifest: `stages/pm_docs/attempt-1/visual_manifest.v1.json`
- git readback: `evidence/git-push-readback.txt`

## Gaps

- `ai_key_unavailable`
- `legal_url_unknown`
- `cloudkit_unconfigured`
- `feishu_row_not_yet_created` (operator CONTROLLER_DELIVERY skip)
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`
- `ul07_photos_picker_ax_ios26` (known_issue)
- `ul07_home_cta_crop` (known_issue)
- `ul07_coach_scroll_crop` (known_issue)
- `ul07_coach_chat_empty_thread` (known_issue)
- `ul07_annotated_mark_fidelity` / `ul07_handsfree_play_crop` / `ul07_settings_scroll` (known_issues)
- camera / long-mic / speech quality → 真机待测

## Blockers

none

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.
