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


public enum SporeCueDevicePolicy {
    public static let targetDevice = "iPhone 17 Pro"
    public static let preferredUDID = "B14CC0EA"
    public static let bannedDevices = ["iPhone 17 Pro Max", "iPhone 16 Pro Max", "iPhone 15 Pro Max"]
}

public enum SporeCueAllergy {
    public static let bannedTwinShells = [
        "MixCue", "WingCue", "FrameCue", "RuleCue", "StopCue", "ClosetCue", "ScoutCue",
    ]
    public static let bannedCompetitorNames = ["Shroomify", "Pilze 123"]
    public static let requiredUI = [
        "vertical species-confidence stack",
        "oversized gill/pore closeup bar",
        "edible/warning chip rail",
    ]
}

public enum SporeCuePermissions {
    public static let required = ["Camera", "Photos", "Microphone", "Speech Recognition"]
}

/// Builds informational edible/warning chips — never edibility certification.
public enum ChipRailBuilder {
    public static func informationalChips(sessionId: String, kinds: [String] = ["info_edible_look", "warning_lookalike", "toxic_lookalike"]) -> [CautionChip] {
        kinds.map { kind in
            let title: String
            switch kind {
            case "info_edible_look":
                title = "Looks edible in guides (info only)"
            case "warning_lookalike":
                title = "Warning lookalike — not a safety OK"
            case "toxic_lookalike":
                title = "Toxic lookalike cue (informational)"
            default:
                title = "Unknown morphology cue"
            }
            return CautionChip(
                sessionId: sessionId,
                kind: kind,
                title: title,
                informationalOnly: true
            )
        }
    }

    public static func ensureDisclaimer(_ text: String) -> String {
        if text.contains(SporeCueCompliance.requiredDisclaimer) { return text }
        return "\(SporeCueCompliance.requiredDisclaimer) — \(text)"
    }
}

/// Maps morphology cues into overlay callouts on the still.
public enum OverlayAnnotator {
    public static func callouts(from cues: [String], sessionId: String, subject: String) -> [MorphologyCallout] {
        cues.prefix(4).enumerated().map { idx, cue in
            let region: String
            switch subject {
            case "gill": region = "gill"
            case "pore": region = "pore"
            case "stem": region = "stem"
            default: region = idx % 2 == 0 ? "cap" : "gill"
            }
            let x = 0.12 + Double(idx) * 0.18
            return MorphologyCallout(
                sessionId: sessionId,
                region: region,
                label: cue,
                normalizedRect: [x, 0.28, 0.22, 0.18],
                note: ChipRailBuilder.ensureDisclaimer(cue)
            )
        }
    }

    public static func placeholderOverlay(sessionId: String, imageLocalURL: String, subject: String) -> OverlayAnnotation {
        let callouts = callouts(
            from: ["cap margin", "gill spacing", "pore surface", "stem texture"],
            sessionId: sessionId,
            subject: subject
        )
        return OverlayAnnotation(sessionId: sessionId, callouts: Array(callouts), imageLocalURL: imageLocalURL)
    }
}

/// TTS field brief script always includes the hard disclaimer.
public enum FieldBriefBuilder {
    public static func script(sessionId: String, topName: String, lookalike: String?, cues: [String]) -> FieldBrief {
        let cueText = cues.prefix(3).joined(separator: ", ")
        let look = lookalike.map { " Watch lookalike: \($0)." } ?? ""
        let body = "Field brief for \(topName). Morphology cues: \(cueText).\(look) Never treat this as food-safety approval."
        return FieldBrief(
            sessionId: sessionId,
            scriptText: ChipRailBuilder.ensureDisclaimer(body),
            spokenAt: nil,
            ttsLocale: "en-US"
        )
    }
}
