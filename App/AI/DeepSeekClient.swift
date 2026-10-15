import Foundation
import FinishCueDomain

struct LaneReadDraft: Sendable {
    var laneNumber: Int
    var athleteLabel: String
    var timeRead: String
}

struct ReadTimesPayload: Sendable {
    var drafts: [LaneReadDraft]
    var stripDesc: String
}

struct CoachReplyPayload: Sendable {
    var reply: String
    var heatOrderNote: String
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
            case let .decodeFailed(reason): return "Could not parse lane reads: \(reason)"
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

    func readTimes(
        stripDesc: String,
        laneGuesses: [Int],
        athleteLabels: [String],
        rawTimeReads: [String],
        priorLaneReads: [String],
        userFeedback: String,
        speechTranscript: String
    ) async throws -> ReadTimesPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "strip_desc": stripDesc,
            "lane_guesses": laneGuesses,
            "athlete_labels": athleteLabels,
            "raw_time_reads": rawTimeReads,
            "prior_lane_reads": priorLaneReads,
            "user_feedback": userFeedback,
            "speech_transcript": speechTranscript,
            "heat_question": "",
        ]
        let system = """
        You are FinishCue, an AI finish-line coach for training and amateur meet photo timing.
        Reply JSON only: {"strip_desc":"","lanes":[{"lane":1,"athlete":"","time":"12.34"}]}
        Not an official FAT timing device. Not betting. Not anti-doping enforcement.
        Never name SprintTimer or competitor brands. Not FormCue HIIT. Not StopCue onion-skin.
        """
        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseReads(content: content, fallbackDesc: stripDesc)
    }

    func coachHeat(
        heatQuestion: String,
        speechTranscript: String,
        priorLaneReads: [String],
        userFeedback: String
    ) async throws -> CoachReplyPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "heat_question": heatQuestion,
            "speech_transcript": speechTranscript,
            "prior_lane_reads": priorLaneReads,
            "user_feedback": userFeedback,
            "strip_desc": "",
            "lane_guesses": [],
            "athlete_labels": [],
            "raw_time_reads": [],
        ]
        let system = """
        You are FinishCue heat coach. Reply JSON only:
        {"reply":"short coach answer","heat_order_note":"lane order summary"}
        Training aid / amateur meet photo timing only. Not official FAT. Not betting. Not anti-doping.
        Never name SprintTimer.
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

    private static func parseReads(content: String, fallbackDesc: String) throws -> ReadTimesPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let desc = (obj["strip_desc"] as? String) ?? fallbackDesc
        let lanes = obj["lanes"] as? [[String: Any]] ?? []
        let drafts: [LaneReadDraft] = lanes.compactMap { row in
            let lane = row["lane"] as? Int ?? Int(row["lane"] as? String ?? "") ?? 0
            guard lane > 0 else { return nil }
            return LaneReadDraft(
                laneNumber: lane,
                athleteLabel: (row["athlete"] as? String) ?? "",
                timeRead: (row["time"] as? String) ?? ""
            )
        }
        guard !drafts.isEmpty else { throw Failure.decodeFailed("empty lanes") }
        return ReadTimesPayload(drafts: drafts, stripDesc: desc)
    }

    private static func parseCoach(content: String) throws -> CoachReplyPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("coach root")
        }
        let reply = (obj["reply"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !reply.isEmpty else { throw Failure.decodeFailed("empty reply") }
        return CoachReplyPayload(
            reply: reply,
            heatOrderNote: (obj["heat_order_note"] as? String) ?? ""
        )
    }
}
