import Foundation
import AppRuntimeCore

/// Frozen navigation destinations from technical_contract.v1.json.
public enum CellarCueRoute: String, Codable, Hashable, Sendable {
    case cellarHome
    case cameraCapture
    case photoImport
    case labelResult
    case windowChat
    case rackCard
    case pullBrief
    case voiceNote
    case aiConsent
    case settings
    case legal
}

public enum CellarCueNavigation {
    public static let storeFileName = "navigation_path.json"

    public static func isValid(_ route: CellarCueRoute) -> Bool {
        switch route {
        case .cellarHome, .cameraCapture, .photoImport, .labelResult, .windowChat,
             .rackCard, .pullBrief, .voiceNote, .aiConsent, .settings, .legal:
            return true
        }
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<CellarCueRoute> {
        TypedNavigationStore(
            url: directory.appendingPathComponent(storeFileName, isDirectory: false),
            isValid: isValid
        )
    }
}
