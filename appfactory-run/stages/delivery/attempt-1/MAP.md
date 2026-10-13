# Delivery — SnagCue AI

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: dfbde5bc-c691-48bb-abc6-18d78a0a0c94  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: b12f70e36ee65f6d9063bdca1c80d51b61f439e1ad6a48adbc4fdb650b54d276  
technical_contract_sha256: 052b1d96aa1fb18617a0a9849ed76d0946274ef92903114658176f9701fd74f2  
product_commit_accepted: 47f1c118b9e5e460b0231de413df86d5ef6d8ae7  
product_commit_head: 1160320e734fb4c9bd8b17032720e33a3649f2a0  
candidate_name: 47f1c118b9e5-146049ffc8bc  
development_bundle_id: com.lingguang.snagcue  

Product: SnagCue AI — walkthrough photos → reviewed punch list with AI field fill, annotated report images, and hands-free TTS checklist readouts (no building-code certification claims).  
Repo: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/product`  
Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/stages/ai_app_accept/attempt-3/MAP.md` → ready  
Package: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/stages/ai_app_build/attempt-3/MAP.md` → ready  
Checklist: n/a (ai_native UltraLite eight-domain accept)  
Visual: pm_docs visual_manifest + accept UL-07 matrix (same manifest sha)

## Operator summary

- Shipped local Simulator App **SnagCue AI** (`com.lingguang.snagcue`), independently accepted UL-01..08 on candidate `47f1c118b9e5-146049ffc8bc`.
- Core hub CTAs: Capture / Snag review / Chat fill / Annotated report / TTS coach; four privacy plist keys + camera/library/mic/speech entries present.
- Accepted product commit `47f1c118…`; delivery also published run context commit `1160320…` (appfactory-run sync).
- GitHub: pushed to `git@github.com:xy-gty/xy-gty.git` branch `snagcue-kf-20261013T095600Z-1e00eb7a` (main non-ff; GaleInfra create blocked by missing `gh` auth).
- P1 local_only: AI key / legal external URLs / CloudKit / Feishu row remain replace-before-submission gaps; Feishu writeback deferred by controller.
- Residual: camera capture / mic record / speech recognition → 真机待测; operator paid unlock deferred (`operator_pricing_deferred_free_app_only`).
- Formal `delivered` milestone is controller complete/readback only — not declared here.

## Eight-domain stamp (from accept)

| check_id | result |
|----------|--------|
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (honest `ai_key_unavailable`) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass |
| UL-06 privacy_permissions | pass (local legal pages) |
| UL-07 ui_interaction | pass (8/8) |
| UL-08 repo_evidence | pass |

## Build / run evidence

- Build: ai_app_build attempt-3 BUILD SUCCEEDED (`evidence/candidate/build.json`)
- Domain tests: TEST SUCCEEDED (`SnagCueDomainTests`)
- Smoke: install/launch on UDID `5E3A8993-F815-4738-8EED-EF032F75704F`
- Candidate receipt: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/artifacts/candidates/47f1c118b9e5-146049ffc8bc/receipt.json` (sha256 `fc68f1f82ba9b32a940fd7d7d947eebf94fd07d82d9a14b184e9f074c8fc5c6b`)
- Accept runtime/screenshots/vision: `stages/ai_app_accept/attempt-3/evidence/`

## Stage cost

Copied from controller `stage_cost_json` (usage unknown → n/a):

| stage | status | attempts | duration_seconds | tokens in/out/cache |
|-------|--------|----------|------------------|---------------------|
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 1844.0 | n/a |
| ai_app_build | validated | 3 | 3436.0 | n/a |
| ai_app_accept | validated | 3 | 5095.0 | n/a |
| delivery | active | 1 | null | n/a |
| **total** | | | **10375.0** | n/a |

Rounds display (factory status): 验收轮次 1 / 上限 2；修复轮次 0.

## Links

- report_html: n/a (UltraLite light wrap-up; large HTML not required)
- repo_url: `https://github.com/xy-gty/xy-gty/tree/snagcue-kf-20261013T095600Z-1e00eb7a`
- repo_ssh: `git@github.com:xy-gty/xy-gty.git`
- branch: `snagcue-kf-20261013T095600Z-1e00eb7a` @ `1160320e734fb4c9bd8b17032720e33a3649f2a0`
- accepted_commit: `47f1c118b9e5e460b0231de413df86d5ef6d8ae7`
- local_product: `/Users/a2026/work/factory-prod-1/runs/kf-20261013T095600Z-1e00eb7a/product`
- feishu_record: n/a (deferred)
- candidate: `47f1c118b9e5-146049ffc8bc`

## Gaps

### replace_before_submission (P1)

- `feishu_row_not_yet_created` — accept `evidence/config-audit.stdout.txt` literal `record_match_error=0`; also copied to delivery `evidence/config-audit.*`
- `legal_url_unknown` — privacy_url / terms_url / support_url UNKNOWN (local legal pages accepted)
- `ai_key_unavailable` — `inspect-key` present=false; source null (do not write secrets)
- `cloudkit_unconfigured`

### other (fail-soft / residual)

- `gh_repo_create_failed:GaleInfra/appfactory-claude-kf-20261013T095600Z-1e00eb7a` — `gh auth login` / GH_TOKEN missing
- `product_github_main_non_fast_forward` — preferred `xy-gty/xy-gty` main rejected; delivered on run branch instead
- `feishu_writeback_deferred_by_controller` — tracking upsert / delivery-card send deferred
- `operator_pricing_deferred_free_app_only`
- advisory: camera / mic / speech recognition → 真机待测

## Evidence index

- evidence/config-audit.stdout.txt (sha256 `1009ed624474b6f89f9cefd916654edd9a0701671cb8f3071fbd2a429ec4847c`)
- evidence/config-audit.receipt.json
- evidence/product-remote-heads.txt
- upstream accept MAP + build MAP + pm_docs MAP (paths above)
