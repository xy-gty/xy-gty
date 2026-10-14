import Foundation
import AppRuntimeCore

/// Frozen navigation routes from technical_contract.v1.
public enum BendCoachRoute: String, Codable, Equatable, Sendable {
    case homeTab = "HomeTab"
    case bendMathChat = "BendMathChat"
    case captureImport = "CaptureImport"
    case bendReview = "BendReview"
    case jobDetail = "JobDetail"
    case diagramOverlay = "DiagramOverlay"
    case ttsCoaching = "TTSCoaching"
    case speechCapture = "SpeechCapture"
    case settings = "Settings"
    case units = "Units"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

public enum BendCoachNavigation {
    public static let allRoutes: [BendCoachRoute] = [
        .homeTab, .bendMathChat, .captureImport, .bendReview, .jobDetail,
        .diagramOverlay, .ttsCoaching, .speechCapture, .settings, .units,
        .legalPages, .consentSheet
    ]

    public static func isValid(_ route: BendCoachRoute) -> Bool {
        allRoutes.contains(route)
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<BendCoachRoute> {
        let url = directory.appendingPathComponent("navigation-path.json", isDirectory: false)
        return TypedNavigationStore(url: url, isValid: isValid)
    }
}
