# Controller accept brief (attempt-3)

Authorized by App 工厂产包主控 urgent 2026-10-13.

## Must explicitly verify and name in MAP/report
1. **UL-02** Active punch hub CTAs navigate: Add photos / Review snags / Chat fill / Annotate / Read aloud
2. **Info.plist** all four present (built app): NSCameraUsageDescription / NSPhotoLibraryUsageDescription / NSMicrophoneUsageDescription / NSSpeechRecognitionUsageDescription
3. **Four features** runnable with punch-list semantic glue:
   - 拍照 Camera capture
   - 选图 Photo library pick
   - 麦克风录音入口 Mic voice note on punch item
   - 语音识别转文字 Speech-to-text into chat/punch fields
   Simulator-impossible → mark 真机待测 (not core blocker if UI entry + plist present)

## Upstream build
- Build attempt-3 MAP ready; product commit `47f1c118…`; candidate `47f1c118b9e5-146049ffc8bc`
- Feishu deferred; non-core known gaps OK

## Do not
Hand-edit MAP/receipts; bypass checks; undo hub CTA / four-feature product work.
