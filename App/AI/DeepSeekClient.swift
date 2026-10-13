import Foundation
import SnagCueDomain

enum DeepSeekClientError: LocalizedError {
    case notConfigured
    case http(Int, String)
    case decode

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "DeepSeek API key not configured"
        case .http(let code, let body): return "DeepSeek HTTP \(code): \(body.prefix(200))"
        case .decode: return "Could not decode DeepSeek response"
        }
    }
}

struct DeepSeekClient {
    let apiKey: String
    var session: URLSession = .shared
    var endpoint = URL(string: "https://api.deepseek.com/chat/completions")!

    func detectSnags(photos: [URL], priorLabels: [String], auditId: String) async throws -> [SnagDraft] {
        let names = photos.map(\.lastPathComponent).joined(separator: ", ")
        let prompt = """
        You are a site-inspection assistant for SnagCue AI. Guidance only — not building-code certification.
        Walkthrough photo files: \(names)
        Prior snag labels: \(priorLabels.joined(separator: "; "))
        Return JSON array of objects with keys: label, approx_location_hint, severity_guess, notes_hint.
        Max 5 items. No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseDrafts(from: text, auditId: auditId, photoId: photos.first.map { $0.deletingPathExtension().lastPathComponent } ?? "")
    }

    func suggestFieldPatch(item: PunchItem, chatText: String, priorFeedback: [String]) async throws -> FieldPatchDraft {
        let prompt = """
        Fill punch-list fields for SnagCue AI. Guidance only.
        Current item JSON-ish: title=\(item.title); location=\(item.location); severity=\(item.severity); assignee=\(item.assignee); due=\(item.dueDate); notes=\(item.notes)
        User chat: \(chatText)
        Prior feedback: \(priorFeedback.joined(separator: " | "))
        Return JSON object keys: location, severity, assignee, due_date, notes, rationale.
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parsePatch(from: text, punchItemId: item.id)
    }

    func annotateCaption(items: [PunchItem]) async throws -> String {
        let labels = items.map { "\($0.title) @ \($0.location)" }.joined(separator: "; ")
        let prompt = "Write one short caption for an annotated snag report covering: \(labels). Guidance only disclaimer tone. Plain text."
        return try await complete(prompt: prompt)
    }

    private func complete(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw DeepSeekClientError.notConfigured }
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

    private func parseDrafts(from text: String, auditId: String, photoId: String) -> [SnagDraft] {
        let json = extractJSONArray(text) ?? "[]"
        guard let data = json.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return [
                SnagDraft(
                    id: UUID().uuidString,
                    auditId: auditId,
                    photoId: photoId,
                    label: text.prefix(80).description,
                    notesHint: "Unstructured model output"
                )
            ]
        }
        return arr.prefix(5).map { row in
            SnagDraft(
                id: UUID().uuidString,
                auditId: auditId,
                photoId: photoId,
                label: stringValue(row["label"]) ?? "Snag",
                approxLocationHint: stringValue(row["approx_location_hint"]) ?? "",
                severityGuess: stringValue(row["severity_guess"]) ?? "medium",
                notesHint: stringValue(row["notes_hint"]) ?? ""
            )
        }
    }

    private func parsePatch(from text: String, punchItemId: String) -> FieldPatchDraft {
        let json = extractJSONObject(text) ?? "{}"
        let row = (try? JSONSerialization.jsonObject(with: Data(json.utf8))) as? [String: Any] ?? [:]
        return FieldPatchDraft(
            id: UUID().uuidString,
            punchItemId: punchItemId,
            location: stringValue(row["location"]),
            severity: stringValue(row["severity"]),
            assignee: stringValue(row["assignee"]),
            dueDate: stringValue(row["due_date"]),
            notes: stringValue(row["notes"]),
            rationale: stringValue(row["rationale"]) ?? text
        )
    }

    private func extractJSONArray(_ text: String) -> String? {
        guard let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]"), start < end else { return nil }
        return String(text[start...end])
    }

    private func extractJSONObject(_ text: String) -> String? {
        guard let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}"), start < end else { return nil }
        return String(text[start...end])
    }

    private func stringValue(_ any: Any?) -> String? {
        if let s = any as? String { return s }
        if let n = any as? NSNumber { return n.stringValue }
        return nil
    }
}
