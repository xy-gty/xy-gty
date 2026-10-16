import Foundation
import AppRuntimeCore

/// Frozen navigation destinations from technical_contract.v1.json.
public enum StirboardRoute: String, Codable, Hashable, Sendable {
    case barHome
    case cameraCapture
    case photoImport
    case idResult
    case recipeChat
    case pourBoard
    case voiceNote
    case aiConsent
    case settings
    case legal
}

public enum StirboardNavigation {
    public static let storeFileName = "navigation_path.json"

    public static func isValid(_ route: StirboardRoute) -> Bool {
        switch route {
        case .barHome, .cameraCapture, .photoImport, .idResult, .recipeChat,
             .pourBoard, .voiceNote, .aiConsent, .settings, .legal:
            return true
        }
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<StirboardRoute> {
        TypedNavigationStore(
            url: directory.appendingPathComponent(storeFileName, isDirectory: false),
            isValid: isValid
        )
    }
}
