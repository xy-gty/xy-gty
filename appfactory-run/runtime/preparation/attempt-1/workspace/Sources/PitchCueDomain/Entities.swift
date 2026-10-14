import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct PracticeSession: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var instrumentLabel: String
    public var updatedAt: Date
    public var freeAccessOpen: Bool
    public init(
        id: String,
        title: String,
        instrumentLabel: String,
        updatedAt: Date,
        freeAccessOpen: Bool = true
    ) {
        self.id = id
        self.title = title
        self.instrumentLabel = instrumentLabel
        self.updatedAt = updatedAt
        self.freeAccessOpen = freeAccessOpen
    }
}

public struct SheetPhoto: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var relativePath: String
    public var source: String
    public init(id: String, sessionId: String, relativePath: String, source: String) {
        self.id = id
        self.sessionId = sessionId
        self.relativePath = relativePath
        self.source = source
    }
}

public struct PracticePlan: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var steps: [String]
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        steps: [String],
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.steps = steps
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var role: String
    public var text: String
    public var feedbackMark: String?
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        role: String,
        text: String,
        feedbackMark: String?,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.feedbackMark = feedbackMark
        self.createdAt = createdAt
    }
}

public struct AudioBed: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var kind: String
    public var pitchHz: Double?
    public var bpm: Double?
    public var waveformParams: [String: Double]
    public init(
        id: String,
        sessionId: String,
        kind: String,
        pitchHz: Double?,
        bpm: Double?,
        waveformParams: [String: Double]
    ) {
        self.id = id
        self.sessionId = sessionId
        self.kind = kind
        self.pitchHz = pitchHz
        self.bpm = bpm
        self.waveformParams = waveformParams
    }
}

public struct PitchSample: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var capturedAt: Date
    public var frequencyHz: Double
    public var centsOffset: Double?
    public init(
        id: String,
        sessionId: String,
        capturedAt: Date,
        frequencyHz: Double,
        centsOffset: Double?
    ) {
        self.id = id
        self.sessionId = sessionId
        self.capturedAt = capturedAt
        self.frequencyHz = frequencyHz
        self.centsOffset = centsOffset
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
