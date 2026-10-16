import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum ZonelightStores {
    public static let meterState = "lux_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "Zonelight"

    /// Keychain service for credential presence (zonelight.ai per technical contract).
    public static let keychainService = "zonelight.ai"
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

    public static func meterStore(directory: URL) -> AtomicCodableStore<ZonelightState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: meterState))
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
