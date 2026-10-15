import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum FolioCueStores {
    public static let stateFile = "foliocue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let navigationFile = "navigation_stack"

    /// Keychain service per technical contract (KeychainCredentialStore role).
    public static let keychainService = "foliocue.ai"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func stateStore(directory: URL) -> AtomicCodableStore<FolioCueState> {
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
        isValid: @escaping (FolioCueRoutePayload) -> Bool = { _ in true }
    ) -> TypedNavigationStore<FolioCueRoutePayload> {
        TypedNavigationStore(
            url: storeURL(directory: directory, name: navigationFile),
            isValid: isValid
        )
    }
}

/// ShelfStore facade — AtomicCodableStore persistence for shelf sessions and related entities.
public struct ShelfStore {
    private let store: AtomicCodableStore<FolioCueState>

    public init(directory: URL) {
        self.store = FolioCueStores.stateStore(directory: directory)
    }

    public func load() throws -> FolioCueState {
        try store.load() ?? FolioCueState()
    }

    public func save(_ state: FolioCueState) throws {
        try store.save(state)
    }

    public func upsertSession(_ session: ShelfSession) throws {
        var state = try load()
        if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
            state.sessions[idx] = session
        } else {
            state.sessions.insert(session, at: 0)
        }
        try save(state)
    }

    public func session(id: String) throws -> ShelfSession? {
        try load().sessions.first(where: { $0.id == id })
    }
}

public enum FolioCueNavigation {
    public static func isValid(_ route: FolioCueRoute) -> Bool {
        FolioCueRoute.allCases.contains(route)
    }
}
