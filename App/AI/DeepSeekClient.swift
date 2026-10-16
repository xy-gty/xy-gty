import Foundation
import AirspanDomain

enum DeepSeekClientError: Error, LocalizedError {
    case notConfigured
    case notAuthorized
    case http(status: Int, detail: String?)
    case decode(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "DeepSeek API key is not configured."
        case .notAuthorized:
            return "AI sharing is not allowed."
        case .http(let status, let detail):
            if let detail, !detail.isEmpty {
                return "DeepSeek HTTP \(status): \(detail)"
            }
            return "DeepSeek HTTP \(status)."
        case .decode(let underlying):
            return "Could not read DeepSeek response: \(underlying.localizedDescription)"
        }
    }
}

struct DuctRunRecognition: Sendable, Equatable {
    var sizeTags: [String]
    var diameterInches: Double?
    var lengthFeet: Double?
}

struct CoachSizingResponse: Sendable, Equatable {
    var text: String
    var cfm: Double?
    var friction: Double?
    var velocity: Double?
    var citedFormulas: [String]
}

/// URLSession client for DeepSeek chat/completions (`deepseek-chat`). Consent is enforced before every request.
final class DeepSeekClient {
    private static let endpoint = URL(string: "https://api.deepseek.com/chat/completions")!
    private static let modelName = "deepseek-chat"

    private let apiKey: String
    private let assertConsent: () throws -> Void
    private let session: URLSession

    init(
        apiKey: String,
        assertConsent: @escaping () throws -> Void = {},
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.assertConsent = assertConsent
        self.session = session
    }

    /// Trailing-closure convenience matching Hemline / AppModel call sites.
    convenience init(apiKey: String, _ assertConsent: @escaping () throws -> Void) {
        self.init(apiKey: apiKey, assertConsent: assertConsent)
    }

    func recognizeDuctRun(photoURL: URL) async throws -> DuctRunRecognition {
        try assertConsent()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DeepSeekClientError.notConfigured
        }
        let photoData = try Data(contentsOf: photoURL)
        let b64 = photoData.base64EncodedString()
        let system = """
        You analyze HVAC duct photos for Airspan. Reply with JSON only:
        {"sizeTags":["…"],"diameterInches":number|null,"lengthFeet":number|null}
        Use imperial inches/feet. \(AirspanIdentity.sizingFormulaDisclaimer)
        """
        let userText = """
        Recognize duct run sizes from this job-site photo. Allowed outbound field: duct_photo_bytes.
        """
        let content: [[String: Any]] = [
            ["type": "text", "text": userText],
            [
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(b64)"]
            ]
        ]
        let raw = try await postChat(
            system: system,
            userContent: .multipart(content),
            jsonObject: true
        )
        return try decodeRecognition(from: raw)
    }

    func coachSizing(
        prompt: String,
        targetCFM: Double,
        ductRunSummary: String,
        priorFeedback: [String]
    ) async throws -> CoachSizingResponse {
        try assertConsent()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DeepSeekClientError.notConfigured
        }
        let feedbackBlock = priorFeedback.isEmpty
            ? "none"
            : priorFeedback.joined(separator: "\n")
        let system = """
        You are Airspan's HVAC duct sizing coach. English only. Cite formulas for friction, velocity, and CFM.
        \(AirspanIdentity.sizingFormulaDisclaimer)
        Reply with JSON only:
        {"text":"…","cfm":number|null,"friction":number|null,"velocity":number|null,"citedFormulas":["…"]}
        """
        let user = """
        chat_text: \(prompt)
        airflow_numbers: target \(Int(targetCFM)) CFM
        duct_run_tags / job_summary: \(ductRunSummary)
        sizing_context / prior_feedback:
        \(feedbackBlock)
        """
        let raw = try await postChat(system: system, userContent: .text(user), jsonObject: true)
        return try decodeCoach(from: raw)
    }

    // MARK: - Transport

    private enum UserContent {
        case text(String)
        case multipart([[String: Any]])
    }

    private func postChat(system: String, userContent: UserContent, jsonObject: Bool) async throws -> String {
        try assertConsent()
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let userMessage: [String: Any]
        switch userContent {
        case .text(let text):
            userMessage = ["role": "user", "content": text]
        case .multipart(let parts):
            userMessage = ["role": "user", "content": parts]
        }

        var body: [String: Any] = [
            "model": Self.modelName,
            "messages": [
                ["role": "system", "content": system],
                userMessage
            ]
        ]
        if jsonObject {
            body["response_format"] = ["type": "json_object"]
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw DeepSeekClientError.http(status: -1, detail: "No HTTP response")
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            let snippet = String(data: data, encoding: .utf8)?
                .prefix(240)
                .replacingOccurrences(of: apiKey, with: "[redacted]")
            throw DeepSeekClientError.http(status: http.statusCode, detail: snippet.map { String($0) })
        }
        return try parseAssistantContent(from: data)
    }

    private func parseAssistantContent(from data: Data) throws -> String {
        do {
            let envelope = try JSONDecoder().decode(ChatCompletionEnvelope.self, from: data)
            guard let text = envelope.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                throw DeepSeekClientError.decode(underlying: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Empty content")))
            }
            return text
        } catch let error as DeepSeekClientError {
            throw error
        } catch {
            throw DeepSeekClientError.decode(underlying: error)
        }
    }

    private func decodeRecognition(from raw: String) throws -> DuctRunRecognition {
        let data = Data(extractJSON(from: raw).utf8)
        do {
            let dto = try JSONDecoder().decode(RecognitionDTO.self, from: data)
            let tags = dto.sizeTags?.filter { !$0.isEmpty } ?? []
            return DuctRunRecognition(
                sizeTags: tags.isEmpty ? ["10×8 rectangular"] : tags,
                diameterInches: dto.diameterInches,
                lengthFeet: dto.lengthFeet
            )
        } catch {
            throw DeepSeekClientError.decode(underlying: error)
        }
    }

    private func decodeCoach(from raw: String) throws -> CoachSizingResponse {
        let data = Data(extractJSON(from: raw).utf8)
        do {
            let dto = try JSONDecoder().decode(CoachDTO.self, from: data)
            guard let text = dto.text, !text.isEmpty else {
                throw DeepSeekClientError.decode(underlying: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Missing text")))
            }
            return CoachSizingResponse(
                text: text,
                cfm: dto.cfm,
                friction: dto.friction,
                velocity: dto.velocity,
                citedFormulas: dto.citedFormulas ?? []
            )
        } catch let error as DeepSeekClientError {
            throw error
        } catch {
            throw DeepSeekClientError.decode(underlying: error)
        }
    }

    private func extractJSON(from raw: String) -> String {
        if let start = raw.firstIndex(of: "{"), let end = raw.lastIndex(of: "}") {
            return String(raw[start ... end])
        }
        return raw
    }
}

// MARK: - DTOs

private struct ChatCompletionEnvelope: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String?
        }
        let message: Message
    }
    let choices: [Choice]
}

private struct RecognitionDTO: Decodable {
    let sizeTags: [String]?
    let diameterInches: Double?
    let lengthFeet: Double?
}

private struct CoachDTO: Decodable {
    let text: String?
    let cfm: Double?
    let friction: Double?
    let velocity: Double?
    let citedFormulas: [String]?
}
