import Foundation
import AppRuntimeCore

/// Frozen navigation routes from technical_contract.v1.
public enum BightstepRoute: String, Codable, Equatable, Sendable {
    case homeTab = "HomeTab"
    case ropeCarousel = "RopeCarousel"
    case knotCapture = "KnotCapture"
    case stageReview = "StageReview"
    case knotStageDetail = "KnotStageDetail"
    case coachChat = "CoachChat"
    case stepOverlay = "StepOverlay"
    case handsFreeCoach = "HandsFreeCoach"
    case speechCapture = "SpeechCapture"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

public enum BightstepNavigation {
    public static let allRoutes: [BightstepRoute] = [
        .homeTab, .ropeCarousel, .knotCapture, .stageReview, .knotStageDetail,
        .coachChat, .stepOverlay, .handsFreeCoach, .speechCapture, .settings,
        .legalPages, .consentSheet
    ]

    public static func isValid(_ route: BightstepRoute) -> Bool {
        allRoutes.contains(route)
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<BightstepRoute> {
        let url = directory.appendingPathComponent("navigation-path.json", isDirectory: false)
        return TypedNavigationStore(url: url, isValid: isValid)
    }
}
