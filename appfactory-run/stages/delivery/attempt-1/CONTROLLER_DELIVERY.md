# Controller delivery — ScoutCue

1. Product dir MUST stay real `scoutcue/` (`product` → symlink). Never rewrite to product/.
2. Push to `git@github.com:xy-gty/xy-gty.git` on an **independent branch** (prefer `delivery/scoutcue-<shortsha>` or similar). Do NOT force-push main.
3. Feishu tracker: skip.
4. No AppIcon / LaunchScreen generation.
5. iPhone 17 Pro only if any sim touch needed (should not need).
6. After push: report tip SHA + branch name in MAP and finish ready.
