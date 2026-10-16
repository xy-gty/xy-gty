import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum FormReviewBar {
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
    public static let disclosureVersion = "workrest.consent.v1"
    public static let fields = [
        "form_photo_descriptor",
        "posture_summary",
        "interval_plan_summary",
        "current_block_label",
        "correction_focus",
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
public enum WorkrestInterfaceNames {
    public static let formReviewBar = "FormReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechIntentCapture = "SpeechIntentCapture"
    public static let handsFreeTTSPlayer = "HandsFreeTTSPlayer"
    public static let intervalChipRail = "IntervalChipRail"
    public static let restRing = "RestRing"
    public static let polaroidFormStrip = "PolaroidFormStrip"
    public static let annotatedFormEditor = "AnnotatedFormEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture mid-set form / posture for AI correction"
    public static let photoLibrary =
        "Import demo / reference poses into the coach flow"
    public static let microphone =
        "Hands-free coach dictate while both hands train"
    public static let speechRecognition =
        "e.g. skip rest / spoken interval intent → coach + TTS"
}

public enum WorkrestIdentity {
    public static let appName = "Workrest"
    public static let developmentBundleId = "com.lingguang.workrest"
    public static let productDir = "workrest"
    public static let uiLanguage = "en-US"
}

public enum WorkrestPalette {
    public static let primary = "#DC2626"
    public static let secondary = "#FEF2F2"
    public static let accent = "#22D3EE"
}
