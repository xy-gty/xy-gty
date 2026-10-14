import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum ScoutCueStores {
    public static let scoutShots = "scout_shots"
    public static let sceneCards = "scene_cards"
    public static let scoutPlans = "scout_plans"
    public static let timingWindows = "timing_windows"
    public static let overlayMarks = "overlay_marks"
    public static let coachMessages = "coach_messages"
    public static let coachTurns = "coach_turns"
    public static let shootNotes = "shoot_notes"
    public static let briefingClips = "briefing_clips"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.scoutcue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func scoutShotStore(directory: URL) -> AtomicCodableStore<[ScoutShot]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: scoutShots))
    }

    public static func sceneCardStore(directory: URL) -> AtomicCodableStore<[SceneCard]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: sceneCards))
    }

    public static func scoutPlanStore(directory: URL) -> AtomicCodableStore<[ScoutPlan]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: scoutPlans))
    }

    public static func timingWindowStore(directory: URL) -> AtomicCodableStore<[TimingWindow]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: timingWindows))
    }

    public static func overlayMarkStore(directory: URL) -> AtomicCodableStore<[OverlayMark]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: overlayMarks))
    }

    public static func coachMessageStore(directory: URL) -> AtomicCodableStore<[CoachMessage]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachMessages))
    }

    public static func coachTurnStore(directory: URL) -> AtomicCodableStore<[CoachTurn]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: coachTurns))
    }

    public static func shootNoteStore(directory: URL) -> AtomicCodableStore<[ShootNote]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: shootNotes))
    }

    public static func briefingClipStore(directory: URL) -> AtomicCodableStore<[BriefingClip]> {
        AtomicCodableStore(url: storeURL(directory: directory, name: briefingClips))
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
