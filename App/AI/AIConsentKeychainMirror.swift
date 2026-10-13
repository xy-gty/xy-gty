import AppRuntimeCore
import Foundation
import SnagCueDomain

/// Mirrors consent allowance into Keychain as `AIConsentRecord` (contract: Keychain + local JSON).
enum AIConsentKeychainMirror {
    private static let store = KeychainCredentialStore(
        service: SnagCueStores.keychainService,
        account: SnagCueStores.keychainConsentAccount
    )

    static func persist(allowed: Bool) async {
        let record = AIConsentRecord(
            disclosureVersion: AIConsentContract.disclosureVersion,
            allowed: allowed
        )
        guard let data = try? JSONEncoder().encode(record) else { return }
        try? await store.save(data)
    }

    static func clear() async {
        try? await store.delete()
    }
}
