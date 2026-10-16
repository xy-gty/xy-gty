import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct FramingSession: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var currentShotSize: String
    public var aspectRatio: String
    public var createdAt: Date
    public var updatedAt: Date
    public init(
        id: String,
        title: String,
        currentShotSize: String,
        aspectRatio: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.currentShotSize = currentShotSize
        self.aspectRatio = aspectRatio
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct FrameStill: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var localFileRef: String
    public var source: String
    public var capturedAt: Date
    public init(
        id: String,
        sessionId: String,
        localFileRef: String,
        source: String,
        capturedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.localFileRef = localFileRef
        self.source = source
        self.capturedAt = capturedAt
    }
}

public struct CompositionDraft: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var stillId: String
    public var issueSummary: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        stillId: String,
        issueSummary: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.stillId = stillId
        self.issueSummary = issueSummary
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CompositionNote: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var stillId: String
    public var subject: String
    public var edges: String
    public var negativeSpace: String
    public var symmetry: String
    public var confirmedAt: Date
    public init(
        id: String,
        sessionId: String,
        stillId: String,
        subject: String,
        edges: String,
        negativeSpace: String,
        symmetry: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.stillId = stillId
        self.subject = subject
        self.edges = edges
        self.negativeSpace = negativeSpace
        self.symmetry = symmetry
        self.confirmedAt = confirmedAt
    }
}

public struct ShotSizePlan: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var chips: [String]
    public var selectedChip: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        chips: [String],
        selectedChip: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.chips = chips
        self.selectedChip = selectedChip
        self.updatedAt = updatedAt
    }
}

public struct AspectOverlay: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var stillId: String
    public var aspectRatioLabel: String
    public var safeFrameEnabled: Bool
    public var ruleOfThirdsEnabled: Bool
    public var notes: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        stillId: String,
        aspectRatioLabel: String,
        safeFrameEnabled: Bool,
        ruleOfThirdsEnabled: Bool,
        notes: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.stillId = stillId
        self.aspectRatioLabel = aspectRatioLabel
        self.safeFrameEnabled = safeFrameEnabled
        self.ruleOfThirdsEnabled = ruleOfThirdsEnabled
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

public struct VoiceIntent: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var transcript: String
    public var shotSizeLabel: String
    public var lensLanguage: String
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        transcript: String,
        shotSizeLabel: String,
        lensLanguage: String,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.transcript = transcript
        self.shotSizeLabel = shotSizeLabel
        self.lensLanguage = lensLanguage
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
