import Foundation
import AppRuntimeCore

/// AIConsentGate seam: provider DeepSeek, disclosure hemline.consent.v1; local + Keychain existence boundary.
public enum HemlineConsentFacade {
    public static let outboundFieldAllowlist: [String] = [
        "chat_text",
        "weather_occasion",
        "garment_photo_bytes",
        "garment_tags",
        "closet_summary",
        "outfit_context"
    ]

    @MainActor
    public static func makeGate(storage: HemlineStorageRoot) -> AIConsentGate {
        AIConsentGate(
            provider: HemlineIdentity.aiProvider,
            disclosureVersion: HemlineIdentity.consentDisclosureVersion,
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
            service: HemlineIdentity.keychainService,
            account: HemlineIdentity.keychainAPIKeyAccount
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
