import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum SunbriefRoute: String, Codable, CaseIterable, Sendable {
    case scoutsHome = "ScoutsHome"
    case captureImport = "CaptureImport"
    case sceneReview = "SceneReview"
    case scoutCardDetail = "ScoutCardDetail"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case goldenOverlay = "GoldenOverlay"
    case nextStopBriefing = "NextStopBriefing"
    case dictateNote = "DictateNote"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
