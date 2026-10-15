import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum RuleCueRoute: String, Codable, CaseIterable, Sendable {
    case sessionsHome = "SessionsHome"
    case newSession = "NewSession"
    case captureImport = "CaptureImport"
    case componentReview = "ComponentReview"
    case tableCoach = "TableCoach"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case setupOverlay = "SetupOverlay"
    case hostTTS = "HostTTS"
    case dictateRules = "DictateRules"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
