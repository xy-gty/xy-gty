import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum HeatbarRoute: String, Codable, CaseIterable, Sendable {
    case heatHome = "HeatHome"
    case captureImport = "CaptureImport"
    case slitScrubber = "SlitScrubber"
    case coachChat = "CoachChat"
    case readingReview = "ReadingReview"
    case finishCard = "FinishCard"
    case calloutDeck = "CalloutDeck"
    case heatDetail = "HeatDetail"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}

/// Parameterized route payload for TypedNavigationStore restore.
public struct HeatbarRoutePayload: Codable, Hashable, Sendable {
    public var route: HeatbarRoute
    public var heatPackId: String?
    public var finishStripId: String?
    public var finishCardId: String?
    /// privacy | terms | support | providerPolicy
    public var legalPage: String?
    public init(
        route: HeatbarRoute,
        heatPackId: String? = nil,
        finishStripId: String? = nil,
        finishCardId: String? = nil,
        legalPage: String? = nil
    ) {
        self.route = route
        self.heatPackId = heatPackId
        self.finishStripId = finishStripId
        self.finishCardId = finishCardId
        self.legalPage = legalPage
    }
}
