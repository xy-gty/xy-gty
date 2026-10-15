import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum HiveCueStores {
    public static let inspections = "inspections"
    public static let frameShots = "frame_shots"
    public static let broodDrafts = "brood_drafts"
    public static let findings = "findings"
    public static let annotatedOverlays = "annotated_overlays"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let voiceNotes = "voice_notes"
    public static let dictatedFields = "dictated_fields"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.hivecue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func inspectionStore(directory: URL) -> AtomicCodableStore<[Inspection]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: inspections))
    }

    public static func frameShotStore(directory: URL) -> AtomicCodableStore<[FrameShot]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: frameShots))
    }

    public static func broodDraftStore(directory: URL) -> AtomicCodableStore<[BroodDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: broodDrafts))
    }

    public static func findingStore(directory: URL) -> AtomicCodableStore<[Finding]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: findings))
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

    public static func voiceNoteStore(directory: URL) -> AtomicCodableStore<[VoiceNote]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: voiceNotes))
    }

    public static func dictatedFieldStore(directory: URL) -> AtomicCodableStore<[DictatedField]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: dictatedFields))
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
