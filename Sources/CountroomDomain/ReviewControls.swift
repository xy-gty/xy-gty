import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum CoachingReviewBar {
    public static let confirm = "Keep"
    public static let reject = "Discard"
    public static let edit = "Edit"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "countroom.consent.v1"
    public static let fields = [
        "sheet_photo_desc",
        "instrument_label",
        "user_goal",
        "speech_transcript",
        "prior_plan_steps",
        "coach_question",
        "user_feedback",
    ]

    @MainActor
    public static func makeGate(
        load: @escaping () throws -> AIConsentGate.State?,
        persist: @escaping (AIConsentGate.State) throws -> Void
    ) -> AIConsentGate {
        AIConsentGate(
            provider: provider,
            disclosureVersion: disclosureVersion,
            load: load,
            persist: persist
        )
    }
}

/// Interface name literals for deferred Builder wiring (no UI).
public enum CountroomInterfaceNames {
    public static let coachingReviewBar = "CoachingReviewBar"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let coachChatForm = "CoachChatForm"
    public static let speechGoalCapture = "SpeechGoalCapture"
    public static let ttsCoach = "TTSCoach"
    public static let audioBedEngine = "AudioBedEngine"
    public static let tunerDial = "TunerDial"
    public static let practiceStrip = "PracticeStrip"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture sheet music or fingering photos so Countroom can coach your practice"
    public static let photoLibrary =
        "Import existing exercise or sheet photos for practice coaching"
    public static let microphone =
        "Listen for pitch and rhythm feedback from your instrument mic"
    public static let speechRecognition =
        "Turn spoken practice goals into text for the AI practice coach"
}

public enum CountroomIdentity {
    public static let appName = "Countroom"
    public static let developmentBundleId = "com.lingguang.countroom"
    public static let productDir = "countroom"
    public static let uiLanguage = "en-US"
}
