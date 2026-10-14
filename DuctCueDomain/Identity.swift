import Foundation

/// Frozen technical identity for DuctCue (P1 preparation scaffold).
public enum DuctCueIdentity {
    public static let appName = "DuctCue"
    public static let developmentBundleID = "com.lingguang.ductcue"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "ductcue.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.ductcue.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let sizingFormulaDisclaimer =
        "Sizing helpers cite formulas — field judgment still required."
}
