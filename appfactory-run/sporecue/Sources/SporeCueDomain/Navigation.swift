import Foundation
import AppRuntimeCore

/// Frozen navigation destinations from technical_contract.v1.json.
public enum SporeCueRoute: String, Codable, Hashable, Sendable {
    case fieldHome
    case cameraCapture
    case photoImport
    case idResult
    case lookalikeChat
    case overlayAnnotate
    case fieldBrief
    case voiceNote
    case aiConsent
    case settings
    case legal
}

public enum SporeCueNavigation {
    public static let storeFileName = "navigation_path.json"

    public static func isValid(_ route: SporeCueRoute) -> Bool {
        switch route {
        case .fieldHome, .cameraCapture, .photoImport, .idResult, .lookalikeChat,
             .overlayAnnotate, .fieldBrief, .voiceNote, .aiConsent, .settings, .legal:
            return true
        }
    }

    @MainActor
    public static func makeStore(directory: URL) -> TypedNavigationStore<SporeCueRoute> {
        TypedNavigationStore(
            url: directory.appendingPathComponent(storeFileName, isDirectory: false),
            isValid: isValid
        )
    }
}
