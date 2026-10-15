# SporeCue — delivery MAP

Status: ready  
report_status: produced  
package_acceptance: accepted  
Stage: delivery  
Attempt: 1  
dispatch_id: 5e344109-87d3-44c5-9c1d-7d2b5bd79a5c  
ai_profile: ultra_lite  
ultra_lite_execution_revision: p1  
production_runtime: cursor  
requested_model: auto  
observed_model: inherit/auto (Cursor Task)  
config_mode: local_only  
delivery_mode: full_app  
milestone_chain: ai_native  

pm_visual_manifest_sha256: 0263b2c8eadb63c6c401b4d4bde562b5079f4c9e11498059822d9b86a00639d2  
technical_contract_sha256: cde02f702a052b37ad3f7a1eb8dd16836639377a1b10261f40bfd83c697e5356  
product_commit: 953628045629d96380e8792457acd895f19955ed  
product_dir: sporecue/ (`sporecue` → `product` symlink)  
product_branch: sporecue/kf-20261015T174239Z-859f7eed  
bundle_id: com.lingguang.sporecue  
remote: git@github.com:xy-gty/xy-gty.git  
repo_url: https://github.com/xy-gty/xy-gty/tree/sporecue/kf-20261015T174239Z-859f7eed  
simulator_udid: B14CC0EA-EA96-4E5A-B32A-3187A83346B7 (iPhone 17 Pro exclusive; Pro Max `315A7C2C` never shutdown/occupied)  
candidate: artifacts/candidates/953628045629-ed4e4e7deb04 (SporeCue.app.zip + receipt; accept bound same tip)  
palette: #9A3412 / #FFF7ED / #0284C7  
unique_ui: SpeciesConfidenceStack + GillPoreCloseupBar + CautionChipRail (纵向物种置信栈 + 超大菌褶/管孔特写条 + 警示 chip 轨)  
≠ twins: MixCue bottle-rail / WingCue field-card / ClosetCue mosaic / FrameCue clapper / ScoutCue sky-arc / RuleCue table-zone / StopCue sprocket  
free_app_only: no StoreKit / paywall / coins / ATT  
AppIcon/LaunchScreen: not generated (operator)  
Feishu: CONTROLLER_DELIVERY skip  

## Product

SporeCue — AI wild-mushroom field ID / foraging coach: shoot or import cap / gill / pore photos, get species confidence stack + lookalikes, chat habitat/features, annotated overlays, TTS field brief. Every ID/edibility/foraging surface states 「非可食认证 / not an edibility certification」. Palette `#9A3412` / `#FFF7ED` / `#0284C7`. Four permissions: Camera / Photos / Microphone / Speech Recognition. Competitor brands absent from App UI copy.

## Controlling gate

