import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum StitchReviewBar {
    public static let confirm = "Keep"
    public static let reject = "Discard"
    public static let edit = "Edit"
}

public enum TurnReview {
    public static let confirm = "Keep"
    public static let reject = "Discard"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "yarncue.consent.v1"
    public static let fields = [
        "wip_photo_descriptor",
        "recognized_stitch_summary",
        "current_row",
        "next_row_intent",
        "pattern_note_text",
        "chat_text",
        "voice_transcript",
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
public enum YarnCueInterfaceNames {
    public static let stitchReviewBar = "StitchReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechNoteCapture = "SpeechNoteCapture"
    public static let handsFreeTTSPlayer = "HandsFreeTTSPlayer"
    public static let yarnBallSwatchStrip = "YarnBallSwatchStrip"
    public static let nextRowStepBand = "NextRowStepBand"
    public static let annotatedDiagramEditor = "AnnotatedDiagramEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture yarn / WIP photos for stitch & row recognition"
    public static let photoLibrary =
        "Import prior WIP / yarn shots into the coach flow"
    public static let microphone =
        "Dictate pattern notes and row intent while knitting"
    public static let speechRecognition =
        "Turn spoken next-row questions into coach chat and TTS"
}

public enum YarnCueIdentity {
    public static let appName = "YarnCue"
    public static let developmentBundleId = "com.lingguang.yarncue"
    public static let productDir = "yarncue"
    public static let uiLanguage = "en-US"
}
