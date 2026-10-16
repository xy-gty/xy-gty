import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum BloomkettleRoute: String, Codable, CaseIterable, Sendable {
    case brewHome = "BrewHome"
    case captureImport = "CaptureImport"
    case funnelTimeline = "FunnelTimeline"
    case coachChat = "CoachChat"
    case readingReview = "ReadingReview"
    case brewNote = "BrewNote"
    case sessionDetail = "SessionDetail"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

/// Parameterized route payload for TypedNavigationStore restore.
public struct BloomkettleRoutePayload: Codable, Hashable, Sendable {
    public var route: BloomkettleRoute
    public var sessionId: String?
    public var shotId: String?
    public var brewNoteId: String?
    /// privacy | terms | support | providerPolicy
    public var legalPage: String?
    public init(
        route: BloomkettleRoute,
        sessionId: String? = nil,
        shotId: String? = nil,
        brewNoteId: String? = nil,
        legalPage: String? = nil
    ) {
        self.route = route
        self.sessionId = sessionId
        self.shotId = shotId
        self.brewNoteId = brewNoteId
        self.legalPage = legalPage
    }
}
