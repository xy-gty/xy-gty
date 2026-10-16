import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum CountroomStores {
    public static let practiceSessions = "practice_sessions"
    public static let sheetPhotos = "sheet_photos"
    public static let practicePlans = "practice_plans"
    public static let coachTurns = "coach_turns"
    public static let audioBeds = "audio_beds"
    public static let pitchSamples = "pitch_samples"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.countroom"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func practiceSessionStore(directory: URL) -> AtomicCodableStore<[PracticeSession]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: practiceSessions))
    }

    public static func sheetPhotoStore(directory: URL) -> AtomicCodableStore<[SheetPhoto]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: sheetPhotos))
    }

    public static func practicePlanStore(directory: URL) -> AtomicCodableStore<[PracticePlan]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: practicePlans))
    }

    public static func coachTurnStore(directory: URL) -> AtomicCodableStore<[CoachTurn]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachTurns))
    }

    public static func audioBedStore(directory: URL) -> AtomicCodableStore<[AudioBed]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: audioBeds))
    }

    public static func pitchSampleStore(directory: URL) -> AtomicCodableStore<[PitchSample]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: pitchSamples))
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
