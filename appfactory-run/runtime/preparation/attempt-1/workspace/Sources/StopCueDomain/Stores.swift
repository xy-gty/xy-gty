import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum StopCueStores {
    public static let projects = "projects"
    public static let frameSequences = "frame_sequences"
    public static let shotPlanDrafts = "shot_plan_drafts"
    public static let timingCues = "timing_cues"
    public static let onionSkinGuides = "onion_skin_guides"
    public static let coachTurns = "coach_turns"
    public static let coachMessages = "coach_messages"
    public static let countdownCues = "countdown_cues"
    public static let dictatedIntervals = "dictated_intervals"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.stopcue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func projectStore(directory: URL) -> AtomicCodableStore<[Project]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: projects))
    }

    public static func frameSequenceStore(directory: URL) -> AtomicCodableStore<[FrameSequence]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: frameSequences))
    }

    public static func shotPlanDraftStore(directory: URL) -> AtomicCodableStore<[ShotPlanDraft]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: shotPlanDrafts))
    }

    public static func timingCueStore(directory: URL) -> AtomicCodableStore<[TimingCue]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: timingCues))
    }

    public static func onionSkinGuideStore(directory: URL) -> AtomicCodableStore<[OnionSkinGuide]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: onionSkinGuides))
    }

    public static func coachTurnStore(directory: URL) -> AtomicCodableStore<[CoachTurn]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachTurns))
    }

    public static func coachMessageStore(directory: URL) -> AtomicCodableStore<[CoachMessage]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachMessages))
    }

    public static func countdownCueStore(directory: URL) -> AtomicCodableStore<[CountdownCue]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: countdownCues))
    }

    public static func dictatedIntervalStore(directory: URL) -> AtomicCodableStore<[DictatedInterval]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: dictatedIntervals))
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
