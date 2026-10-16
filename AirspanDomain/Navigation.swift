import Foundation
import AppRuntimeCore

/// Frozen navigation routes from technical_contract.v1.
public enum AirspanRoute: String, Codable, Equatable, Sendable {
    case homeTab = "HomeTab"
    case jobsCanvas = "JobsCanvas"
    case jobCapture = "JobCapture"
    case ductRunReview = "DuctRunReview"
    case ductRunDetail = "DuctRunDetail"
    case coachChat = "CoachChat"
    case sizeDiagram = "SizeDiagram"
    case fieldSteps = "FieldSteps"
    case speechCapture = "SpeechCapture"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

public enum AirspanNavigation {
    public static let allRoutes: [AirspanRoute] = [
        .homeTab, .jobsCanvas, .jobCapture, .ductRunReview, .ductRunDetail,
        .coachChat, .sizeDiagram, .fieldSteps, .speechCapture, .settings,
        .legalPages, .consentSheet
    ]

    public static func isValid(_ route: AirspanRoute) -> Bool {
        allRoutes.contains(route)
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<AirspanRoute> {
        let url = directory.appendingPathComponent("navigation-path.json", isDirectory: false)
        return TypedNavigationStore(url: url, isValid: isValid)
    }
}
