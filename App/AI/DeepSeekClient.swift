import Foundation
import ClosetCueDomain

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

struct GarmentRecognitionResult {
    let category: String
    let colorTone: String
    let seasonHint: String
    let tags: [String]
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

    func recognizeGarment(photoURL: URL) async throws -> GarmentRecognitionResult {
        let photoData = (try? Data(contentsOf: photoURL)) ?? Data()
        let byteDigest = photoData.prefix(256).base64EncodedString()
        let prompt = """
        You are ClosetCue AI wardrobe assistant. \(ClosetCueIdentity.styleSuggestionDisclaimer)
        garment_photo_bytes: \(photoData.count) bytes (sample): \(byteDigest)
        file: \(photoURL.lastPathComponent)
        Return JSON object keys: category, color_tone, season_hint, tags (string array).
        Use wardrobe-friendly labels (Tops, Bottoms, Outerwear, Shoes, Accessories).
        No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseGarment(from: text)
    }

    func stylistChat(
        prompt: String,
        weather: String,
        occasion: String,
        closetSummary: String,
        priorFeedback: [String]
    ) async throws -> String {
        let userPrompt = """
        You are ClosetCue stylist AI. \(ClosetCueIdentity.styleSuggestionDisclaimer)
        weather_occasion: \(weather) · \(occasion)
        closet_summary: \(closetSummary)
        outfit_context / prior feedback: \(priorFeedback.joined(separator: " | "))
        chat_text / user question: \(prompt)
        Suggest a concrete outfit using closet items when possible. Plain English, bullet-friendly.
        """
        return try await complete(prompt: userPrompt)
    }

    func morningBriefingUtterances(plan: OutfitPlan) async throws -> [String] {
        let prompt = """
        Write 3-4 short spoken morning briefing lines for ClosetCue.
        \(ClosetCueIdentity.styleSuggestionDisclaimer)
        outfit_context: \(plan.promptText)
        stylist plan: \(plan.responseText)
        Return JSON array of strings (each one utterance). No markdown.
        """
        let text = try await complete(prompt: prompt)
        return parseUtterances(from: text, fallbackPlan: plan)
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
        else { throw DeepSeekClientError.decode }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseGarment(from text: String) -> GarmentRecognitionResult {
        let json = extractJSONObject(text) ?? "{}"
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return GarmentRecognitionResult(
                category: "Tops",
                colorTone: "Neutral",
                seasonHint: "All-season",
                tags: [String(text.prefix(80))]
            )
        }
        let category = (obj["category"] as? String) ?? "Tops"
        let colorTone = (obj["color_tone"] as? String) ?? "Neutral"
        let seasonHint = (obj["season_hint"] as? String) ?? "All-season"
        var tags = (obj["tags"] as? [String]) ?? []
        if tags.isEmpty { tags = [category, colorTone, seasonHint] }
        return GarmentRecognitionResult(
            category: category,
            colorTone: colorTone,
            seasonHint: seasonHint,
            tags: tags
        )
    }

    private func parseUtterances(from text: String, fallbackPlan: OutfitPlan) -> [String] {
        if let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]"),
           let data = String(text[start...end]).data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [String],
           !arr.isEmpty {
            return arr + [ClosetCueIdentity.styleSuggestionDisclaimer]
        }
        let line = fallbackPlan.responseText.split(separator: "\n").first.map(String.init)
            ?? "Review today's outfit in ClosetCue."
        return [
            "Good morning from ClosetCue.",
            line,
            ClosetCueIdentity.styleSuggestionDisclaimer
        ]
    }

    private func extractJSONObject(_ text: String) -> String? {
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return nil
    }
}
