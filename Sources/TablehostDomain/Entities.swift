import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct GameSession: Codable, Hashable, Sendable {
    public var id: String
    public var gameName: String
    public var playerCount: Int
    public var currentPhase: String
    public var createdAt: Date
    public var updatedAt: Date
    public init(
        id: String,
        gameName: String,
        playerCount: Int,
        currentPhase: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.gameName = gameName
        self.playerCount = playerCount
        self.currentPhase = currentPhase
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct TablePhoto: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var localFileRef: String
    public var source: String
    public var kind: String
    public var capturedAt: Date
    public init(
        id: String,
        sessionId: String,
        localFileRef: String,
        source: String,
        kind: String,
        capturedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.localFileRef = localFileRef
        self.source = source
        self.kind = kind
        self.capturedAt = capturedAt
    }
}

public struct ComponentDraft: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var tablePhotoId: String
    public var componentSummary: String
    public var phaseSummary: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        tablePhotoId: String,
        componentSummary: String,
        phaseSummary: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.tablePhotoId = tablePhotoId
        self.componentSummary = componentSummary
        self.phaseSummary = phaseSummary
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct ComponentMap: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var items: [String]
    public var confirmedAt: Date
    public init(
        id: String,
        sessionId: String,
        items: [String],
        confirmedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.items = items
        self.confirmedAt = confirmedAt
    }
}

public struct PhaseStep: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var order: Int
    public var title: String
    public var hint: String
    public var confirmedAt: Date
    public init(
        id: String,
        sessionId: String,
        order: Int,
        title: String,
        hint: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.order = order
        self.title = title
        self.hint = hint
        self.confirmedAt = confirmedAt
    }
}

public struct SetupOverlay: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var tablePhotoId: String
    public var zoneBoxes: [String]
    public var arrowNotes: [String]
    public var notes: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        tablePhotoId: String,
        zoneBoxes: [String],
        arrowNotes: [String],
        notes: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.tablePhotoId = tablePhotoId
        self.zoneBoxes = zoneBoxes
        self.arrowNotes = arrowNotes
        self.notes = notes
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        role: String,
        text: String,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

public struct CoachMessage: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public var status: String
    public init(
        id: String,
        sessionId: String,
        role: String,
        text: String,
        createdAt: Date,
        status: String
    ) {
        self.id = id
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.status = status
    }
}

public struct HostCue: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var cueKind: String
    public var text: String
    public var sortIndex: Int
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        cueKind: String,
        text: String,
        sortIndex: Int,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.cueKind = cueKind
        self.text = text
        self.sortIndex = sortIndex
        self.createdAt = createdAt
    }
}

public struct SpokenQuestion: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var questionText: String
    public var transcript: String
    public var notes: String
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        questionText: String,
        transcript: String,
        notes: String,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.questionText = questionText
        self.transcript = transcript
        self.notes = notes
        self.createdAt = createdAt
    }
}

public struct AIConsentRecord: Codable, Hashable, Sendable {
    public var disclosureVersion: String
    public var allowed: Bool
    public init(disclosureVersion: String, allowed: Bool) {
        self.disclosureVersion = disclosureVersion
        self.allowed = allowed
    }
}
