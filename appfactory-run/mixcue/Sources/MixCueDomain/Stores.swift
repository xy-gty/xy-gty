import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum MixCueStores {
    public static let mixState = "mix_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "MixCue"
    public static let mediaDirectoryName = "MixCue"

    /// Keychain service for credential presence (mixcue.ai per technical contract).
    public static let keychainService = "mixcue.ai"
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

    public static func mixStore(directory: URL) -> AtomicCodableStore<MixCueState> {
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
    private let store: AtomicCodableStore<MixCueState>

    public init(directory: URL) {
        self.store = MixCueStores.mixStore(directory: directory)
    }

    public func load() throws -> MixCueState {
        try store.load() ?? MixCueState()
    }

    public func save(_ state: MixCueState) throws {
        try store.save(state)
    }
}
