# MAP.progress — ai_app_accept attempt-1 (complete)

- Timing: acceptance span execution_seq=2 completed (~643s monotonic).
- Simulator: B14CC0EA lease acquired/released (twice; final release ok).
- Candidate install/launch: evidence/install.log launch.log pid ok.
- Domain tests: 11/11 pass (DomainTests.xcresult).
- UI journeys (external harness): UL03 coach+consent pass; UL02 rack/TTS/voice pass; UL07 scroll grid+Shoot pass; UL04/UL06 harness flakes (Form/WebView a11y).
- Vision: 01-home CR-HOME-01 fail top-fold (grid/CTAs below fold); XCTest scroll contradicts as runtime pass.
- Product commit verified eded2779 (clean).
- Repair e3: binder `map_contract_binding_missing` — add `technical_contract_sha256` + `product_dir: cellarcue/` to MAP header; preserve UL stamps / Option A / evidence; re-finish ready; do not advance factory.
- Writing MAP.md last + cursor-package ultra-lite finish --status ready.
