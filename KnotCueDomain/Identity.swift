import Foundation

/// Frozen technical identity for KnotCue (P1 preparation scaffold).
public enum KnotCueIdentity {
    public static let appName = "KnotCue"
    public static let developmentBundleID = "com.lingguang.knotcue"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"
    public static let productFolderSlug = "knotcue"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "knotcue.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.knotcue.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let coachingDisclaimer =
        "Knot coaching is educational — field judgment and safety still required."
}
