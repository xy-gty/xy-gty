import Foundation

/// Frozen technical identity for DocBrief AI (P1 preparation scaffold).
public enum DocBriefIdentity {
    public static let appName = "DocBrief AI"
    public static let developmentBundleID = "com.lingguang.docbrief"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "docbrief.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.docbrief.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let nonCertificationDisclaimer =
        "Recognition and suggestions are organization aids only — not financial, tax, or legal certification, and not official credentials."
}
