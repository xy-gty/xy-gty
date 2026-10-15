import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Inspection: Codable, Hashable, Sendable {
    public var id: String
    public var hiveLabel: String
    public var inspectedAt: Date
    public var currentFrameLabel: String
    public var updatedAt: Date
    public init(
        id: String,
        hiveLabel: String,
        inspectedAt: Date,
        currentFrameLabel: String,
        updatedAt: Date
    ) {
        self.id = id
        self.hiveLabel = hiveLabel
        self.inspectedAt = inspectedAt
        self.currentFrameLabel = currentFrameLabel
        self.updatedAt = updatedAt
    }
}

public struct FrameShot: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var relativePath: String
    public var source: String
    public var capturedAt: Date
    public init(
        id: String,
        inspectionId: String,
        relativePath: String,
        source: String,
        capturedAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.relativePath = relativePath
        self.source = source
        self.capturedAt = capturedAt
    }
}

public struct BroodDraft: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var frameShotId: String
    public var broodSummary: String
    public var storesSummary: String
    public var pestSigns: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        inspectionId: String,
        frameShotId: String,
        broodSummary: String,
        storesSummary: String,
        pestSigns: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.frameShotId = frameShotId
        self.broodSummary = broodSummary
        self.storesSummary = storesSummary
        self.pestSigns = pestSigns
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct Finding: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var frameShotId: String
    public var tag: String
    public var detail: String
    public var confirmedAt: Date
    public init(
        id: String,
        inspectionId: String,
        frameShotId: String,
        tag: String,
        detail: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.frameShotId = frameShotId
        self.tag = tag
        self.detail = detail
        self.confirmedAt = confirmedAt
    }
}

public struct AnnotatedOverlay: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var frameShotId: String
    public var xNorm: Double
    public var yNorm: Double
    public var heatValue: Double
    public var label: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        inspectionId: String,
        frameShotId: String,
        xNorm: Double,
        yNorm: Double,
        heatValue: Double,
        label: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.frameShotId = frameShotId
        self.xNorm = xNorm
        self.yNorm = yNorm
        self.heatValue = heatValue
        self.label = label
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public init(
        id: String,
        inspectionId: String,
        role: String,
        text: String,
        createdAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

public struct CoachMessage: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public var status: String
    public init(
        id: String,
        inspectionId: String,
        role: String,
        text: String,
        createdAt: Date,
        status: String
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.status = status
    }
}

public struct VoiceNote: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var text: String
    public var sortIndex: Int
    public var createdAt: Date
    public init(
        id: String,
        inspectionId: String,
        text: String,
        sortIndex: Int,
        createdAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.text = text
        self.sortIndex = sortIndex
        self.createdAt = createdAt
    }
}

public struct DictatedField: Codable, Hashable, Sendable {
    public var id: String
    public var inspectionId: String
    public var fieldKey: String
    public var value: String
    public var transcript: String
    public var createdAt: Date
    public init(
        id: String,
        inspectionId: String,
        fieldKey: String,
        value: String,
        transcript: String,
        createdAt: Date
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.fieldKey = fieldKey
        self.value = value
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
