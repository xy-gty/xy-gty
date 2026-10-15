# MixCue — P1 technical contract

`config_mode: local_only`

## Identity

- app_name: MixCue
- product_dir: mixcue/ (symlink mixcue → product)
- development_bundle_id: com.lingguang.mixcue
- platform: iOS 17+ SwiftUI, iPhone 17 Pro Simulator only (prefer UDID B14CC0EA); never Pro Max
- language: UI en-US; PM docs zh-CN
- idea_source: operator_external
- commerce: free_app_only this package — no StoreKit / paywall / coins / ATT. Operator “one-time unlock for unlimited mix packs” is out of scope (separate iap_att). Unlimited local mix sessions in this build.
- Do NOT generate AppIcon / LaunchScreen assets
- Do NOT name Cocktail Party or Bevnap in any App copy

## Scope

1. Capture or import a bottle / label / garnish still → create a MixSession
2. AI base-spirit ID with ranked candidates + label cues (出站需 consent + key)
3. Coach chat for recipes and substitutes (text + speech-to-text)
4. Pour method board: large next-pour card + garnish chip row
5. TTS hands-free shake / stir step guidance
6. Microphone voice notes while both hands shake or stir
7. Persist mixes / confirmed spirits / chat / pour boards locally; restart restore
8. Four real permission flows: Camera, Photos, Microphone, Speech Recognition
9. Local legal / privacy / support pages; provider policy reachable
10. Honest offline / unconfigured AI states

Out of scope: IAP unlock, coin catalog, ATT, AppIcon/LaunchScreen, WingCue/FrameCue/RuleCue/StopCue/ClosetCue/ScoutCue UI twins, Pro Max simulator, competitor names in App copy.

## Domain entities

| Entity | Key fields | Persistence |
|--------|------------|-------------|
| MixSession | id, createdAt, photoLocalURL, source(camera\|photos), subject(bottle\|label\|garnish), status(draft\|identified\|confirmed) | AtomicCodableStore |
| SpiritCandidate | sessionId, displayName, baseSpirit, confidence, rank, labelCues[] | nested in session / store |
| PourStep | sessionId, recipeId, ordinal, action(pour\|shake\|stir\|strain\|garnish), amountMl?, durationSec?, instruction | nested |
| GarnishChip | sessionId, recipeId, name, placed, accentColor | nested |
| RecipeCard | sessionId, title, baseSpirit, steps[], garnishChips[], substituteNotes | nested |
| CoachTurn | sessionId, role(user\|coach), text, sttSource?, createdAt | store |
| VoiceNote | sessionId?, localAudioURL, transcript?, createdAt | store + file |
| AIConsentRecord | provider, disclosureVersion, grantedAt, revokedAt? | AIConsentGate / Keychain-adjacent |
| AppSettings | ttsEnabled, speechInputEnabled, consentRevoked | store |

## Interfaces

| Interface | Responsibility |
|-----------|----------------|
| MixStore | CRUD MixSession + related; AtomicCodableStore\<MixCueState\> |
| PhotoCaptureService | Camera stills of bottle face / label / garnish → save |
| PhotoLibraryImporter | Photos picker → decode → atomic save via PhotoImportSession |
| SpiritIDClient | Build context from still + prior confirmed spirits → DeepSeek vision/text; returns structured candidates + label cues |
| CoachChatClient | Recipe / substitute Q&A with session context + confirmed feedback on second call |
| PourBoardBuilder | Map recipe → large next-pour card + garnish chip row; advance ordinal |
| TTSPlayer | Speak pour / shake / stir instruction strings (AVSpeechSynthesizer) |
| VoiceNoteRecorder | Mic record while hands busy → file; optional on-device transcript hook |
| SpeechQuestionIngress | SFSpeechRecognizer → CoachTurn user text (e.g. “what can I sub for Cointreau”) |
| ConsentGate | Shared AIConsentGate before any outbound send; Settings revoke |
| KeychainCredentialStore | Read DEEPSEEK_API_KEY presence only via Secrets.xcconfig / Keychain service mixcue.ai |
| TypedNavigationStore\<Route\> | Route enum restore |

Review controls:
- confirm: Save Mix / Keep / Use
- reject: Dismiss / Reject
- edit: Edit pour steps

## Navigation (Route)

```
.rootTab
  .barHome            // vertical bottle-rail + large next-pour card + garnish chip row
  .cameraCapture      // live camera for bottle / label / garnish
  .photoImport        // Photos picker bridge
  .idResult(sessionId)// spirit candidates on bottle-rail context
  .recipeChat(sessionId)
  .pourBoard(sessionId)// next-pour card + garnish chips + TTS step
  .voiceNote(sessionId?)
  .aiConsent          // first outbound
  .settings           // permissions, revoke AI, local legal links
  .legal(page)        // privacy | terms | support | providerPolicy
```

First-use: Bar Home empty → Capture/Import → (consent if outbound) → ID Result → Recipe chat → Pour board / TTS. Skip allowed; no fake results.

## Storage / AI / permissions

- Storage: app support directory JSON via AtomicCodableStore; photos/audio under Application Support/MixCue/; Keychain for credential presence
- AI provider: DeepSeek (vision + chat). Outbound disabled until key or authorized config. Disclose provider + fields before first send.
- Send fields: bottle/label/garnish still (local file ref), user question text, prior confirmed spirits/substitutes, active recipe id, optional voice transcript
- privacy_url: UNKNOWN
- terms_url: UNKNOWN
- support_url: UNKNOWN
- ai_key: UNKNOWN
- cloudkit: UNKNOWN

Permissions (real flows, extend core cocktail coach):
1. Camera — capture bottle face / label / garnish for ID
2. Photos — import bar-shelf album stills to complete ID
3. Microphone — hands-free notes while both hands shake/stir
4. Speech Recognition — spoken substitute/recipe questions into coach chat

## UI species (hard)

- Palette primary #E11D48 · secondary #FFF1F2 · accent #CA8A04
- Signature: 竖向瓶架轨 + 大号下一步倒法卡 + 装饰 chip 行
- Ban twins of WingCue field-card stack, ClosetCue mosaic, FrameCue safe-frame/clapper, ScoutCue sky-arc, RuleCue table-zone/turn-step, StopCue film-sprocket; ban all-black/dark-gray clones
- Ban competitor names Cocktail Party / Bevnap in App UI copy

## Foundation binding

Consume AppRuntimeCore 1.0.0: AIConsentGate, AtomicCodableStore, KeychainCredentialStore, PhotoImportSession, RuntimeForm, TypedNavigationStore.
