import Foundation
import RacknoteDomain

struct LabelOCRPayload: Sendable {
    var producer: String
    var vintage: String
    var varietal: String
    var region: String
    var rawText: String
    var confidence: Double
    var suggestedBinLabel: String?
    var timelinePoints: [String]
    var windowStatus: String
    var coachTip: String
}

struct CoachReplyPayload: Sendable {
    var reply: String
    var pairingDish: String?
    var pairingRationale: String?
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
            case let .decodeFailed(reason): return "Could not parse label OCR: \(reason)"
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

    func identifyLabel(
        bottleId: String,
        photoDescriptor: String,
        captureSubject: String,
        confirmedNotes: [String],
        question: String
    ) async throws -> LabelOCRPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "label_still": photoDescriptor,
            "subject": captureSubject,
            "user_question": question,
            "confirmed_bottle_notes": confirmedNotes,
            "active_bottle_or_bin_id": bottleId,
            "optional_voice_transcript": "",
        ]

        let system = """
        You are Racknote, an AI wine-cellar coach. Reply with JSON only:
        {"producer":"","vintage":"","varietal":"","region":"","rawText":"","confidence":0.0,
         "suggestedBinLabel":"R1-B1","timelinePoints":["hold:2026","approaching:2028","open:2030","past:2038"],
         "windowStatus":"hold","coachTip":""}
        Structure label OCR for bin placement and drinking-window timeline.
        NEVER claim sommelier certification, certified tasting, or investment returns.
        Always include phrases in coachTip: 非侍酒认证 / not a sommelier certification; 非投资建议 / not investment advice; 21+.
        Do not name Vinocell. Not a Stirboard/Gillnote/Fieldmark/Mattebox/Tablehost/Onionreel twin.
        """

        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseOCR(content: content)
    }

    func coachWindowPairing(
        bottleId: String,
        question: String,
        bottleSummary: String,
        confirmedNotes: [String]
    ) async throws -> CoachReplyPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "user_question": question,
            "bottle_summary": bottleSummary,
            "confirmed_bottle_notes": confirmedNotes,
            "active_bottle_or_bin_id": bottleId,
        ]
        let system = """
        You are Racknote drinking-window and food-pairing coach. Reply JSON only:
        {"reply":"...","pairingDish":"...","pairingRationale":"..."}
        Restate 非侍酒认证 / not a sommelier certification and 非投资建议 / not investment advice and 21+
        whenever alcohol advice appears. Never claim certified tasting or investment returns.
        Do not name Vinocell.
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

    private static func parseOCR(content: String) throws -> LabelOCRPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let conf: Double
        if let d = obj["confidence"] as? Double {
            conf = d
        } else if let n = obj["confidence"] as? NSNumber {
            conf = n.doubleValue
        } else {
            conf = 0.7
        }
        var tip = obj["coachTip"] as? String ?? "Label fields ready for bin placement."
        tip = CellarComplianceCopy.ensureDisclaimers(tip)
        return LabelOCRPayload(
            producer: (obj["producer"] as? String) ?? "Unknown producer",
            vintage: (obj["vintage"] as? String) ?? "",
            varietal: (obj["varietal"] as? String) ?? "",
            region: (obj["region"] as? String) ?? "",
            rawText: (obj["rawText"] as? String) ?? "",
            confidence: min(max(conf, 0), 1),
            suggestedBinLabel: obj["suggestedBinLabel"] as? String,
            timelinePoints: (obj["timelinePoints"] as? [String]) ?? [],
            windowStatus: (obj["windowStatus"] as? String) ?? "hold",
            coachTip: tip
        )
    }

    private static func parseCoach(content: String) throws -> CoachReplyPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let reply = obj["reply"] as? String else {
            throw Failure.decodeFailed("reply")
        }
        return CoachReplyPayload(
            reply: CellarComplianceCopy.ensureDisclaimers(reply),
            pairingDish: obj["pairingDish"] as? String,
            pairingRationale: obj["pairingRationale"] as? String
        )
    }
}
