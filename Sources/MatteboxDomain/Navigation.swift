import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum MatteboxRoute: String, Codable, CaseIterable, Sendable {
    case sessionsHome = "SessionsHome"
    case newSession = "NewSession"
    case captureImport = "CaptureImport"
    case compositionReview = "CompositionReview"
    case slateStage = "SlateStage"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case overlayMarks = "OverlayMarks"
    case handsFreeTTS = "HandsFreeTTS"
    case dictateShot = "DictateShot"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
