# Delivery

- Status: ready
- report_status: produced
- package_acceptance: accepted
- Product: DocBrief AI — AI document / whiteboard / receipt briefing coach (import → recognize fields → chat extract → summary card → TTS); free_app_only this delivery
- Repo: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/product` · `git@github.com:xy-gty/xy-gty.git` branch `docbrief-ai-kf-20261013T095745Z-aa3ad9a0`
- Verification: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/ai_app_accept/attempt-2/MAP.md` → ready
- Package: n/a (ai_native UltraLite; independent accept)
- Checklist: n/a (ai_native eight-domain UL stamps in accept MAP)
- Visual: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/pm_docs/attempt-1/visual_manifest.v1.json`

pm_visual_manifest_sha256: ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc  
technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0  
product_commit: 09c4c0c3ca4b546b94253a7cd3d89f119e0b272b  
product_branch: main  
bundle_id: com.lingguang.docbrief  
candidate: 09c4c0c3ca4b-7ce60dbd04e8  
candidate_receipt: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/artifacts/candidates/09c4c0c3ca4b-7ce60dbd04e8/receipt.json`  
dispatch_id: 82987770-6eed-49d7-9869-00351af2f17a  
config_mode: local_only  
operator_report: `/Users/a2026/work/factory-prod-2/work/docbrief-delivery-report.md`

## Operator summary

- Shipped local Simulator App DocBrief AI at accepted commit `09c4c0c3ca4b546b94253a7cd3d89f119e0b272b`; independent accept attempt-2 Verdict ready; factory package_acceptance=accepted.
- Core sell path exercised: Start brief → Create → import/recognize/fields/Chat/Summary/TTS; four Info.plist permissions with measurable entry points (Take photo / Add photos / Voice supplement).
- Live outbound AI honestly unavailable (`ai_key_unavailable`); local import/manual Save/persistence and legal HTML pages load.
- Product HEAD pushed to `git@github.com:xy-gty/xy-gty.git` branch `docbrief-ai-kf-20261013T095745Z-aa3ad9a0` (same SHA). Remote `main` already held unrelated tip `ad72edd…`; non-ff rejected; no force-push.
- Feishu delivery card deferred by operator (`feishu_deferred_operator`); not a delivery block.
- Soft UL-07 filled-state / wrong-screen and Simulator camera/dictation limits are known_issues only.
- Replace before App Store submission: AI key, legal external URLs, CloudKit, Feishu row, paid unlock (deferred free_app_only).

## Independent eight-domain (from accept attempt-2)

| check_id | result |
|---|---|
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (honest unconfigured; local_only) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live adaptation N/A without key) |
| UL-06 privacy_permissions | pass (local legal + revoke measured) |
| UL-07 ui_interaction | pass (soft known_issues listed upstream) |
| UL-08 repo_evidence | pass |

## Stage cost

Copied from controller `stage_cost_json` (usage unknown → n/a):

| stage | status | attempts | duration_seconds | tokens |
|---|---|---|---|---|
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 2699.0 | n/a |
| ai_app_build | validated | 2 | 2472.0 | n/a |
| ai_app_accept | validated | 2 | 6067.0 | n/a |
| delivery | active→finish | 1 | null (in progress at MAP write) | n/a |
| **total** | | | **11238.0** | n/a |

Rounds: 验收轮次 2 / 上限 2；修复轮次 1.

## Links

- report_html: n/a (not generated; see operator_report markdown)
- repo_url: https://github.com/xy-gty/xy-gty/tree/docbrief-ai-kf-20261013T095745Z-aa3ad9a0
- commits: 09c4c0c3ca4b546b94253a7cd3d89f119e0b272b
- feishu_record: n/a (`feishu_deferred_operator`)
- push_evidence: `evidence/product-push.txt`
- accept_map: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/ai_app_accept/attempt-2/MAP.md`
- build_map: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/ai_app_build/attempt-2/MAP.md`
- pm_map: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/pm_docs/attempt-1/MAP.md`
- config_audit: `/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/ai_app_accept/attempt-2/evidence/config-audit.receipt.json`

## Gaps

### replace_before_submission

1. `ai_key_unavailable` — no Secrets.xcconfig / authorized key; outbound closed
2. `legal_url_unknown` — external privacy/terms/support URLs UNKNOWN; local HTML loads
3. `cloudkit_unconfigured` — local AtomicCodableStore only
4. `feishu_row_not_yet_created` — audit `record_match_error=0`
5. `feishu_deferred_operator` — operator deferred Feishu delivery card / Bitable writeback
6. `operator_pricing_deferred_free_app_only` — paid unlock not in this UltraLite delivery

### other (non-blocking)

7. `main_non_ff_rejected` — xy-gty `main` tip `ad72eddb1b46077b63645d0ad9b5241f35179bcc`; delivered on run branch instead (same pattern as `snagcue-kf-…`)
8. `camera_simulator` / `dictation_simulator` — known_issue
9. Soft UL-07 filled-state / wrong-screen — known_issues per accept (not block)
10. `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — inherit accept infra gap; Delivery did not need product source reads

## Residual risk

- Submission blocked until replace_before_submission items closed (key, legal URLs, CloudKit, Feishu, pricing).
- Formal `delivered` milestone is controller complete/status readback — not declared here.
