import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum FieldmarkStores {
    public static let fieldmarkState = "fieldmark_state"
    public static let aiConsentLocal = "ai_consent_local"

    /// Keychain service for credential presence (fieldmark.ai per technical contract).
    public static let keychainService = "fieldmark.ai"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"

    public static let mediaDirectoryName = "Fieldmark"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func supportDirectory(base: URL) -> URL {
        base.appendingPathComponent(mediaDirectoryName, isDirectory: true)
    }

    public static func sightingStore(directory: URL) -> AtomicCodableStore<FieldmarkState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: fieldmarkState))
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
    private let store: AtomicCodableStore<FieldmarkState>

    public init(directory: URL) {
        self.store = FieldmarkStores.sightingStore(directory: directory)
    }

    public func load() throws -> FieldmarkState {
        try store.load() ?? FieldmarkState()
    }

    public func save(_ state: FieldmarkState) throws {
        try store.save(state)
    }
}
