# YarnCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 8e82ada9-2b14-4316-965e-b5196124d9eb  
execution_seq: 1  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance); vision observed_model Auto  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: 12cf6f34ae151bb7f403ab95cc7f3099bfae39f8e457adcc8afddc38399b4ab5  
technical_contract_sha256: f053d2ed94177b694d55ab0f4804c9d10fab8634d08141f95a8469f50fd6fa0f  
product_commit: 4770b6a8073711e044ddfce4575e49c535768ce1  
product_dir: yarncue/  
product_branch: yarncue/kf-20261014T130415Z  
bundle_id: com.lingguang.yarncue  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive lease; never Pro Max)  
candidate: artifacts/candidates/4770b6a80737-bc768aee891c (candidate_unaccepted)  

code_query: code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp' (journeys from PM/build MAP labels + AX/UITest; no Grep-as-code-query)

CONTROLLER Option A (goal): non-core UL/AX vision fails with runtime evidence complete → soft known_issues (no infinite retry). No product source edits by Acceptance.

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Install+launch `com.lingguang.yarncue` on leased iPhone 17 Pro; UITest `testUL01HomeLaunch` (`evidence/runtime/uitest-ul01.log`); home `evidence/runtime/ul01-home.png` / `rt-home-empty.png` sha256 `24083718a1ed9cf082a0abe95dcae9a4b43e7bb9d1dcfb869eada43f8f62a9d7`; freeze `evidence/product-freeze.json`; upstream BUILD SUCCEEDED |
| UL-02 core_flows | pass | UITest `testUL02CoreFlowsAndPrivacy` (`evidence/runtime/uitest-ul02c.log`): New project → Create & capture → Photo library → Stitch review Keep → Ask coach (Projects stack) → Send local tip → Turn Keep → Annotate / Hands-free / Dictate entries → Settings legal. AX under `evidence/runtime/*.ax.txt`. Camera / long mic / speech quality → 真机待测 |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable`. Runtime banner `AI unavailable: DeepSeek key not configured (local_only gap).` on coach chat; local weave tip path exercised (Send → Turn review). Not canned DeepSeek theater |
| UL-04 reviewed_persistence | pass | Domain Keep/Discard: `evidence/runtime/domain-tests.log` (8/8 incl. `testStitchCueKeepPersists`, `testDiscardDoesNotWriteConfirmedCue`). Runtime: Stitch Keep + Turn Keep; relaunch shows `Accept WIP` (`ul04-relaunch-home.ax.txt`). CloudKit → gap |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback` passed. Live second outbound adaptation deferred by `ai_key_unavailable` (gap); feedback field exercised in UITest |
| UL-06 privacy_permissions | pass | Local Privacy / Terms / Support / Provider policy open (`ul06-*.png` / `.ax.txt`). Settings Allow outbound AI toggle + revoke path (`ul06-02`/`ul06-04`). Honest no outbound without key. Remote legal URLs UNKNOWN = gap |
| UL-07 ui_interaction | pass (known_issues) | Design reuse 8/8 + fresh runtime Cursor vision 8/8 (`visual_readback_index.v1.json`). Pass: home-empty, capture-import, stitch-review, project-coach, hands-free-tts, settings-privacy. Fail→known_issue: coach-chat, annotated-wip (Option A). No frame regen |
| UL-08 repo_evidence | pass | Evidence bound to commit `4770b6a8073711e044ddfce4575e49c535768ce1`, attempt-1 paths, candidate `4770b6a80737-bc768aee891c`, domain/build upstream logs. Product source read-only. No AppIcon/LaunchScreen generation |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| home-empty | CR-home-empty | `../pm_docs/attempt-1/frames/home-empty-r1.png` `f6706f69…` | reused_design | `evidence/runtime/rt-home-empty.png` `24083718…` | runtime home-empty (pass) | pass — YarnCue empty home + swatch strip + New project |
| capture-import | CR-capture-import | capture-import-r1 `8d0752fe…` | reused | `rt-capture-import.png` `ae76d4ef…` | pass | pass — Camera + Photo library |
| stitch-review | CR-stitch-review | stitch-review-r1 `33fa3476…` | reused | `rt-stitch-review.png` `a1fa2d5f…` | pass | pass — Keep / Discard / Edit |
| project-coach | CR-project-coach | project-coach-r1 `ff4c4e4e…` | reused | `rt-project-coach.png` `f34ca565…` | pass | pass — yarn-ball strip + next-row band |
| coach-chat | CR-coach-chat | coach-chat-r1 `02724cba…` | reused | `rt-coach-chat.png` `c4e368fe…` | fail | **known_issue** — Weave coach + Send + AI unavailable; Keep/Discard on Turn review after Send |
| annotated-wip | CR-annotated-wip | annotated-wip-r1 `9ace33af…` | reused | `rt-annotated-wip.png` `5b2ca75a…` | fail | **known_issue** — photo + Keep marks; pins after tap not in this shot |
| hands-free-tts | CR-hands-free-tts | hands-free-tts-r1 `a3b4c135…` | reused | `rt-hands-free-tts.png` `cf1cca51…` | pass | pass — Play / Next step |
| settings-privacy | CR-settings-privacy | settings-privacy-r1 `1ff6a829…` | reused | `rt-settings-privacy.png` `abb203e4…` | pass | pass — Allow outbound AI + local legal rows |

Index: `visual_readback_index.v1.json`.

## known_issues (non-blocking — Option A)

1. `ul07_coach_chat_keep_discard_on_turn_review` — Design criterion wants Keep/Discard on chat frame; runtime local_only path shows Send then Turn review Keep/Discard.
2. `ul07_annotated_wip_pins_after_tap` — Annotate shot has WIP photo + Keep marks before pin placement; pins require tap.
3. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek outbound / second-call adaptation proof (honest unconfigured UI observed).
4. `coach_tab_path_split` — Coach tab NavigationStack does not share Projects `path`; Ask coach / Annotate / TTS pushes must run on Projects stack (harness adapted; product note for Delivery).
5. `branding_assets_deferred` — no AppIcon/LaunchScreen this round (operator).

## Gaps (delivery / submit-before)

- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local pages load)
- `cloudkit_unconfigured`
- `feishu_row_not_yet_created` (operator skip tracker; audit persisted)
- `operator_pricing_deferred_free_app_only`
- camera / long-mic / speech quality → 真机待测 (entries + usage copy present)

## Blockers

(none)

## Evidence index

- `evidence/product-freeze.json`
- `evidence/config/inspect-key.json`, `evidence/config-audit.receipt.json`
- `evidence/runtime/` (UITest logs, screenshots, AX)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `../ai_app_build/attempt-1/MAP.md` / candidate `4770b6a80737-bc768aee891c`
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- PhotosPicker on CN Simulator needs 关闭 tip dismissal + cell tap before Coach assertions.
- YarnCue `push()` binds Projects NavigationStack only; Coach tab is a separate stack — acceptance journeys must Ask coach from Projects after Keep.
- Design criteria that require Keep/Discard on the chat frame will fail on truthful local_only Send→Turn review sequencing; judge Turn review separately.

## Hand-off

Delivery may consume this ready accept MAP + product commit `4770b6a8073711e044ddfce4575e49c535768ce1` under dir `yarncue/` on independent branch `yarncue/kf-20261014T130415Z` → `git@github.com:xy-gty/xy-gty.git` (not force main). Feishu skip OK.
