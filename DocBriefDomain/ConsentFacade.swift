import Foundation
import AppRuntimeCore

/// AIConsentGate seam: provider DeepSeek, disclosure docbrief.consent.v1; local + Keychain existence boundary.
public enum DocBriefConsentFacade {
    public static let outboundFieldAllowlist: [String] = [
        "document_photo_bytes",
        "recognized_type",
        "extracted_fields",
        "chat_text",
        "action_hints"
    ]

    @MainActor
    public static func makeGate(storage: DocBriefStorageRoot) -> AIConsentGate {
        AIConsentGate(
            provider: DocBriefIdentity.aiProvider,
            disclosureVersion: DocBriefIdentity.consentDisclosureVersion,
            load: {
                guard let record = try storage.consentLocal.load() else { return nil }
                return AIConsentGate.State(
                    provider: record.provider,
                    disclosureVersion: record.disclosureVersion,
                    generation: record.generation,
                    granted: record.granted
                )
            },
            persist: { state in
                try storage.consentLocal.save(
                    AIConsentRecord(
                        provider: state.provider,
                        disclosureVersion: state.disclosureVersion,
                        generation: state.generation,
                        granted: state.granted,
                        updatedAt: Date()
                    )
                )
            }
        )
    }

#if canImport(Security)
    public static func makeAPIKeyStore() -> KeychainCredentialStore {
        KeychainCredentialStore(
            service: DocBriefIdentity.keychainService,
            account: DocBriefIdentity.keychainAPIKeyAccount
        )
    }

    /// Existence-only probe; never reads the secret into product logs.
    public static func apiKeyConfigured(_ store: KeychainCredentialStore? = nil) async -> Bool {
        let resolved = store ?? makeAPIKeyStore()
        do {
            guard let data = try await resolved.load() else { return false }
            return !data.isEmpty
        } catch {
            return false
        }
    }
#endif
}
