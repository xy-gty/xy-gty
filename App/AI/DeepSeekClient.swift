import Foundation
import BrewCueDomain

struct PourStepDraft: Sendable {
    var kind: String
    var pourIndex: Int
    var targetGrams: Double?
    var targetSeconds: Double?
    var note: String
}

struct CoachBrewPayload: Sendable {
    var steps: [PourStepDraft]
    var grind: String?
    var shotDesc: String
}

struct CoachChatPayload: Sendable {
    var reply: String
    var nextGrams: Double?
    var nextSeconds: Double?
}

@MainActor
struct DeepSeekClient {
    enum Failure: LocalizedError {
        case notAuthorized
        case missingAPIKey
        case httpStatus(Int, String)
        case emptyResponse
        case decodeFailed(String)

        var errorDescription: String? {
            switch self {
            case .notAuthorized: return "AI send blocked: consent not granted."
            case .missingAPIKey: return "DeepSeek API key not configured."
            case let .httpStatus(code, body): return "DeepSeek HTTP \(code): \(body.prefix(200))"
            case .emptyResponse: return "DeepSeek returned an empty response."
            case let .decodeFailed(reason): return "Could not parse brew coach reply: \(reason)"
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

    func coachBrew(
        shotDesc: String,
        beanGuess: String,
        grindGuess: String,
        bloomNote: String,
        pourGuesses: [String],
        cremaNote: String,
        brewQuestion: String,
        speechTranscript: String,
        priorPourSteps: [String],
        userFeedback: String
    ) async throws -> CoachBrewPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "shot_desc": shotDesc,
            "bean_guess": beanGuess,
            "grind_guess": grindGuess,
            "bloom_note": bloomNote,
            "pour_guesses": pourGuesses,
            "crema_note": cremaNote,
            "brew_question": brewQuestion,
            "speech_transcript": speechTranscript,
            "prior_pour_steps": priorPourSteps,
            "user_feedback": userFeedback,
        ]
        let system = """
        You are BrewCue, an AI home pour-over coach only.
        Reply JSON only: {"shot_desc":"","grind":"medium","steps":[{"kind":"bloom|pour|drawdown","pour_index":0,"grams":40,"seconds":30,"note":""}]}
        Home brew coach only; not barista certification; not nutrition/medical; not equipment warranty; no alcohol-service claims.
        Never name The Great Coffee App or competitors. Not MixCue/CellarCue/FolioCue/FinishCue/PantryCue.
        """
        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseBrew(content: content, fallbackDesc: shotDesc)
    }

    func coachChat(
        brewQuestion: String,
        speechTranscript: String,
        priorPourSteps: [String],
        userFeedback: String,
        grindGuess: String
    ) async throws -> CoachChatPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "brew_question": brewQuestion,
            "speech_transcript": speechTranscript,
            "prior_pour_steps": priorPourSteps,
            "user_feedback": userFeedback,
            "grind_guess": grindGuess,
            "shot_desc": "",
            "bean_guess": "",
            "bloom_note": "",
            "pour_guesses": [],
            "crema_note": "",
        ]
        let system = """
        You are BrewCue chat coach. Reply JSON only:
        {"reply":"short coach answer","next_grams":60,"next_seconds":30}
        Home brew coach only; not barista certification; not nutrition/medical; not equipment warranty; no alcohol-service claims.
        Never name The Great Coffee App.
        """
        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseChat(content: content)
    }

    private func chat(system: String, userJSON: [String: Any]) async throws -> String {
        try assertAuthorized()
        let body: [String: Any] = [
            "model": Self.modelID,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": String(data: try JSONSerialization.data(withJSONObject: userJSON), encoding: .utf8) ?? "{}"],
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.35,
        ]
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
            throw Failure.httpStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw Failure.emptyResponse
        }
        return content
    }

    private static func parseBrew(content: String, fallbackDesc: String) throws -> CoachBrewPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let desc = (obj["shot_desc"] as? String) ?? fallbackDesc
        let grind = obj["grind"] as? String
        let rows = obj["steps"] as? [[String: Any]] ?? []
        let steps: [PourStepDraft] = rows.compactMap { row in
            let kind = (row["kind"] as? String) ?? "pour"
            let pourIndex = row["pour_index"] as? Int ?? Int(row["pour_index"] as? String ?? "") ?? 0
            let grams = row["grams"] as? Double ?? (row["grams"] as? Int).map(Double.init)
            let seconds = row["seconds"] as? Double ?? (row["seconds"] as? Int).map(Double.init)
            return PourStepDraft(
                kind: kind,
                pourIndex: pourIndex,
                targetGrams: grams,
                targetSeconds: seconds,
                note: (row["note"] as? String) ?? ""
            )
        }
        guard !steps.isEmpty else { throw Failure.decodeFailed("empty steps") }
        return CoachBrewPayload(steps: steps, grind: grind, shotDesc: desc)
    }

    private static func parseChat(content: String) throws -> CoachChatPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("chat root")
        }
        let reply = (obj["reply"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !reply.isEmpty else { throw Failure.decodeFailed("empty reply") }
        let grams = obj["next_grams"] as? Double ?? (obj["next_grams"] as? Int).map(Double.init)
        let secs = obj["next_seconds"] as? Double ?? (obj["next_seconds"] as? Int).map(Double.init)
        return CoachChatPayload(reply: reply, nextGrams: grams, nextSeconds: secs)
    }
}
