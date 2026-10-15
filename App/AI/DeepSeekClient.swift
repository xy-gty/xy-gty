import Foundation
import LuxCueDomain

struct ExposureIDPayload: Sendable {
    var ev: Double
    var aperture: String
    var shutter: String
    var iso: String
    var confidence: Double
    var rationale: String
    var zoneHint: String
}

struct CoachReplyPayload: Sendable {
    var reply: String
    var strategy: String
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
            case let .decodeFailed(reason): return "Could not parse exposure ID: \(reason)"
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

    func identifyExposure(
        sessionId: String,
        photoDescriptor: String,
        zoneHint: String,
        confirmedNotes: [String],
        question: String
    ) async throws -> ExposureIDPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "spot_or_imported_still": photoDescriptor,
            "user_question": question,
            "confirmed_exposure_notes": confirmedNotes,
            "active_session_id": sessionId,
            "optional_voice_transcript": "",
            "zone_hint": zoneHint,
        ]
        let system = """
        You are LuxCue, an AI exposure / light-meter coach. Reply with JSON only:
        {"ev":0.0,"aperture":"f/2.8","shutter":"1/125","iso":"200","confidence":0.0,"rationale":"","zoneHint":"V"}
        Suggest EV / aperture / shutter / ISO with zone advice for photography lighting.
        ALWAYS include in rationale: 非校准实验室仪表 / not a calibrated lab instrument; 非医疗用光 / not for medical lighting.
        NEVER claim lab calibration or medical lighting use. Do not name myLightMeter.
        Not a FrameCue/NightCue/ScoutCue/StopCue/CellarCue/MixCue/SporeCue twin.
        """
        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseExposure(content: content)
    }

    func coachZoneFilmDigital(
        sessionId: String,
        question: String,
        sessionSummary: String,
        confirmedNotes: [String]
    ) async throws -> CoachReplyPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "user_question": question,
            "session_summary": sessionSummary,
            "confirmed_exposure_notes": confirmedNotes,
            "active_session_id": sessionId,
        ]
        let system = """
        You are LuxCue zone / film / digital coach. Reply JSON only:
        {"reply":"...","strategy":"zone|film|digital"}
        Restate 非校准实验室仪表 / not a calibrated lab instrument and 非医疗用光 / not for medical lighting.
        Never claim lab calibration or medical lighting. Do not name myLightMeter.
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

    private static func parseExposure(content: String) throws -> ExposureIDPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("not JSON")
        }
        let ev = (obj["ev"] as? Double) ?? Double(obj["ev"] as? String ?? "") ?? 0
        let rationale = LuxCueComplianceCopy.ensureDisclaimers((obj["rationale"] as? String) ?? "")
        return ExposureIDPayload(
            ev: ev,
            aperture: (obj["aperture"] as? String) ?? "f/2.8",
            shutter: (obj["shutter"] as? String) ?? "1/125",
            iso: (obj["iso"] as? String) ?? "200",
            confidence: (obj["confidence"] as? Double) ?? 0.5,
            rationale: rationale,
            zoneHint: (obj["zoneHint"] as? String) ?? "V"
        )
    }

    private static func parseCoach(content: String) throws -> CoachReplyPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("coach not JSON")
        }
        let reply = LuxCueComplianceCopy.ensureDisclaimers((obj["reply"] as? String) ?? "")
        return CoachReplyPayload(
            reply: reply,
            strategy: (obj["strategy"] as? String) ?? "zone"
        )
    }
}
