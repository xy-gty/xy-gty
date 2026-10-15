import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Session: Codable, Hashable, Sendable {
    public var id: String
    public var locationLabel: String
    public var sessionDate: Date
    public var sceneGoal: String
    public var currentFrameLabel: String
    public var updatedAt: Date
    public init(
        id: String,
        locationLabel: String,
        sessionDate: Date,
        sceneGoal: String,
        currentFrameLabel: String,
        updatedAt: Date
    ) {
        self.id = id
        self.locationLabel = locationLabel
        self.sessionDate = sessionDate
        self.sceneGoal = sceneGoal
        self.currentFrameLabel = currentFrameLabel
        self.updatedAt = updatedAt
    }
}

public struct NightFrame: Codable, Hashable, Sendable {
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

public struct ExposureDraft: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var nightFrameId: String
    public var exposureSummary: String
    public var noiseSummary: String
    public var trailSigns: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        nightFrameId: String,
        exposureSummary: String,
        noiseSummary: String,
        trailSigns: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.nightFrameId = nightFrameId
        self.exposureSummary = exposureSummary
        self.noiseSummary = noiseSummary
        self.trailSigns = trailSigns
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct DiagnosisFinding: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var nightFrameId: String
    public var tag: String
    public var detail: String
    public var confirmedAt: Date
    public init(
        id: String,
        sessionId: String,
        nightFrameId: String,
        tag: String,
        detail: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.nightFrameId = nightFrameId
        self.tag = tag
        self.detail = detail
        self.confirmedAt = confirmedAt
    }
}

public struct AnnotatedOverlay: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var nightFrameId: String
    public var xNorm: Double
    public var yNorm: Double
    public var diagnosisValue: Double
    public var label: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        sessionId: String,
        nightFrameId: String,
        xNorm: Double,
        yNorm: Double,
        diagnosisValue: Double,
        label: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.nightFrameId = nightFrameId
        self.xNorm = xNorm
        self.yNorm = yNorm
        self.diagnosisValue = diagnosisValue
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

public struct FieldCue: Codable, Hashable, Sendable {
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

public struct DictatedExposure: Codable, Hashable, Sendable {
    public var id: String
    public var sessionId: String
    public var iso: String
    public var shutterS: String
    public var aperture: String
    public var notes: String
    public var transcript: String
    public var createdAt: Date
    public init(
        id: String,
        sessionId: String,
        iso: String,
        shutterS: String,
        aperture: String,
        notes: String,
        transcript: String,
        createdAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.iso = iso
        self.shutterS = shutterS
        self.aperture = aperture
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
