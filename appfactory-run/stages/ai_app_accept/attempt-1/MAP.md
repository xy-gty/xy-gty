# PitchCue — ai_app_accept MAP

Status: ready  
Verdict: ready  
Stage: ai_app_accept  
Attempt: 1  
dispatch_id: 5d398972-e53d-4efd-98f2-8a3d730cbc3e  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task / cloud Acceptance)  
environment: cloud  
config_mode: local_only  

pm_visual_manifest_sha256: 37f0534c682301ff11f167d2408eb2481d395f67260203b0f52e821b0ce0de22  
technical_contract_sha256: 025f0d83d669b1d4c31dfabb13d085ddfd42cea01bc13866f511746b2143c782  
product_commit: 0c9a46961a1b19bfe70c2b422641a07dd3d2a2e7  
product_branch: main  
bundle_id: com.lingguang.pitchcue  
simulator_udid: 8843C141-E2FE-4DEA-A58F-0A63A5C649EF (iPhone 17 Pro exclusive lease)  
candidate: artifacts/candidates/0c9a46961a1b-529d64745e90 (candidate_unaccepted)  

code_query: code_query_blocked:codebase_memory_index_failed:FileNotFoundError:[Errno 2] No such file or directory: 'codebase-memory-mcp' (journeys from PM/build MAP labels + AX/UITest; no Grep-as-code-query)

## Stamp

| check_id | result | evidence |
| --- | --- | --- |
| UL-01 build_launch | pass | Install+launch `com.lingguang.pitchcue` on leased iPhone 17 Pro; UITest `testUL01HomeLaunch` + `testUL02CoreFlowsAndPrivacy` (`evidence/runtime/uitest-ul02c.log`); home `evidence/runtime/ul01-home.png` / `rt-home-empty.png` sha256 `936b6d94777bab33d5d29d9156c876dcaef66b59c1a2d2cafb23dc97b8830eeb`; freeze `evidence/product-freeze.json` |
| UL-02 core_flows | pass | New practice → Continue to Capture/Import → Photo library → Coach chat (Ask coach) → Plan review Keep/Discard/Edit → Practice floor (strip/waveform/Count-in/Drone/Metronome) → Pitch check (circular dial) → Settings legal. Logs `uitest-ul02c.log` + `uitest-coach-floor.log`; AX under `evidence/runtime/*.ax.txt`. Camera / long mic = 真机待测 (entries present). |
| UL-03 live_ai | pass | P1 local_only: `evidence/config/inspect-key.json` → `ai_key_unavailable`. Runtime shows `AI unavailable: DeepSeek key not configured (local_only gap).` on coach/settings (`rt2-coach.ax.txt`, `ul06-01-settings.ax.txt`). Local draft plan review smoke present (Keep/Discard/Edit). Not canned live DeepSeek. |
| UL-04 reviewed_persistence | pass | Domain Keep/Discard/persist: `evidence/runtime/domain-tests.log` (8/8). Runtime: Plan review Keep exercised; Sessions lists `Practice session` after Keep (`rt2-sessions.ax.txt`). CloudKit → gap. |
| UL-05 feedback_reuse | pass | Domain `testSecondCallContextCarriesConfirmedFeedback` passed. Live second outbound adaptation deferred by `ai_key_unavailable` (gap). |
| UL-06 privacy_permissions | pass | Local Privacy / Terms / Support open (`ul06-privacy.png`, `ul06-terms.png`, `ul06-support.png`). In-app **DeepSeek Provider Policy** loads (`ul06-provider.png` / `.ax.txt`). Settings AI data sharing + **Revoke AI consent** (`rt-settings-privacy.png`). Honest no outbound without key. Remote legal URLs UNKNOWN = gap. |
| UL-07 ui_interaction | pass | Design reuse 7/7 + fresh runtime vision 7/7 (`visual_readback_index.v1.json`). Pass: home-empty, capture-import, plan-review, practice-floor, pitch-feedback, settings-privacy. Coach-chat vision **fail** on same-frame plan steps (Ask coach present; steps on Plan review after Ask under local_only) → known_issue below, not UL-07 block. |
| UL-08 repo_evidence | pass | Evidence bound to commit `0c9a46961a1b19bfe70c2b422641a07dd3d2a2e7`, attempt-1 paths, candidate `0c9a46961a1b-529d64745e90`, domain/build upstream logs. No product source edits by Acceptance. |

