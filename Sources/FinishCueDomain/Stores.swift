import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum FinishCueStores {
    public static let stateFile = "finishcue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let navigationFile = "navigation_stack"

    /// Keychain service for DeepSeek API key existence + consent mirror.
    public static let keychainService = "com.lingguang.finishcue"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func stateStore(directory: URL) -> AtomicCodableStore<FinishCueState> {
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
        isValid: @escaping (FinishCueRoutePayload) -> Bool = { _ in true }
    ) -> TypedNavigationStore<FinishCueRoutePayload> {
        TypedNavigationStore(
            url: storeURL(directory: directory, name: navigationFile),
            isValid: isValid
        )
    }
}

/// Heat pack CRUD surface (interface name literal; implementation deferred to Builder).
public protocol HeatPackStore {
    func load() throws -> FinishCueState
    func save(_ state: FinishCueState) throws
    func upsertHeatPack(_ pack: HeatPack) throws
    func heatPack(id: String) throws -> HeatPack?
}
