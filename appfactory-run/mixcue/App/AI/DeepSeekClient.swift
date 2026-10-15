import Foundation
import MixCueDomain

struct SpiritIDPayload: Sendable {
    var candidates: [SpiritCandidate]
    var coachTip: String
}

struct CoachReplyPayload: Sendable {
    var reply: String
    var recipe: RecipeCard?
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
            case let .decodeFailed(reason): return "Could not parse spirit ID: \(reason)"
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

    func identifySpirit(
        sessionId: String,
        photoDescriptor: String,
        subject: String,
        confirmedSpirits: [String],
        question: String
    ) async throws -> SpiritIDPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "bottle_label_garnish_still": photoDescriptor,
            "subject": subject,
            "user_question": question,
            "confirmed_spirits_substitutes": confirmedSpirits,
            "active_recipe_id": "",
            "optional_voice_transcript": "",
        ]

        let system = """
        You are MixCue, an AI home-bar cocktail coach. Reply with JSON only:
        {"candidates":[{"displayName":"","baseSpirit":"","confidence":0.0,"rank":1,"labelCues":["cue"]}],
         "coachTip":""}
        Rank base-spirit candidates from bottle/label/garnish stills. Never name Cocktail Party or Bevnap.
        Not a WingCue/FrameCue/RuleCue/StopCue/ClosetCue/ScoutCue twin.
        """

        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseIdentify(content: content, sessionId: sessionId)
    }

    func coachRecipe(
        sessionId: String,
        question: String,
        candidates: [SpiritCandidate],
        confirmedSpirits: [String]
    ) async throws -> CoachReplyPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let names = candidates.map(\.displayName)
        let payload: [String: Any] = [
            "user_question": question,
            "candidates": names,
            "confirmed_spirits_substitutes": confirmedSpirits,
        ]
        let system = """
        You are MixCue recipe/substitute coach. Reply JSON only:
        {"reply":"short coach answer","recipe":{"title":"","baseSpirit":"","substituteNotes":"",
         "steps":[{"ordinal":1,"action":"pour","amountMl":45,"durationSec":null,"instruction":""}],
         "garnishChips":[{"name":"","placed":false,"accentColor":"#CA8A04"}]}}
        Never name Cocktail Party or Bevnap. Keep steps suitable for a large next-pour card.
        """
        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseCoach(content: content, sessionId: sessionId)
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

    private static func parseIdentify(content: String, sessionId: String) throws -> SpiritIDPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let rawCandidates = obj["candidates"] as? [[String: Any]] ?? []
        var candidates: [SpiritCandidate] = []
        for (idx, raw) in rawCandidates.prefix(4).enumerated() {
            let rank = (raw["rank"] as? Int) ?? (idx + 1)
            let cues = raw["labelCues"] as? [String] ?? []
            candidates.append(
                SpiritCandidate(
                    sessionId: sessionId,
                    displayName: raw["displayName"] as? String ?? "Unknown bottle",
                    baseSpirit: raw["baseSpirit"] as? String ?? "spirit",
                    confidence: (raw["confidence"] as? Double) ?? 0.5,
                    rank: rank,
                    labelCues: cues
                )
            )
        }
        if candidates.isEmpty {
            throw Failure.decodeFailed("empty candidates")
        }
        return SpiritIDPayload(
            candidates: candidates,
            coachTip: obj["coachTip"] as? String ?? ""
        )
    }

    private static func parseCoach(content: String, sessionId: String) throws -> CoachReplyPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("coach root")
        }
        let reply = obj["reply"] as? String ?? content
        var recipe: RecipeCard?
        if let raw = obj["recipe"] as? [String: Any] {
            let recipeId = "ai-\(sessionId.prefix(8))"
            let base = raw["baseSpirit"] as? String ?? "spirit"
            let stepsRaw = raw["steps"] as? [[String: Any]] ?? []
            let steps: [PourStep] = stepsRaw.enumerated().map { idx, step in
                PourStep(
                    sessionId: sessionId,
                    recipeId: recipeId,
                    ordinal: (step["ordinal"] as? Int) ?? (idx + 1),
                    action: step["action"] as? String ?? "pour",
                    amountMl: step["amountMl"] as? Double,
                    durationSec: step["durationSec"] as? Double,
                    instruction: step["instruction"] as? String ?? "Follow the pour card."
                )
            }
            let chipsRaw = raw["garnishChips"] as? [[String: Any]] ?? []
            let chips: [GarnishChip] = chipsRaw.map { chip in
                GarnishChip(
                    sessionId: sessionId,
                    recipeId: recipeId,
                    name: chip["name"] as? String ?? "Garnish",
                    placed: chip["placed"] as? Bool ?? false,
                    accentColor: chip["accentColor"] as? String ?? MixCuePalette.accent
                )
            }
            recipe = RecipeCard(
                sessionId: sessionId,
                title: raw["title"] as? String ?? "Coach mix",
                baseSpirit: base,
                steps: steps.isEmpty ? PourBoardBuilder.placeholderRecipe(sessionId: sessionId, baseSpirit: base).steps : steps,
                garnishChips: chips.isEmpty ? PourBoardBuilder.placeholderRecipe(sessionId: sessionId, baseSpirit: base).garnishChips : chips,
                substituteNotes: raw["substituteNotes"] as? String ?? ""
            )
        }
        return CoachReplyPayload(reply: reply, recipe: recipe)
    }
}
