import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Project: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var targetFrameRate: Double
    public var createdAt: Date
    public var updatedAt: Date
    public init(
        id: String,
        title: String,
        targetFrameRate: Double,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.targetFrameRate = targetFrameRate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct FrameSequence: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var frameRefs: [String]
    public var source: String
    public var capturedAt: Date
    public init(
        id: String,
        projectId: String,
        frameRefs: [String],
        source: String,
        capturedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.frameRefs = frameRefs
        self.source = source
        self.capturedAt = capturedAt
    }
}

public struct ShotPlanDraft: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var frameSequenceId: String
    public var shotPlanSummary: String
    public var timingSummary: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        projectId: String,
        frameSequenceId: String,
        shotPlanSummary: String,
        timingSummary: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.frameSequenceId = frameSequenceId
        self.shotPlanSummary = shotPlanSummary
        self.timingSummary = timingSummary
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct TimingCue: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var intervalMs: Int
    public var countdownText: String
    public var confirmedAt: Date
    public init(
        id: String,
        projectId: String,
        intervalMs: Int,
        countdownText: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.intervalMs = intervalMs
        self.countdownText = countdownText
        self.confirmedAt = confirmedAt
    }
}

public struct OnionSkinGuide: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var frameSequenceId: String
    public var alignmentHint: String
    public var displacementNote: String
    public var notes: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        projectId: String,
        frameSequenceId: String,
        alignmentHint: String,
        displacementNote: String,
        notes: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.frameSequenceId = frameSequenceId
        self.alignmentHint = alignmentHint
        self.displacementNote = displacementNote
        self.notes = notes
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public init(
        id: String,
        projectId: String,
        role: String,
        text: String,
        createdAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

public struct CoachMessage: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public var status: String
    public init(
        id: String,
        projectId: String,
        role: String,
        text: String,
        createdAt: Date,
        status: String
    ) {
        self.id = id
        self.projectId = projectId
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.status = status
    }
}

public struct CountdownCue: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var cueKind: String
    public var text: String
    public var sortIndex: Int
    public var createdAt: Date
    public init(
        id: String,
        projectId: String,
        cueKind: String,
        text: String,
        sortIndex: Int,
        createdAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.cueKind = cueKind
        self.text = text
        self.sortIndex = sortIndex
        self.createdAt = createdAt
    }
}

public struct DictatedInterval: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var intervalMs: Int
    public var cueText: String
    public var notes: String
    public var transcript: String
    public var createdAt: Date
    public init(
        id: String,
        projectId: String,
        intervalMs: Int,
        cueText: String,
        notes: String,
        transcript: String,
        createdAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.intervalMs = intervalMs
        self.cueText = cueText
        self.notes = notes
        self.transcript = transcript
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
