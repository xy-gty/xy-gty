import Foundation
import WingCueDomain

struct SpeciesIDPayload: Sendable {
    var candidates: [SpeciesCandidate]
    var fieldMarks: [FieldMark]
    var lookalike: LookalikePair?
    var coachTip: String
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
            case let .decodeFailed(reason): return "Could not parse species ID: \(reason)"
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

    func identifySpecies(
        sessionId: String,
        photoDescriptor: String,
        confirmedMarks: [String],
        question: String
    ) async throws -> SpeciesIDPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "bird_still": photoDescriptor,
            "user_question": question,
            "confirmed_species_marks": confirmedMarks,
            "lookalike_pair_ids": [] as [String],
            "optional_voice_transcript": "",
        ]

        let system = """
        You are WingCue, an AI birding field coach. Reply with JSON only:
        {"candidates":[{"commonName":"","scientificName":"","confidence":0.0,"rank":1,"silhouetteKey":""}],
         "fieldMarks":[{"candidateRank":1,"label":"","bodyRegion":"","salience":0.0,"chipEmphasis":true}],
         "contrastNotes":"","coachTip":""}
        Rank lookalikes; emphasize field marks a birder can see. Not a ClosetCue/FrameCue/ScoutCue/RuleCue/StopCue twin.
        """

        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseIdentify(content: content, sessionId: sessionId)
    }

    func coachLookalike(
        sessionId: String,
        question: String,
        candidates: [SpeciesCandidate],
        confirmedMarks: [String]
    ) async throws -> String {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let names = candidates.map(\.commonName)
        let payload: [String: Any] = [
            "user_question": question,
            "candidates": names,
            "confirmed_species_marks": confirmedMarks,
        ]
        let system = """
        You are WingCue lookalike coach. Reply JSON only: {"reply":"short contrast tip citing field marks"}.
        """
        let content = try await chat(system: system, userJSON: payload)
        if let data = content.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let reply = obj["reply"] as? String, !reply.isEmpty {
            return reply
        }
        return content
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

    private static func parseIdentify(content: String, sessionId: String) throws -> SpeciesIDPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let rawCandidates = obj["candidates"] as? [[String: Any]] ?? []
        var candidates: [SpeciesCandidate] = []
        for (idx, raw) in rawCandidates.prefix(3).enumerated() {
            let rank = (raw["rank"] as? Int) ?? (idx + 1)
            candidates.append(
                SpeciesCandidate(
                    sessionId: sessionId,
                    scientificName: raw["scientificName"] as? String ?? "Unknown",
                    commonName: raw["commonName"] as? String ?? "Unknown bird",
                    confidence: raw["confidence"] as? Double ?? 0.5,
                    rank: rank,
                    silhouetteKey: raw["silhouetteKey"] as? String ?? "passerine"
                )
            )
        }
        if candidates.isEmpty {
            throw Failure.decodeFailed("no candidates")
        }
        let rawMarks = obj["fieldMarks"] as? [[String: Any]] ?? []
        var marks: [FieldMark] = []
        for raw in rawMarks {
            let rank = raw["candidateRank"] as? Int ?? 1
            let candidateId = candidates.first(where: { $0.rank == rank })?.scientificName
                ?? candidates[0].scientificName
            marks.append(
                FieldMark(
                    candidateId: candidateId,
                    label: raw["label"] as? String ?? "mark",
                    bodyRegion: raw["bodyRegion"] as? String ?? "body",
                    salience: raw["salience"] as? Double ?? 0.5,
                    chipEmphasis: raw["chipEmphasis"] as? Bool ?? true
                )
            )
        }
        var lookalike: LookalikePair?
        if candidates.count >= 2 {
            lookalike = LookalikePair(
                sessionId: sessionId,
                leftCandidateId: candidates[0].scientificName,
                rightCandidateId: candidates[1].scientificName,
                contrastNotes: obj["contrastNotes"] as? String ?? ""
            )
        }
        return SpeciesIDPayload(
            candidates: candidates,
            fieldMarks: marks,
            lookalike: lookalike,
            coachTip: obj["coachTip"] as? String ?? ""
        )
    }
}
