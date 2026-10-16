import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct ShelfSession: Codable, Hashable, Sendable {
    public var id: String
    public var createdAt: Date
    /// camera | photos
    public var source: String
    /// draft | identified | confirmed
    public var status: String
    public var shelfNote: String?
    public var disclaimerAck: Bool
    public init(
        id: String,
        createdAt: Date,
        source: String,
        status: String,
        shelfNote: String? = nil,
        disclaimerAck: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.source = source
        self.status = status
        self.shelfNote = shelfNote
        self.disclaimerAck = disclaimerAck
    }
}

public struct CoverCapture: Codable, Hashable, Sendable {
    public var sessionId: String
    /// cover | spine | shelfRow
    public var captureKind: String
    public var photoLocalURL: String
    public var capturedAt: Date
    public init(
        sessionId: String,
        captureKind: String,
        photoLocalURL: String,
        capturedAt: Date
    ) {
        self.sessionId = sessionId
        self.captureKind = captureKind
        self.photoLocalURL = photoLocalURL
        self.capturedAt = capturedAt
    }
}

public struct BookID: Codable, Hashable, Sendable {
    public var sessionId: String
    public var title: String
    public var author: String
    public var editionHint: String?
    public var confidence: Double
    public var rationale: String
    public var complianceBanner: String
    public init(
        sessionId: String,
        title: String,
        author: String,
        editionHint: String? = nil,
        confidence: Double,
        rationale: String,
        complianceBanner: String
    ) {
        self.sessionId = sessionId
        self.title = title
        self.author = author
        self.editionHint = editionHint
        self.confidence = confidence
        self.rationale = rationale
        self.complianceBanner = complianceBanner
    }
}

public struct SpineRailItem: Codable, Hashable, Sendable {
    public var bookId: String
    public var spineLabel: String
    public var coverThumbURL: String?
    public var position: Int
    public var shelfLane: String
    public init(
        bookId: String,
        spineLabel: String,
        coverThumbURL: String? = nil,
        position: Int,
        shelfLane: String
    ) {
        self.bookId = bookId
        self.spineLabel = spineLabel
        self.coverThumbURL = coverThumbURL
        self.position = position
        self.shelfLane = shelfLane
    }
}

public struct ReadingProgress: Codable, Hashable, Sendable {
    public var sessionId: String
    /// tbr | reading | done
    public var state: String
    /// 0…100
    public var percent: Int
    public var updatedAt: Date
    public init(
        sessionId: String,
        state: String,
        percent: Int,
        updatedAt: Date
    ) {
        self.sessionId = sessionId
        self.state = state
        self.percent = percent
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var sessionId: String?
    /// user | coach
    public var role: String
    public var text: String
    /// tbr | reading | find
    public var strategy: String
    public var sttSource: Bool?
    public var createdAt: Date
    public init(
        sessionId: String? = nil,
        role: String,
        text: String,
        strategy: String,
        sttSource: Bool? = nil,
        createdAt: Date
    ) {
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.strategy = strategy
        self.sttSource = sttSource
        self.createdAt = createdAt
    }
}

public struct ShelfCardAnnotation: Codable, Hashable, Sendable {
    public var sessionId: String
    public var callouts: [String]
    public var imageLocalURL: String
    public var generatedAt: Date
    public init(
        sessionId: String,
        callouts: [String],
        imageLocalURL: String,
        generatedAt: Date
    ) {
        self.sessionId = sessionId
        self.callouts = callouts
        self.imageLocalURL = imageLocalURL
        self.generatedAt = generatedAt
    }
}

public struct FindCallout: Codable, Hashable, Sendable {
    public var sessionId: String
    public var scriptText: String
    public var spokenAt: Date?
    public var ttsLocale: String
    public init(
        sessionId: String,
        scriptText: String,
        spokenAt: Date? = nil,
        ttsLocale: String
    ) {
        self.sessionId = sessionId
        self.scriptText = scriptText
        self.spokenAt = spokenAt
        self.ttsLocale = ttsLocale
    }
}

public struct VoiceNote: Codable, Hashable, Sendable {
    public var sessionId: String?
    public var localAudioURL: String
    public var transcript: String?
    public var createdAt: Date
    public init(
        sessionId: String? = nil,
        localAudioURL: String,
        transcript: String? = nil,
        createdAt: Date
    ) {
        self.sessionId = sessionId
        self.localAudioURL = localAudioURL
        self.transcript = transcript
        self.createdAt = createdAt
    }
}

public struct AIConsentRecord: Codable, Hashable, Sendable {
    public var provider: String
    public var disclosureVersion: String
    public var grantedAt: Date
    public var revokedAt: Date?
    public init(
        provider: String,
        disclosureVersion: String,
        grantedAt: Date,
        revokedAt: Date? = nil
    ) {
        self.provider = provider
        self.disclosureVersion = disclosureVersion
        self.grantedAt = grantedAt
        self.revokedAt = revokedAt
    }
}

public struct AppSettings: Codable, Hashable, Sendable {
    public var ttsEnabled: Bool
    public var speechInputEnabled: Bool
    public var consentRevoked: Bool
    public var alwaysShowComplianceBanner: Bool
    public init(
        ttsEnabled: Bool = true,
        speechInputEnabled: Bool = true,
        consentRevoked: Bool = false,
        alwaysShowComplianceBanner: Bool = true
    ) {
        self.ttsEnabled = ttsEnabled
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
        self.alwaysShowComplianceBanner = alwaysShowComplianceBanner
    }
}

/// Aggregate root persisted via AtomicCodableStore\<SpinewellState\>.
public struct SpinewellState: Codable, Hashable, Sendable {
    public var sessions: [ShelfSession]
    public var captures: [CoverCapture]
    public var bookIDs: [BookID]
    public var spineRail: [SpineRailItem]
    public var readingProgress: [ReadingProgress]
    public var coachTurns: [CoachTurn]
    public var shelfCards: [ShelfCardAnnotation]
    public var findCallouts: [FindCallout]
    public var voiceNotes: [VoiceNote]
    public var settings: AppSettings
    public init(
        sessions: [ShelfSession] = [],
        captures: [CoverCapture] = [],
        bookIDs: [BookID] = [],
        spineRail: [SpineRailItem] = [],
        readingProgress: [ReadingProgress] = [],
        coachTurns: [CoachTurn] = [],
        shelfCards: [ShelfCardAnnotation] = [],
        findCallouts: [FindCallout] = [],
        voiceNotes: [VoiceNote] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.sessions = sessions
        self.captures = captures
        self.bookIDs = bookIDs
        self.spineRail = spineRail
        self.readingProgress = readingProgress
        self.coachTurns = coachTurns
        self.shelfCards = shelfCards
        self.findCallouts = findCallouts
        self.voiceNotes = voiceNotes
        self.settings = settings
    }
}
