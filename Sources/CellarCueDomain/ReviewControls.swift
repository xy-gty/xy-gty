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

public enum CellarCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max"]
}

public enum CellarCuePermissions {
    public static let required = ["camera", "photos", "microphone", "speech_recognition"]
}

public enum CellarCueAllergy {
    public static let bannedTwinShells = [
        "MixCue", "SporeCue", "WingCue", "FrameCue", "RuleCue", "StopCue",
    ]
    public static let bannedCompetitorNames = ["Vinocell"]
    public static let requiredUI = [
        "cellar row/bin grid",
        "large label-OCR hero card",
        "drinking-window aging timeline",
    ]
}

public enum CellarCueGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}

/// Ensures alcohol-advice copy always carries both hard disclaimers + 21+.
public enum CellarComplianceCopy {
    public static func ensureDisclaimers(_ text: String) -> String {
        var out = text
        for phrase in CellarCueCompliance.requiredDisclaimers {
            if !out.contains(phrase) {
                out += " \(phrase)."
            }
        }
        if CellarCueCompliance.ageGate21PlusOnAlcoholAdvice, !out.contains(CellarCueCompliance.ageGateLabel) {
            out += " \(CellarCueCompliance.ageGateLabel)."
        }
        return out
    }

    public static func makePullBriefScript(
        bottle: BottleEntry,
        binLabel: String,
        windowStatus: String
    ) -> PullBrief {
        let name = [bottle.producer, bottle.vintage, bottle.varietal]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        let display = name.isEmpty ? "this bottle" : name
        let body = """
        Pull brief for \(display) in \(binLabel). Window status: \(windowStatus). \
        \(CellarCueCompliance.sommelierCertificationDisclaimer). \
        \(CellarCueCompliance.investmentAdviceDisclaimer). \
        \(CellarCueCompliance.ageGateLabel). Informational only — never certified tasting or investment returns.
        """
        return PullBrief(
            bottleId: bottle.id,
            scriptText: body,
            spokenAt: nil,
            ttsLocale: "en-US"
        )
    }

    public static func defaultTimeline(for bottleId: String, vintage: String?) -> DrinkingWindow {
        let year = Int(vintage ?? "") ?? Calendar.current.component(.year, from: Date())
        let points = [
            "hold:\(year + 2)",
            "approaching:\(year + 5)",
            "open:\(year + 8)",
            "past:\(year + 15)",
        ]
        return DrinkingWindow(
            bottleId: bottleId,
            peakStart: nil,
            peakEnd: nil,
            status: "hold",
            timelinePoints: points
        )
    }

    public static func ensureDefaultRack(state: inout CellarCueState) {
        guard state.racks.isEmpty else { return }
        let rack = CellarRack(
            id: "rack-home",
            name: "Home cellar",
            rowCount: 3,
            binCountPerRow: 4,
            createdAt: Date()
        )
        state.racks = [rack]
        var bins: [CellarBin] = []
        for row in 1 ... rack.rowCount {
            for col in 1 ... rack.binCountPerRow {
                bins.append(
                    CellarBin(
                        id: "R\(row)-B\(col)",
                        rackId: rack.id,
                        row: row,
                        column: col,
                        label: "R\(row)-B\(col)"
                    )
                )
            }
        }
        state.bins = bins
    }
}
