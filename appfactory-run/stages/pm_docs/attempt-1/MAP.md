# ScoutCue — pm_docs MAP

Status: ready  
Verdict: ready  
idea_source: operator_external  
ai_profile: ultra_lite  
production_runtime: cursor  
ultra_lite_execution_revision: p1  
config_mode: local_only  
dispatch_id: a4b687aa-f874-48ff-a831-ec93fb02eab5

technical_contract_sha256: d3e76b0d232df6307e64e68865cfecf4d83f0a5cc8687d954fdb93efbcd2d801  
pm_visual_manifest_sha256: da707cf60ead9792181caf23e7be568bfbcc394084f881885a9c093cbd7400f5

## One-line product

ScoutCue is a free AI photo-scout / timing planner: import or shoot scenery, keep scout cards, chat sun/moon golden-hour windows on a sky-arc timeline, soft overlay pins, TTS next-stop briefings, and dictated shoot notes—without DimCue measure twins, KnotCue rope carousels, or an all-black shell.

## Documents

- build/product.md
- build/features.md
- build/design.md
- build/acceptance.md
- technical/contract.md
- technical_contract.v1.json (frozen)
- technical_contract.binding.v1.json
- visual_manifest.v1.json (frozen)

## Identity

- app_name: ScoutCue
- development_bundle_id: com.lingguang.scoutcue
- ui_language: en-US
- product_dir_hint: scoutcue/
- delivery_remote: git@github.com:xy-gty/xy-gty.git (independent branch preferred)
- simulator: iPhone 17 Pro ONLY

## Deviations

- Operator “Paid / Unlock paid scouting packs” **not implemented** in this UltraLite delivery: `ai_v0_defaults=free_app_only` / `iap_opt_in=false` — no StoreKit, paywall, coins, or ATT. Gap `operator_pricing_deferred_free_app_only`. All scout cards and timing windows are unrestricted locally.
- Feishu delivery tracker skipped per operator (`feishu_row_not_yet_created` / client unavailable).
- Device camera / mic capture may mark 真机待测 in Acceptance; Simulator still exercises journey entry points.
- No AppIcon / LaunchScreen generation this round.

## Visuals

| frame_id | image | receipt | readback | status |
|----------|-------|---------|----------|--------|
| home-empty | frames/scoutcue-home-empty-r1.png | ok | pass | done |
| capture-import | frames/scoutcue-capture-import-r1.png | ok | pass | done |
| scout-card | frames/scoutcue-scout-card-r1.png | ok | pass | done |
| coach-chat | frames/scoutcue-coach-chat-r1.png | ok | pass (answer) | done |
| golden-overlay | frames/scoutcue-golden-overlay-r2.png | ok | pass (answer) | done |
| tts-briefing | frames/scoutcue-tts-briefing-r1.png | ok | pass | done |
| dictate-note | frames/scoutcue-dictate-note-r1.png | ok | pass | done |
| settings-privacy | frames/scoutcue-settings-privacy-r1.png | ok | pass | done |

- Batches: evidence/image-batch-r1.json (contaminated generic stems quarantined) + evidence/image-batch-r2.json (ScoutCue-unique stems via Cursor GenerateImage → GrokBot local_seed) + evidence/image-batch-r3-overlay.json (golden-overlay r2)
- visual_manifest.v1.json frozen sha256 da707cf60ead9792181caf23e7be568bfbcc394084f881885a9c093cbd7400f5
- design_provenance_gate: ok
- No independent assets declared (frame-embedded only); branding assets not generated
- Hard privacy Info.plist copy required for Camera / Photo Library / Microphone / Speech Recognition

## Gaps (honest, non-blocking for later stages)

- privacy_url / terms_url / support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN
- feishu_row_not_yet_created
- operator_pricing_deferred_free_app_only
- camera/mic device capture: 真机待测 where Simulator cannot exercise hardware

## Evidence index

- evidence/preflight/pm_visuals_preflight.json
- evidence/image-batch-r1.json / image-batch-r1.result.json
- evidence/image-batch-r2.json / image-batch-r2.result.json
- evidence/image-batch-r3-overlay.json / image-batch-r3-overlay.result.json
- evidence/criteria/*.txt
- evidence/visual-readback/*.receipt.json (+ raw jsonl)
- visual_manifest.v1.json
- technical_contract.v1.json / technical_contract.binding.v1.json
- frames/prompts/scoutcue-*-r*.txt / frames/scoutcue-*-r*.png
- frames/_contaminated_r1/ (quarantined CuePartner seed collisions)

## lessons_candidates

- Generic stems (`home-empty-r1`) collide with other-app local_seed inventory; always use product-prefixed stems (`scoutcue-*`) after Cursor GenerateImage seed drops.
- Overlay criteria must allow ScoutCue sky-arc decoration while still banning DimCue measure rods / KnotCue rope carousels.
