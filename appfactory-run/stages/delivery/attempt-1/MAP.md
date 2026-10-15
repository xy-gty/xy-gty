# YarnCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 18b7b80e-bbda-4de4-bb0f-ae225c8319ca  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
delivery_mode: full_app  
milestone_chain: ai_native  
config_mode: local_only  

pm_visual_manifest_sha256: 12cf6f34ae151bb7f403ab95cc7f3099bfae39f8e457adcc8afddc38399b4ab5  
technical_contract_sha256: f053d2ed94177b694d55ab0f4804c9d10fab8634d08141f95a8469f50fd6fa0f  
product_commit: 4770b6a8073711e044ddfce4575e49c535768ce1  
product_dir: yarncue/  
product_branch: yarncue/kf-20261014T130415Z  
bundle_id: com.lingguang.yarncue  

## Product

YarnCue — free AI knitting/crochet (weave) coach: snap or import yarn & WIP photos → stitch/row review → next-row step band + coach chat → annotated WIP → hands-free TTS; local_only until DeepSeek key is configured.

## Repo / push readback

- Local: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/product`
- Remote: `git@github.com:xy-gty/xy-gty.git`
- Branch: `yarncue/kf-20261014T130415Z` (independent; not main)
- Commit: `4770b6a8073711e044ddfce4575e49c535768ce1`
- ls-remote: `4770b6a8073711e044ddfce4575e49c535768ce1	refs/heads/yarncue/kf-20261014T130415Z`
- URL: https://github.com/xy-gty/xy-gty/tree/yarncue/kf-20261014T130415Z

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/stages/ai_app_accept/attempt-1/MAP.md` → Verdict ready
- Factory status: `package_acceptance=accepted`
- Build MAP: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/stages/ai_app_build/attempt-1/MAP.md` → ready
- PM MAP: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/stages/pm_docs/attempt-1/MAP.md`
- Candidate: `artifacts/candidates/4770b6a80737-bc768aee891c` (`candidate_unaccepted` local Simulator App; receipt binds commit `4770b6a8073711e044ddfce4575e49c535768ce1`)

## Independent eight-domain (from accept MAP)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (honest `ai_key_unavailable` local_only) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second outbound deferred by key gap) |
| UL-06 privacy_permissions | pass (local legal; remote URLs gap) |
| UL-07 ui_interaction | pass (known_issues: coach-chat, annotated-wip) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped YarnCue on independent branch `yarncue/kf-20261014T130415Z` → xy-gty/xy-gty @ `4770b6a`.
- Core coach chain exercised on leased iPhone 17 Pro: New project → capture/import → Stitch Keep → Ask coach → Turn Keep → Annotate / Hands-free / Dictate → Settings legal.
- Build SUCCEEDED; domain tests 8/8; accept ready after one acceptance round (repair rounds 0).
- Live DeepSeek outbound closed without key; local weave tip path used; UI shows truthful unconfigured banner.
- Non-blocking known_issues: coach-chat Keep/Discard on Turn review vs design chat frame; annotated WIP pins after tap; branding assets deferred; Coach tab stack split.
- Feishu delivery tracker skipped per operator CONTROLLER_DELIVERY.
- Formal `delivered` milestone is controller complete/readback — not declared here.

## replace_before_submission

| item | literal |
| --- | --- |
| AI key | `ai_key_unavailable` (no Secrets.xcconfig / authorized config; ai_key_source: none) |
| Legal remote URLs | `legal_url_unknown` (local Privacy/Terms/Support/Provider pages load) |
| CloudKit | `cloudkit_unconfigured` |
| Feishu App row | `feishu_row_not_yet_created` (operator skip; audit persisted) |
| Pricing | `operator_pricing_deferred_free_app_only` |
| Device | camera / long-mic / speech quality → 真机待测 |

## Stage cost

Copied from dispatch `stage_cost_json` (controller ledger; usage unknown → n/a).

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 48009.0 | n/a |
| ai_app_build | validated | 1 | 778.0 | n/a |
| ai_app_accept | validated | 1 | 2346.0 | n/a |
| delivery | active | 1 | null | n/a |
| **total** | | | **51133.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

## Links

- report_html: n/a (optional UltraLite HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/yarncue/kf-20261014T130415Z
- commits: `4770b6a8073711e044ddfce4575e49c535768ce1`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- accept_map: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/stages/ai_app_accept/attempt-1/MAP.md`
- build_map: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/stages/ai_app_build/attempt-1/MAP.md`
- candidate: `/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/artifacts/candidates/4770b6a80737-bc768aee891c/`
- config: `stages/ai_app_accept/attempt-1/evidence/config/inspect-key.json`, `evidence/config-audit.receipt.json`, `evidence/config-audit.stdout.txt`
- visual index: `stages/ai_app_accept/attempt-1/visual_readback_index.v1.json`
- visual manifest: `stages/pm_docs/attempt-1/visual_manifest.v1.json`

## Gaps

- `ai_key_unavailable`
- `legal_url_unknown`
- `cloudkit_unconfigured`
- `feishu_row_not_yet_created` (operator CONTROLLER_DELIVERY skip)
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred` (no AppIcon/LaunchScreen this round)
- `ul07_coach_chat_keep_discard_on_turn_review` (known_issue)
- `ul07_annotated_wip_pins_after_tap` (known_issue)
- camera / long-mic / speech quality → 真机待测

## Blockers

(none)
