import Foundation
import AppRuntimeCore

/// Review affordances and AI consent literals from technical contract.
public enum ComponentReviewBar {
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
    public static let disclosureVersion = "rulecue.consent.v1"
    public static let fields = [
        "game_session_summary",
        "component_map_summary",
        "phase_steps_summary",
        "setup_overlay_notes",
        "current_zone_label",
        "chat_text",
        "voice_transcript",
        "spoken_question",
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
public enum RuleCueInterfaceNames {
    public static let componentReviewBar = "ComponentReviewBar"
    public static let turnReview = "TurnReview"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let speechRulesCapture = "SpeechRulesCapture"
    public static let hostCueTTSPlayer = "HostCueTTSPlayer"
    public static let tableZoneCards = "TableZoneCards"
    public static let turnStepBar = "TurnStepBar"
    public static let setupOverlayEditor = "SetupOverlayEditor"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture rulebook pages, component close-ups, and current table layout for AI setup coaching"
    public static let photoLibrary =
        "Import rulebook page images or past table photos to compare setups"
    public static let microphone =
        "Hands-free rules questions while setting up the table"
    public static let speechRecognition =
        "Write spoken rules questions into the coach chat and trigger the next tip"
}

public enum RuleCueIdentity {
    public static let appName = "RuleCue"
    public static let developmentBundleId = "com.lingguang.rulecue"
    public static let productDir = "rulecue"
    public static let uiLanguage = "en-US"
    public static let deliveryRepo = "git@github.com:xy-gty/xy-gty.git"
    public static let deliveryBranchHint = "xy-gty"
}

public enum RuleCuePalette {
    public static let primary = "#854D0E"
    public static let secondary = "#FEFCE8"
    public static let accent = "#0891B2"
}

public enum RuleCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum RuleCueAllergy {
    public static let bannedTwinShells = [
        "StopCue",
        "NightCue",
        "HiveCue",
        "FormCue",
        "YarnCue",
        "ScoutCue",
    ]
    public static let bannedPalettes = [
        "#16A34A/#F0FDF4/#DB2777",
        "#1E3A8A",
    ]
    public static let bannedUIChrome = [
        "film-sprocket timeline",
        "onion-skin overlay",
        "night-frame rail",
    ]
    public static let requiredUI = [
        "table zone cards",
        "turn step bar",
    ]
}
