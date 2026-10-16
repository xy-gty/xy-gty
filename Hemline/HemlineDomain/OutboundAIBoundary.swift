import Foundation

/// Outbound AI defaults off until Secrets.xcconfig DEEPSEEK_API_KEY or authorized config exists.
/// config_mode=local_only; privacy/terms/support/cloudkit/ai_key remain UNKNOWN gaps.
public enum HemlineOutboundAIBoundary {
    public static let configMode = "local_only"
    public static let privacyURLGap = "UNKNOWN"
    public static let termsURLGap = "UNKNOWN"
    public static let supportURLGap = "UNKNOWN"
    public static let aiKeyGap = "UNKNOWN"
    public static let cloudKitGap = "UNKNOWN"

    public static let secretsXcconfigKey = "DEEPSEEK_API_KEY"
    public static let operatorPricingDeferred = "operator_pricing_deferred_free_app_only"

    public struct AuthorizationSnapshot: Equatable, Sendable {
        public var consentGranted: Bool
        public var apiKeyPresent: Bool
        public var outboundEnabled: Bool

        public init(consentGranted: Bool, apiKeyPresent: Bool) {
            self.consentGranted = consentGranted
            self.apiKeyPresent = apiKeyPresent
            self.outboundEnabled = consentGranted && apiKeyPresent
        }
    }

    public static func snapshot(consentGranted: Bool, apiKeyPresent: Bool) -> AuthorizationSnapshot {
        AuthorizationSnapshot(consentGranted: consentGranted, apiKeyPresent: apiKeyPresent)
    }

    public static func filterOutboundPayload(_ fields: [String: Data]) -> [String: Data] {
        let allow = Set(HemlineConsentFacade.outboundFieldAllowlist)
        return fields.filter { allow.contains($0.key) }
    }
}
