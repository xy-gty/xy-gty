import Foundation

/// Frozen technical identity for Hemline (P1 preparation scaffold).
public enum HemlineIdentity {
    public static let appName = "Hemline"
    public static let developmentBundleID = "com.lingguang.hemline"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "hemline.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.hemline.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let styleSuggestionDisclaimer =
        "Style suggestions only — not a brand or retailer endorsement."
}
