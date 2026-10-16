import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum BrewCueStores {
    public static let stateFile = "brewcue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let navigationFile = "navigation_stack"

    /// Keychain service for DeepSeek API key existence + consent mirror.
    public static let keychainService = "com.lingguang.brewcue"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func stateStore(directory: URL) -> AtomicCodableStore<BrewCueState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: stateFile))
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

    @MainActor
    public static func navigationStore(
        directory: URL,
        isValid: @escaping (BrewCueRoutePayload) -> Bool = { _ in true }
    ) -> TypedNavigationStore<BrewCueRoutePayload> {
        TypedNavigationStore(
            url: storeURL(directory: directory, name: navigationFile),
            isValid: isValid
        )
    }
}

/// Brew session CRUD surface (interface name literal; implementation deferred to Builder).
public protocol BrewSessionStore {
    func load() throws -> BrewCueState
    func save(_ state: BrewCueState) throws
    func upsertSession(_ session: BrewSession) throws
    func session(id: String) throws -> BrewSession?
}
