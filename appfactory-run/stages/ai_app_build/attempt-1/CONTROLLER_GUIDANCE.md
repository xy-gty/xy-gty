# Controller guidance — ScoutCue product dir

- Canonical product directory: **`scoutcue/`** (real directory).
- `product` is a symlink → `scoutcue` for factory path compatibility. Do not write as if `product/` were a separate tree.
- All new writes under `runs/<run>/scoutcue/` (or via the `product` symlink to the same inode).
- Do **not** generate AppIcon PNGs or LaunchScreen assets.
- Visual frames: use scoutcue-* / r2 real images only; ignore tiny placeholder frames.
- Continue integration_build → MAP + finish ready.
- Delivery: independent branch to xy-gty (not blind force main). Feishu skip. iPhone 17 Pro only.
