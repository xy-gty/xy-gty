import Foundation

/// Frozen technical identity for Airspan (P1 preparation scaffold).
public enum AirspanIdentity {
    public static let appName = "Airspan"
    public static let developmentBundleID = "com.lingguang.airspan"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "airspan.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.airspan.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let sizingFormulaDisclaimer =
        "Sizing helpers cite formulas — field judgment still required."
}
