import Foundation
import OnionreelDomain

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

    func coachStopMotion(
        frameSequenceDescriptor: String,
        shotPlanSummary: String,
        timingSummary: String,
        onionSkinNotes: String,
        currentFrameLabel: String,
        chatText: String,
        voiceTranscript: String,
        dictatedIntervalFields: [String],
        priorFeedback: [String],
        projectId: String
    ) async throws -> CoachTurn {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "frame_sequence_descriptor": frameSequenceDescriptor,
            "shot_plan_summary": shotPlanSummary,
            "timing_summary": timingSummary,
            "onion_skin_notes": onionSkinNotes,
            "current_frame_label": currentFrameLabel,
            "chat_text": chatText,
            "voice_transcript": voiceTranscript,
            "dictated_interval_fields": dictatedIntervalFields,
            "prior_feedback": priorFeedback,
        ]

        let system = """
        You are Onionreel's AI stop-motion coach. Reply with JSON only:
        {"reply":"concise next-frame coaching for a stop-motion shooter"}
        Reuse shot plans, timing, onion-skin notes and prior_feedback. Hands may be on the set — keep interval and alignment steps actionable. Not a night-exposure or solar scout twin.
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
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            throw Failure.httpStatus(http.statusCode, bodyText)
        }

        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw Failure.emptyResponse
        }

        let replyText: String
        if let contentData = content.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any],
           let reply = obj["reply"] as? String, !reply.isEmpty {
            replyText = reply
        } else if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            replyText = content
        } else {
            throw Failure.decodeFailed("missing reply")
        }

        return CoachTurn(
            id: UUID().uuidString,
            projectId: projectId,
            role: "coach",
            text: replyText,
            createdAt: Date()
        )
    }
}
