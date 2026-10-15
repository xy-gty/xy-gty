import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum NightCueStores {
    public static let sessions = "sessions"
    public static let nightFrames = "night_frames"
    public static let exposureDrafts = "exposure_drafts"
    public static let diagnosisFindings = "diagnosis_findings"
    public static let annotatedOverlays = "annotated_overlays"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let fieldCues = "field_cues"
    public static let dictatedExposures = "dictated_exposures"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.nightcue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func sessionStore(directory: URL) -> AtomicCodableStore<[Session]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: sessions))
    }

    public static func nightFrameStore(directory: URL) -> AtomicCodableStore<[NightFrame]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: nightFrames))
    }

    public static func exposureDraftStore(directory: URL) -> AtomicCodableStore<[ExposureDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: exposureDrafts))
    }

    public static func diagnosisFindingStore(directory: URL) -> AtomicCodableStore<[DiagnosisFinding]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: diagnosisFindings))
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

    public static func fieldCueStore(directory: URL) -> AtomicCodableStore<[FieldCue]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: fieldCues))
    }

    public static func dictatedExposureStore(directory: URL) -> AtomicCodableStore<[DictatedExposure]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: dictatedExposures))
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
