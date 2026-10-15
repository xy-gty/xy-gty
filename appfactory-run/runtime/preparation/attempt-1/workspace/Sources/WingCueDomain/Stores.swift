import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum WingCueStores {
    public static let wingCueState = "wingcue_state"
    public static let aiConsentLocal = "ai_consent_local"

    /// Keychain service for credential presence (wingcue.ai per technical contract).
    public static let keychainService = "wingcue.ai"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static let mediaDirectoryName = "WingCue"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func supportDirectory(base: URL) -> URL {
        base.appendingPathComponent(mediaDirectoryName, isDirectory: true)
    }

    public static func sightingStore(directory: URL) -> AtomicCodableStore<WingCueState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: wingCueState))
    }

    public static func aiConsentLocalStore(directory: URL) -> AtomicCodableStore<AIConsentRecord> {
        AtomicCodableStore(url: storeURL(directory: directory, name: aiConsentLocal))
    }

    public static func apiKeyStore() -> KeychainCredentialStore {
        KeychainCredentialStore(service: keychainService, account: keychainAPIKeyAccount)
    }

    public static func consentKeychainStore() -> KeychainCredentialStore {
        KeychainCredentialStore(service: keychainService, account: keychainConsentAccount)
    }
}

/// SightingStore facade — AtomicCodableStore persistence for sessions and related entities.
public struct SightingStore {
    private let store: AtomicCodableStore<WingCueState>

    public init(directory: URL) {
        self.store = WingCueStores.sightingStore(directory: directory)
    }

    public func load() throws -> WingCueState {
        try store.load() ?? WingCueState()
    }

    public func save(_ state: WingCueState) throws {
        try store.save(state)
    }
}
