# ScoutCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: d695be94-2db4-45bf-8680-2e6f3d788d87  
execution_seq: 3  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: 8109b7525dc308cf4d9d0e4ef418350f42862f696df35c33940283b7b8794d4e  
technical_contract_sha256: d3e76b0d232df6307e64e68865cfecf4d83f0a5cc8687d954fdb93efbcd2d801  
product_commit: 8d33ae437c6acc26021c90036c5f816a6f3d3033  
product_dir: scoutcue/  
product_branch: main  
bundle_id: com.lingguang.scoutcue  
simulator: iPhone 17 Pro only (never Pro Max 6C8C645A)  
candidate: artifacts/candidates/8d33ae437c6a-c57d1802c565 (candidate_unaccepted)  

CONTROLLER_FINISH / Option A HARD STOP (e3): UL-07 scout-card/coach-chat/golden-overlay vision fails + dictate Errno17 + UL-02 Settings soft + ai_key_unavailable → non-blocking known_issues only. Existing evidence + visual_readback_index reused as-is. No screenshot-vision. No frame regeneration. No further UITests.

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Upstream build MAP + runtime install/launch evidence under `evidence/runtime/`; smoke/home shots present |
| UL-02 core_flows | pass (soft) | Journey + UITest logs (`uitest-ul02.log`, `uitest-settings.log`, `uitest-legal*.log`); Settings soft gaps → known_issues |
| UL-03 live_ai | pass | `evidence/config/inspect-key.json` → `ai_key_unavailable` (expected local_only); honest unconfigured UI |
| UL-04 reviewed_persistence | pass | Runtime relaunch/home-persisted AX + Keep/Discard flows in `evidence/runtime/`; domain tests upstream 8/8 |
| UL-05 feedback_reuse | pass | Domain second-call encoding upstream; live outbound deferred by `ai_key_unavailable` |
| UL-06 privacy_permissions | pass | Settings/privacy runtime shot + AX; local Legal pages; Revoke consent path exercised |
| UL-07 ui_interaction | pass (known_issues) | Runtime vision receipts under `evidence/visual-readback/runtime/`; pass: home-empty, capture-import, dictate-note, tts-briefing, settings-privacy. Fail (non-core): scout-card, scout-card-review, coach-chat, golden-overlay → known_issues. No frame regen per Option A. |
| UL-08 repo_evidence | pass | Evidence bound to product commit `8d33ae437c6a…`, attempt-1 paths, candidate `8d33ae437c6a-c57d1802c565`. Product dir remains `scoutcue/`. No AppIcon/LaunchScreen generation. |

## UL-07 runtime vision (existing receipts only)

| frame_id | conclusion | receipt |
| --- | --- | --- |
| home-empty | pass | `evidence/visual-readback/runtime/home-empty.receipt.json` |
| capture-import | pass | `…/capture-import.receipt.json` |
| scout-card | **fail** → known_issue | `…/scout-card.receipt.json` (+ review fail) |
| coach-chat | **fail** → known_issue | `…/coach-chat.receipt.json` |
| golden-overlay | **fail** → known_issue | `…/golden-overlay.receipt.json` |
| tts-briefing | pass | `…/tts-briefing.receipt.json` |
| dictate-note | pass (path Errno17 → known_issue) | `…/dictate-note.receipt.json` |
| settings-privacy | pass | `…/settings-privacy.receipt.json` |

Index: `visual_readback_index.v1.json` (entries present).

## known_issues (non-blocking — CONTROLLER Option A)

1. `ul07_scout_card_vision_fail` — runtime scout-card / scout-card-review vision fail×; do not regen frames.
2. `ul07_coach_chat_vision_fail` — coach-chat vision fail; non-core.
3. `ul07_golden_overlay_vision_fail` — golden-overlay vision fail; non-core.
4. `dictate_errno17` — dictate path collision / Errno17 during accept; non-core.
5. `ul02_settings_soft_uitest` — Settings missing / soft UITest fails; non-core.
6. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek outbound.
7. `branding_assets_deferred` — no AppIcon/LaunchScreen this round (operator).

## Gaps (delivery / submit-before)

- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local pages load)
- `cloudkit_unconfigured`
- `feishu_row_not_yet_created` (operator skip tracker)
- `operator_pricing_deferred_free_app_only`
- camera / mic / speech quality → 真机待测

## Blockers

(none)

## Evidence index

- `evidence/runtime/` (UITest logs, screenshots, AX)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `evidence/config/inspect-key.json`, `evidence/config/config-audit.receipt.json`
- `CONTROLLER_OPTION_A.md` (strengthened)
- `../ai_app_build/attempt-1/MAP.md` / candidate `8d33ae437c6a-c57d1802c565`
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## Hand-off

Delivery may consume this ready accept MAP + product commit `8d33ae437c6acc26021c90036c5f816a6f3d3033` under real dir `scoutcue/` (`product` → symlink). Push independent branch to `git@github.com:xy-gty/xy-gty.git` (not force main). Feishu skip.
