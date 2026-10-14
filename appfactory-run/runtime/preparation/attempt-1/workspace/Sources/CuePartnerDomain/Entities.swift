import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Scene: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var roles: [String]
    public var locked: Bool
    public var createdAt: Date
    public init(id: String, title: String, roles: [String], locked: Bool, createdAt: Date) {
        self.id = id; self.title = title; self.roles = roles
        self.locked = locked; self.createdAt = createdAt
    }
}

public struct ScriptPage: Codable, Hashable, Sendable {
    public var id: String
    public var sceneId: String
    public var relativePath: String
    public var ocrText: String
    public init(id: String, sceneId: String, relativePath: String, ocrText: String) {
        self.id = id; self.sceneId = sceneId
        self.relativePath = relativePath; self.ocrText = ocrText
    }
}

public struct CueLine: Codable, Hashable, Sendable {
    public var id: String
    public var sceneId: String
    public var role: String
    public var text: String
    public var pauseMilliseconds: Int
    public init(id: String, sceneId: String, role: String, text: String, pauseMilliseconds: Int) {
        self.id = id; self.sceneId = sceneId; self.role = role
        self.text = text; self.pauseMilliseconds = pauseMilliseconds
    }
}

public struct PartnerTurn: Codable, Hashable, Sendable {
    public var id: String
    public var sceneId: String
    public var partnerRole: String
    public var draftText: String
    public var confirmed: Bool
    public init(id: String, sceneId: String, partnerRole: String, draftText: String, confirmed: Bool) {
        self.id = id; self.sceneId = sceneId; self.partnerRole = partnerRole
        self.draftText = draftText; self.confirmed = confirmed
    }
}

public struct RehearsalMessage: Codable, Hashable, Sendable {
    public var id: String
    public var sceneId: String
    public var role: String
    public var text: String
    public var createdAt: Date
    public init(id: String, sceneId: String, role: String, text: String, createdAt: Date) {
        self.id = id; self.sceneId = sceneId; self.role = role
        self.text = text; self.createdAt = createdAt
    }
}

public struct VoiceNote: Codable, Hashable, Sendable {
    public var id: String
    public var sceneId: String
    public var relativeAudioPath: String
    public var transcript: String?
    public init(id: String, sceneId: String, relativeAudioPath: String, transcript: String?) {
        self.id = id; self.sceneId = sceneId
        self.relativeAudioPath = relativeAudioPath; self.transcript = transcript
    }
}

/// Local bundle catalog preset id (optional stage ambience).
public struct AmbiencePreset: Codable, Hashable, Sendable {
    public var id: String
    public var displayName: String
    public init(id: String, displayName: String) {
        self.id = id; self.displayName = displayName
    }
}

public struct AIConsentRecord: Codable, Hashable, Sendable {
    public var disclosureVersion: String
    public var allowed: Bool
    public init(disclosureVersion: String, allowed: Bool) {
        self.disclosureVersion = disclosureVersion; self.allowed = allowed
    }
}
