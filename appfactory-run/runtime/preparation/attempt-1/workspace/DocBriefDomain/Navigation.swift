import Foundation
import AppRuntimeCore

/// Frozen navigation routes from technical_contract.v1.
public enum DocBriefRoute: String, Codable, Equatable, Sendable {
    case homeTab = "HomeTab"
    case newBrief = "NewBrief"
    case importCapture = "ImportCapture"
    case recognitionReview = "RecognitionReview"
    case briefDetail = "BriefDetail"
    case chatExtract = "ChatExtract"
    case actionReview = "ActionReview"
    case summaryCard = "SummaryCard"
    case ttsBriefing = "TTSBriefing"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

public enum DocBriefNavigation {
    public static let allRoutes: [DocBriefRoute] = [
        .homeTab, .newBrief, .importCapture, .recognitionReview, .briefDetail,
        .chatExtract, .actionReview, .summaryCard, .ttsBriefing, .settings,
        .legalPages, .consentSheet
    ]

    public static func isValid(_ route: DocBriefRoute) -> Bool {
        allRoutes.contains(route)
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<DocBriefRoute> {
        let url = directory.appendingPathComponent("navigation-path.json", isDirectory: false)
        return TypedNavigationStore(url: url, isValid: isValid)
    }
}
