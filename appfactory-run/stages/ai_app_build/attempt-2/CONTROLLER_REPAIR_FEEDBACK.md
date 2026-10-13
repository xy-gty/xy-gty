# Controller repair feedback — attempt-2 (operator-authorized 修复轮1)

Source: accept attempt-1 blocked MAP + 主控硬规则四权限/四功能.
Prior accept continue--repair only bumps accept (cannot edit product); path used:
`factory block` → `factory retry-from --stage ai_app_build --operator-authorized`.

## Must fix (product)

1. **Plist keys** in `project.yml` / Info.plist:
   - Keep: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` (DocBrief-aligned copy)
   - Add: `INFOPLIST_KEY_NSMicrophoneUsageDescription` — voice supplement for actions/due dates or spoken brief questions
   - Add: `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription` — same DocBrief-aligned purpose

2. **Four measurable features** (do not replace main sell: import→fields→chat extract→summary card→TTS):
   - **Camera**: ImportCapture — add tappable **Take photo** / camera capture that writes `DocumentPhoto` (sim UI testable; device camera may known_issue)
   - **Photos**: keep existing PhotosPicker **Add photos**
   - **Mic + Speech recognition**: near Chat extract or TTS briefing, add **Voice supplement** — dictate → fill ActionItem title/due_date or briefing question draft, human Save/Not this; never replace primary CTAs

3. **UL-07 soft visual**: may known_issues (`ul07_fields_review_wrong_screen_hub_not_recognition` etc.) or opportunistic fix; not core blocker vs four-perm.
4. Non-blocking gaps: `ai_key_unavailable`, legal URL unknown, CloudKit, Feishu — leave as gaps.

## Stage report mandatory literals

Name all four keys + four entry points in MAP:
- NSCameraUsageDescription → Take photo (ImportCapture)
- NSPhotoLibraryUsageDescription → Add photos (PhotosPicker)
- NSMicrophoneUsageDescription → Voice supplement
- NSSpeechRecognitionUsageDescription → Voice supplement

Then rebuild candidate_unaccepted, finish ready.
