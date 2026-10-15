# CONTROLLER STEER — STOP Keep loops (authorized Option A)

dispatch: 4a6d927a-7937-481f-b0a7-8f173ac9b461
run: kf-20261015T075333Z-d3a0d226
time: 2026-10-15 16:58 CST

## Order (binding)
1. **STOP** further PhotosPicker / Keep UITest retries (r2–r5 already failed; no r6+).
2. Use HiveCue pipeline: PrepCapture (already done / reuse session) → host **`seed_post_keep.py`** → RestJourney (coach/chat/TTS/settings screenshots + domain Keep proof).
3. Script path (ready for you):
   `runs/kf-20261015T075333Z-d3a0d226/stages/ai_app_accept/attempt-1/evidence/runtime/seed_post_keep.py`
4. Write MAP.md Status/Verdict **ready** with **known_issues (Option A)** for iOS 26 ZH PhotosPicker AX / Exposure Keep not hittable — mirror HiveCue:
   `runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_accept/attempt-1/MAP.md` §known_issues.
5. `cursor-package ultra-lite finish --status ready` then exit. Do **not** regenerate frames/images. Prefer UDID B14CC0EA; **never** touch Pro Max 315A7C2C.
6. Keep semantics: `NightCueDomainTests.testFindingKeepPersists` already proves ACC Keep persistence.

Ship accept → delivery. No more Keep cycles.
