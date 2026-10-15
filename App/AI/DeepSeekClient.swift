import Foundation
import FolioCueDomain

struct BookIDPayload: Sendable {
    var book: BookID
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
            case let .decodeFailed(reason): return "Could not parse book ID: \(reason)"
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

    func identifyBook(
        sessionId: String,
        photoDescriptor: String,
        captureKind: String,
        confirmedNotes: [String],
        question: String
    ) async throws -> BookIDPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }

        let payload: [String: Any] = [
            "cover_or_spine_still": photoDescriptor,
            "capture_kind": captureKind,
            "user_question": question,
            "confirmed_book_notes": confirmedNotes,
            "active_session_id": sessionId,
            "optional_voice_transcript": "",
        ]

        let system = """
        You are FolioCue, an AI personal bookshelf coach. Reply with JSON only:
        {"title":"","author":"","editionHint":"","confidence":0.0,"rationale":"","complianceBanner":"个人藏书教练 / personal bookshelf coach"}
        Identify books from personal cover/spine stills for a home shelf. Never scrape bookstore catalogs.
        Never provide full-text piracy reading. Never grade homework. Never name BookBuddy.
        Not a LuxCue/CellarCue/MixCue/SporeCue/FrameCue/NightCue/ScoutCue/StopCue twin.
        """

        let content = try await chat(system: system, userJSON: payload)
        return try Self.parseIdentify(content: content, sessionId: sessionId)
    }

    func coachShelf(
        sessionId: String,
        question: String,
        book: BookID?,
        progress: ReadingProgress?,
        confirmedNotes: [String],
        strategy: String
    ) async throws -> CoachReplyPayload {
        try assertAuthorized()
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Failure.missingAPIKey
        }
        let payload: [String: Any] = [
            "user_question": question,
            "strategy": strategy,
            "active_session_id": sessionId,
            "book_title": book?.title ?? "",
            "book_author": book?.author ?? "",
            "reading_state": progress?.state ?? "tbr",
            "reading_percent": progress?.percent ?? 0,
            "confirmed_book_notes": confirmedNotes,
        ]
        let system = """
        You are FolioCue TBR/reading coach. Reply JSON only:
        {"reply":"short coach answer","strategy":"tbr|reading|find"}
        Personal bookshelf coach only. Not bookstore catalog scraping. Not a full-text piracy reader. Not homework grading.
        Never name BookBuddy.
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

    private static func parseIdentify(content: String, sessionId: String) throws -> BookIDPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure.decodeFailed("root")
        }
        let title = (obj["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let author = (obj["author"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let title, !title.isEmpty, let author, !author.isEmpty else {
            throw Failure.decodeFailed("title/author")
        }
        let confidence: Double
        if let d = obj["confidence"] as? Double {
            confidence = d
        } else if let n = obj["confidence"] as? NSNumber {
            confidence = n.doubleValue
        } else {
            confidence = 0.5
        }
        let book = BookID(
            sessionId: sessionId,
            title: title,
            author: author,
            editionHint: obj["editionHint"] as? String,
            confidence: min(1, max(0, confidence)),
            rationale: (obj["rationale"] as? String) ?? "",
            complianceBanner: (obj["complianceBanner"] as? String)
                ?? FolioCueCompliance.personalBookshelfCoach
        )
        return BookIDPayload(book: book)
    }

    private static func parseCoach(content: String) throws -> CoachReplyPayload {
        guard let data = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let reply = obj["reply"] as? String,
              !reply.isEmpty else {
            throw Failure.decodeFailed("coach reply")
        }
        let strategy = (obj["strategy"] as? String) ?? "tbr"
        return CoachReplyPayload(reply: reply, strategy: strategy)
    }
}
