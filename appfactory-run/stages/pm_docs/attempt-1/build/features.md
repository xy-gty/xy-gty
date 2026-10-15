# WingCue — features

## F1 Capture bird still (Camera)

- **Entry:** Field Home → Shoot
- **Op:** Request Camera if needed → capture body/plumage close-up → save via PhotoCaptureService
- **Result:** New `IDSession` status=draft with photoLocalURL
- **Persist:** session + image file
- **Empty/deny:** Show permission coaching; stay on Field Home
- **Cancel:** Discard draft capture; no session write
- **ACC-CAM-01:** Denied camera still allows Photos import path

## F2 Import trip album (Photos)

- **Entry:** Field Home → Import
- **Op:** Photos picker → PhotoImportSession decode + atomic save
- **Result:** `IDSession` draft
- **ACC-PHO-01:** Late picker results rejected after cancel

## F3 AI species ID + field marks

- **Entry:** After capture/import, primary “Identify”
- **Op:** If no consent → aiConsent sheet. If no key → honest unconfigured. Else SpeciesIDClient sends bird still + prior confirmed marks context
- **Result:** Ranked `SpeciesCandidate[]` + `FieldMark[]`; session → identified; UI shows field-card stack + oversized chips + silhouette bar
- **Review:** Save ID (confirm) writes confirmed candidate; Dismiss leaves identified without confirm; Edit marks adjusts chip set then Save
- **ACC-AI-01:** No outbound before consent grant
- **ACC-AI-02:** Structured candidates bound to session id
- **ACC-AI-03:** Second Identify after Save includes confirmed marks/feedback in request context

## F4 Lookalike coach chat

- **Entry:** ID Result → Clarify lookalikes
- **Op:** Text field or Speech Recognition → CoachTurn user → CoachChatClient streams/returns coach text citing candidates
- **Result:** Turns persist under session
- **ACC-CHAT-01:** Speech path creates turn with sttSource=speech
- **ACC-CHAT-02:** Reject/dismiss of a coach suggestion does not mutate confirmed species

## F5 Annotated overlay

- **Entry:** ID Result → Annotate
- **Op:** OverlayAnnotator maps marks → callouts; user can drag labels lightly; Save overlay
- **Result:** `AnnotatedOverlay` file + entity
- **ACC-OVL-01:** Overlay references same photo as session

## F6 TTS tips

- **Entry:** ID Result / Overlay → Speak tip
- **Op:** TTSPlayer speaks commonName + top field-mark tip
- **ACC-TTS-01:** Works offline without AI key

## F7 Microphone voice notes

- **Entry:** Field Home or session → Voice note
- **Op:** Mic permission → record while hands on binoculars → save `VoiceNote`; optional transcript
- **ACC-MIC-01:** Deny mic keeps text chat and capture paths

## F8 Speech questions into coach

- **Entry:** Lookalike chat mic affordance
- **Op:** Speech Recognition permission → “which warbler has the white wing bars” → user CoachTurn
- **ACC-SPEECH-01:** Deny speech keeps typed chat

## F9 Persistence & restart

- **Op:** SightingStore AtomicCodableStore load on launch; TypedNavigationStore restores route prefix
- **ACC-PERS-01:** Confirmed ID + overlay + chat survive kill/relaunch
- **ACC-PERS-02:** Rejected AI result never appears in store

## F10 Settings, consent revoke, legal

- **Entry:** Settings gear
- **Op:** Toggle TTS/speech; Revoke AI consent (immediate stop outbound); open local Privacy / Terms / Support / Provider policy
- **Gaps:** privacy_url / terms_url / support_url / ai_key / cloudkit = UNKNOWN (local_only)

## Entity relationships

```
IDSession 1—* SpeciesCandidate 1—* FieldMark
IDSession 1—0..1 LookalikePair
IDSession 1—* CoachTurn
IDSession 1—* AnnotatedOverlay
IDSession 0..1—* VoiceNote
AIConsentRecord (singleton gate)
```

## AI contract summary

| Item | Value |
|------|-------|
| Provider | DeepSeek |
| Reads | bird still, question, confirmed marks, lookalike ids, optional transcript |
| Structured out | candidates[], fieldMarks[], contrastNotes |
| Actions | Save ID / Dismiss / Edit marks |
| Feedback reuse | Confirmed + edited marks enter next SpeciesID/Coach call |
| Consent | Shared gate; Settings revoke |
| Failures | Unconfigured / network / cancel shown honestly |

## Errors / empty / recovery

| State | UX |
|-------|-----|
| No sightings | Field Home empty mint canvas + Shoot/Import |
| ID failure | Banner with Retry; photo kept |
| Cancel mid-ID | Return to draft session |
| No key | Banner “AI not configured — local capture still works” |
| Permission deny | Inline coach card per permission; alternate path if any |
