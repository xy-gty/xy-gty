import Foundation
import AppRuntimeCore

/// Review affordances from technical contract.
public enum ShelfReviewControls {
    public static let confirm = ["Save to Shelf", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit title", "Edit progress"]
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "foliocue.consent.v1"
    public static let fields = [
        "cover_or_spine_still",
        "user_question",
        "confirmed_book_notes",
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
public enum FolioCueInterfaceNames {
    public static let shelfStore = "ShelfStore"
    public static let coverSpineCapture = "CoverSpineCapture"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let bookIDClient = "BookIDClient"
    public static let coachChatClient = "CoachChatClient"
    public static let spineRailController = "SpineRailController"
    public static let shelfCardAnnotator = "ShelfCardAnnotator"
    public static let ttsFindCallout = "TTSFindCallout"
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

public enum PrivacyUsageCopy {
    public static let camera =
        "Capture cover, spine, or shelf-row photos to identify books on your personal shelf"
    public static let photoLibrary =
        "Import library or bookshelf album stills to backfill your personal shelf"
    public static let microphone =
        "Hands-free shelf location and TBR notes while holding books"
    public static let speechRecognition =
        "Speak shelf coach questions such as where a book is or mark reading progress"
}

public enum FolioCueCompliance {
    public static let personalBookshelfCoach =
        "个人藏书教练 / personal bookshelf coach"
    public static let notBookstoreCatalogScraping =
        "非书店目录爬取 / not bookstore catalog scraping"
    public static let notFullTextPiracyReader =
        "非全文盗版阅读器 / not a full-text piracy reader"
    public static let notHomeworkGrading =
        "非课业批改 / not homework grading"

    public static let requiredDisclaimers = [
        personalBookshelfCoach,
        notBookstoreCatalogScraping,
        notFullTextPiracyReader,
        notHomeworkGrading,
    ]
}

public enum FolioCueIdentity {
    public static let appName = "FolioCue"
    public static let developmentBundleId = "com.lingguang.foliocue"
    public static let productDir = "foliocue"
    public static let uiLanguage = "en-US"
    public static let deliveryRepo = "git@github.com:xy-gty/xy-gty.git"
    public static let deliveryBranchHint = "xy-gty"
}

public enum FolioCuePalette {
    public static let primary = "#065F46"
    public static let secondary = "#FEF3C7"
    public static let accent = "#C026D3"
}

public enum FolioCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

/// Explicit anti-twin markers — Builder must not adopt these shells.
public enum FolioCueAllergy {
    public static let bannedTwinShells = [
        "LuxCue",
        "CellarCue",
        "MixCue",
        "SporeCue",
        "FrameCue",
        "NightCue",
        "ScoutCue",
        "StopCue",
    ]
    public static let bannedAppCopyNames = [
        "BookBuddy",
    ]
    public static let requiredUI = [
        "horizontal spine-rail shelf",
        "large cover OCR card",
        "reading progress bar",
    ]
    public static let noAppIconOrLaunchScreen = true
}
