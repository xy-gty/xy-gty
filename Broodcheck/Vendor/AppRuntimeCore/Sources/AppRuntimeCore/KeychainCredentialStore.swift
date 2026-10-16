import Foundation
#if canImport(Security)
import Security

/// All Security calls run on a private queue. No built-in App identity or secret.
public final class KeychainCredentialStore: @unchecked Sendable {
    public struct Failure: Error, Equatable, Sendable {
        public let status: OSStatus
        public init(status: OSStatus) { self.status = status }
    }
    private let service: String
    private let account: String
    private let queue = DispatchQueue(label: "AppRuntimeCore.credentials")

    public init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    private var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service, kSecAttrAccount as String: account]
    }
    public func load() async throws -> Data? {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                var attributes = self.query
                attributes[kSecReturnData as String] = true
                attributes[kSecMatchLimit as String] = kSecMatchLimitOne
                var result: CFTypeRef?
                let status = SecItemCopyMatching(attributes as CFDictionary, &result)
                if status == errSecItemNotFound { continuation.resume(returning: nil) }
                else if status != errSecSuccess { continuation.resume(throwing: Failure(status: status)) }
                else if let bytes = result as? Data { continuation.resume(returning: bytes) }
                else { continuation.resume(throwing: Failure(status: errSecDecode)) }
            }
        }
    }
    public func save(_ data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                let query = self.query
                var status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
                if status == errSecItemNotFound {
                    var insertion = query
                    insertion[kSecValueData as String] = data
                    insertion[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                    status = SecItemAdd(insertion as CFDictionary, nil)
                    // A concurrent caller can create the item between update and add.
                    if status == errSecDuplicateItem {
                        status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
                    }
                }
                if status == errSecSuccess { continuation.resume() }
                else { continuation.resume(throwing: Failure(status: status)) }
            }
        }
    }
    public func delete() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                let status = SecItemDelete(self.query as CFDictionary)
                if status == errSecSuccess || status == errSecItemNotFound { continuation.resume() }
                else { continuation.resume(throwing: Failure(status: status)) }
            }
        }
    }
}
#endif
