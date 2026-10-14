import Foundation

/// Shared domain entities frozen by technical_contract.v1 (AtomicCodableStore / local persistence).

public enum UnitSystem: String, Codable, Equatable, Sendable {
    case imperial
    case metric
}

public struct JobSession: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var unitSystem: UnitSystem
    public var fieldPhotoIDs: [UUID]
    public var bendMarkupIDs: [UUID]
    public var diagramOverlayIDs: [UUID]
    public var coachingStepIDs: [UUID]
    public var bendQueryIDs: [UUID]

    public init(
        id: UUID = UUID(),
        title: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        unitSystem: UnitSystem = .imperial,
        fieldPhotoIDs: [UUID] = [],
        bendMarkupIDs: [UUID] = [],
        diagramOverlayIDs: [UUID] = [],
        coachingStepIDs: [UUID] = [],
        bendQueryIDs: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.unitSystem = unitSystem
        self.fieldPhotoIDs = fieldPhotoIDs
        self.bendMarkupIDs = bendMarkupIDs
        self.diagramOverlayIDs = diagramOverlayIDs
        self.coachingStepIDs = coachingStepIDs
        self.bendQueryIDs = bendQueryIDs
    }
}

public struct BendQuery: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSessionID: UUID
    public var promptText: String
    public var responseText: String
    public var unitSystem: UnitSystem
    public var createdAt: Date
    public var includesAssistiveDisclaimer: Bool

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID,
        promptText: String,
        responseText: String = "",
        unitSystem: UnitSystem = .imperial,
        createdAt: Date = Date(),
        includesAssistiveDisclaimer: Bool = true
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.promptText = promptText
        self.responseText = responseText
        self.unitSystem = unitSystem
        self.createdAt = createdAt
        self.includesAssistiveDisclaimer = includesAssistiveDisclaimer
    }
}

public struct FieldPhoto: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSessionID: UUID
    public var localFileName: String
    public var importedAt: Date
    public var sourceKind: String

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID,
        localFileName: String,
        importedAt: Date = Date(),
        sourceKind: String = "photo_library"
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.localFileName = localFileName
        self.importedAt = importedAt
        self.sourceKind = sourceKind
    }
}

public struct BendRecognitionDraft: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSessionID: UUID
    public var fieldPhotoID: UUID
    public var proposedBendType: String
    public var markupHints: [String]
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID,
        fieldPhotoID: UUID,
        proposedBendType: String,
        markupHints: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.fieldPhotoID = fieldPhotoID
        self.proposedBendType = proposedBendType
        self.markupHints = markupHints
        self.createdAt = createdAt
    }
}

public struct BendMarkup: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSessionID: UUID
    public var fieldPhotoID: UUID
    public var bendType: String
    public var keyDimensions: [String: String]
    public var unitSystem: UnitSystem
    public var confirmedAt: Date

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID,
        fieldPhotoID: UUID,
        bendType: String,
        keyDimensions: [String: String] = [:],
        unitSystem: UnitSystem = .imperial,
        confirmedAt: Date = Date()
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.fieldPhotoID = fieldPhotoID
        self.bendType = bendType
        self.keyDimensions = keyDimensions
        self.unitSystem = unitSystem
        self.confirmedAt = confirmedAt
    }
}

public struct DiagramOverlay: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSessionID: UUID
    public var bendMarkupID: UUID?
    public var localFileName: String
    public var status: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID,
        bendMarkupID: UUID? = nil,
        localFileName: String = "",
        status: String = "draft",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.bendMarkupID = bendMarkupID
        self.localFileName = localFileName
        self.status = status
        self.createdAt = createdAt
    }
}

public struct CoachingStep: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var jobSessionID: UUID
    public var orderIndex: Int
    public var utterance: String
    public var includesAssistiveDisclaimer: Bool

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID,
        orderIndex: Int,
        utterance: String,
        includesAssistiveDisclaimer: Bool = true
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.orderIndex = orderIndex
        self.utterance = utterance
        self.includesAssistiveDisclaimer = includesAssistiveDisclaimer
    }
}

public struct UnitPreference: Codable, Equatable, Sendable {
    public var unitSystem: UnitSystem
    public var firstExplanationSeen: Bool
    public var updatedAt: Date

    public init(
        unitSystem: UnitSystem = .imperial,
        firstExplanationSeen: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.unitSystem = unitSystem
        self.firstExplanationSeen = firstExplanationSeen
        self.updatedAt = updatedAt
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
        provider: String = BendCoachIdentity.aiProvider,
        disclosureVersion: String = BendCoachIdentity.consentDisclosureVersion,
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
    public var jobSessionID: UUID?
    public var transcript: String
    public var isListening: Bool
    public var startedAt: Date

    public init(
        id: UUID = UUID(),
        jobSessionID: UUID? = nil,
        transcript: String = "",
        isListening: Bool = false,
        startedAt: Date = Date()
    ) {
        self.id = id
        self.jobSessionID = jobSessionID
        self.transcript = transcript
        self.isListening = isListening
        self.startedAt = startedAt
    }
}

public struct JobSessionCatalog: Codable, Equatable, Sendable {
    public var sessions: [JobSession]
    public init(sessions: [JobSession] = []) { self.sessions = sessions }
}

public struct BendQueryCatalog: Codable, Equatable, Sendable {
    public var queries: [BendQuery]
    public init(queries: [BendQuery] = []) { self.queries = queries }
}

public struct FieldPhotoCatalog: Codable, Equatable, Sendable {
    public var photos: [FieldPhoto]
    public init(photos: [FieldPhoto] = []) { self.photos = photos }
}

public struct BendRecognitionDraftCatalog: Codable, Equatable, Sendable {
    public var drafts: [BendRecognitionDraft]
    public init(drafts: [BendRecognitionDraft] = []) { self.drafts = drafts }
}

public struct BendMarkupCatalog: Codable, Equatable, Sendable {
    public var markups: [BendMarkup]
    public init(markups: [BendMarkup] = []) { self.markups = markups }
}

public struct DiagramOverlayCatalog: Codable, Equatable, Sendable {
    public var overlays: [DiagramOverlay]
    public init(overlays: [DiagramOverlay] = []) { self.overlays = overlays }
}

public struct CoachingStepCatalog: Codable, Equatable, Sendable {
    public var steps: [CoachingStep]
    public init(steps: [CoachingStep] = []) { self.steps = steps }
}
