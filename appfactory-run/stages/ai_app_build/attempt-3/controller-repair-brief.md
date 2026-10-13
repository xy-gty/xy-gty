# Controller repair brief (attempt-3 / CONTROLLER HARD RULE 2026-10-13)

Authorized by App 工厂产包主控 hard rule + packaging resume.

## Preserve
- Product commit `b85a9124…` Active punch hub `NavigationStack(path:)` binding — UL-02 hub CTAs (Add photos / Review snags / Chat fill / Annotate / Read aloud) must keep navigating.
- Do not regress prior AI consent / local legal / domain tests.

## Hard rule (must land in this product commit)
1. **Info.plist / project.yml** — all four keys with SnagCue site-inspection-specific copy:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription` (already present — keep/refine)
   - `NSMicrophoneUsageDescription` (MISSING — add)
   - `NSSpeechRecognitionUsageDescription` (MISSING — add)

2. **Each key ↔ complete usable feature** (runtime-testable; Simulator gaps → 真机待测):
   - Camera capture (拍照) — walkthrough photo for snag recognition
   - Photo library pick (选图) — already via PhotosPicker; keep
   - Microphone recording entry (麦克风录音入口) — voice note into punch item / hands-free
   - Speech recognition → text (语音识别转文字) — supplements punch-list field fill

3. **Semantic glue** — features EXTEND core sell-path, do NOT replace:
   walkthrough photos → defect/snag recognition → chat punch-list fill → annotated report → TTS checklist readout
   Example: speech-to-text fills punch-list fields; mic supports voice note on punch item.

4. **Accept report expectation** — stage report MUST explicitly name: four plist keys present + four features verified (pass / gap / 真机待测).

## Non-blockers (known gaps)
ai_key_unavailable / legal URL UNKNOWN / CloudKit unconfigured / feishu deferred / pricing deferred / physical camera may be 真机待测 on Simulator.

## Delivery
Publish new `candidate_unaccepted` after compile + domain tests + smoke. Write MAP last; finish via official `cursor-package ultra-lite finish`. Prefer later delivery to xy-gty; Feishu deferred.
