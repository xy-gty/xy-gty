import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum PitchCueRoute: String, Codable, CaseIterable, Sendable {
    case practiceHome = "PracticeHome"
    case newSession = "NewSession"
    case captureImport = "CaptureImport"
    case coachChat = "CoachChat"
    case planReview = "PlanReview"
    case practiceFloor = "PracticeFloor"
    case pitchFeedback = "PitchFeedback"
    case sessionDetail = "SessionDetail"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
