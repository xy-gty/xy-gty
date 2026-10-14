import Foundation

/// Review affordances and AI consent literals from technical contract.
public enum OCRReviewBar {
    public static let confirm = "Keep"
    public static let reject = "Discard"
    public static let edit = "Edit text"
}

public enum TurnReview {
    public static let confirm = "Keep"
    public static let reject = "Discard"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "cuepartner.consent.v1"
    public static let fields = [
        "script_page_ocr_text",
        "cue_lines",
        "partner_role",
        "user_line_text",
        "voice_transcript",
        "chat_text",
    ]
}

/// Interface name literals for deferred Builder wiring (no UI).
public enum CuePartnerInterfaceNames {
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechLineCapture = "SpeechLineCapture"
    public static let cueTTSPlayer = "CueTTSPlayer"
    public static let ambiencePlayer = "AmbiencePlayer"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture handwritten or printed script draft pages for OCR"
    public static let photoLibrary =
        "Import script photos so CuePartner can OCR your own pages"
    public static let microphone =
        "Record rehearsal or line voice notes for practice"
    public static let speechRecognition =
        "Turn spoken lines into text for the AI scene partner"
}
