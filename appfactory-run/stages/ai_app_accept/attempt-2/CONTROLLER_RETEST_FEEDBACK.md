# Controller retest feedback — accept attempt-2

Builder repair commit `09c4c0c3ca4b546b94253a7cd3d89f119e0b272b` / candidate `09c4c0c3ca4b-7ce60dbd04e8`.

## Must verify (core)
Four Info.plist keys present + four UI entry points measurable:
- NSCameraUsageDescription → Take photo (ImportCapture)
- NSPhotoLibraryUsageDescription → Add photos
- NSMicrophoneUsageDescription → Voice supplement
- NSSpeechRecognitionUsageDescription → Voice supplement (Chat extract and/or TTS)
Sim limits (synthetic camera / dictation draft) → known_issues, not block.

## Soft (known_issues OK)
UL-07 wrong-screen / filled-state soft visual (e.g. `ul07_fields_review_wrong_screen_hub_not_recognition`); ai_key/legal/CloudKit/feishu.

Main sell still: import → fields → chat extract → summary card → TTS. Voice supplement must not replace primary CTAs.

Prefer Status ready with known_issues over blocked for soft visual alone if four-perm pass.
