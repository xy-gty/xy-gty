import Foundation
import AppRuntimeCore

/// Review affordances from technical contract.
public enum LuxReviewControls {
    public static let confirm = ["Save Reading", "Keep", "Use"]
    public static let reject = ["Dismiss", "Reject"]
    public static let edit = ["Edit EV", "Edit zone"]
}

/// Hard compliance disclaimers — required on every EV / exposure / zone / meter / TTS surface.
public enum ZonelightCompliance {
    public static let calibratedLabInstrument = false
    public static let medicalLighting = false
    public static let neverClaimLabCalibrationOrMedicalLighting = true
    public static let requiredDisclaimers = [
        "非校准实验室仪表 / not a calibrated lab instrument",
        "非医疗用光 / not for medical lighting",
    ]
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "zonelight.consent.v1"
    public static let fields = [
        "spot_or_imported_still",
        "user_question",
        "confirmed_exposure_notes",
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
public enum ZonelightInterfaceNames {
    public static let meterStore = "MeterStore"
    public static let spotMeterCapture = "SpotMeterCapture"
    public static let photoLibraryImporter = "PhotoLibraryImporter"
    public static let exposureIDClient = "ExposureIDClient"
    public static let coachChatClient = "CoachChatClient"
    public static let zoneDialController = "ZoneDialController"
    public static let meterCardAnnotator = "MeterCardAnnotator"
    public static let ttsSetCallout = "TTSSetCallout"
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

/// Permission usage strings extending meter coach (no competitor names).
public enum PrivacyUsageCopy {
    public static let camera =
        "Capture spot-meter and gray-card readings so Zonelight can suggest exposure coaching"
    public static let photoLibrary =
        "Import stills to complete spot-meter sessions in Zonelight"
    public static let microphone =
        "Record hands-free meter notes while holding the camera"
    public static let speechRecognition =
        "Turn spoken zone and exposure questions into coach chat text"
}

public enum ZonelightIdentity {
    public static let appName = "Zonelight"
    public static let developmentBundleId = "com.lingguang.zonelight"
    public static let productDir = "zonelight"
    public static let uiLanguage = "en-US"
    public static let simulatorPrefUDID = "B14CC0EA"
}

public enum ZonelightPalette {
    public static let primary = "#1D4ED8"
    public static let secondary = "#F0F9FF"
    public static let accent = "#EAB308"
}

public enum ZonelightUISpecies {
    public static let signature =
        "zone_system_dial + oversized_ev_readout_bar + spot_meter_cross_card"
}

public enum ZonelightGaps {
    public static let privacyURL = "UNKNOWN"
    public static let termsURL = "UNKNOWN"
    public static let supportURL = "UNKNOWN"
    public static let aiKey = "UNKNOWN"
    public static let cloudkit = "UNKNOWN"
}
