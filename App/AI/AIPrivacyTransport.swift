import AppRuntimeCore
import Foundation
import CuePartnerDomain

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

    static func partnerReply(
        gate: AIConsentGate,
        apiKey: String,
        sceneTitle: String,
        ocrText: String,
        cueLines: [CueLine],
        partnerRole: String,
        userLine: String,
        voiceTranscript: String?,
        history: [RehearsalMessage]
    ) async throws -> PartnerTurn {
        try await perform(gate: gate, apiKey: apiKey) { client in
            try await client.partnerReply(
                sceneTitle: sceneTitle,
                ocrText: ocrText,
                cueLines: cueLines,
                partnerRole: partnerRole,
                userLine: userLine,
                voiceTranscript: voiceTranscript,
                history: history
            )
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
    static let fieldLabels: [String: String] = [
        "script_page_ocr_text": "Script page OCR text",
        "cue_lines": "Cue lines for the scene",
        "partner_role": "Partner role you selected",
        "user_line_text": "Your typed rehearsal line",
        "voice_transcript": "Spoken-line transcript",
        "chat_text": "Chat messages you enter"
    ]
    static func displayLabel(for fieldId: String) -> String {
        fieldLabels[fieldId] ?? fieldId
    }
}
