import Foundation

/// Frozen technical identity for Bightstep (P1 preparation scaffold).
public enum BightstepIdentity {
    public static let appName = "Bightstep"
    public static let developmentBundleID = "com.lingguang.bightstep"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"
    public static let productFolderSlug = "bightstep"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "bightstep.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.bightstep.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let coachingDisclaimer =
        "Knot coaching is educational — field judgment and safety still required."
}
