import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum SpinewellStores {
    public static let stateFile = "spinewell_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let navigationFile = "navigation_stack"

    /// Keychain service per technical contract (KeychainCredentialStore role).
    public static let keychainService = "spinewell.ai"
    public static let keychainAPIKeyAccount = "DEEPSEEK_API_KEY"
    public static let keychainConsentAccount = "ai_consent_record"

    public static func storeURL(directory: URL, name: String) -> URL {
        directory.appendingPathComponent("\(name).json", isDirectory: false)
    }

    public static func stateStore(directory: URL) -> AtomicCodableStore<SpinewellState> {
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
        isValid: @escaping (SpinewellRoutePayload) -> Bool = { _ in true }
    ) -> TypedNavigationStore<SpinewellRoutePayload> {
        TypedNavigationStore(
            url: storeURL(directory: directory, name: navigationFile),
            isValid: isValid
        )
    }
}

/// ShelfStore facade — AtomicCodableStore persistence for shelf sessions and related entities.
public struct ShelfStore {
    private let store: AtomicCodableStore<SpinewellState>

    public init(directory: URL) {
        self.store = SpinewellStores.stateStore(directory: directory)
    }

    public func load() throws -> SpinewellState {
        try store.load() ?? SpinewellState()
    }

    public func save(_ state: SpinewellState) throws {
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

public enum SpinewellNavigation {
    public static func isValid(_ route: SpinewellRoute) -> Bool {
        SpinewellRoute.allCases.contains(route)
    }
}
