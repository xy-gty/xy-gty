import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum GillnoteStores {
    public static let forageState = "spore_cue_state"
    public static let aiConsentLocal = "ai_consent_local"
    public static let supportFolderName = "Gillnote"
    public static let mediaDirectoryName = "Gillnote"

    /// Keychain service for credential presence (gillnote.ai per technical contract).
    public static let keychainService = "gillnote.ai"
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

    public static func forageStore(directory: URL) -> AtomicCodableStore<GillnoteState> {
        AtomicCodableStore(url: storeURL(directory: directory, name: forageState))
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


/// ForageStore facade — AtomicCodableStore persistence for forage sessions and related entities.
public struct ForageStore {
    private let store: AtomicCodableStore<GillnoteState>

    public init(directory: URL) {
        self.store = GillnoteStores.forageStore(directory: directory)
    }

    public func load() throws -> GillnoteState {
        try store.load() ?? GillnoteState()
    }

    public func save(_ state: GillnoteState) throws {
        try store.save(state)
    }
}
