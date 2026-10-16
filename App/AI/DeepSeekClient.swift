import Foundation
import WorkrestDomain

@MainActor
struct DeepSeekClient {
    enum Failure: LocalizedError {
        case notAuthorized
        case missingAPIKey
        case invalidURL
        case httpStatus(Int, String)
        case emptyResponse
        case decodeFailed(String)

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "AI send blocked: consent not granted."
            case .missingAPIKey:
                return "DeepSeek API key not configured."
            case .invalidURL:
                return "DeepSeek endpoint misconfigured."
            case let .httpStatus(code, body):
                return "DeepSeek HTTP \(code): \(body.prefix(200))"
            case .emptyResponse:
                return "DeepSeek returned an empty response."
            case let .decodeFailed(reason):
                return "Could not parse coach response: \(reason)"
            }
        }
    }

    private static let endpoint = URL(string: "https://api.deepseek.com/chat/completions")!
    private static let modelID = "deepseek-chat"

    private let apiKey: String
    private let assertAuthorized: () throws -> Void
    private let session: URLSession

    init(apiKey: String, assertAuthorized: @escaping () throws -> Void, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.assertAuthorized = assertAuthorized
        self.session = session
    }

    func coachForm(
        formPhotoDescriptor: String,
        postureSummary: String,
        intervalPlanSummary: String,
        currentBlockLabel: String,
        correctionFocus: String,
        chatText: String,
        voiceTranscript: String,
        priorFeedback: [String],
        sessionId: String
    ) async throws -> CoachTurn {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "form_photo_descriptor": formPhotoDescriptor,
            "posture_summary": postureSummary,
            "interval_plan_summary": intervalPlanSummary,
            "current_block_label": currentBlockLabel,
            "correction_focus": correctionFocus,
            "chat_text": chatText,
            "voice_transcript": voiceTranscript,
            "prior_feedback": priorFeedback,
        ]

        let system = """
        You are Workrest's AI HIIT form coach. Reply with JSON only:
        {"reply":"concise posture + interval coaching for the athlete"}
        Reuse prior_feedback, posture_summary, and interval_plan_summary. Hands stay on the work — keep cues actionable.
        """
        let body: [String: Any] = [
            "model": Self.modelID,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": String(data: try JSONSerialization.data(withJSONObject: payload), encoding: .utf8) ?? "{}"],
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.4,
        ]

        try assertAuthorized()
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        try assertAuthorized()

        guard let http = response as? HTTPURLResponse else {
            throw Failure.httpStatus(-1, "non-HTTP response")
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            let snippet = String(data: data, encoding: .utf8) ?? ""
            throw Failure.httpStatus(http.statusCode, snippet)
        }

        let api = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = api.choices.first?.message.content, !content.isEmpty else {
            throw Failure.emptyResponse
        }
        let reply = try parseReply(content)
        return CoachTurn(
            id: UUID().uuidString,
            sessionId: sessionId,
            role: "coach",
            text: reply,
            createdAt: Date()
        )
    }

    private struct ChatCompletionResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String? }
            let message: Message
        }
        let choices: [Choice]
    }

    private struct CoachJSON: Decodable {
        let reply: String?
    }

    private func parseReply(_ content: String) throws -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else {
            throw Failure.decodeFailed("invalid UTF-8")
        }
        do {
            let decoded = try JSONDecoder().decode(CoachJSON.self, from: data)
            let reply = (decoded.reply ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if reply.isEmpty { throw Failure.emptyResponse }
            return reply
        } catch {
            if trimmed.count > 12 { return trimmed }
            throw Failure.decodeFailed(error.localizedDescription)
        }
    }
}
