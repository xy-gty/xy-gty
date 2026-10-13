import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).
public struct Audit: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var createdAt: Date
    public init(id: String, title: String, createdAt: Date) {
        self.id = id; self.title = title; self.createdAt = createdAt
    }
}

public struct WalkthroughPhoto: Codable, Hashable, Sendable {
    public var id: String
    public var auditId: String
    public var relativePath: String
    public init(id: String, auditId: String, relativePath: String) {
        self.id = id; self.auditId = auditId; self.relativePath = relativePath
    }
}

public struct SnagDraft: Codable, Hashable, Sendable {
    public var id: String
    public var photoId: String
    public var label: String
    public var notes: String
    public init(id: String, photoId: String, label: String, notes: String) {
        self.id = id; self.photoId = photoId; self.label = label; self.notes = notes
    }
}

public struct PunchItem: Codable, Hashable, Sendable {
    public var id: String
    public var auditId: String
    public var title: String
    public var location: String
    public var severity: String
    public var status: String
    public init(id: String, auditId: String, title: String, location: String, severity: String, status: String) {
        self.id = id; self.auditId = auditId; self.title = title
        self.location = location; self.severity = severity; self.status = status
    }
}

public struct ReportDraft: Codable, Hashable, Sendable {
    public var id: String
    public var auditId: String
    public var imageRelativePath: String?
    public init(id: String, auditId: String, imageRelativePath: String?) {
        self.id = id; self.auditId = auditId; self.imageRelativePath = imageRelativePath
    }
}

public struct AIConsentRecord: Codable, Hashable, Sendable {
    public var disclosureVersion: String
    public var allowed: Bool
    public init(disclosureVersion: String, allowed: Bool) {
        self.disclosureVersion = disclosureVersion; self.allowed = allowed
    }
}

public struct CoachSession: Codable, Hashable, Sendable {
    public var auditId: String
    public var stepIndex: Int
    public init(auditId: String, stepIndex: Int) {
        self.auditId = auditId; self.stepIndex = stepIndex
    }
}
