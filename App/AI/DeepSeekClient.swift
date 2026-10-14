import Foundation
import CuePartnerDomain

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

    func partnerReply(
        sceneTitle: String,
        ocrText: String,
        cueLines: [CueLine],
        partnerRole: String,
        userLine: String,
        voiceTranscript: String?,
        history: [RehearsalMessage]
    ) async throws -> PartnerTurn {
        let cues = cueLines.prefix(40).map { "\($0.role): \($0.text)" }.joined(separator: "\n")
        let hist = history.suffix(12).map { "\($0.role): \($0.text)" }.joined(separator: "\n")
        let feedback = history.flatMap(\.feedbackNotes).suffix(8).joined(separator: " | ")
        let prompt = """
        You are CuePartner AI, a rehearsal scene partner. Stay in character as \(partnerRole).
        Scene: \(sceneTitle)
        Script OCR excerpt: \(ocrText.prefix(1200))
        Cue lines:
        \(cues)
        Confirmed rehearsal history:
        \(hist)
        Prior feedback: \(feedback)
        User (\(voiceTranscript == nil ? "typed" : "spoken")) line: \(userLine)
        Optional voice transcript: \(voiceTranscript ?? "")
        Reply as JSON object keys: draft_text, beat_hint. Plain JSON only. Practice draft — not professional coaching certification.
        """
        let text = try await complete(prompt: prompt)
        return parseTurn(from: text, sceneId: cueLines.first?.sceneId ?? "", partnerRole: partnerRole)
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
            "temperature": 0.4
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

    private func parseTurn(from text: String, sceneId: String, partnerRole: String) -> PartnerTurn {
        let json = extractJSONObject(text) ?? "{}"
        let row = (try? JSONSerialization.jsonObject(with: Data(json.utf8))) as? [String: Any] ?? [:]
        let draft = (row["draft_text"] as? String)
            ?? (row["beat_hint"] as? String)
            ?? text
        return PartnerTurn(
            id: UUID().uuidString,
            sceneId: sceneId,
            partnerRole: partnerRole,
            draftText: draft.trimmingCharacters(in: .whitespacesAndNewlines),
            confirmed: false
        )
    }

    private func extractJSONObject(_ text: String) -> String? {
        guard let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}"), start < end else { return nil }
        return String(text[start...end])
    }
}
