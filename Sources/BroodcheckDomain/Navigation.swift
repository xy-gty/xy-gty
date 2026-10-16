import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum BroodcheckRoute: String, Codable, CaseIterable, Sendable {
    case inspectionsHome = "InspectionsHome"
    case newInspection = "NewInspection"
    case captureImport = "CaptureImport"
    case broodReview = "BroodReview"
    case inspectionCoach = "InspectionCoach"
    case coachChat = "CoachChat"
    case turnReview = "TurnReview"
    case annotatedFrame = "AnnotatedFrame"
    case handsFreeTTS = "HandsFreeTTS"
    case dictateFields = "DictateFields"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
