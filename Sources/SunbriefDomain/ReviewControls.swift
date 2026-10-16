import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum SceneReviewBar {
    public static let confirm = "Keep"
    public static let reject = "Discard"
    public static let edit = "Edit labels"
}

public enum TurnReview {
    public static let confirm = "Keep"
    public static let reject = "Discard"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "sunbrief.consent.v1"
    public static let fields = [
        "scene_labels",
        "shot_meta",
        "plan_windows",
        "user_chat_text",
        "voice_transcript",
        "overlay_notes",
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
public enum SunbriefInterfaceNames {
    public static let sceneReviewBar = "SceneReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let overlayEditor = "OverlayEditor"
    public static let briefingPlayer = "BriefingPlayer"
    public static let speechNoteCapture = "SpeechNoteCapture"
    public static let skyArcTimeline = "SkyArcTimeline"
    public static let softCardStack = "SoftCardStack"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "On-site composition capture + scene recognition for scouting"
    public static let photoLibrary =
        "Import prior scouting shots; recompute best shoot windows"
    public static let microphone =
        "Dictate shoot notes and intent into the scout plan"
    public static let speechRecognition =
        "Turn spoken intent such as golden-hour ridge timing into a timed plan and coach chat"
}

public enum SunbriefIdentity {
    public static let appName = "Sunbrief"
    public static let developmentBundleId = "com.lingguang.sunbrief"
    public static let productDir = "sunbrief"
    public static let uiLanguage = "en-US"
}
