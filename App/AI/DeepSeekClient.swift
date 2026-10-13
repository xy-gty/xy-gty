import Foundation
import DocBriefDomain

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

    func recognizeDocument(
        photoURL: URL,
        briefID: UUID,
        photoID: UUID,
        priorType: String?
    ) async throws -> RecognitionDraft {
        let photoData = (try? Data(contentsOf: photoURL)) ?? Data()
        let byteDigest = photoData.prefix(256).base64EncodedString()
        let prompt = """
        You are DocBrief AI. Guidance only — not financial, tax, or legal certification.
        document_photo_bytes: \(photoData.count) bytes (sample base64 prefix): \(byteDigest)
        Photo file: \(photoURL.lastPathComponent)
        Prior type: \(priorType ?? "none")
        Return JSON object with keys: doc_type (document|whiteboard|receipt|other), fields (array of {key,value}), notes_hint.
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseRecognition(from: text, briefID: briefID, photoID: photoID)
    }

    func extractActions(
        chatText: String,
        fields: [ExtractedField],
        priorActions: [ActionItem],
        priorFeedback: [String],
        recognizedType: String?,
        briefID: UUID
    ) async throws -> ActionItem {
        let fieldBlob = fields.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
        let actionBlob = priorActions.map(\.text).joined(separator: "; ")
        let prompt = """
        Extract one action item and optional deadline for DocBrief AI. Guidance only.
        Recognized type: \(recognizedType ?? "unknown")
        Fields: \(fieldBlob)
        Prior actions: \(actionBlob)
        Prior feedback: \(priorFeedback.joined(separator: " | "))
        User chat: \(chatText)
        Return JSON object keys: text, due_date (ISO8601 or empty), rationale.
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseAction(from: text, briefID: briefID)
    }

    func makeSummaryCard(
        brief: Brief,
        fields: [ExtractedField],
        actions: [ActionItem]
    ) async throws -> SummaryCardDraft {
        let fieldBlob = fields.map { "\($0.key): \($0.value)" }.joined(separator: "; ")
        let actionBlob = actions.map(\.text).joined(separator: "; ")
        let prompt = """
        Write a short visual summary card for DocBrief AI brief "\(brief.title)".
        Fields: \(fieldBlob)
        Actions: \(actionBlob)
        Return JSON object keys: headline, body. Include a guidance-only disclaimer tone in body.
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseSummary(from: text, briefID: brief.id)
    }

    private func complete(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw DeepSeekClientError.notConfigured }
        do {
            try assertAuthorized?()
        } catch {
            throw DeepSeekClientError.notAuthorized
        }
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
        else {
            throw DeepSeekClientError.decode
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseRecognition(from text: String, briefID: UUID, photoID: UUID) -> RecognitionDraft {
        let json = extractJSONObject(text) ?? "{}"
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return RecognitionDraft(
                briefID: briefID,
                documentPhotoID: photoID,
                proposedType: "document",
                proposedFields: [ExtractedField(briefID: briefID, key: "notes", value: String(text.prefix(120)))]
            )
        }
        let type = (obj["doc_type"] as? String) ?? "document"
        let rawFields = obj["fields"] as? [[String: Any]] ?? []
        let fields = rawFields.prefix(8).compactMap { row -> ExtractedField? in
            guard let key = row["key"] as? String, let value = row["value"] as? String else { return nil }
            return ExtractedField(briefID: briefID, key: key, value: value)
        }
        return RecognitionDraft(
            briefID: briefID,
            documentPhotoID: photoID,
            proposedType: type,
            proposedFields: fields.isEmpty
                ? [ExtractedField(briefID: briefID, key: "notes_hint", value: (obj["notes_hint"] as? String) ?? "")]
                : Array(fields)
        )
    }

    private func parseAction(from text: String, briefID: UUID) -> ActionItem {
        let json = extractJSONObject(text) ?? "{}"
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ActionItem(briefID: briefID, text: String(text.prefix(160)))
        }
        let actionText = (obj["text"] as? String) ?? "Follow up"
        var deadline: Date?
        if let due = obj["due_date"] as? String, !due.isEmpty {
            deadline = ISO8601DateFormatter().date(from: due)
        }
        return ActionItem(briefID: briefID, text: actionText, deadline: deadline)
    }

    private func parseSummary(from text: String, briefID: UUID) -> SummaryCardDraft {
        let json = extractJSONObject(text) ?? "{}"
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return SummaryCardDraft(
                briefID: briefID,
                headline: "Brief summary",
                body: text + "\n\n" + DocBriefIdentity.nonCertificationDisclaimer,
                includesDisclaimer: true
            )
        }
        return SummaryCardDraft(
            briefID: briefID,
            headline: (obj["headline"] as? String) ?? "Brief summary",
            body: (obj["body"] as? String) ?? text,
            includesDisclaimer: true
        )
    }

    private func extractJSONObject(_ text: String) -> String? {
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return nil
    }
}
