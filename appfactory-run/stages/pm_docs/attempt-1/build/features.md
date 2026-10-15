# MixCue — features

## F1 Capture bottle / label / garnish (Camera)

- **Entry:** Bar Home → Shoot
- **Op:** Request Camera if needed → capture bottle face / label / garnish → save via PhotoCaptureService
- **Result:** New `MixSession` status=draft with photoLocalURL + subject
- **Persist:** session + image file
- **Empty/deny:** Show permission coaching; stay on Bar Home
- **Cancel:** Discard draft capture; no session write
- **ACC-CAM-01:** Denied camera still allows Photos import path

## F2 Import bar-shelf album (Photos)

- **Entry:** Bar Home → Import
- **Op:** Photos picker → PhotoImportSession decode + atomic save
- **Result:** `MixSession` draft
- **ACC-PHO-01:** Late picker results rejected after cancel

## F3 AI base-spirit ID + label cues

- **Entry:** After capture/import, primary “Identify”
- **Op:** If no consent → aiConsent sheet. If no key → honest unconfigured. Else SpiritIDClient sends still + prior confirmed spirits context
- **Result:** Ranked `SpiritCandidate[]` with labelCues; session → identified; UI shows vertical bottle-rail + candidates
- **Review:** Save Mix (confirm) writes confirmed spirit; Dismiss leaves identified without confirm; Edit pour steps later on board
- **ACC-AI-01:** No outbound before consent grant
- **ACC-AI-02:** Structured candidates bound to session id
- **ACC-AI-03:** Second Identify after Save includes confirmed spirits/feedback in request context

## F4 Recipe / substitute coach chat

- **Entry:** ID Result → Ask coach
- **Op:** Text field or Speech Recognition → CoachTurn user → CoachChatClient returns recipe + substitute notes citing candidates
- **Result:** Turns + optional `RecipeCard` persist under session
- **ACC-CHAT-01:** Speech path creates turn with sttSource=speech
- **ACC-CHAT-02:** Reject/dismiss of a coach suggestion does not mutate confirmed spirit

## F5 Pour board (next-pour card + garnish chips)

- **Entry:** Recipe available → Open pour board
- **Op:** PourBoardBuilder maps steps → large next-pour card + garnish chip row; user advances ordinal; Save Mix locks board
- **Result:** `PourStep[]` + `GarnishChip[]` persisted
- **ACC-POUR-01:** Next-pour card shows current ordinal instruction only; chips reflect garnish placed state

## F6 TTS shake / stir steps

- **Entry:** Pour board → Speak step
- **Op:** TTSPlayer speaks current PourStep instruction
- **ACC-TTS-01:** Works offline without AI key

## F7 Microphone voice notes

- **Entry:** Bar Home or session → Voice note
- **Op:** Mic permission → record while both hands shake/stir → save `VoiceNote`; optional transcript
- **ACC-MIC-01:** Deny mic keeps text chat and capture paths

## F8 Speech questions into coach

- **Entry:** Recipe chat mic affordance
- **Op:** Speech Recognition permission → “what can I sub for Cointreau” → user CoachTurn
- **ACC-SPEECH-01:** Deny speech keeps typed chat

## F9 Persistence & restart

- **Op:** MixStore AtomicCodableStore load on launch; TypedNavigationStore restores route prefix
- **ACC-PERS-01:** Confirmed mix + pour board + chat survive kill/relaunch
- **ACC-PERS-02:** Rejected AI result never appears in store

## F10 Settings, consent revoke, legal

- **Entry:** Settings gear
- **Op:** Toggle TTS/speech; Revoke AI consent (immediate stop outbound); open local Privacy / Terms / Support / Provider policy
- **Gaps:** privacy_url / terms_url / support_url / ai_key / cloudkit = UNKNOWN (local_only)

## Entity relationships

```
MixSession 1—* SpiritCandidate
MixSession 1—0..1 RecipeCard 1—* PourStep
RecipeCard 1—* GarnishChip
MixSession 1—* CoachTurn
MixSession 0..1—* VoiceNote
AIConsentRecord (singleton gate)
```

## AI contract summary

| Item | Value |
|------|-------|
| Provider | DeepSeek |
| Reads | bottle/label/garnish still, question, confirmed spirits/substitutes, active recipe id, optional transcript |
| Structured out | candidates[], labelCues[], recipe steps, garnish chips, substituteNotes |
| Actions | Save Mix / Dismiss / Edit pour steps |
| Feedback reuse | Confirmed + edited spirits/substitutes enter next SpiritID/Coach call |
| Consent | Shared gate; Settings revoke |
| Failures | Unconfigured / network / cancel shown honestly |

## Errors / empty / recovery

| State | UX |
|-------|-----|
| No mixes | Bar Home empty blush canvas + bottle-rail hint + Shoot/Import |
| ID failure | Banner with Retry; photo kept |
| Cancel mid-ID | Return to draft session |
| No key | Banner “AI not configured — local capture still works” |
| Permission deny | Inline coach card per permission; alternate path if any |
