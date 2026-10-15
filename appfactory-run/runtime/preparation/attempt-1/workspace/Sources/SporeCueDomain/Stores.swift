import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum SporeCueStores {
    public static let forageState = "spore_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "SporeCue"

    /// Keychain service for credential presence (sporecue.ai per technical contract).
    public static let keychainService = "sporecue.ai"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func applicationSupportDirectory(
        fileManager: FileManager = .default
    ) throws -> URL {
        let root = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = root.appendingPathComponent(supportFolderName, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func forageStore(directory: URL) -> AtomicCodableStore<SporeCueState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: forageState))
    }

    public static func aiConsentLocalStore(directory: URL) -> AtomicCodableStore<AIConsentGate.State> {
        AtomicCodableStore(url: storeURL(directory: directory, name: aiConsentLocal))
    }

    public static func apiKeyStore() -> KeychainCredentialStore {
        KeychainCredentialStore(service: keychainService, account: keychainAPIKeyAccount)
    }

    public static func consentKeychainStore() -> KeychainCredentialStore {
        KeychainCredentialStore(service: keychainService, account: keychainConsentAccount)
    }
}
