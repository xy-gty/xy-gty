import Foundation
import AppRuntimeCore

/// Review affordances from technical contract.
public enum CellarReviewControls {
    public static let confirm = ["Save Bottle", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit bin", "Edit window"]
}

/// Hard compliance — required on alcohol advice / drinking window / pairing / coach surfaces.
public enum CellarCueCompliance {
    public static let sommelierCertificationDisclaimer = "非侍酒认证 / not a sommelier certification"
    public static let investmentAdviceDisclaimer = "非投资建议 / not investment advice"
    public static let requiredDisclaimers = [
        sommelierCertificationDisclaimer,
        investmentAdviceDisclaimer,
    ]
    public static let sommelierCertification = false
    public static let investmentAdvice = false
    public static let ageGate21PlusOnAlcoholAdvice = true
    public static let neverClaimCertifiedTastingOrGuaranteedReturns = true
    public static let ageGateLabel = "21+"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "cellarcue.consent.v1"
    public static let fields = [
        "label_still",
        "user_question",
        "confirmed_bottle_notes",
        "active_bottle_or_bin_id",
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
public enum CellarCueInterfaceNames {
    public static let cellarStore = "CellarStore"
    public static let photoCaptureService = "PhotoCaptureService"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let labelOCRClient = "LabelOCRClient"
    public static let coachChatClient = "CoachChatClient"
    public static let drinkingWindowTimeline = "DrinkingWindowTimeline"
    public static let rackCardAnnotator = "RackCardAnnotator"
    public static let ttsPullBrief = "TTSPullBrief"
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

/// Permission usage strings extending cellar coach (no Vinocell / competitor names).
public enum PrivacyUsageCopy {
    public static let camera =
        "Capture wine label, cork, and bin-tag stills so CellarCue can place bottles in your cellar grid"
    public static let photoLibrary =
        "Import cellar photos to complete label OCR and bin placement in CellarCue"
    public static let microphone =
        "Record hands-free bin notes while carrying bottles"
    public static let speechRecognition =
        "Turn spoken drinking-window and pairing questions into coach chat text"
}

public enum CellarCueIdentity {
    public static let appName = "CellarCue"
    public static let developmentBundleId = "com.lingguang.cellarcue"
    public static let productDir = "cellarcue"
    public static let uiLanguage = "en-US"
    public static let simulatorPrefUDID = "B14CC0EA"
}

public enum CellarCuePalette {
    public static let primary = "#3730A3"
    public static let secondary = "#EEF2FF"
    public static let accent = "#EA580C"
}

public enum CellarCueUISpecies {
    public static let signature =
        "cellar_row_bin_grid + large_label_ocr_hero_card + drinking_window_aging_timeline"
}

public enum CellarCueGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}
