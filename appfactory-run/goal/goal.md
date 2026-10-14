# Run objective

# External idea (operator-selected)

**Mode:** pure Cursor Ultra-lite (no Codex / hybrid)
**App working title:** CuePartner AI
**Positioning:** paid AI rehearsal partner for actors (line partner / cue coach)
**Reference:** LineLearner / com.alldayapps.linelearner — category reference only; do NOT copy brand, UI, assets, or claim licensed scripts

## Idea
Build a paid AI rehearsal partner for actors: import script photos for OCR, chat as scene partner with role switching, TTS cue lines with timing, optional stage ambience beds—unlock unlimited scenes and character voices.

## Hard privacy capabilities (controller 2026-10-13 — MUST land in first build Info.plist + runtime-testable entries)
These EXTEND the core sell-path; they must NOT replace: script import/OCR → scene partner chat (role switch) → TTS cue lines with timing → optional ambience → unlock.
Semantic glue required:
- Camera: capture handwritten/print script draft pages
- Photo library: import script photos for OCR
- Microphone: record rehearsal / line Voice notes
- Speech recognition: spoken lines → text fed into the AI scene partner
Simulator: entry + journey testable; device camera/record may mark 真机待测

Info.plist must include app-specific copy for:
NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription

## Constraints
- Do NOT ship copyrighted scripts; users bring their own text/photos
- Do NOT copy LineLearner brand or UI
- Core features should work offline where practical
- Product images via factory build-chain self-generation only
- Prefer product delivery to git@github.com:xy-gty/xy-gty.git
- Core sell-path must be runtime-tested; simulator-impossible items mark as 真机待测
- Only core defects block delivery; non-core → known_issues; max 2 repair rounds
- Feishu registration and delivery-card send deferred (controller)

## Operator channel
- Slot A continuous packaging
- production_runtime: cursor (pure Cursor Ultra-lite, model auto)
- worktree: /Users/a2026/work/factory-prod-1

The operator supplies the external idea. DeepSeekPMAgent designs this product; do not discover, rank or substitute ideas. AI UltraLite: design/build/accept/delivery. Handoff is progressive MAP.md only — see docs/agent-io-markdown.md.
