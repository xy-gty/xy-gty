import Foundation

/// Shared domain entities frozen by technical_contract.v1 (AtomicCodableStore / local persistence).

public struct JobSite: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var summary: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String = "",
        summary: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct DuctRunDraft: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSiteID: UUID?
    public var localFileName: String
    public var proposedSizeTags: [String]
    public var proposedDiameterInches: Double?
    public var proposedLengthFeet: Double?
    public var sourceKind: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        jobSiteID: UUID? = nil,
        localFileName: String,
        proposedSizeTags: [String] = [],
        proposedDiameterInches: Double? = nil,
        proposedLengthFeet: Double? = nil,
        sourceKind: String = "photo_library",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.jobSiteID = jobSiteID
        self.localFileName = localFileName
        self.proposedSizeTags = proposedSizeTags
        self.proposedDiameterInches = proposedDiameterInches
        self.proposedLengthFeet = proposedLengthFeet
        self.sourceKind = sourceKind
        self.createdAt = createdAt
    }
}

public struct DuctRun: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSiteID: UUID?
    public var localFileName: String
    public var sizeTags: [String]
    public var diameterInches: Double?
    public var lengthFeet: Double?
    public var sourceKind: String
    public var confirmedAt: Date

    public init(
        id: UUID = UUID(),
        jobSiteID: UUID? = nil,
        localFileName: String,
        sizeTags: [String] = [],
        diameterInches: Double? = nil,
        lengthFeet: Double? = nil,
        sourceKind: String = "photo_library",
        confirmedAt: Date = Date()
    ) {
        self.id = id
        self.jobSiteID = jobSiteID
        self.localFileName = localFileName
        self.sizeTags = sizeTags
        self.diameterInches = diameterInches
        self.lengthFeet = lengthFeet
        self.sourceKind = sourceKind
        self.confirmedAt = confirmedAt
    }
}

public struct SizingSession: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSiteID: UUID?
    public var ductRunID: UUID?
    public var promptText: String
    public var responseText: String
    public var cfm: Double?
    public var friction: Double?
    public var velocity: Double?
    public var citedFormulas: [String]
    public var includesSizingDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        jobSiteID: UUID? = nil,
        ductRunID: UUID? = nil,
        promptText: String,
        responseText: String = "",
        cfm: Double? = nil,
        friction: Double? = nil,
        velocity: Double? = nil,
        citedFormulas: [String] = [],
        includesSizingDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.jobSiteID = jobSiteID
        self.ductRunID = ductRunID
        self.promptText = promptText
        self.responseText = responseText
        self.cfm = cfm
        self.friction = friction
        self.velocity = velocity
        self.citedFormulas = citedFormulas
        self.includesSizingDisclaimer = includesSizingDisclaimer
        self.createdAt = createdAt
    }
}

public struct SizeDiagram: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var sizingSessionID: UUID?
    public var ductRunID: UUID?
    public var localFileName: String
    public var status: String
    public var createdAt: Date
    public var savedAt: Date?

    public init(
        id: UUID = UUID(),
        sizingSessionID: UUID? = nil,
        ductRunID: UUID? = nil,
        localFileName: String = "",
        status: String = "draft",
        createdAt: Date = Date(),
        savedAt: Date? = nil
    ) {
        self.id = id
        self.sizingSessionID = sizingSessionID
        self.ductRunID = ductRunID
        self.localFileName = localFileName
        self.status = status
        self.createdAt = createdAt
        self.savedAt = savedAt
    }
}

public struct FieldStepPlan: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var ductRunID: UUID?
    public var sizeDiagramID: UUID?
    public var steps: [String]
    public var includesSizingDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        ductRunID: UUID? = nil,
        sizeDiagramID: UUID? = nil,
        steps: [String] = [],
        includesSizingDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ductRunID = ductRunID
        self.sizeDiagramID = sizeDiagramID
        self.steps = steps
        self.includesSizingDisclaimer = includesSizingDisclaimer
        self.createdAt = createdAt
    }
}

/// Local durable mirror of consent; KeychainCredentialStore also used for credential existence.
public struct AIConsentRecord: Codable, Equatable, Sendable {
    public var provider: String
    public var disclosureVersion: String
    public var generation: UInt64
    public var granted: Bool
    public var updatedAt: Date

    public init(
        provider: String = DuctCueIdentity.aiProvider,
        disclosureVersion: String = DuctCueIdentity.consentDisclosureVersion,
        generation: UInt64 = 0,
        granted: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.provider = provider
        self.disclosureVersion = disclosureVersion
        self.generation = generation
        self.granted = granted
        self.updatedAt = updatedAt
    }
}

/// Session-scoped mic + STT capture (session + transcript; not AtomicCodableStore primary).
public struct SpeechCaptureSession: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var transcript: String
    public var isListening: Bool
    public var startedAt: Date

    public init(
        id: UUID = UUID(),
        transcript: String = "",
        isListening: Bool = false,
        startedAt: Date = Date()
    ) {
        self.id = id
        self.transcript = transcript
        self.isListening = isListening
        self.startedAt = startedAt
    }
}

public struct JobSiteCatalog: Codable, Equatable, Sendable {
    public var sites: [JobSite]
    public init(sites: [JobSite] = []) { self.sites = sites }
}

public struct DuctRunDraftCatalog: Codable, Equatable, Sendable {
    public var drafts: [DuctRunDraft]
    public init(drafts: [DuctRunDraft] = []) { self.drafts = drafts }
}

public struct DuctRunCatalog: Codable, Equatable, Sendable {
    public var runs: [DuctRun]
    public init(runs: [DuctRun] = []) { self.runs = runs }
}

public struct SizingSessionCatalog: Codable, Equatable, Sendable {
    public var sessions: [SizingSession]
    public init(sessions: [SizingSession] = []) { self.sessions = sessions }
}

public struct SizeDiagramCatalog: Codable, Equatable, Sendable {
    public var diagrams: [SizeDiagram]
    public init(diagrams: [SizeDiagram] = []) { self.diagrams = diagrams }
}

public struct FieldStepPlanCatalog: Codable, Equatable, Sendable {
    public var plans: [FieldStepPlan]
    public init(plans: [FieldStepPlan] = []) { self.plans = plans }
}
