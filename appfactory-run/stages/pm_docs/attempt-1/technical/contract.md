# WingCue — P1 technical contract

`config_mode: local_only`

## Identity

- app_name: WingCue
- product_dir: wingcue/ (symlink wingcue → product)
- development_bundle_id: com.lingguang.wingcue
- platform: iOS 17+ SwiftUI, iPhone 17 Pro Simulator only (prefer UDID B14CC0EA); never Pro Max
- language: UI en-US; PM docs zh-CN
- idea_source: operator_external
- commerce: free_app_only this package — no StoreKit / paywall / coins / ATT. Operator “one-time unlock” is out of scope (separate iap_att). Unlimited local ID packs in this build.
- Do NOT generate AppIcon / LaunchScreen assets

## Scope

1. Capture or import a bird still → create an ID session
2. AI species ID with ranked candidates + field marks (出站需 consent + key)
3. Coach chat to clarify lookalikes (text + speech-to-text)
4. Generate annotated overlay callouts on the photo
5. TTS read species name / ID tips
6. Hands-free voice notes via microphone while holding binoculars
7. Persist sightings / confirmed IDs / chat / overlays locally; restart restore
8. Four real permission flows: Camera, Photos, Microphone, Speech Recognition
9. Local legal / privacy / support pages; provider policy reachable
10. Honest offline / unconfigured AI states

Out of scope: IAP unlock, coin catalog, ATT, AppIcon/LaunchScreen, ClosetCue/FrameCue/ScoutCue/RuleCue/StopCue UI twins, Pro Max simulator.

## Domain entities

| Entity | Key fields | Persistence |
|--------|------------|-------------|
| IDSession | id, createdAt, photoLocalURL, source(camera\|photos), status(draft\|identified\|confirmed) | AtomicCodableStore |
| SpeciesCandidate | sessionId, scientificName, commonName, confidence, rank, silhouetteKey | nested in session / store |
| FieldMark | candidateId, label, bodyRegion, salience(0–1), chipEmphasis | nested |
| LookalikePair | sessionId, leftCandidateId, rightCandidateId, contrastNotes | nested |
| CoachTurn | sessionId, role(user\|coach), text, sttSource?, createdAt | store |
| AnnotatedOverlay | sessionId, photoLocalURL, callouts[{markId,x,y,label}], createdAt | store + file |
| VoiceNote | sessionId?, localAudioURL, transcript?, createdAt | store + file |
| AIConsentRecord | provider, disclosureVersion, grantedAt, revokedAt? | AIConsentGate / Keychain-adjacent |
| AppSettings | ttsEnabled, speechInputEnabled, consentRevoked | store |

## Interfaces

| Interface | Responsibility |
|-----------|----------------|
| SightingStore | CRUD IDSession + related; AtomicCodableStore\<WingCueState\> |
| PhotoCaptureService | Camera stills → PhotoImportSession-compatible save |
| PhotoLibraryImporter | Photos picker → decode → atomic save |
| SpeciesIDClient | Build context from session photo + prior confirmed marks → DeepSeek vision/text; returns structured candidates + field marks |
| CoachChatClient | Lookalike Q&A with session context + confirmed feedback on second call |
| OverlayAnnotator | Map field marks → callout geometry on photo; persist AnnotatedOverlay |
| TTSPlayer | Speak species name / tip strings (AVSpeechSynthesizer) |
| VoiceNoteRecorder | Mic record → file; optional on-device transcript hook |
| SpeechQuestionIngress | SFSpeechRecognizer → CoachTurn user text |
| ConsentGate | Shared AIConsentGate before any outbound send; Settings revoke |
| KeychainCredentialStore | Read DEEPSEEK_API_KEY presence only via Secrets.xcconfig / Keychain service wingcue.ai |
| TypedNavigationStore\<Route\> | Route enum restore |

Review controls:
- confirm: Save ID
- reject: Dismiss
- edit: Edit marks

## Navigation (Route)

```
.rootTab
  .fieldHome          // stacked field-cards + capture CTAs + coach input bar
  .cameraCapture      // live camera for plumage close-up
  .photoImport        // Photos picker bridge
  .idResult(sessionId)// field-card stack + oversized mark chips + silhouette compare bar
  .lookalikeChat(sessionId)
  .overlayStudio(sessionId)
  .voiceNote(sessionId?)
  .aiConsent          // first outbound
  .settings           // permissions, revoke AI, local legal links
  .legal(page)        // privacy | terms | support | providerPolicy
```

First-use: Field Home empty → Capture/Import → (consent if outbound) → ID Result → optional chat / overlay / TTS. Skip allowed; no fake results.

## Storage / AI / permissions

- Storage: app support directory JSON via AtomicCodableStore; photos/audio under Application Support/WingCue/; Keychain for credential presence
- AI provider: DeepSeek (vision + chat). Outbound disabled until key or authorized config. Disclose provider + fields before first send.
- Send fields: cropped/full bird still (local file ref), user question text, prior confirmed species/marks, lookalike pair ids, optional voice transcript
- privacy_url: UNKNOWN
- terms_url: UNKNOWN
- support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN

Permissions (real flows, extend core):
1. Camera — field capture of body/plumage
2. Photos — import trip album stills
3. Microphone — hands-free notes / optional call recording
4. Speech Recognition — spoken coach questions

## UI species (hard)

- Palette primary #0F766E · secondary #F0FDFA · accent #C2410C
- Signature: 物种 field-card 叠层 + 超大鉴别特征 chips + 剪影对比条
- Ban twins of ClosetCue mosaic, FrameCue safe-frame/clapper, ScoutCue sky-arc, RuleCue table-zone/turn-step, StopCue film-sprocket; ban all-black/dark-gray clones

## Foundation binding

Consume AppRuntimeCore 1.0.0: AIConsentGate, AtomicCodableStore, KeychainCredentialStore, PhotoImportSession, RuntimeForm, TypedNavigationStore.