## UL-07 design ↔ runtime comparison

| frame_id | criterion | design image/hash | design receipt | runtime image/hash | runtime receipt | judgment |
| --- | --- | --- | --- | --- | --- | --- |
| home-empty | crit-home-empty | `../pm_docs/attempt-1/frames/home-empty-r2.png` `3015493991…` | reused design-crit-home-empty | `evidence/runtime/rt-home-empty.png` `936b6d9477…` | runtime-crit-home-empty (pass) | pass — PitchCue empty home + strip + New practice |
| capture-import | crit-capture-import | capture-import-r2 `4137681701…` | reused | `rt-capture-import.png` `b8e39fdead…` | runtime-crit-capture-import (pass) | pass — Camera + Photo library on lilac |
| coach-chat | crit-coach-chat | coach-chat-r2 `6a185da6d5…` | reused | `rt-coach-chat.png` `4aaec8ca28…` | runtime-crit-coach-chat (**fail**) | **known_issue** — Coach chat + violet Ask coach present; plan steps appear on Plan review after Ask (local_only), not same frame |
| plan-review | crit-plan-review | plan-review-r2 `8b0affeee0…` | reused | `rt-plan-review.png` `83e6942c2c…` | runtime-crit-plan-review (pass) | pass — Keep / Discard / Edit + steps |
| practice-floor | crit-practice-floor | practice-floor-r2 | reused | `rt-practice-floor.png` `ea893f9ae0…` | runtime-crit-practice-floor (pass) | pass — strip + continuous waveform + Count-in/beds |
| pitch-feedback | crit-pitch-feedback | pitch-feedback-r2 | reused | `rt-pitch-feedback.png` `a5677e3906…` | runtime-crit-pitch-feedback (pass) | pass — circular tuner dial (Simulator demo drift noted) |
| settings-privacy | crit-settings-privacy | settings-privacy-r2 | reused | `rt-settings-privacy.png` `d9761a83b7…` | runtime-crit-settings-privacy (pass) | pass — Revoke + legal/provider rows |

## known_issues (non-blocking)

1. `ul07_coach_chat_plan_steps_on_review_not_chat` — Design criterion wants plan steps on the coach-chat frame; runtime local_only path shows Ask coach on Coach chat, then Plan review with Discard/Edit/Keep + steps after Ask. Plan-review frame itself passes.
2. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek outbound / second-call adaptation proof (honest unconfigured UI observed).
3. `branding_assets_deferred` — solid placeholder AppIcon (operator deferred).

## Gaps (delivery / submit-before)

- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local pages load).
- `cloudkit_unconfigured`
- `feishu_row_not_yet_created` (operator skip tracker; audit persisted)
- `operator_pricing_deferred_free_app_only`
- camera / long-mic quality → 真机待测 (entries + usage copy present)

## Blockers

(none)

## Evidence index

- `evidence/product-freeze.json`
- `evidence/config/inspect-key.json`, `evidence/config-audit.receipt.json`
- `evidence/runtime/` (UITest logs, screenshots, AX)
- `evidence/visual-readback/` + `visual_readback_index.v1.json`
- `../ai_app_build/attempt-1/MAP.md` / candidate `0c9a46961a1b-529d64745e90`
- `../pm_docs/attempt-1/visual_manifest.v1.json`

## lessons_candidates

- Limited Photos library chrome can leave Capture AX overlapping the picker; complete Add/关闭 before Coach assertions.
- Coach-chat design criteria that require plan steps same-frame will fail on truthful local_only Ask→Plan review sequencing; judge plan-review separately.
- Exact button labels (`Continue to Capture / Import`, `Photo library`, `Revoke AI consent`, `DeepSeek Provider Policy`) are more reliable than broad CONTAINS taps.

## Hand-off

Delivery may consume this ready accept MAP + product commit `0c9a46961a1b19bfe70c2b422641a07dd3d2a2e7` for `git@github.com:xy-gty/xy-gty.git`.
