import Foundation
import AppRuntimeCore

/// Frozen navigation destinations from technical_contract.v1.json.
public enum ZonelightRoute: String, Codable, Hashable, Sendable {
    case meterHome
    case cameraSpot
    case photoImport
    case exposureResult
    case coachChat
    case meterCard
    case setCallout
    case voiceNote
    case aiConsent
    case settings
    case legal
}

public enum ZonelightNavigation {
    public static let storeFileName = "navigation_path.json"

    public static func isValid(_ route: ZonelightRoute) -> Bool {
        switch route {
        case .meterHome, .cameraSpot, .photoImport, .exposureResult, .coachChat,
             .meterCard, .setCallout, .voiceNote, .aiConsent, .settings, .legal:
            return true
        }
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<ZonelightRoute> {
        TypedNavigationStore(
            url: directory.appendingPathComponent(storeFileName, isDirectory: false),
            isValid: isValid
        )
    }
}
