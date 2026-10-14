# Controller hard rule — product dir

Checkout MUST be named **scoutcue/** (this package is after DuctCue; `product/` is forbidden as the real directory name).

Current layout: `runs/.../scoutcue/` is the real tree; `runs/.../product` is a symlink to `scoutcue` so factory defaults still resolve.

Continue integration_build writing only through this checkout. Do NOT generate AppIcon/Launch. Simulator: iPhone 17 Pro only.
