import Foundation
import AppRuntimeCore

/// Review affordances from technical contract.
public enum SporeReviewControls {
    public static let confirm = ["Save Find", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit callouts"]
}

/// Hard compliance disclaimer — required on every ID / edibility / foraging surface.
public enum SporeCueCompliance {
    public static let requiredDisclaimer = "非可食认证 / not an edibility certification"
    public static let edibilityCertification = false
    public static let neverImplySafeToEat = true
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "sporecue.consent.v1"
    public static let fields = [
        "cap_gill_pore_still",
        "user_question",
        "confirmed_species_notes",
        "active_session_id",
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

/// Interface name literals for deferred Builder wiring (no UI).
public enum SporeCueInterfaceNames {
    public static let forageStore = "ForageStore"
    public static let photoCaptureService = "PhotoCaptureService"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let speciesIDClient = "SpeciesIDClient"
    public static let coachChatClient = "CoachChatClient"
    public static let overlayAnnotator = "OverlayAnnotator"
    public static let chipRailBuilder = "ChipRailBuilder"
    public static let ttsFieldBrief = "TTSFieldBrief"
    public static let voiceNoteRecorder = "VoiceNoteRecorder"
    public static let speechQuestionIngress = "SpeechQuestionIngress"
    public static let consentGate = "ConsentGate"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let photoImportSession = "PhotoImportSession"
    public static let runtimeForm = "RuntimeForm"
    public static let aiConsentGate = "AIConsentGate"
}

/// Permission usage strings extending foraging ID coach (no competitor names).
public enum PrivacyUsageCopy {
    public static let camera =
        "Capture cap, gill, and pore close-ups so SporeCue can help identify field finds"
    public static let photoLibrary =
        "Import hike album stills to complete species identification in SporeCue"
    public static let microphone =
        "Record hands-free field notes while holding a knife or basket"
    public static let speechRecognition =
        "Turn spoken lookalike and habitat questions into coach chat text"
}

public enum SporeCueIdentity {
    public static let appName = "SporeCue"
    public static let developmentBundleId = "com.lingguang.sporecue"
    public static let productDir = "sporecue"
    public static let uiLanguage = "en-US"
    public static let simulatorPrefUDID = "B14CC0EA"
}

public enum SporeCuePalette {
    public static let primary = "#9A3412"
    public static let secondary = "#FFF7ED"
    public static let accent = "#0284C7"
}

public enum SporeCueUISpecies {
    public static let signature =
        "vertical_species_confidence_stack + oversized_gill_pore_closeup_bar + edible_warning_chip_rail"
}

public enum SporeCueGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}
