import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum CellarCueStores {
    public static let cellarState = "cellar_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "CellarCue"

    /// Keychain service for credential presence (cellarcue.ai per technical contract).
    public static let keychainService = "cellarcue.ai"
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

    public static func cellarStore(directory: URL) -> AtomicCodableStore<CellarCueState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: cellarState))
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
