import Foundation
import AppRuntimeCore

/// Review affordances from technical contract.
public enum MixReviewControls {
    public static let confirm = ["Save Mix", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit pour steps"]
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "mixcue.consent.v1"
    public static let fields = [
        "bottle_label_garnish_still",
        "user_question",
        "confirmed_spirits_substitutes",
        "active_recipe_id",
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
public enum MixCueInterfaceNames {
    public static let mixStore = "MixStore"
    public static let photoCaptureService = "PhotoCaptureService"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let spiritIDClient = "SpiritIDClient"
    public static let coachChatClient = "CoachChatClient"
    public static let pourBoardBuilder = "PourBoardBuilder"
    public static let ttsPlayer = "TTSPlayer"
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

/// Permission usage strings extending cocktail-coach core (no competitor names).
public enum PrivacyUsageCopy {
    public static let camera =
        "Capture bottle faces, labels, and garnish stills so MixCue can identify base spirits for your mix session"
    public static let photoLibrary =
        "Import bar-shelf album stills to complete spirit identification in MixCue"
    public static let microphone =
        "Record hands-free voice notes while both hands shake or stir"
    public static let speechRecognition =
        "Turn spoken substitute and recipe questions into coach chat text"
}

public enum MixCueIdentity {
    public static let appName = "MixCue"
    public static let developmentBundleId = "com.lingguang.mixcue"
    public static let productDir = "mixcue"
    public static let uiLanguage = "en-US"
    public static let simulatorPrefUDID = "B14CC0EA"
}

public enum MixCuePalette {
    public static let primary = "#E11D48"
    public static let secondary = "#FFF1F2"
    public static let accent = "#CA8A04"
}

public enum MixCueUISpecies {
    public static let signature = "vertical_bottle_rail + large_next_pour_card + garnish_chip_row"
}

public enum MixCueGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}
