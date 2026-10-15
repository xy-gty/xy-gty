import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum FrameReviewBar {
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
    public static let disclosureVersion = "stopcue.consent.v1"
    public static let fields = [
        "frame_sequence_descriptor",
        "shot_plan_summary",
        "timing_summary",
        "onion_skin_notes",
        "current_frame_label",
        "chat_text",
        "voice_transcript",
        "dictated_interval_fields",
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
public enum StopCueInterfaceNames {
    public static let frameReviewBar = "FrameReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechIntervalCapture = "SpeechIntervalCapture"
    public static let countdownCueTTSPlayer = "CountdownCueTTSPlayer"
    public static let filmSprocketTimeline = "FilmSprocketTimeline"
    public static let onionSkinOverlayCanvas = "OnionSkinOverlayCanvas"
    public static let onionSkinGuideEditor = "OnionSkinGuideEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture frame-by-frame stop-motion sequences for AI coaching"
    public static let photoLibrary =
        "Import frame sequences into the StopCue coach timeline"
    public static let microphone =
        "Hands-free interval and cue edits while shooting"
    public static let speechRecognition =
        "Dictate interval or cue edits (e.g. next frame a bit closer) into the storyboard coach"
}

public enum StopCueIdentity {
    public static let appName = "StopCue"
    public static let developmentBundleId = "com.lingguang.stopcue"
    public static let productDir = "stopcue"
    public static let uiLanguage = "en-US"
    public static let deliveryRepo = "git@github.com:xy-gty/xy-gty.git"
    public static let deliveryBranchHint = "xy-gty"
}

public enum StopCuePalette {
    public static let primary = "#16A34A"
    public static let secondary = "#F0FDF4"
    public static let accent = "#DB2777"
}

public enum StopCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum StopCueAllergy {
    public static let bannedTwinShells = [
        "NightCue",
        "CuePartner",
        "HiveCue",
        "FormCue",
        "YarnCue",
        "ScoutCue",
    ]
    public static let requiredUI = [
        "film-sprocket timeline",
        "onion-skin overlay preview",
    ]
}
