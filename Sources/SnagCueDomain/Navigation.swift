import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum SnagCueRoute: String, Codable, CaseIterable, Sendable {
    case homeTab = "HomeTab"
    case newAudit = "NewAudit"
    case capture = "Capture"
    case snagRecognitionReview = "SnagRecognitionReview"
    case punchList = "PunchList"
    case chatFill = "ChatFill"
    case fieldReview = "FieldReview"
    case annotatedReport = "AnnotatedReport"
    case ttsCoach = "TTSCoach"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
