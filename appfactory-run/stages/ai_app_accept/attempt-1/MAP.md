# MAP — ai_app_accept attempt-1

Status: blocked  
Verdict: blocked

pm_visual_manifest_sha256: ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc  
technical_contract_sha256: 1a685a427ccc34c95a8450a0cb87f3f75ae6086ee359b87652ea11fbf99d8aa0  
product_commit: 0ddb3670393a1fe8ba4797f1682c19aa67f9b235  
product_branch: main  
bundle_id: com.lingguang.docbrief  
candidate: 0ddb3670393a-f526913024b3 (candidate_unaccepted)  
simulator_udid: C83D64D9-AB8C-4908-B82B-53091BCC4F9A  
dispatch_id: 16cfd319-4009-4a57-a935-c10fac16de11  
code_query: code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp'  
production_child_model: auto  
screenshot_vision_model: auto

## Stamp

| check_id | result | evidence |
|---|---|---|
| UL-01 build_launch | pass | Candidate exe sha256 `3770d201c1d4e2c0986f13eceed5b16fe6c8585acfa7020a3f6ad8c90ab91ffb` matches publish; install/launch on leased UDID; XCUITest `testUL01_homeLaunch` passed (`evidence/uitest-all2.log`); launch shot `screenshots/ul01-launch.png` + vision pass `evidence/visual-readback/ul01-launch.receipt.json`; runtime home `screenshots/runtime-home-empty.png` |
| UL-02 core_flows | pass | XCUITest `testUL02_coreLocalFlows` passed: Start brief → Create → import/recognize/local field/Chat/Summary/TTS navigation without crash (`evidence/uitest-all2.log`) |
| UL-03 live_ai | pass | P1 local_only; `inspect-key` → `ai_key_unavailable` (`evidence/config-key.inspect.json`); runtime shows honest “AI unavailable: DeepSeek key not configured (local_only gap)” on recognition/summary/settings; no canned success. Local import/manual field/TTS UI exercised |
| UL-04 reviewed_persistence | pass | Manual Save field path exercised; `testUL04_relaunchPersistence` passed — brief “Accept Sample Brief” / “Visual Tour Brief” remains after relaunch (`evidence/uitest-all2.log`). CloudKit unconfigured = gap |
| UL-05 feedback_reuse | pass | No outbound key: second live-AI adaptation not applicable; honest unconfigured on Chat extract + local draft/Save|Not this path observed in UITest. Live feedback matrix deferred until key |
| UL-06 privacy_permissions | pass | Consent Allow path + Settings legal pages; `testUL06_privacyLegalAndRevoke` passed (≥3 legal opens). Local `privacy.html`/`terms.html`/`support.html` in candidate app. External URL UNKNOWN = gap |
| UL-07 ui_interaction | fail | Per-frame design reuse (8× `reused_design`) + fresh runtime Cursor vision. home-empty pass; capture-import uncertain; fields-review / brief-detail-filled / chat-extract / summary-card / tts-briefing / settings-privacy fail vs PM criteria. See UL-07 table |
| UL-08 repo_evidence | pass | Evidence bound to commit `0ddb3670393a1fe8ba4797f1682c19aa67f9b235`, clean product worktree, attempt paths under `stages/ai_app_accept/attempt-1/`, candidate receipt + upstream build `evidence/upstream-build.json`, index `evidence/accept-evidence.v1.json` |

## UL-07 frame compare

product_commit: `0ddb3670393a1fe8ba4797f1682c19aa67f9b235`  
design_manifest: `stages/pm_docs/attempt-1/visual_manifest.v1.json` sha256 `ce43e843fe336a5ad2098904dd7a7048610dfd94a8e0011242a20c00adbca1fc`

