import Foundation
import AppRuntimeCore

/// AIConsentGate seam: provider DeepSeek, disclosure airspan.consent.v1; local + Keychain existence boundary.
public enum AirspanConsentFacade {
    public static let outboundFieldAllowlist: [String] = [
        "chat_text",
        "airflow_numbers",
        "duct_photo_bytes",
        "duct_run_tags",
        "job_summary",
        "sizing_context"
    ]

    @MainActor
    public static func makeGate(storage: AirspanStorageRoot) -> AIConsentGate {
        AIConsentGate(
            provider: AirspanIdentity.aiProvider,
            disclosureVersion: AirspanIdentity.consentDisclosureVersion,
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
            service: AirspanIdentity.keychainService,
            account: AirspanIdentity.keychainAPIKeyAccount
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
