# SporeCue — features

idea_source: operator_external  
Hard rule: every ID / edibility / foraging surface shows 「非可食认证 / not an edibility certification」. Never imply safe to eat.

## Feature matrix

### F1 Capture / Import still

- **Entry:** Field Home → Shoot / Import
- **Ops:** Camera captures cap|gill|pore; Photos imports hike still via PhotoImportSession
- **Result:** ForageSession(draft) with local photo
- **Persist:** photo file + session JSON
- **Empty:** empty stack with Shoot/Import CTAs
- **Error/cancel:** permission deny → Settings tip; cancel returns home without fake ID
- **Restart:** draft sessions listed

### F2 Species ID + confidence stack

- **Entry:** after still ready → Identify (consent if first outbound)
- **Ops:** SpeciesIDClient sends still + prior notes; shows vertical ranked SpeciesCandidate stack
- **Result:** status=identified; morphology cues; informational CautionChips
- **AI fields in:** still ref, prior confirmed notes; **out:** candidates, cues, chips (informationalOnly)
- **Human review:** Save Find / Keep / Use vs Dismiss / Reject; Reject does not persist candidates
- **Feedback reuse:** second Identify includes confirmed notes / rejected labels
- **Unconfigured:** honest banner; local still kept

### F3 Oversized gill/pore closeup bar

- **Entry:** ID Result / Overlay
- **Ops:** bar shows enlarged gill/pore crop with MorphologyCallout pins
- **Result:** user can jump callout → overlay annotate
- **Never:** bar copy saying edible/safe

### F4 Edible / warning chip rail

- **Entry:** ID Result under disclaimer banner
- **Ops:** ChipRailBuilder renders info_edible_look / warning_lookalike / toxic_lookalike / unknown
- **Result:** chips filter chat prompts; all marked informationalOnly
- **Copy:** chip titles must not say “safe to eat” or “certified”

### F5 Lookalike / habitat coach chat

- **Entry:** ID Result → Ask coach; Speech button for spoken Q
- **Ops:** text or SFSpeechRecognizer → CoachTurn; CoachChatClient answers habitat/features/lookalikes
- **Result:** turns persist; answers restate disclaimer when touching edibility
- **Second call:** includes confirmed species + user corrections

### F6 Annotated overlay

- **Entry:** Annotate from ID Result
- **Ops:** OverlayAnnotator places callouts; user Edit callouts then Keep
- **Result:** OverlayAnnotation saved with session
- **Reject:** discards draft callouts, keeps session photo

### F7 TTS field brief

- **Entry:** Play brief on ID Result / Field Brief route
- **Ops:** TTSFieldBrief speaks script including disclaimer + morphology + lookalike caution
- **Cancel:** stop speech; session unchanged

### F8 Voice notes (Microphone)

- **Entry:** Voice note while hands busy
- **Ops:** record → VoiceNote file; optional transcript hook
- **Result:** attached to session; usable as coach context after review

### F9 Permissions & consent

- Camera / Photos / Mic / Speech — each tied to F1/F5/F8 flows
- AIConsentGate before first outbound; Settings revoke stops sends immediately
- Local privacy / terms / support / provider policy pages load offline

### F10 Settings & legal

- Toggle TTS / speech input; revoke AI; alwaysShowEdibilityDisclaimer (default on, cannot fully hide on ID surfaces)
- Local legal pages; external URL gaps UNKNOWN

## Entities & relations

ForageSession 1—* SpeciesCandidate, MorphologyCallout, CautionChip, CoachTurn  
ForageSession 0..1 OverlayAnnotation, FieldBrief  
ForageSession * VoiceNote  
AppSettings / AIConsentRecord singleton-ish

## Error / empty / restore

| State | Behavior |
|-------|----------|
| Empty home | stack placeholder + Shoot/Import |
| Permission denied | inline reason + Open Settings |
| AI key missing | local-only; no canned species |
| Model failure | retry / keep still |
| Cancel mid-ID | return to draft session |
| Restart | restore sessions, stack, chat, overlays |
