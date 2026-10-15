import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum YarnCueRoute: String, Codable, CaseIterable, Sendable {
    case projectsHome = "ProjectsHome"
    case newProject = "NewProject"
    case captureImport = "CaptureImport"
    case stitchReview = "StitchReview"
    case projectCoach = "ProjectCoach"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case annotatedWIP = "AnnotatedWIP"
    case handsFreeTTS = "HandsFreeTTS"
    case dictateNote = "DictateNote"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
