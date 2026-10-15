# CellarCue — P1 technical contract

`config_mode: local_only`

## Identity

- app_name: CellarCue
- product_dir: cellarcue/ (symlink cellarcue → product; deliver as cellarcue, not product)
- development_bundle_id: com.lingguang.cellarcue
- platform: iOS 17+ SwiftUI, iPhone 17 Pro Simulator only (prefer UDID B14CC0EA); never Pro Max
- language: UI en-US; PM docs zh-CN
- idea_source: operator_external
- commerce: free_app_only this package — no StoreKit / paywall / coins / ATT. Operator “one-time unlock for unlimited cellar packs” is out of scope (separate iap_att). Unlimited local cellar bins in this build.
- Do NOT generate AppIcon / LaunchScreen assets
- Do NOT name Vinocell in any App copy
- NOT MixCue / SporeCue / WingCue / FrameCue / RuleCue / StopCue twins

## Hard compliance (non-negotiable)

- Every product surface that touches alcohol advice, drinking windows, food pairing, or cellar coaching MUST clearly state: 「非侍酒认证 / not a sommelier certification」 and 「非投资建议 / not investment advice」
- 21+ related wording must appear on surfaces that show alcohol recommendations (drinking window, pairing, pull/pour brief)
- NEVER claim certified tasting advice, guaranteed investment returns, or “drink now for value”
- Drinking-window / aging timeline and pairing answers are informational coaching only — not sommelier certification

## Scope

1. Capture or import a wine label / cork / bin-tag still → create a BottleEntry bound to a CellarBin
2. AI label OCR + bottle ID written into row/bin slot (出站需 consent + key)
3. Large label-OCR hero card as primary result surface
4. Drinking-window aging timeline on the bottle card
5. Coach chat for drinking window & food pairing (text + speech-to-text)
6. Annotated cellar-rack cards for pull/pour planning
7. TTS pull/pour brief (scripts include compliance + 21+)
8. Microphone hands-free bin notes while carrying bottles
9. Persist cellar / bottles / chat / rack cards locally; restart restore
10. Four real permission flows: Camera, Photos, Microphone, Speech Recognition
11. Local legal / privacy / support pages; provider policy reachable
12. Honest offline / unconfigured AI states

Out of scope: IAP unlock, coin catalog, ATT, AppIcon/LaunchScreen, MixCue/SporeCue/WingCue/FrameCue/RuleCue/StopCue UI twins, Pro Max simulator, Vinocell (or other competitor) names in App copy, sommelier certification claims, investment advice.

## Domain entities

| Entity | Key fields | Persistence |
|--------|------------|-------------|
| CellarRack | id, name, rowCount, binCountPerRow, createdAt | AtomicCodableStore |
| CellarBin | id, rackId, row, column, label | nested / store |
| BottleEntry | id, binId, createdAt, photoLocalURL, source(camera\|photos), status(draft\|identified\|confirmed), vintage?, producer?, varietal?, region?, disclaimerAck, ageGateAck | AtomicCodableStore |
| LabelOCRResult | bottleId, rawText, structuredFields, confidence | nested |
| DrinkingWindow | bottleId, peakStart, peakEnd, status(hold\|approaching\|open\|past), timelinePoints[] | nested |
| PairingNote | bottleId, dish, rationale, informationalOnly=true | nested |
| RackCardAnnotation | bottleId, callouts[], imageLocalURL, generatedAt | nested |
| CoachTurn | bottleId?, role(user\|coach), text, sttSource?, createdAt | store |
| PullBrief | bottleId, scriptText, spokenAt?, ttsLocale | nested |
| VoiceNote | bottleId?, binId?, localAudioURL, transcript?, createdAt | store + file |
| AIConsentRecord | provider, disclosureVersion, grantedAt, revokedAt? | AIConsentGate |
| AppSettings | ttsEnabled, speechInputEnabled, consentRevoked, alwaysShowComplianceBanner, ageGateAcknowledged | store |

## Interfaces

| Interface | Responsibility |
|-----------|----------------|
| CellarStore | CRUD racks/bins/bottles + related; AtomicCodableStore\<CellarCueState\> |
| PhotoCaptureService | Camera stills of label / cork / bin tag → save |
| PhotoLibraryImporter | Photos picker → decode → atomic save via PhotoImportSession |
| LabelOCRClient | Still → DeepSeek structured label ID + bin placement suggestion (never sommelier certification / investment advice) |
| CoachChatClient | Drinking-window / food-pairing Q&A with bottle context + feedback reuse |
| DrinkingWindowTimeline | Build aging timeline points from vintage + style cues |
| RackCardAnnotator | Annotated cellar-rack cards for pull/pour |
| TTSPullBrief | Speak pull/pour brief (AVSpeechSynthesizer); script must include compliance + 21+ |
| VoiceNoteRecorder | Mic record while hands carry bottles → file |
| SpeechQuestionIngress | SFSpeechRecognizer → CoachTurn (e.g. “where is the 2015 Barolo”, “pair with lamb?”) |
| ConsentGate | Shared AIConsentGate before any outbound send; Settings revoke |
| KeychainCredentialStore | Read DEEPSEEK_API_KEY presence; service cellarcue.ai |
| TypedNavigationStore\<Route\> | Route enum restore |

Review controls:
- confirm: Save Bottle / Keep / Use
- reject: Dismiss / Reject
- edit: Edit bin / Edit window

## Navigation (Route)

```
.rootTab
  .cellarHome            // row/bin grid + hero OCR card slot + window timeline strip
  .cameraCapture         // live camera for label / cork / bin tag
  .photoImport           // Photos picker bridge
  .labelResult(bottleId) // large OCR hero + bin write + timeline
  .windowChat(bottleId)  // drinking window & pairing coach
  .rackCard(bottleId)    // annotated rack card
  .pullBrief(bottleId)   // TTS pull/pour brief
  .voiceNote(bottleId?)
  .aiConsent
  .settings
  .legal(page)           // privacy | terms | support | providerPolicy
```

First-use: Cellar Home empty → Capture/Import → (consent if outbound) → Label Result (compliance + 21+ visible) → Window chat → Rack card / TTS brief. Skip allowed; no fake bottles; never imply certified tasting or investment returns.

## Storage / AI / permissions

- Local AtomicCodableStore + photo/audio files in Application Support
- Outbound AI default disabled until key or authorized config (`local_only`)
- Provider: DeepSeek; send fields: label still, user question, confirmed bottle notes, active bottle/bin id, optional voice transcript
- Permissions: camera, photos, microphone, speech_recognition — each extends cellar coach core loop

## P1 config gaps

```
privacy_url: UNKNOWN
terms_url: UNKNOWN
support_url: UNKNOWN
ai_key: UNKNOWN
cloudkit: UNKNOWN
config_mode: local_only
```

Builder must NOT “verify existing authorized configuration”. Legal acceptance = local legal pages load. Feishu CONTROLLER_DELIVERY skip. Option A soft known_issues for non-core UL fails.

## Palette / UI species

- primary `#3730A3` · secondary `#EEF2FF` · accent `#EA580C`
- UI: 酒架 row/bin 网格 + 大号酒标 OCR 主卡 + 饮用窗陈年时间轴
- Ban twins: MixCue vertical bottle-rail, SporeCue confidence stack, WingCue field-card stack, FrameCue safe-frame/clapper, RuleCue table zone, StopCue film-sprocket, ClosetCue mosaic, ScoutCue sky-arc
