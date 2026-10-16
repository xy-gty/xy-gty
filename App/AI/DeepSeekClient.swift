import Foundation
import CountroomDomain

/// HTTPS DeepSeek chat completions for practice coaching (text context only).
@MainActor
struct DeepSeekClient {
    enum Failure: LocalizedError {
        case notAuthorized
        case missingAPIKey
        case invalidURL
        case httpStatus(Int, String)
        case emptyResponse
        case decodeFailed(String)
        case modelRefused(String)

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
            case let .modelRefused(reason):
                return reason
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

    func coachPractice(
        sheetPhotoDesc: String,
        instrumentLabel: String,
        userGoal: String,
        speechTranscript: String,
        priorPlanSteps: [String],
        coachQuestion: String,
        userFeedback: String,
        sessionId: String
    ) async throws -> (plan: PracticePlan, turn: CoachTurn) {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload = CoachPayload(
            sheet_photo_desc: sheetPhotoDesc,
            instrument_label: instrumentLabel,
            user_goal: userGoal,
            speech_transcript: speechTranscript,
            prior_plan_steps: priorPlanSteps,
            coach_question: coachQuestion,
            user_feedback: userFeedback
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let payloadJSON = String(data: try encoder.encode(payload), encoding: .utf8) ?? "{}"

        let system = """
        You are Countroom's AI practice coach for instrumentalists. Reply with JSON only:
        {"steps":[{"title":"short","durationSec":number,"tip":"spoken tip"}],"reply":"coach chat reply"}
        Coaching aid only — not a medical or professional tuner replacement. Reuse prior_plan_steps and user_feedback when present.
        """
        let body: [String: Any] = [
            "model": Self.modelID,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": payloadJSON],
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
        return try parseCoachJSON(content, sessionId: sessionId)
    }

    private struct CoachPayload: Encodable {
        let sheet_photo_desc: String
        let instrument_label: String
        let user_goal: String
        let speech_transcript: String
        let prior_plan_steps: [String]
        let coach_question: String
        let user_feedback: String
    }

    private struct ChatCompletionResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String? }
            let message: Message
        }
        let choices: [Choice]
    }

    private struct CoachJSON: Decodable {
        struct Step: Decodable {
            let title: String?
            let durationSec: Double?
            let tip: String?
        }
        let steps: [Step]?
        let reply: String?
    }

    private func parseCoachJSON(_ content: String, sessionId: String) throws -> (plan: PracticePlan, turn: CoachTurn) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else {
            throw Failure.decodeFailed("invalid UTF-8")
        }
        let decoded: CoachJSON
        do {
            decoded = try JSONDecoder().decode(CoachJSON.self, from: data)
        } catch {
            throw Failure.decodeFailed(error.localizedDescription)
        }
        let steps = (decoded.steps ?? []).compactMap { step -> String? in
            let title = (step.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return nil }
            let dur = Int(step.durationSec ?? 60)
            let tip = (step.tip ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return "\(title)|\(dur)|\(tip)"
        }
        guard !steps.isEmpty else {
            throw Failure.modelRefused("Coach did not return practice steps.")
        }
        let plan = PracticePlan(
            id: UUID().uuidString,
            sessionId: sessionId,
            steps: steps,
            status: "draft",
            updatedAt: Date()
        )
        let reply = (decoded.reply ?? "Here is a warm-up plan to review.").trimmingCharacters(in: .whitespacesAndNewlines)
        let turn = CoachTurn(
            id: UUID().uuidString,
            sessionId: sessionId,
            role: "coach",
            text: reply,
            feedbackMark: nil,
            createdAt: Date()
        )
        return (plan, turn)
    }
}
