import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum MatteboxStores {
    public static let framingSessions = "framing_sessions"
    public static let frameStills = "frame_stills"
    public static let compositionDrafts = "composition_drafts"
    public static let compositionNotes = "composition_notes"
    public static let shotSizePlans = "shot_size_plans"
    public static let aspectOverlays = "aspect_overlays"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let voiceIntents = "voice_intents"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.mattebox"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func framingSessionStore(directory: URL) -> AtomicCodableStore<[FramingSession]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: framingSessions))
    }

    public static func frameStillStore(directory: URL) -> AtomicCodableStore<[FrameStill]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: frameStills))
    }

    public static func compositionDraftStore(directory: URL) -> AtomicCodableStore<[CompositionDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: compositionDrafts))
    }

    public static func compositionNoteStore(directory: URL) -> AtomicCodableStore<[CompositionNote]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: compositionNotes))
    }

    public static func shotSizePlanStore(directory: URL) -> AtomicCodableStore<[ShotSizePlan]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: shotSizePlans))
    }

    public static func aspectOverlayStore(directory: URL) -> AtomicCodableStore<[AspectOverlay]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: aspectOverlays))
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
