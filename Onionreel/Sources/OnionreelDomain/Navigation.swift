import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum OnionreelRoute: String, Codable, CaseIterable, Sendable {
    case projectsHome = "ProjectsHome"
    case newProject = "NewProject"
    case captureImport = "CaptureImport"
    case frameReview = "FrameReview"
    case stopCoach = "StopCoach"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case onionSkinGuide = "OnionSkinGuide"
    case countdownTTS = "CountdownTTS"
    case dictateInterval = "DictateInterval"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
