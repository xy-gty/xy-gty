import Foundation
import AppRuntimeCore

/// Frozen navigation routes from technical_contract.v1.
public enum ClosetCueRoute: String, Codable, Equatable, Sendable {
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

public enum ClosetCueNavigation {
    public static let allRoutes: [ClosetCueRoute] = [
        .homeTab, .closetShelf, .captureImport, .garmentReview, .closetItemDetail,
        .stylistChat, .flatLayBoard, .morningBriefing, .speechCapture, .settings,
        .legalPages, .consentSheet
    ]

    public static func isValid(_ route: ClosetCueRoute) -> Bool {
        allRoutes.contains(route)
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<ClosetCueRoute> {
        let url = directory.appendingPathComponent("navigation-path.json", isDirectory: false)
        return TypedNavigationStore(url: url, isValid: isValid)
    }
}
