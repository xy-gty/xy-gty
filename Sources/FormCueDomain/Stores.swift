import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum FormCueStores {
    public static let sessions = "sessions"
    public static let formShots = "form_shots"
    public static let formCueDrafts = "form_cue_drafts"
    public static let formCorrections = "form_corrections"
    public static let intervalBlocks = "interval_blocks"
    public static let annotatedOverlays = "annotated_overlays"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let voiceIntents = "voice_intents"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.formcue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func sessionStore(directory: URL) -> AtomicCodableStore<[Session]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: sessions))
    }

    public static func formShotStore(directory: URL) -> AtomicCodableStore<[FormShot]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: formShots))
    }

    public static func formCueDraftStore(directory: URL) -> AtomicCodableStore<[FormCueDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: formCueDrafts))
    }

    public static func formCorrectionStore(directory: URL) -> AtomicCodableStore<[FormCorrection]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: formCorrections))
    }

    public static func intervalBlockStore(directory: URL) -> AtomicCodableStore<[IntervalBlock]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: intervalBlocks))
    }

    public static func annotatedOverlayStore(directory: URL) -> AtomicCodableStore<[AnnotatedOverlay]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: annotatedOverlays))
    }

    public static func coachTurnStore(directory: URL) -> AtomicCodableStore<[CoachTurn]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachTurns))
    }

    public static func coachMessageStore(directory: URL) -> AtomicCodableStore<[CoachMessage]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachMessages))
    }

    public static func voiceIntentStore(directory: URL) -> AtomicCodableStore<[VoiceIntent]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: voiceIntents))
    }

    public static func aiConsentLocalStore(directory: URL) -> AtomicCodableStore<AIConsentRecord> {
        AtomicCodableStore(url: storeURL(directory: directory, name: aiConsentLocal))
    }

    public static func apiKeyStore() -> KeychainCredentialStore {
        KeychainCredentialStore(service: keychainService, account: keychainAPIKeyAccount)
    }

    public static func consentKeychainStore() -> KeychainCredentialStore {
        KeychainCredentialStore(service: keychainService, account: keychainConsentAccount)
    }
}
