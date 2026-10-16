import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum ShutterduskRoute: String, Codable, CaseIterable, Sendable {
    case sessionsHome = "SessionsHome"
    case newSession = "NewSession"
    case captureImport = "CaptureImport"
    case exposureReview = "ExposureReview"
    case nightCoach = "NightCoach"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case annotatedOverlay = "AnnotatedOverlay"
    case fieldCueTTS = "FieldCueTTS"
    case dictateExposure = "DictateExposure"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
