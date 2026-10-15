# CellarCue — features

idea_source: operator_external  
Hard rule: every alcohol-advice surface shows 「非侍酒认证 / not a sommelier certification」 and 「非投资建议 / not investment advice」; 21+ where alcohol recommendations appear. Never claim certified tasting or guaranteed returns.

## Feature matrix

### F1 Capture / Import label

- **Entry:** Cellar Home → Shoot / Import
- **Ops:** Camera captures label|cork|bin-tag; Photos imports album still via PhotoImportSession
- **Result:** BottleEntry(draft) with local photo
- **Persist:** photo file + session JSON
- **Empty:** empty row/bin grid with Shoot/Import CTAs
- **Error/cancel:** permission deny → Settings tip; cancel returns home without fake ID
- **Restart:** draft bottles listed in bins

### F2 Label OCR + bin write

- **Entry:** after still ready → Identify / Place (consent if first outbound)
- **Ops:** LabelOCRClient sends still + prior notes; writes structured fields into selected CellarBin
- **Result:** status=identified; large label-OCR hero card; bin slot filled
- **AI fields in:** still ref, prior confirmed notes; **out:** OCR fields, confidence, bin suggestion
- **Human review:** Save Bottle / Keep / Use vs Dismiss / Reject; Reject does not persist OCR as confirmed
- **Feedback reuse:** second Identify includes confirmed bottle notes / rejected labels
- **Unconfigured:** honest banner; local still kept

### F3 Large label-OCR hero card

- **Entry:** Label Result / Cellar Home selection
- **Ops:** hero card shows OCR producer/vintage/varietal with confidence
- **Result:** user can Edit bin / Edit window then Keep
- **Never:** hero copy claiming sommelier certification or investment upside

### F4 Drinking-window aging timeline

- **Entry:** Label Result under compliance banners + 21+ chip
- **Ops:** DrinkingWindowTimeline renders hold / approaching / open / past points
- **Result:** timeline feeds coach prompts; informationalOnly
- **Copy:** must not say “guaranteed peak value” or certified drink timing

### F5 Drinking-window / pairing coach chat

- **Entry:** Label Result → Ask coach; Speech for spoken Q (“where is the 2015 Barolo”, “pair with lamb?”)
- **Ops:** text or SFSpeechRecognizer → CoachTurn; CoachChatClient answers window/pairing
- **Result:** turns persist; answers restate compliance + 21+ when touching alcohol advice
- **Second call:** includes confirmed bottle + user corrections

### F6 Annotated rack card

- **Entry:** Make rack card from Label Result
- **Ops:** RackCardAnnotator places pull/pour callouts; user Edit then Keep
- **Result:** RackCardAnnotation saved with bottle
- **Reject:** discards draft callouts, keeps bottle photo

### F7 TTS pull/pour brief

- **Entry:** Play brief on Label Result / Pull Brief route
- **Ops:** TTSPullBrief speaks script including compliance + 21+ + bin location + window status
- **Cancel:** stop speech; bottle unchanged

### F8 Voice notes (Microphone)

- **Entry:** Voice note while carrying bottles
- **Ops:** record → VoiceNote file; optional transcript hook
- **Result:** attached to bottle/bin; usable as coach context after review

### F9 Permissions & consent

- Camera / Photos / Mic / Speech — each tied to F1/F5/F8 flows extending cellar coach
- AIConsentGate before first outbound; Settings revoke stops sends immediately
- Local privacy / terms / support / provider policy pages load offline

### F10 Settings & legal

- Toggle TTS / speech input; revoke AI; alwaysShowComplianceBanner (default on, cannot fully hide on alcohol-advice surfaces); ageGateAcknowledged
- Local legal pages; external URL gaps UNKNOWN

## Entities & relations

CellarRack 1—* CellarBin  
CellarBin 0..1 BottleEntry  
BottleEntry 0..1 LabelOCRResult, DrinkingWindow, RackCardAnnotation, PullBrief  
BottleEntry 1—* PairingNote, CoachTurn  
BottleEntry * VoiceNote  
AppSettings / AIConsentRecord singleton-ish

## Error / empty / restore

| State | Behavior |
|-------|----------|
| Empty home | row/bin grid placeholder + Shoot/Import |
| Permission denied | inline reason + Open Settings |
| AI key missing | local-only; no canned OCR |
| Model failure | retry / keep still |
| Cancel mid-ID | return to draft bottle |
| Restart | restore racks, bins, bottles, chat, rack cards |
