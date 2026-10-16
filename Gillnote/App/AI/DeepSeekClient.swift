import Foundation
import GillnoteDomain

struct SpeciesIDPayload: Sendable {
    var candidates: [SpeciesCandidate]
    var chips: [CautionChip]
    var callouts: [MorphologyCallout]
    var coachTip: String
}

struct CoachReplyPayload: Sendable {
    var reply: String
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
        subject: String,
        confirmedNotes: [String],
        question: String
    ) async throws -> SpeciesIDPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "cap_gill_pore_still": photoDescriptor,
            "subject": subject,
            "user_question": question,
            "confirmed_species_notes": confirmedNotes,
            "active_session_id": sessionId,
            "optional_voice_transcript": "",
        ]

        let system = """
        You are Gillnote, an AI wild-mushroom field coach. Reply with JSON only:
        {"candidates":[{"displayName":"","scientificName":"","confidence":0.0,"rank":1,"morphologyCues":["cue"]}],
         "chipKinds":["info_edible_look","warning_lookalike"],
         "coachTip":""}
        Rank morphological species hypotheses from cap/gill/pore stills.
        NEVER say safe to eat, confirmed edible, or certify consumption.
        Always treat chips as informational only. Do not name Shroomify or Pilze 123.
        Not a Stirboard/Fieldmark/Mattebox/Tablehost/Onionreel/Hemline/Sunbrief twin.
        Include phrase: 非可食认证 / not an edibility certification in coachTip.
        """

        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseIdentify(content: content, sessionId: sessionId, subject: subject)
    }

    func coachLookalike(
        sessionId: String,
        question: String,
        candidates: [SpeciesCandidate],
        confirmedNotes: [String]
    ) async throws -> CoachReplyPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let names = candidates.map(\.displayName)
        let payload: [String: Any] = [
            "user_question": question,
            "candidates": names,
            "confirmed_species_notes": confirmedNotes,
            "active_session_id": sessionId,
        ]
        let system = """
        You are Gillnote lookalike/habitat coach. Reply JSON only: {"reply":"..."}.
        Contrast habitat and morphology. Restate 非可食认证 / not an edibility certification
        whenever edibility or foraging risk is mentioned. Never imply safe to eat.
        Do not name Shroomify or Pilze 123.
        """
        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseCoach(content: content)
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

    private static func parseIdentify(content: String, sessionId: String, subject: String) throws -> SpeciesIDPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let rawCandidates = obj["candidates"] as? [[String: Any]] ?? []
        var candidates: [SpeciesCandidate] = []
        for (idx, raw) in rawCandidates.prefix(5).enumerated() {
            let rank = (raw["rank"] as? Int) ?? (idx + 1)
            let cues = raw["morphologyCues"] as? [String] ?? []
            let conf: Double
            if let d = raw["confidence"] as? Double {
                conf = d
            } else if let n = raw["confidence"] as? NSNumber {
                conf = n.doubleValue
            } else {
                conf = max(0.2, 0.9 - Double(idx) * 0.12)
            }
            candidates.append(
                SpeciesCandidate(
                    sessionId: sessionId,
                    displayName: (raw["displayName"] as? String) ?? "Candidate \(rank)",
                    scientificName: raw["scientificName"] as? String,
                    confidence: min(max(conf, 0), 1),
                    rank: rank,
                    morphologyCues: cues
                )
            )
        }
        let kinds = obj["chipKinds"] as? [String] ?? ["info_edible_look", "warning_lookalike", "unknown"]
        let chips = ChipRailBuilder.informationalChips(sessionId: sessionId, kinds: kinds)
        let topCues = candidates.sorted { $0.rank < $1.rank }.first?.morphologyCues
            ?? ["gill spacing", "pore surface"]
        let callouts = OverlayAnnotator.callouts(from: topCues, sessionId: sessionId, subject: subject)
        var tip = obj["coachTip"] as? String ?? "Morphology candidates ready."
        tip = ChipRailBuilder.ensureDisclaimer(tip)
        return SpeciesIDPayload(candidates: candidates, chips: chips, callouts: callouts, coachTip: tip)
    }

    private static func parseCoach(content: String) throws -> CoachReplyPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let reply = obj["reply"] as? String else {
            throw Failure.decodeFailed("reply")
        }
        return CoachReplyPayload(reply: ChipRailBuilder.ensureDisclaimer(reply))
    }
}
