import Foundation
import AppRuntimeCore

/// Frozen navigation destinations from technical_contract.v1.json.
public enum LuxCueRoute: String, Codable, Hashable, Sendable {
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

public enum LuxCueNavigation {
    public static let storeFileName = "navigation_path.json"

    public static func isValid(_ route: LuxCueRoute) -> Bool {
        switch route {
        case .meterHome, .cameraSpot, .photoImport, .exposureResult, .coachChat,
             .meterCard, .setCallout, .voiceNote, .aiConsent, .settings, .legal:
            return true
        }
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<LuxCueRoute> {
        TypedNavigationStore(
            url: directory.appendingPathComponent(storeFileName, isDirectory: false),
            isValid: isValid
        )
    }
}
