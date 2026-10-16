import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum StirboardStores {
    public static let mixState = "mix_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "Stirboard"
    public static let mediaDirectoryName = "Stirboard"

    /// Keychain service for credential presence (stirboard.ai per technical contract).
    public static let keychainService = "stirboard.ai"
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

    public static func mixStore(directory: URL) -> AtomicCodableStore<StirboardState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: mixState))
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

/// MixStore facade — AtomicCodableStore persistence for mix sessions and related entities.
public struct MixStore {
    private let store: AtomicCodableStore<StirboardState>

    public init(directory: URL) {
        self.store = StirboardStores.mixStore(directory: directory)
    }

    public func load() throws -> StirboardState {
        try store.load() ?? StirboardState()
    }

    public func save(_ state: StirboardState) throws {
        try store.save(state)
    }
}
