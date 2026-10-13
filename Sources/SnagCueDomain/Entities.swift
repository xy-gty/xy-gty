import Foundation
import AppRuntimeCore

/// Product entities expanded from sealed preparation scaffolding.
public struct Audit: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var title: String
    public var siteLabel: String
    public var createdAt: Date
    public var status: String

    public init(
        id: String,
        title: String,
        siteLabel: String = "",
        createdAt: Date = Date(),
        status: String = "open"
    ) {
        self.id = id
        self.title = title
        self.siteLabel = siteLabel
        self.createdAt = createdAt
        self.status = status
    }
}

public struct WalkthroughPhoto: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var auditId: String
    public var relativePath: String
    public var sequence: Int

    public init(id: String, auditId: String, relativePath: String, sequence: Int = 0) {
        self.id = id
        self.auditId = auditId
        self.relativePath = relativePath
        self.sequence = sequence
    }
}

public struct SnagDraft: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var auditId: String
    public var photoId: String
    public var label: String
    public var approxLocationHint: String
    public var severityGuess: String
    public var notesHint: String

    public init(
        id: String,
        auditId: String,
        photoId: String,
        label: String,
        approxLocationHint: String = "",
        severityGuess: String = "medium",
        notesHint: String = ""
    ) {
        self.id = id
        self.auditId = auditId
        self.photoId = photoId
        self.label = label
        self.approxLocationHint = approxLocationHint
        self.severityGuess = severityGuess
        self.notesHint = notesHint
    }
}

public struct PunchItem: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var auditId: String
    public var title: String
    public var location: String
    public var severity: String
    public var assignee: String
    public var dueDate: String
    public var notes: String
    public var photoRefs: [String]
    public var status: String
    public var feedbackNotes: [String]

    public init(
        id: String,
        auditId: String,
        title: String,
        location: String = "",
        severity: String = "medium",
        assignee: String = "",
        dueDate: String = "",
        notes: String = "",
        photoRefs: [String] = [],
        status: String = "open",
        feedbackNotes: [String] = []
    ) {
        self.id = id
        self.auditId = auditId
        self.title = title
        self.location = location
        self.severity = severity
        self.assignee = assignee
        self.dueDate = dueDate
        self.notes = notes
        self.photoRefs = photoRefs
        self.status = status
        self.feedbackNotes = feedbackNotes
    }
}

public struct ReportDraft: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var auditId: String
    public var punchItemIds: [String]
    public var imageRelativePath: String?
    public var caption: String

    public init(
        id: String,
        auditId: String,
        punchItemIds: [String] = [],
        imageRelativePath: String? = nil,
        caption: String = ""
    ) {
        self.id = id
        self.auditId = auditId
        self.punchItemIds = punchItemIds
        self.imageRelativePath = imageRelativePath
        self.caption = caption
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

public struct CoachSession: Codable, Hashable, Sendable {
    public var auditId: String
    public var stepIndex: Int
    public var isPlaying: Bool

    public init(auditId: String, stepIndex: Int = 0, isPlaying: Bool = false) {
        self.auditId = auditId
        self.stepIndex = stepIndex
        self.isPlaying = isPlaying
    }
}

public struct FieldPatchDraft: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var punchItemId: String
    public var location: String?
    public var severity: String?
    public var assignee: String?
    public var dueDate: String?
    public var notes: String?
    public var rationale: String

    public init(
        id: String,
        punchItemId: String,
        location: String? = nil,
        severity: String? = nil,
        assignee: String? = nil,
        dueDate: String? = nil,
        notes: String? = nil,
        rationale: String = ""
    ) {
        self.id = id
        self.punchItemId = punchItemId
        self.location = location
        self.severity = severity
        self.assignee = assignee
        self.dueDate = dueDate
        self.notes = notes
        self.rationale = rationale
    }
}
