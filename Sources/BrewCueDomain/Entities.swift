import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct BrewSession: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    /// Optional gear / brewer note (e.g. V60, Kalita).
    public var gearNote: String
    /// Snapshot of compliance banner text at session creation.
    public var complianceSnapshot: String
    public var createdAt: Date
    public var updatedAt: Date
    public init(
        id: String,
        title: String,
        gearNote: String = "",
        complianceSnapshot: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.gearNote = gearNote
        self.complianceSnapshot = complianceSnapshot
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct BrewShot: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    /// camera | photos
    public var source: String
    /// bean | grounds | bloom | pour | crema | other
    public var subject: String
    /// Local file ref for captured or imported brew still.
    public var localMediaURL: String
    public var capturedAt: Date
    public init(
        id: String,
        sessionId: String,
        source: String,
        subject: String,
        localMediaURL: String,
        capturedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.source = source
        self.subject = subject
        self.localMediaURL = localMediaURL
        self.capturedAt = capturedAt
    }
}

public struct PourStep: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    /// bloom | pour | drawdown
    public var kind: String
    /// 0 for bloom/drawdown; 1…N for pour N.
    public var pourIndex: Int
    public var targetGrams: Double?
    public var targetSeconds: Double?
    public var sortIndex: Int
    public var note: String
    public init(
        id: String,
        sessionId: String,
        kind: String,
        pourIndex: Int = 0,
        targetGrams: Double? = nil,
        targetSeconds: Double? = nil,
        sortIndex: Int = 0,
        note: String = ""
    ) {
        self.id = id
        self.sessionId = sessionId
        self.kind = kind
        self.pourIndex = pourIndex
        self.targetGrams = targetGrams
        self.targetSeconds = targetSeconds
        self.sortIndex = sortIndex
        self.note = note
    }
}

public struct GrindPick: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    /// fine | medium_fine | medium | medium_coarse | coarse
    public var grind: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        grind: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.grind = grind
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    /// user | coach
    public var role: String
    public var text: String
    /// Optional feedback mark from human review.
    public var feedbackMark: String?
    public var sttSource: Bool
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        role: String,
        text: String,
        feedbackMark: String? = nil,
        sttSource: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.feedbackMark = feedbackMark
        self.sttSource = sttSource
        self.createdAt = createdAt
    }
}

public struct BrewNote: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var ratioSummary: String
    public var grindSummary: String
    public var stepSummary: String
    /// draft | confirmed | discarded
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        ratioSummary: String = "",
        grindSummary: String = "",
        stepSummary: String = "",
        status: String = "draft",
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.ratioSummary = ratioSummary
        self.grindSummary = grindSummary
        self.stepSummary = stepSummary
        self.status = status
        self.updatedAt = updatedAt
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
    public var speechInputEnabled: Bool
    public var consentRevoked: Bool
    public var alwaysShowComplianceBanner: Bool
    public init(
        speechInputEnabled: Bool = true,
        consentRevoked: Bool = false,
        alwaysShowComplianceBanner: Bool = true
    ) {
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
        self.alwaysShowComplianceBanner = alwaysShowComplianceBanner
    }
}

/// Aggregate root persisted via AtomicCodableStore\<BrewCueState\>.
public struct BrewCueState: Codable, Hashable, Sendable {
    public var sessions: [BrewSession]
    public var shots: [BrewShot]
    public var pourSteps: [PourStep]
    public var grindPicks: [GrindPick]
    public var coachTurns: [CoachTurn]
    public var brewNotes: [BrewNote]
    public var settings: AppSettings
    public init(
        sessions: [BrewSession] = [],
        shots: [BrewShot] = [],
        pourSteps: [PourStep] = [],
        grindPicks: [GrindPick] = [],
        coachTurns: [CoachTurn] = [],
        brewNotes: [BrewNote] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.sessions = sessions
        self.shots = shots
        self.pourSteps = pourSteps
        self.grindPicks = grindPicks
        self.coachTurns = coachTurns
        self.brewNotes = brewNotes
        self.settings = settings
    }
}
