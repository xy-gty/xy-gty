import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum SpinewellRoute: String, Codable, CaseIterable, Sendable {
    case shelfHome = "shelfHome"
    case cameraCapture = "cameraCapture"
    case photoImport = "photoImport"
    case bookIdResult = "bookIdResult"
    case coachChat = "coachChat"
    case shelfCard = "shelfCard"
    case findCallout = "findCallout"
    case voiceNote = "voiceNote"
    case aiConsent = "aiConsent"
    case settings = "settings"
    case legal = "legal"
}

/// Parameterized route payload for TypedNavigationStore restore.
public struct SpinewellRoutePayload: Codable, Hashable, Sendable {
    public var route: SpinewellRoute
    public var sessionId: String?
    /// privacy | terms | support | providerPolicy
    public var legalPage: String?
    public init(
        route: SpinewellRoute,
        sessionId: String? = nil,
        legalPage: String? = nil
    ) {
        self.route = route
        self.sessionId = sessionId
        self.legalPage = legalPage
    }
}
