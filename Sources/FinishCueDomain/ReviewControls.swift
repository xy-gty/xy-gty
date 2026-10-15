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
    public static let disclosureVersion = "finishcue.consent.v1"
    public static let fields = [
        "strip_desc",
        "lane_guesses",
        "athlete_labels",
        "raw_time_reads",
        "heat_question",
        "speech_transcript",
        "prior_lane_reads",
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
public enum FinishCueInterfaceNames {
    public static let readingReviewBar = "ReadingReviewBar"
    public static let aiConsentGate = "AIConsentGate"
    public static let photoImportSession = "PhotoImportSession"
    public static let cameraCapture = "CameraCapture"
    public static let coachChatForm = "CoachChatForm"
    public static let speechCueCapture = "SpeechCueCapture"
    public static let ttsCallout = "TTSCallout"
    public static let slitScanScrubber = "SlitScanScrubber"
    public static let laneScaleRail = "LaneScaleRail"
    public static let timeCalloutChips = "TimeCalloutChips"
    public static let atomicCodableStore = "AtomicCodableStore"
    public static let keychainCredentialStore = "KeychainCredentialStore"
    public static let typedNavigationStore = "TypedNavigationStore"
    public static let runtimeForm = "RuntimeForm"
}

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture finish-line slit or video so FinishCue can read lanes and times"
    public static let photoLibrary =
        "Import training or amateur-meet finish strips for review and coaching"
    public static let microphone =
        "Hands-free start and lap calls while the phone is racked at the finish"
    public static let speechRecognition =
        "Turn spoken cues like start heat or mark lane into coach chat text"
}

public enum FinishCueCompliance {
    public static let trainingAidAmateurMeet =
        "辅助训练/业余会合影计时 · Training aid & amateur meet photo timing"
    public static let notOfficialFAT =
        "非官方 FAT 计时设备 · not an official FAT timing device"
    public static let notBettingOrAntiDoping =
        "非博彩/反兴奋剂 · not betting or anti-doping"

    public static let requiredDisclaimers = [
        trainingAidAmateurMeet,
        notOfficialFAT,
        notBettingOrAntiDoping,
    ]

    public static let bannerZH =
        "辅助训练/业余会合影计时；非官方 FAT 计时设备；非博彩/反兴奋剂"
    public static let bannerEN =
        "Training aid & amateur meet photo timing; not an official FAT timing device; not betting or anti-doping"
}

public enum FinishCueIdentity {
    public static let appName = "FinishCue"
    public static let developmentBundleId = "com.lingguang.finishcue"
    public static let productDir = "finishcue"
    public static let uiLanguage = "en-US"
    public static let deliveryRepo = "git@github.com:xy-gty/xy-gty.git"
    public static let deliveryBranchHint = "xy-gty"
}

public enum FinishCuePalette {
    public static let primary = "#BE185D"
    public static let secondary = "#ECFEFF"
    public static let accent = "#65A30D"
}

public enum FinishCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum FinishCueAllergy {
    public static let bannedTwinShells = [
        "FolioCue",
        "LuxCue",
        "StopCue",
        "FormCue",
        "CellarCue",
        "MixCue",
    ]
    public static let bannedAppCopyNames = [
        "SprintTimer",
    ]
    /// FormCue = HIIT bricks; StopCue = onion-skin freeze — do not reuse.
    public static let differentiationNotes = [
        "FormCue HIIT bricks — not FinishCue",
        "StopCue onion-skin freeze — not FinishCue",
    ]
    public static let requiredUI = [
        "horizontal slit-scan finish-bar scrubber",
        "lane scale rail",
        "time callout chips",
    ]
    public static let noAppIconOrLaunchScreen = true
}
