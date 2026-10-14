import Foundation
import BendCoachDomain

enum DeepSeekClientError: LocalizedError {
    case notConfigured
    case notAuthorized
    case http(Int, String)
    case decode

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "DeepSeek API key not configured"
        case .notAuthorized: return "AI data sharing not authorized"
        case .http(let code, let body): return "DeepSeek HTTP \(code): \(body.prefix(200))"
        case .decode: return "Could not decode DeepSeek response"
        }
    }
}

struct DeepSeekClient {
    let apiKey: String
    var session: URLSession = .shared
    var endpoint: URL = {
        let host = ["api", "deepseek", "com"].joined(separator: ".")
        return URL(string: "https://\(host)/chat/completions")!
    }()
    private var assertAuthorized: (() throws -> Void)?

    init(apiKey: String, assertAuthorized: (() throws -> Void)? = nil) {
        self.apiKey = apiKey
        self.assertAuthorized = assertAuthorized
    }

    func bendMathChat(
        prompt: String,
        unitSystem: UnitSystem,
        priorMarkups: [BendMarkup],
        priorFeedback: [String]
    ) async throws -> String {
        let markupBlob = priorMarkups.map { "\($0.bendType):\($0.keyDimensions)" }.joined(separator: "; ")
        let userPrompt = """
        You are BendCoach AI, a field conduit-bending coach for electricians.
        \(BendCoachIdentity.assistiveDisclaimer)
        unit_system: \(unitSystem.rawValue)
        Prior confirmed marks: \(markupBlob)
        Prior feedback: \(priorFeedback.joined(separator: " | "))
        User question: \(prompt)
        Reply in plain English with step summary and key mark points. Label numbers as assistive.
        """
        return try await complete(prompt: userPrompt)
    }

    func recognizeBend(
        photoURL: URL,
        jobSessionID: UUID,
        photoID: UUID,
        unitSystem: UnitSystem
    ) async throws -> BendRecognitionDraft {
        let photoData = (try? Data(contentsOf: photoURL)) ?? Data()
        let byteDigest = photoData.prefix(256).base64EncodedString()
        let prompt = """
        You are BendCoach AI. \(BendCoachIdentity.assistiveDisclaimer)
        field_photo_bytes: \(photoData.count) bytes (sample): \(byteDigest)
        unit_system: \(unitSystem.rawValue)
        Return JSON object keys: bend_type (offset|saddle|stub90|other), markup_hints (string array).
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseRecognition(from: text, jobSessionID: jobSessionID, photoID: photoID)
    }

    func diagramHints(markup: BendMarkup) async throws -> String {
        let prompt = """
        BendCoach AI diagram overlay hints. \(BendCoachIdentity.assistiveDisclaimer)
        bend_type: \(markup.bendType)
        dimensions: \(markup.keyDimensions)
        Return short take-up / shrink / mark guidance as plain text.
        """
        return try await complete(prompt: prompt)
    }

    func coachingSteps(jobSessionID: UUID, markup: BendMarkup?, context: String) async throws -> [CoachingStep] {
        let prompt = """
        Write 3-5 ordered field coaching steps for BendCoach AI.
        \(BendCoachIdentity.assistiveDisclaimer)
        bend: \(markup?.bendType ?? "general")
        context: \(context)
        Return JSON array of objects with keys: order_index (int), utterance (string).
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseSteps(from: text, jobSessionID: jobSessionID)
    }

    private func complete(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw DeepSeekClientError.notConfigured }
        do { try assertAuthorized?() } catch { throw DeepSeekClientError.notAuthorized }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": "Return concise plain text or JSON only."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.2
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(code) else {
            throw DeepSeekClientError.http(code, String(data: data, encoding: .utf8) ?? "")
        }
        guard
            let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = obj["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw DeepSeekClientError.decode }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseRecognition(from text: String, jobSessionID: UUID, photoID: UUID) -> BendRecognitionDraft {
        let json = extractJSONObject(text) ?? "{}"
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return BendRecognitionDraft(
                jobSessionID: jobSessionID,
                fieldPhotoID: photoID,
                proposedBendType: "offset",
                markupHints: [String(text.prefix(120))]
            )
        }
        let type = (obj["bend_type"] as? String) ?? "offset"
        let hints = (obj["markup_hints"] as? [String]) ?? []
        return BendRecognitionDraft(
            jobSessionID: jobSessionID,
            fieldPhotoID: photoID,
            proposedBendType: type,
            markupHints: hints.isEmpty ? ["Review marks on photo"] : hints
        )
    }

    private func parseSteps(from text: String, jobSessionID: UUID) -> [CoachingStep] {
        if let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]"),
           let data = String(text[start...end]).data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return arr.enumerated().compactMap { idx, row in
                guard let utterance = row["utterance"] as? String else { return nil }
                let order = (row["order_index"] as? Int) ?? idx
                return CoachingStep(jobSessionID: jobSessionID, orderIndex: order, utterance: utterance)
            }
        }
        return [
            CoachingStep(jobSessionID: jobSessionID, orderIndex: 0, utterance: text)
        ]
    }

    private func extractJSONObject(_ text: String) -> String? {
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return nil
    }
}
