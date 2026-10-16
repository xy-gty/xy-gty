import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum RacknoteStores {
    public static let cellarState = "cellar_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "Racknote"
    public static let mediaDirectoryName = "Racknote"

    /// Keychain service for credential presence (racknote.ai per technical contract).
    public static let keychainService = "racknote.ai"
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

    public static func cellarStore(directory: URL) -> AtomicCodableStore<RacknoteState> {
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

/// CellarStore facade — AtomicCodableStore persistence for racks, bins, bottles, and related entities.
public struct CellarStore {
    private let store: AtomicCodableStore<RacknoteState>

    public init(directory: URL) {
        self.store = RacknoteStores.cellarStore(directory: directory)
    }

    public func load() throws -> RacknoteState {
        try store.load() ?? RacknoteState()
    }

    public func save(_ state: RacknoteState) throws {
        try store.save(state)
    }
}
