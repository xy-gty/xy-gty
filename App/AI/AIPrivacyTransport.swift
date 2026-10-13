import AppRuntimeCore
import Foundation
import SnagCueDomain

/// Outbound DeepSeek calls wrapped with `AIConsentGate` permit validation and in-flight revoke cancellation.
@MainActor
enum AIPrivacyTransport {
    enum Failure: LocalizedError {
        case notAuthorized
        case notConfigured

        var errorDescription: String? {
            switch self {
            case .notAuthorized: return "AI data sharing not authorized"
            case .notConfigured: return "DeepSeek API key not configured"
            }
        }
    }

    static func detectSnags(
        gate: AIConsentGate,
        apiKey: String,
        photos: [URL],
        priorLabels: [String],
        auditId: String
    ) async throws -> [SnagDraft] {
        try await perform(gate: gate, apiKey: apiKey) { client in
            try await client.detectSnags(photos: photos, priorLabels: priorLabels, auditId: auditId)
        }
    }

    static func suggestFieldPatch(
        gate: AIConsentGate,
        apiKey: String,
        item: PunchItem,
        chatText: String,
        priorFeedback: [String]
    ) async throws -> FieldPatchDraft {
        try await perform(gate: gate, apiKey: apiKey) { client in
            try await client.suggestFieldPatch(item: item, chatText: chatText, priorFeedback: priorFeedback)
        }
    }

    static func annotateCaption(
        gate: AIConsentGate,
        apiKey: String,
        items: [PunchItem]
    ) async throws -> String {
        try await perform(gate: gate, apiKey: apiKey) { client in
            try await client.annotateCaption(items: items)
        }
    }

    private static func perform<T>(
        gate: AIConsentGate,
        apiKey: String,
        operation: @escaping @MainActor (DeepSeekClient) async throws -> T
    ) async throws -> T {
        guard !apiKey.isEmpty else { throw Failure.notConfigured }
        let permit = try gate.permit()
        return try await gate.perform(permit: permit) {
            let client = DeepSeekClient(apiKey: apiKey, assertAuthorized: { try gate.validate(permit) })
            return try await operation(client)
        }
    }
}

extension AIConsentContract {
    /// User-visible labels for consent disclosure (technical ids in `fields`).
    static let fieldLabels: [String: String] = [
        "walkthrough_photo_bytes": "Walkthrough photo data",
        "punch_item_fields": "Punch-list field values",
        "chat_text": "Chat messages you enter",
        "snag_labels": "Snag titles and labels"
    ]

    static func displayLabel(for fieldId: String) -> String {
        fieldLabels[fieldId] ?? fieldId
    }
}
