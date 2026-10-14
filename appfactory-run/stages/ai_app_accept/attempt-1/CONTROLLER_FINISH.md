# CONTROLLER_FINISH — ScoutCue accept (Option A hard stop)

**STOP all visual re-read / regen / screenshot-vision retries immediately.**

Already decided non-core known_issues (do not re-judge, do not regenerate images):
- UL-07 `scout-card` / `scout-card-review` vision fail (Edit control missing) — fail× recorded
- UL-07 `coach-chat` vision fail
- UL-07 `golden-overlay` vision fail
- `dictate` Errno17 / dictate-note issues
- UL-02 Settings soft / `ai_key_unavailable`

## Required now (only)
1. Reuse existing evidence under `evidence/` + `visual_readback_index.v1.json` as-is.
2. Write attempt-root `MAP.md` with Status/Verdict **ready**, UL-01..UL-08 stamp; put the items above under **known_issues (non-blocking)**. No blockers.
3. Product paths: real `scoutcue/`; `product`→symlink OK. iPhone 17 Pro only. No AppIcon/Launch gen.
4. Run the exact UltraLite finish argv from dispatch with `--status ready`.
5. Do **not** run more UITests for Settings/UL-07, do **not** call screenshot-vision again, do **not** regenerate frames.

This supersedes any in-progress scout-card-review loop.
