import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum CompositionReviewBar {
    public static let confirm = "Keep"
    public static let reject = "Discard"
    public static let edit = "Edit"
}

public enum TurnReview {
    public static let confirm = "Keep"
    public static let reject = "Discard"
}

public enum OverlayEditor {
    public static let confirm = "Keep marks"
    public static let reject = "Discard"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "framecue.consent.v1"
    public static let fields = [
        "still_descriptor",
        "composition_summary",
        "shot_size_label",
        "aspect_ratio_label",
        "lens_language",
        "overlay_focus",
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
public enum FrameCueInterfaceNames {
    public static let compositionReviewBar = "CompositionReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechIntentCapture = "SpeechIntentCapture"
    public static let handsFreeTTSPlayer = "HandsFreeTTSPlayer"
    public static let clapperFrameCanvas = "ClapperFrameCanvas"
    public static let shotSizeChipBar = "ShotSizeChipBar"
    public static let overlayEditor = "OverlayEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture on-set framing trial shots for composition coaching"
    public static let photoLibrary =
        "Import scout or reference stills for aspect and framing analysis"
    public static let microphone =
        "Hands-free on-set director cues while both hands hold the camera"
    public static let speechRecognition =
        "Spoken shot-size instructions written into coach chat and refresh overlays"
}

public enum FrameCueIdentity {
    public static let appName = "FrameCue"
    public static let developmentBundleId = "com.lingguang.framecue"
    public static let productDir = "framecue"
    public static let uiLanguage = "en-US"
}

public enum FrameCuePalette {
    public static let primary = "#7E22CE"
    public static let secondary = "#FAF5FF"
    public static let accent = "#F59E0B"
}

public enum FrameCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum FrameCueAllergy {
    public static let bannedTwinShells = [
        "RuleCue",
        "StopCue",
        "NightCue",
    ]
    public static let bannedUIChrome = [
        "table zone cards",
        "turn step bar",
        "film-sprocket timeline",
        "night-frame rail",
        "full-black shell",
        "deep-gray shell",
    ]
    public static let requiredUI = [
        "clapper frame canvas",
        "bottom shot-size chip bar",
    ]
    public static let noAppIconOrLaunchScreen = true
}
