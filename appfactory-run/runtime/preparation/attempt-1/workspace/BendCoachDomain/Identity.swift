import Foundation

/// Frozen technical identity for BendCoach AI (P1 preparation scaffold).
public enum BendCoachIdentity {
    public static let appName = "BendCoach AI"
    public static let developmentBundleID = "com.lingguang.bendcoach"
    public static let uiLanguage = "en-US"
    public static let docsLanguage = "zh-CN"

    public static let aiProvider = "DeepSeek"
    public static let consentDisclosureVersion = "bendcoach.consent.v1"

    /// Keychain coordinates for API-key existence checks only (never invent values).
    public static let keychainService = "com.lingguang.bendcoach.credentials"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"

    public static let assistiveDisclaimer =
        "Assistive guidance only — not a substitute for code or engineer judgment."
}
