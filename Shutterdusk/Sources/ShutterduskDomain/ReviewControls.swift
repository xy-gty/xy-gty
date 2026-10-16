import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum ExposureReviewBar {
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
    public static let disclosureVersion = "shutterdusk.consent.v1"
    public static let fields = [
        "frame_photo_descriptor",
        "exposure_summary",
        "noise_summary",
        "trail_signs",
        "scene_plan_summary",
        "current_frame_label",
        "chat_text",
        "voice_transcript",
        "dictated_exposure_fields",
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
public enum ShutterduskInterfaceNames {
    public static let exposureReviewBar = "ExposureReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechExposureCapture = "SpeechExposureCapture"
    public static let fieldCueTTSPlayer = "FieldCueTTSPlayer"
    public static let nightFrameRail = "NightFrameRail"
    public static let exposureDiagnosisOverlayCanvas = "ExposureDiagnosisOverlayCanvas"
    public static let annotatedOverlayEditor = "AnnotatedOverlayEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture night test frames for AI long-exposure coaching"
    public static let photoLibrary =
        "Import past night frames to compare exposure and noise"
    public static let microphone =
        "Hands-free parameter Q&A while holding a tripod"
    public static let speechRecognition =
        "Dictate exposure settings (ISO, shutter, aperture, notes) into the coach"
}

public enum ShutterduskIdentity {
    public static let appName = "Shutterdusk"
    public static let developmentBundleId = "com.lingguang.shutterdusk"
    public static let productDir = "shutterdusk"
    public static let uiLanguage = "en-US"
    public static let deliveryRepo = "git@github.com:xy-gty/xy-gty.git"
    public static let deliveryBranchHint = "xy-gty"
}

public enum ShutterduskPalette {
    public static let primary = "#1E3A8A"
    public static let secondary = "#EFF6FF"
    public static let accent = "#FBBF24"
}

public enum ShutterduskDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum ShutterduskAllergy {
    public static let bannedTwinShells = [
        "Broodcheck",
        "Workrest",
        "Loopwell",
        "Sunbrief",
    ]
    public static let requiredUI = [
        "night-frame rail",
        "exposure-diagnosis overlays",
    ]
}
