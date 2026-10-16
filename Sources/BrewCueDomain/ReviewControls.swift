import Foundation
import AppRuntimeCore

/// Review affordances from technical contract (ReadingReviewBar).
public enum ReadingReviewBar {
    public static let confirm = "Keep"
    public static let reject = "Discard"
    public static let edit = "Edit"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "brewcue.consent.v1"
    public static let fields = [
        "shot_desc",
        "bean_guess",
        "grind_guess",
        "bloom_note",
        "pour_guesses",
        "crema_note",
        "brew_question",
        "speech_transcript",
        "prior_pour_steps",
        "user_feedback",
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
public enum BrewCueInterfaceNames {
    public static let readingReviewBar = "ReadingReviewBar"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let coachChatForm = "CoachChatForm"
    public static let speechCueCapture = "SpeechCueCapture"
    public static let funnelTimeline = "FunnelTimeline"
    public static let nextPourCard = "NextPourCard"
    public static let grindChipRail = "GrindChipRail"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture beans, grounds, bloom, pour, or crema so BrewCue can coach your pour-over"
    public static let photoLibrary =
        "Import post-brew shots for diagnosis and pour-over coaching"
    public static let microphone =
        "Hands-free pour cues while both hands hold the kettle"
    public static let speechRecognition =
        "Turn spoken cues like 1:16 V60 or next pour into coach chat text"
}

public enum BrewCueCompliance {
    public static let homeBrewCoach =
        "家用冲煮教练 · home brew coach only"
    public static let notBaristaCertification =
        "非咖啡师认证 · not barista certification"
    public static let notNutritionMedical =
        "非营养医疗 · not nutrition or medical advice"
    public static let notEquipmentWarranty =
        "非设备质保 · not equipment warranty"
    public static let noAlcoholServiceClaims =
        "无酒类服务宣称 · no alcohol-service claims"

    public static let requiredDisclaimers = [
        homeBrewCoach,
        notBaristaCertification,
        notNutritionMedical,
        notEquipmentWarranty,
        noAlcoholServiceClaims,
    ]

    public static let bannerZH =
        "家用冲煮教练；非咖啡师认证；非营养医疗；非设备质保；无酒类服务宣称"
    public static let bannerEN =
        "Home brew coach only; not barista certification; not nutrition/medical; not equipment warranty; no alcohol-service claims"
}

public enum BrewCueIdentity {
    public static let appName = "BrewCue"
    public static let developmentBundleId = "com.lingguang.brewcue"
    public static let productDir = "brewcue"
    public static let uiLanguage = "en-US"
    public static let deliveryRepo = "git@github.com:xy-gty/xy-gty.git"
    public static let deliveryBranchHint = "xy-gty"
}

public enum BrewCuePalette {
    public static let primary = "#A16207"
    public static let secondary = "#ECFDF5"
    public static let accent = "#4F46E5"
}

public enum BrewCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum BrewCueAllergy {
    public static let bannedTwinShells = [
        "MixCue",
        "CellarCue",
        "FolioCue",
        "FinishCue",
        "PantryCue",
    ]
    public static let bannedAppCopyNames = [
        "The Great Coffee App",
    ]
    public static let differentiationNotes = [
        "MixCue bottle-rail — not BrewCue",
        "CellarCue bin grid — not BrewCue",
        "FolioCue spine-rail — not BrewCue",
        "FinishCue slit scrubber — not BrewCue",
        "PantryCue layout — not BrewCue",
    ]
    public static let requiredUI = [
        "vertical pour-over funnel timeline",
        "oversized next-pour grams/time card",
        "grind chip rail",
    ]
    public static let noAppIconOrLaunchScreen = true
}
