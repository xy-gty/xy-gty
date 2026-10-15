import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum YarnCueStores {
    public static let projects = "projects"
    public static let wipShots = "wip_shots"
    public static let stitchRecognitionDrafts = "stitch_recognition_drafts"
    public static let stitchCues = "stitch_cues"
    public static let annotatedOverlays = "annotated_overlays"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let patternNotes = "pattern_notes"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.yarncue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func projectStore(directory: URL) -> AtomicCodableStore<[Project]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: projects))
    }

    public static func wipShotStore(directory: URL) -> AtomicCodableStore<[WIPShot]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: wipShots))
    }

    public static func stitchRecognitionDraftStore(directory: URL) -> AtomicCodableStore<[StitchRecognitionDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: stitchRecognitionDrafts))
    }

    public static func stitchCueStore(directory: URL) -> AtomicCodableStore<[StitchCue]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: stitchCues))
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

    public static func patternNoteStore(directory: URL) -> AtomicCodableStore<[PatternNote]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: patternNotes))
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