| frame_id | criterion | design image/hash | runtime image/hash | design read | runtime read | agent conclusion |
|---|---|---|---|---|---|---|
| home-empty | crit-home-empty | pm `frames/home-empty-r2.png` `7088b117…` | `screenshots/runtime-home-empty.png` `7747a0dd…` | reused_design lookup | `evidence/visual-readback/runtime-home-empty.receipt.json` pass | match |
| capture-import | crit-capture-import | `frames/capture-import-r2.png` `cf349bc5…` | `screenshots/runtime-capture-import.png` `76292616…` | reused_design | `…/runtime-capture-import.receipt.json` uncertain | DocBrief AI wordmark not visible on Import; structure/CTA ok |
| fields-review | crit-fields-review | `frames/fields-review-r2.png` `c03383ed…` | `screenshots/runtime-fields-review.png` `2cdad9ec…` | reused_design | `…/runtime-fields-review.receipt.json` fail | Review fields empty / no Save·Not this·sample receipt fields (AI unavailable path) |
| brief-detail-filled | crit-brief-detail-filled | `frames/brief-detail-filled-r2.png` `b0dba110…` | `screenshots/runtime-brief-detail-filled.png` `524fde0f…` | reused_design | `…/runtime-brief-detail-filled.receipt.json` fail | Active brief CTAs present; missing filled fields/actions content vs design |
| chat-extract | crit-chat-extract | `frames/chat-extract-r2.png` `16a452c3…` | `screenshots/runtime-chat-extract.png` `7d9002c3…` | reused_design | `…/runtime-chat-extract.receipt.json` fail | Chat extract chrome incomplete vs design thread/Send/Save matrix |
| summary-card | crit-summary-card | `frames/summary-card-r2.png` `ec77d70d…` | `screenshots/runtime-summary-card.png` `0d29b74d…` | reused_design | `…/runtime-summary-card.receipt.json` fail | Only Generate + AI unavailable; no Use/Discard preview card |
| tts-briefing | crit-tts-briefing | `frames/tts-briefing-r2.png` `bb96b124…` | `screenshots/runtime-tts-briefing.png` `56ec0522…` | reused_design | `…/runtime-tts-briefing.receipt.json` fail | Play/Next present; segment not document-actions content; DocBrief chrome weak |
| settings-privacy | crit-settings-privacy | `frames/settings-privacy-r2.png` `46fa6976…` | `screenshots/runtime-settings-privacy.png` `cd327dd9…` | reused_design | `…/runtime-settings-privacy.receipt.json` fail | Privacy/Terms/Support visible; literal “Revoke AI consent” control missing (Allow DeepSeek toggle instead) |

## Gaps

1. `ul07_visual_reproduction:<fields-review|brief-detail-filled|chat-extract|summary-card|tts-briefing>` — runtime screens do not satisfy PM filled-state criteria / DocBrief chrome consistency. suggested_node: ai_build  
2. `ul07_settings_revoke_label` — Settings lacks visible “Revoke AI consent” control required by crit-settings-privacy (Allow DeepSeek inference toggle present). suggested_node: ai_build  
3. `ul07_brand_chrome_secondary_screens` — DocBrief AI title/chrome weak or absent off home (capture-import uncertain). suggested_node: ai_build  
4. `ai_key_unavailable` — no Secrets.xcconfig / authorized key; outbound closed; honest UI. gap (not UL-03 fail)  
5. `legal_url_unknown` — external privacy/terms/support URLs UNKNOWN; local HTML loads. gap  
6. `cloudkit_unconfigured` — local AtomicCodableStore only. gap  
7. `feishu_row_not_yet_created` — audit `record_match_error=0` (`evidence/config-audit.receipt.json`). gap  
8. `operator_pricing_deferred_free_app_only` — inherited from PM/Builder. gap  
9. `code_query_blocked:codebase_memory_index_failed:…codebase-memory-mcp` — acceptance avoided product source reads; used PM/Builder maps + binary strings + runtime. gap/infra  
10. `register-new rewritten` — some runtime receipt register-new calls rejected as rewritten after re-vision; receipts on disk remain authoritative for MAP citations.

## Screenshots

- `screenshots/ul01-launch.png`  
- `screenshots/runtime-home-empty.png`  
- `screenshots/runtime-capture-import.png`  
- `screenshots/runtime-fields-review.png`  
- `screenshots/runtime-brief-detail-filled.png`  
- `screenshots/runtime-chat-extract.png`  
- `screenshots/runtime-summary-card.png`  
- `screenshots/runtime-tts-briefing.png`  
- `screenshots/runtime-settings-privacy.png`

## Instrumentation

- timing: stage_execution (pre-started) + visual_readback/runtime_smoke/visual_capture/evidence spans via `factory.ultra_lite_timing`  
- uitest harness (outside product): `uitest-harness/`  
- vision: `python3 -m cursor_package.vision` model auto  
- design reads: `factory.ultra_lite_visual_readback lookup --record-reuse` ×8  

## lessons_candidates

- Acceptance screenshot tour must assert on-screen markers before host `simctl io screenshot`; otherwise wrong-route PNGs poison UL-07.  
- Settings revoke should expose a literal “Revoke AI consent” control for criterion-aligned vision, not only an Allow toggle.
