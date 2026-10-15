import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum BroodReviewBar {
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
    public static let disclosureVersion = "hivecue.consent.v1"
    public static let fields = [
        "frame_photo_descriptor",
        "brood_summary",
        "stores_summary",
        "pest_signs",
        "inspection_plan_summary",
        "current_frame_label",
        "chat_text",
        "voice_transcript",
        "dictated_fields",
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
public enum HiveCueInterfaceNames {
    public static let broodReviewBar = "BroodReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechFieldCapture = "SpeechFieldCapture"
    public static let handsFreeTTSPlayer = "HandsFreeTTSPlayer"
    public static let hexCombGrid = "HexCombGrid"
    public static let inspectionRail = "InspectionRail"
    public static let heatOverlayCanvas = "HeatOverlayCanvas"
    public static let annotatedFrameEditor = "AnnotatedFrameEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture brood-frame photos for AI hive inspection"
    public static let photoLibrary =
        "Import past frame photos to compare brood / stores / pests"
    public static let microphone =
        "Hands-free inspection notes while suited and gloved"
    public static let speechRecognition =
        "Dictate inspection fields (queen seen, temperament, notes) into the log"
}

public enum HiveCueIdentity {
    public static let appName = "HiveCue"
    public static let developmentBundleId = "com.lingguang.hivecue"
    public static let productDir = "hivecue"
    public static let uiLanguage = "en-US"
    public static let deliveryBranchHint = "xy-gty"
}

public enum HiveCuePalette {
    public static let primary = "#9F1239"
    public static let secondary = "#FDF2F8"
    public static let accent = "#4D7C0F"
}

public enum HiveCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}