- Verification: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T174239Z-859f7eed/stages/ai_app_accept/attempt-1/MAP.md` → Verdict: ready  
- Factory `package_acceptance`: accepted  
- Upstream build: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T174239Z-859f7eed/stages/ai_app_build/attempt-1/MAP.md` → ready  
- Upstream PM: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T174239Z-859f7eed/stages/pm_docs/attempt-1/MAP.md`  
- Package: n/a (ai_native; no PDA)  
- Checklist: n/a (ai_native)  
- Visual: `/Users/a2026/work/factory-prod-1/runs/kf-20261015T174239Z-859f7eed/stages/pm_docs/attempt-1/visual_manifest.v1.json`  

## Packaging artifacts

- Local zip: `artifacts/candidates/953628045629-ed4e4e7deb04/SporeCue.app.zip` (present, ~678K)  
- Receipt sha256: `6c0259a294f8801ffab58a284042dd7d82ba94c635ff1eb17e2d4e0ec9735f6d`  
- Source commit freeze: `953628045629d96380e8792457acd895f19955ed`  
- Remote tip readback: `953628045629d96380e8792457acd895f19955ed	refs/heads/sporecue/kf-20261015T174239Z-859f7eed` (match)  
- Legacy hyphen branch same tip: `refs/heads/sporecue-kf-20261015T174239Z-859f7eed`  
- Evidence: `evidence/packaging-readback.txt`  
- Feishu skip: `evidence/feishu-controller-delivery-skip.txt` (record_id n/a, blocker=false)  

## UL eight-domain stamp (from accept; not re-judged)

| check_id | result |
| --- | --- |
| UL-01 build_launch | pass |
| UL-02 core_flows | pass |
| UL-03 live_ai | pass (P1 local_only honest `ai_key_unavailable`) |
| UL-04 reviewed_persistence | pass |
| UL-05 feedback_reuse | pass (live second outbound deferred by key gap) |
| UL-06 privacy_permissions | pass (Camera/Photos/Mic/Speech + local legal HTML) |
| UL-07 ui_interaction | pass (Option A known_issues on non-core vision / fold) |
| UL-08 repo_evidence | pass |

## Operator summary

- Shipped SporeCue on independent branch `sporecue/kf-20261015T174239Z-859f7eed` → `xy-gty/xy-gty` at `953628045629…`
- product_dir remains `sporecue/` (symlink → `product`); bundle `com.lingguang.sporecue`
- Build + domain 12/12 + Simulator smoke/UITest on iPhone 17 Pro `B14CC0EA…` only; Pro Max left Booted untouched
- Core UL-01 / UL-02b sell / UL-04 / UL-06 runtime journeys passed; AX proves `SpeciesConfidenceStack` + `GillPoreCloseupBar` + disclaimer 非可食认证
- Four permission entry points present; hardware quality 真机待测
- free_app_only; no AppIcon/LaunchScreen this round
- Feishu delivery writeback skipped per CONTROLLER_DELIVERY
- Option A soft known_issues already sealed in accept — retained non-blocking
- Formal `delivered` milestone is controller complete/status readback only — not claimed here

## Stage cost

Copy of controller `stage_cost_json` (usage unknown → n/a):

| stage | status | attempts | duration_seconds | usage |
| --- | --- | --- | --- | --- |
| goal | validated | 1 | null | n/a |
| pm_docs | validated | 1 | 1182.0 | n/a |
| ai_app_build | validated | 1 | 1043.0 | n/a |
| ai_app_accept | validated | 1 | 1390.0 | n/a |
| delivery | active→produced | 1 | null at report time | n/a |
| **total (validated stages)** | | | **3615.0** | n/a |

Rounds: 验收轮次 1/2；修复轮次 0.

Observed UltraLite timing (completed leaf/stage spans; incomplete retained as-is, not guessed):

| stage / span | duration_seconds | note |
| --- | --- | --- |
| pm_docs stage_execution | 1162.731524 | completed |
| pm_docs planning | 911.780512 | completed |
| pm_docs visual_capture | 126.853136 | completed |
| pm_docs visual_readback | 705.811687 | completed |
| ai_app_build stage_execution | 992.426125 | completed |
| ai_app_build integration_build | 40.692357 | completed |
| ai_app_build domain_tests | 18.975537 | completed |
| ai_app_build runtime_smoke | 439.039329 | completed |
| ai_app_accept stage_execution | 1361.965834 | completed |
| delivery stage_execution | incomplete host span at MAP write | controller-started; finished after MAP |
| delivery evidence `delivery-evidence-1` | 19.105061 | completed |
| formal `delivered` | null | controller complete only |

Speed baseline vs 30–45min / −30%: **not_proven** (不等价样本；含验收运行与视觉读图窗口).

## Links

- report_html: n/a (UltraLite light; HTML skipped)
- repo_url: https://github.com/xy-gty/xy-gty/tree/sporecue/kf-20261015T174239Z-859f7eed
- commits: `953628045629d96380e8792457acd895f19955ed`
- feishu_record: n/a (CONTROLLER_DELIVERY skip)
- candidate: `artifacts/candidates/953628045629-ed4e4e7deb04`
- accept evidence: `stages/ai_app_accept/attempt-1/evidence/`
- build evidence: `stages/ai_app_build/attempt-1/` (MAP, build/domain/smoke logs, candidate)
- config audit: build `evidence/config-audit.stdout.txt` + accept `evidence/config/inspect-key.json` (ai_key_unavailable)
- packaging readback: `stages/delivery/attempt-1/evidence/packaging-readback.txt`

## known_issues (non-blocking — CONTROLLER Option A; sealed in accept)

1. `ul07_home_vision_strict_fail` — runtime vision fail vs still criteria; AX proves SpeciesConfidenceStack / GillPoreCloseupBar + Shoot/Import + 非可食认证
2. `ul07_capture_vision_system_photos_sheet` — Shoot surfaced limited Photos privacy sheet vs design camera still
3. `ul07_id_vision_empty_ranks_without_ai_key` — ranked names require live DeepSeek; stack chrome + disclaimer present
4. `ul07_chat_overlay_shot_timing` — lookalike/overlay screenshots may lag navigation; UITest exercised Ask coach + Annotate
5. `ul07_voice_note_not_recording_state` — sheet Start/Close proven; mid-record Stop not captured
6. `ul07_settings_consent_vision_partial` — Settings vision fail on single fold; scrolled AX proves permissions+legal; ConsentSheet not isolated
7. `ai_key_unavailable` — expected P1 local_only; blocks live DeepSeek / second-call outbound proof
8. `branding_assets_deferred` — no AppIcon/LaunchScreen (operator)
9. `camera_mic_speech_device_quality` — Simulator entry points only; 真机待测
10. `support_html_mentions_forbid_competitors` — `App/Resources/Legal/support.html` prose mentions Shroomify/Pilze 123 (UI surfaces do not)

## Gaps / replace_before_submission

- `feishu_row_not_yet_created` (CONTROLLER_DELIVERY skip; record_match_error=0)
- `legal_url_unknown` — remote privacy/terms/support UNKNOWN (local HTML packaged)
- `ai_key_unavailable` — no Secrets.xcconfig / authorized config (`ai_key_source: none`)
- `cloudkit_unconfigured`
- `operator_pricing_deferred_free_app_only`
- `branding_assets_deferred`

## Blockers

(none)

## Hand-off

Controller may complete run after this ready MAP. Do not treat Delivery ready as factory `delivered` until status readback after complete.

## lessons_candidates

- Delivery with CONTROLLER_DELIVERY skip must still list Feishu/legal/key/CloudKit under replace_before_submission without inventing writeback success.
- Keep product_dir identity as `sporecue/` symlink; never report path-only `product/` as the operator product_dir.
- AX ids `SpeciesConfidenceStack` / `GillPoreCloseupBar` are the uniqueness proof vs MixCue/WingCue/ClosetCue/FrameCue/ScoutCue/RuleCue/StopCue twins.
- Packaging-ready gate for this run = candidate zip + receipt + remote tip matching accept freeze `953628045629…`.
