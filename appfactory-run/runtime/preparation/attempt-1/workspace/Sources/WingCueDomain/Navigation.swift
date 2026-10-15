import Foundation
import AppRuntimeCore

/// Frozen navigation destinations from technical_contract.v1.json.
public enum WingCueRoute: Codable, Hashable, Sendable {
    case fieldHome
    case cameraCapture
    case photoImport
    case idResult(sessionId: String)
    case lookalikeChat(sessionId: String)
    case overlayStudio(sessionId: String)
    case voiceNote(sessionId: String?)
    case aiConsent
    case settings
    case legal(page: String)

    public var kind: String {
        switch self {
        case .fieldHome: return "root"
        case .cameraCapture: return "modal"
        case .photoImport: return "sheet"
        case .idResult, .lookalikeChat, .overlayStudio, .settings, .legal: return "push"
        case .voiceNote, .aiConsent: return "sheet"
        }
    }
}

public typealias WingCueNavigationStore = TypedNavigationStore<WingCueRoute>
