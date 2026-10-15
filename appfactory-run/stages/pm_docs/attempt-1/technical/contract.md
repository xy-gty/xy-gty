# SporeCue — P1 technical contract

`config_mode: local_only`

## Identity

- app_name: SporeCue
- product_dir: sporecue/ (symlink sporecue → product; deliver as sporecue, not product)
- development_bundle_id: com.lingguang.sporecue
- platform: iOS 17+ SwiftUI, iPhone 17 Pro Simulator only (prefer UDID B14CC0EA); never Pro Max
- language: UI en-US; PM docs zh-CN
- idea_source: operator_external
- commerce: free_app_only this package — no StoreKit / paywall / coins / ATT. Operator “one-time unlock for unlimited ID packs” is out of scope (separate iap_att). Unlimited local ID sessions in this build.
- Do NOT generate AppIcon / LaunchScreen assets
- Do NOT name Shroomify or Pilze 123 in any App copy
- NOT MixCue / WingCue / FrameCue / RuleCue / StopCue / ClosetCue / ScoutCue twins

## Hard compliance (non-negotiable)

- Every product surface that touches ID, edibility, or foraging MUST clearly state: 「非可食认证 / not an edibility certification」
- NEVER imply a mushroom is safe to eat, “confirmed edible”, or certified for consumption
- Warning / caution / edible-look chips are informational only — not safety approval
- Chip rail labels must use informational wording (e.g. “looks edible in guides”, “warning lookalike”) and always sit under the certification disclaimer

## Scope

1. Capture or import a cap / gill / pore still → create a ForageSession
2. AI species ID with ranked candidates + confidence on a vertical species-confidence stack (出站需 consent + key)
3. Oversized gill / pore closeup bar highlighting annotated morphology callouts
4. Informational edible / warning chip rail (never edible certification)
5. Coach chat for habitat / features / lookalikes (text + speech-to-text)
6. Annotated overlay callouts on the still
7. TTS field brief of morphology / lookalike caution (not “safe to eat” advice)
8. Microphone voice notes while hands hold knife/basket
9. Persist sessions / confirmed species notes / chat / overlays locally; restart restore
10. Four real permission flows: Camera, Photos, Microphone, Speech Recognition
11. Local legal / privacy / support pages; provider policy reachable
12. Honest offline / unconfigured AI states

Out of scope: IAP unlock, coin catalog, ATT, AppIcon/LaunchScreen, MixCue/WingCue/FrameCue/RuleCue/StopCue/ClosetCue/ScoutCue UI twins, Pro Max simulator, competitor names in App copy, any edibility certification claim.

## Domain entities

| Entity | Key fields | Persistence |
|--------|------------|-------------|
| ForageSession | id, createdAt, photoLocalURL, source(camera\|photos), subject(cap\|gill\|pore), status(draft\|identified\|confirmed), disclaimerAck | AtomicCodableStore |
| SpeciesCandidate | sessionId, displayName, scientificName?, confidence, rank, morphologyCues[] | nested / store |
| MorphologyCallout | sessionId, region(gill\|pore\|cap\|stem), label, normalizedRect, note | nested |
| CautionChip | sessionId, kind(info_edible_look\|warning_lookalike\|toxic_lookalike\|unknown), title, informationalOnly=true | nested |
| OverlayAnnotation | sessionId, callouts[], imageLocalURL | nested |
| CoachTurn | sessionId, role(user\|coach), text, sttSource?, createdAt | store |
| FieldBrief | sessionId, scriptText, spokenAt?, ttsLocale | nested |
| VoiceNote | sessionId?, localAudioURL, transcript?, createdAt | store + file |
| AIConsentRecord | provider, disclosureVersion, grantedAt, revokedAt? | AIConsentGate |
| AppSettings | ttsEnabled, speechInputEnabled, consentRevoked, alwaysShowEdibilityDisclaimer | store |

## Interfaces

| Interface | Responsibility |
|-----------|----------------|
| ForageStore | CRUD ForageSession + related; AtomicCodableStore\<SporeCueState\> |
| PhotoCaptureService | Camera stills of cap / gill / pore → save |
| PhotoLibraryImporter | Photos picker → decode → atomic save via PhotoImportSession |
| SpeciesIDClient | Still + prior confirmed notes → DeepSeek; returns ranked species + morphology cues + informational chips (never safe-to-eat verdict) |
| CoachChatClient | Habitat / feature / lookalike Q&A with session context + feedback reuse |
| OverlayAnnotator | Map morphology cues → annotated overlay callouts |
| ChipRailBuilder | Build edible/warning informational chip rail under disclaimer |
| TTSFieldBrief | Speak field brief (AVSpeechSynthesizer); script must include disclaimer |
| VoiceNoteRecorder | Mic record while hands busy → file |
| SpeechQuestionIngress | SFSpeechRecognizer → CoachTurn (e.g. “how does this differ from death cap”) |
| ConsentGate | Shared AIConsentGate before any outbound send; Settings revoke |
| KeychainCredentialStore | Read DEEPSEEK_API_KEY presence; service sporecue.ai |
| TypedNavigationStore\<Route\> | Route enum restore |

Review controls:
- confirm: Save Find / Keep / Use
- reject: Dismiss / Reject
- edit: Edit callouts

## Navigation (Route)

```
.rootTab
  .fieldHome           // vertical species-confidence stack + oversized gill/pore bar + chip rail
  .cameraCapture       // live camera for cap / gill / pore
  .photoImport         // Photos picker bridge
  .idResult(sessionId) // ranked stack + closeup bar + chips + disclaimer
  .lookalikeChat(sessionId)
  .overlayAnnotate(sessionId)
  .fieldBrief(sessionId) // TTS brief
  .voiceNote(sessionId?)
  .aiConsent
  .settings
  .legal(page)         // privacy | terms | support | providerPolicy
```

First-use: Field Home empty → Capture/Import → (consent if outbound) → ID Result (disclaimer visible) → Lookalike chat → Overlay / TTS brief. Skip allowed; no fake species; never imply safe to eat.

## Storage / AI / permissions

- Storage: app support JSON via AtomicCodableStore; photos/audio under Application Support/SporeCue/; Keychain for credential presence
- AI provider: DeepSeek (vision + chat). Outbound disabled until key or authorized config. Disclose provider + fields before first send.
- Send fields: cap/gill/pore still (local file ref), user question text, prior confirmed species notes / feedback, active session id, optional voice transcript
- privacy_url: UNKNOWN
- terms_url: UNKNOWN
- support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN

Permissions (real flows, extend core foraging ID coach):
1. Camera — field capture of cap / gill / pore close-ups for ID
2. Photos — import hike album stills to complete ID
3. Microphone — hands-free field notes while holding knife/basket
4. Speech Recognition — spoken lookalike / habitat questions into coach chat

## UI species & palette

- UI: 纵向物种置信栈 + 超大菌褶/管孔特写条 + 可食/警示 chip 轨
- primary `#9A3412` · secondary `#FFF7ED` · accent `#0284C7`
- Must differ from MixCue bottle-rail, WingCue field-card stack, ClosetCue mosaic, FrameCue safe-frame/clapper, ScoutCue sky-arc, RuleCue table zone, StopCue film-sprocket

## Delivery notes

- Feishu CONTROLLER_DELIVERY skip
- Deliver `git@github.com:xy-gty/xy-gty.git` independent branch (Builder/Delivery)
- Option A soft known_issues for non-core UL fails; P1 UNKNOWN gaps must not block delivery
