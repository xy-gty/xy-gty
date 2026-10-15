import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum FormCueRoute: String, Codable, CaseIterable, Sendable {
    case sessionsHome = "SessionsHome"
    case newSession = "NewSession"
    case captureImport = "CaptureImport"
    case formReview = "FormReview"
    case sessionCoach = "SessionCoach"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case annotatedForm = "AnnotatedForm"
    case handsFreeTTS = "HandsFreeTTS"
    case dictateIntent = "DictateIntent"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
