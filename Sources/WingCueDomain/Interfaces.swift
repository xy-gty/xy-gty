import Foundation
import AppRuntimeCore

/// Interface name literals for deferred Builder wiring (no UI / no network).
public enum WingCueInterfaceNames {
    public static let sightingStore = "SightingStore"
    public static let photoCaptureService = "PhotoCaptureService"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let speciesIDClient = "SpeciesIDClient"
    public static let coachChatClient = "CoachChatClient"
    public static let overlayAnnotator = "OverlayAnnotator"
    public static let ttsPlayer = "TTSPlayer"
    public static let voiceNoteRecorder = "VoiceNoteRecorder"
    public static let speechQuestionIngress = "SpeechQuestionIngress"
    public static let consentGate = "ConsentGate"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let photoImportSession = "PhotoImportSession"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let runtimeForm = "RuntimeForm"
    public static let aiConsentGate = "AIConsentGate"
}

/// Review affordances from technical contract.
public enum IDReviewControls {
    public static let confirm = ["Save ID", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit marks"]
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "wingcue.consent.v1"
    public static let fields = [
        "bird_still",
        "user_question",
        "confirmed_species_marks",
        "lookalike_pair_ids",
        "optional_voice_transcript",
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

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture bird plumage close-ups for species identification"
    public static let photoLibrary =
        "Import trip album stills for species ID sessions"
    public static let microphone =
        "Record hands-free field voice notes while holding binoculars"
    public static let speechRecognition =
        "Speak lookalike coach questions without typing"
}

public enum WingCueIdentity {
    public static let appName = "WingCue"
    public static let developmentBundleId = "com.lingguang.wingcue"
    public static let productDir = "wingcue"
    public static let uiLanguage = "en-US"
    public static let simulatorPrefUDID = "B14CC0EA"
}

public enum WingCuePalette {
    public static let primary = "#0F766E"
    public static let secondary = "#F0FDFA"
    public static let accent = "#C2410C"
}

public enum WingCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

public enum WingCueUISpecies {
    public static let signature = "field-card_stack + oversized_field_mark_chips + silhouette_compare_bar"
    public static let fieldCardStack = "FieldCardStack"
    public static let oversizedFieldMarkChips = "OversizedFieldMarkChips"
    public static let silhouetteCompareBar = "SilhouetteCompareBar"
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum WingCueAllergy {
    public static let bannedTwinShells = [
        "ClosetCue",
        "FrameCue",
        "ScoutCue",
        "RuleCue",
        "StopCue",
    ]
    public static let requiredUI = [
        "field-card stack",
        "oversized field-mark chips",
        "silhouette compare bar",
    ]
}

public enum WingCuePermissions {
    public static let required = [
        "camera",
        "photos",
        "microphone",
        "speech_recognition",
    ]
}

public enum WingCueGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}
