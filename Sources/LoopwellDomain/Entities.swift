import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Project: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var yarnSwatchHexes: [String]
    public var currentRow: Int
    public var updatedAt: Date
    public init(
        id: String,
        title: String,
        yarnSwatchHexes: [String],
        currentRow: Int,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.yarnSwatchHexes = yarnSwatchHexes
        self.currentRow = currentRow
        self.updatedAt = updatedAt
    }
}

public struct WIPShot: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var relativePath: String
    public var source: String
    public var capturedAt: Date
    public init(
        id: String,
        projectId: String,
        relativePath: String,
        source: String,
        capturedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.relativePath = relativePath
        self.source = source
        self.capturedAt = capturedAt
    }
}

public struct StitchRecognitionDraft: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var wipShotId: String
    public var stitchName: String
    public var rowNumber: Int
    public var stepIndex: Int
    public var notes: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        projectId: String,
        wipShotId: String,
        stitchName: String,
        rowNumber: Int,
        stepIndex: Int,
        notes: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.wipShotId = wipShotId
        self.stitchName = stitchName
        self.rowNumber = rowNumber
        self.stepIndex = stepIndex
        self.notes = notes
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct StitchCue: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var stepIndex: Int
    public var stitchName: String
    public var rowNumber: Int
    public var notes: String
    public var confirmedAt: Date
    public init(
        id: String,
        projectId: String,
        stepIndex: Int,
        stitchName: String,
        rowNumber: Int,
        notes: String,
        confirmedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.stepIndex = stepIndex
        self.stitchName = stitchName
        self.rowNumber = rowNumber
        self.notes = notes
        self.confirmedAt = confirmedAt
    }
}

public struct AnnotatedOverlay: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var wipShotId: String
    public var xNorm: Double
    public var yNorm: Double
    public var label: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        projectId: String,
        wipShotId: String,
        xNorm: Double,
        yNorm: Double,
        label: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.wipShotId = wipShotId
        self.xNorm = xNorm
        self.yNorm = yNorm
        self.label = label
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

public struct PatternNote: Codable, Hashable, Sendable {
    public var id: String
    public var projectId: String
    public var text: String
    public var source: String
    public var createdAt: Date
    public init(
        id: String,
        projectId: String,
        text: String,
        source: String,
        createdAt: Date
    ) {
        self.id = id
        self.projectId = projectId
        self.text = text
        self.source = source
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
