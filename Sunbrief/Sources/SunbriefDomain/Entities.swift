import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct ScoutShot: Codable, Hashable, Sendable {
    public var id: String
    public var relativePath: String
    public var source: String
    public var capturedAt: Date
    public var latitude: Double?
    public var longitude: Double?
    public init(
        id: String,
        relativePath: String,
        source: String,
        capturedAt: Date,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.relativePath = relativePath
        self.source = source
        self.capturedAt = capturedAt
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct SceneCard: Codable, Hashable, Sendable {
    public var id: String
    public var shotId: String
    public var placeLabel: String
    public var lightQuality: String
    public var facingHint: String
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        shotId: String,
        placeLabel: String,
        lightQuality: String,
        facingHint: String,
        status: String,
        updatedAt: Date
    ) {
        self.id = id
        self.shotId = shotId
        self.placeLabel = placeLabel
        self.lightQuality = lightQuality
        self.facingHint = facingHint
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct TimingWindow: Codable, Hashable, Sendable {
    public var id: String
    public var kind: String
    public var startsAt: Date
    public var endsAt: Date
    public var label: String
    public init(
        id: String,
        kind: String,
        startsAt: Date,
        endsAt: Date,
        label: String
    ) {
        self.id = id
        self.kind = kind
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.label = label
    }
}

public struct ScoutPlan: Codable, Hashable, Sendable {
    public var id: String
    public var cardId: String
    public var title: String
    public var windowIds: [String]
    public var notes: String
    public var updatedAt: Date
    public init(
        id: String,
        cardId: String,
        title: String,
        windowIds: [String],
        notes: String,
        updatedAt: Date
    ) {
        self.id = id
        self.cardId = cardId
        self.title = title
        self.windowIds = windowIds
        self.notes = notes
        self.updatedAt = updatedAt
    }
}

public struct OverlayMark: Codable, Hashable, Sendable {
    public var id: String
    public var cardId: String
    public var shotId: String
    public var xNorm: Double
    public var yNorm: Double
    public var text: String
    public init(
        id: String,
        cardId: String,
        shotId: String,
        xNorm: Double,
        yNorm: Double,
        text: String
    ) {
        self.id = id
        self.cardId = cardId
        self.shotId = shotId
        self.xNorm = xNorm
        self.yNorm = yNorm
        self.text = text
    }
}

public struct CoachMessage: Codable, Hashable, Sendable {
    public var id: String
    public var cardId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public var status: String
    public init(
        id: String,
        cardId: String,
        role: String,
        text: String,
        createdAt: Date,
        status: String
    ) {
        self.id = id
        self.cardId = cardId
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.status = status
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var cardId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public init(
        id: String,
        cardId: String,
        role: String,
        text: String,
        createdAt: Date
    ) {
        self.id = id
        self.cardId = cardId
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

public struct ShootNote: Codable, Hashable, Sendable {
    public var id: String
    public var planId: String
    public var transcript: String
    public var createdAt: Date
    public init(
        id: String,
        planId: String,
        transcript: String,
        createdAt: Date
    ) {
        self.id = id
        self.planId = planId
        self.transcript = transcript
        self.createdAt = createdAt
    }
}

public struct BriefingClip: Codable, Hashable, Sendable {
    public var id: String
    public var planId: String
    public var stopLabel: String
    public var spokenText: String
    public var order: Int
    public init(
        id: String,
        planId: String,
        stopLabel: String,
        spokenText: String,
        order: Int
    ) {
        self.id = id
        self.planId = planId
        self.stopLabel = stopLabel
        self.spokenText = spokenText
        self.order = order
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
