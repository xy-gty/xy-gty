import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum TablehostStores {
    public static let gameSessions = "game_sessions"
    public static let tablePhotos = "table_photos"
    public static let componentDrafts = "component_drafts"
    public static let componentMaps = "component_maps"
    public static let phaseSteps = "phase_steps"
    public static let setupOverlays = "setup_overlays"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let hostCues = "host_cues"
    public static let spokenQuestions = "spoken_questions"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.tablehost"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func gameSessionStore(directory: URL) -> AtomicCodableStore<[GameSession]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: gameSessions))
    }

    public static func tablePhotoStore(directory: URL) -> AtomicCodableStore<[TablePhoto]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: tablePhotos))
    }

    public static func componentDraftStore(directory: URL) -> AtomicCodableStore<[ComponentDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: componentDrafts))
    }

    public static func componentMapStore(directory: URL) -> AtomicCodableStore<[ComponentMap]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: componentMaps))
    }

    public static func phaseStepStore(directory: URL) -> AtomicCodableStore<[PhaseStep]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: phaseSteps))
    }

    public static func setupOverlayStore(directory: URL) -> AtomicCodableStore<[SetupOverlay]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: setupOverlays))
    }

    public static func coachTurnStore(directory: URL) -> AtomicCodableStore<[CoachTurn]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachTurns))
    }

    public static func coachMessageStore(directory: URL) -> AtomicCodableStore<[CoachMessage]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachMessages))
    }

    public static func hostCueStore(directory: URL) -> AtomicCodableStore<[HostCue]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: hostCues))
    }

    public static func spokenQuestionStore(directory: URL) -> AtomicCodableStore<[SpokenQuestion]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: spokenQuestions))
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
