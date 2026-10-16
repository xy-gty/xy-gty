import Foundation
import AppRuntimeCore

/// Frozen navigation routes from technical_contract.v1.
public enum HemlineRoute: String, Codable, Equatable, Sendable {
    case homeTab = "HomeTab"
    case closetShelf = "ClosetShelf"
    case captureImport = "CaptureImport"
    case garmentReview = "GarmentReview"
    case closetItemDetail = "ClosetItemDetail"
    case stylistChat = "StylistChat"
    case flatLayBoard = "FlatLayBoard"
    case morningBriefing = "MorningBriefing"
    case speechCapture = "SpeechCapture"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

public enum HemlineNavigation {
    public static let allRoutes: [HemlineRoute] = [
        .homeTab, .closetShelf, .captureImport, .garmentReview, .closetItemDetail,
        .stylistChat, .flatLayBoard, .morningBriefing, .speechCapture, .settings,
        .legalPages, .consentSheet
    ]

    public static func isValid(_ route: HemlineRoute) -> Bool {
        allRoutes.contains(route)
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<HemlineRoute> {
        let url = directory.appendingPathComponent("navigation-path.json", isDirectory: false)
        return TypedNavigationStore(url: url, isValid: isValid)
    }
}
