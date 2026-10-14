import Foundation

/// Frozen technical identity for ClosetCue (P1 preparation scaffold).
public enum ClosetCueIdentity {
    public static let appName = "ClosetCue"
    public static let developmentBundleID = "com.lingguang.closetcue"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "closetcue.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.closetcue.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let styleSuggestionDisclaimer =
        "Style suggestions only — not a brand or retailer endorsement."
}
