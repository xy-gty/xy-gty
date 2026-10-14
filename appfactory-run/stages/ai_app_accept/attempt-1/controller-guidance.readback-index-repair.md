# URGENT — repair visual_readback_index (factory complete blocked)

Factory `complete` rejected: `ValueError:ultra_lite_readback_index_empty`.

Root cause: attempt-1 `visual_readback_index.v1.json` used non-factory shape (`design_entries`/`runtime_entries`) instead of flat `entries` + `counts` with modes `reused_design` / `new_runtime_read`.

## Do this (official CLI only — NEVER hand-edit MAP/receipts)

1. Quarantine the bad index (rename to `visual_readback_index.v1.json.bad-shape`) — do not invent entries by hand.
2. Rebuild via factory CLI only:
   - For each of 7 frames: `python3 -m factory.ultra_lite_visual_readback lookup --run kf-20261014T073212Z-4039fa46 --frame-id <id> --criterion-file evidence/criteria/crit-<id>.txt --side design --attempt 1 --record-reuse`
   - For each of 7 runtime screenshots already under `evidence/runtime/rt-*.png` with existing `runtime-crit-*.receipt.json`: `python3 -m factory.ultra_lite_visual_readback register-new --run ... --stage ai_app_accept --attempt 1 --side runtime --image-ref evidence/runtime/rt-<frame>.png --receipt-ref evidence/visual-readback/runtime-crit-<frame>.receipt.json --product-commit 0c9a46961a1b19bfe70c2b422641a07dd3d2a2e7`
3. Paths in register-new must be **relative to attempt-1 root**.
4. If register-new rejects old thread / path: run **fresh** vision reads (new thread_ids) on the same rt-*.png files, then register-new. Do NOT re-run full UL UITest matrix. Do NOT boot Pro Max.
5. Keep MAP Status/Verdict **ready**; known_issues unchanged (Option A).
6. `cursor-package ultra-lite finish --status ready` again, then stop.

Also: UL02 fixed; no product/ rename rewind; Feishu skip; no AppIcon regen; iPhone 17 Pro only.
