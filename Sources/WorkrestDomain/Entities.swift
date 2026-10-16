import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Session: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var targetBodyArea: String
    public var currentBlockLabel: String
    public var updatedAt: Date
    public init(
        id: String,
        title: String,
        targetBodyArea: String,
        currentBlockLabel: String,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.targetBodyArea = targetBodyArea
        self.currentBlockLabel = currentBlockLabel
        self.updatedAt = updatedAt
    }
}

public struct FormShot: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var relativePath: String
    public var source: String
    public var capturedAt: Date
    public init(
        id: String,
        sessionId: String,
        relativePath: String,
        source: String,
        capturedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.relativePath = relativePath
        self.source = source
        self.capturedAt = capturedAt
    }
}

public struct WorkrestDraft: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var formShotId: String
    public var postureSummary: String
    public var correctionFocus: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        formShotId: String,
        postureSummary: String,
        correctionFocus: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.formShotId = formShotId
        self.postureSummary = postureSummary
        self.correctionFocus = correctionFocus
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct FormCorrection: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var formShotId: String
    public var jointHint: String
    public var alignmentHint: String
    public var cueText: String
    public var confirmedAt: Date
    public init(
        id: String,
        sessionId: String,
        formShotId: String,
        jointHint: String,
        alignmentHint: String,
        cueText: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.formShotId = formShotId
        self.jointHint = jointHint
        self.alignmentHint = alignmentHint
        self.cueText = cueText
        self.confirmedAt = confirmedAt
    }
}

public struct IntervalBlock: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var label: String
    public var workSeconds: Int
    public var restSeconds: Int
    public var rounds: Int
    public var sortIndex: Int
    public init(
        id: String,
        sessionId: String,
        label: String,
        workSeconds: Int,
        restSeconds: Int,
        rounds: Int,
        sortIndex: Int
    ) {
        self.id = id
        self.sessionId = sessionId
        self.label = label
        self.workSeconds = workSeconds
        self.restSeconds = restSeconds
        self.rounds = rounds
        self.sortIndex = sortIndex
    }
}

public struct AnnotatedOverlay: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var formShotId: String
    public var xNorm: Double
    public var yNorm: Double
    public var label: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        formShotId: String,
        xNorm: Double,
        yNorm: Double,
        label: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.formShotId = formShotId
        self.xNorm = xNorm
        self.yNorm = yNorm
        self.label = label
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
    public var intentKind: String
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        transcript: String,
        intentKind: String,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.transcript = transcript
        self.intentKind = intentKind
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
