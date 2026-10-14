import Foundation

/// Shared domain entities frozen by technical_contract.v1 (AtomicCodableStore / local persistence).

public struct PracticeSession: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var title: String
    public var summary: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String = "",
        summary: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct KnotCaptureDraft: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var practiceSessionID: UUID?
    public var localFileName: String
    public var proposedStageTags: [String]
    public var proposedWrongHauls: [String]
    public var proposedRopeDiameterMM: Double?
    public var sourceKind: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        practiceSessionID: UUID? = nil,
        localFileName: String,
        proposedStageTags: [String] = [],
        proposedWrongHauls: [String] = [],
        proposedRopeDiameterMM: Double? = nil,
        sourceKind: String = "photo_library",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.practiceSessionID = practiceSessionID
        self.localFileName = localFileName
        self.proposedStageTags = proposedStageTags
        self.proposedWrongHauls = proposedWrongHauls
        self.proposedRopeDiameterMM = proposedRopeDiameterMM
        self.sourceKind = sourceKind
        self.createdAt = createdAt
    }
}

public struct KnotStage: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var practiceSessionID: UUID?
    public var localFileName: String
    public var stageTags: [String]
    public var wrongHauls: [String]
    public var ropeDiameterMM: Double?
    public var sourceKind: String
    public var includesCoachingDisclaimer: Bool
    public var confirmedAt: Date

    public init(
        id: UUID = UUID(),
        practiceSessionID: UUID? = nil,
        localFileName: String,
        stageTags: [String] = [],
        wrongHauls: [String] = [],
        ropeDiameterMM: Double? = nil,
        sourceKind: String = "photo_library",
        includesCoachingDisclaimer: Bool = true,
        confirmedAt: Date = Date()
    ) {
        self.id = id
        self.practiceSessionID = practiceSessionID
        self.localFileName = localFileName
        self.stageTags = stageTags
        self.wrongHauls = wrongHauls
        self.ropeDiameterMM = ropeDiameterMM
        self.sourceKind = sourceKind
        self.includesCoachingDisclaimer = includesCoachingDisclaimer
        self.confirmedAt = confirmedAt
    }
}

public struct CoachTurn: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var practiceSessionID: UUID?
    public var knotStageID: UUID?
    public var promptText: String
    public var responseText: String
    public var haulContext: String
    public var speechTranscript: String
    public var includesCoachingDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        practiceSessionID: UUID? = nil,
        knotStageID: UUID? = nil,
        promptText: String,
        responseText: String = "",
        haulContext: String = "",
        speechTranscript: String = "",
        includesCoachingDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.practiceSessionID = practiceSessionID
        self.knotStageID = knotStageID
        self.promptText = promptText
        self.responseText = responseText
        self.haulContext = haulContext
        self.speechTranscript = speechTranscript
        self.includesCoachingDisclaimer = includesCoachingDisclaimer
        self.createdAt = createdAt
    }
}

public struct StepOverlay: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var practiceSessionID: UUID?
    public var knotStageID: UUID?
    public var coachTurnID: UUID?
    public var localFileName: String
    public var annotationNotes: [String]
    public var status: String
    public var createdAt: Date
    public var savedAt: Date?

    public init(
        id: UUID = UUID(),
        practiceSessionID: UUID? = nil,
        knotStageID: UUID? = nil,
        coachTurnID: UUID? = nil,
        localFileName: String = "",
        annotationNotes: [String] = [],
        status: String = "draft",
        createdAt: Date = Date(),
        savedAt: Date? = nil
    ) {
        self.id = id
        self.practiceSessionID = practiceSessionID
        self.knotStageID = knotStageID
        self.coachTurnID = coachTurnID
        self.localFileName = localFileName
        self.annotationNotes = annotationNotes
        self.status = status
        self.createdAt = createdAt
        self.savedAt = savedAt
    }
}

public struct HandsFreePlan: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var knotStageID: UUID?
    public var stepOverlayID: UUID?
    public var steps: [String]
    public var includesCoachingDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        knotStageID: UUID? = nil,
        stepOverlayID: UUID? = nil,
        steps: [String] = [],
        includesCoachingDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.knotStageID = knotStageID
        self.stepOverlayID = stepOverlayID
        self.steps = steps
        self.includesCoachingDisclaimer = includesCoachingDisclaimer
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
        provider: String = KnotCueIdentity.aiProvider,
        disclosureVersion: String = KnotCueIdentity.consentDisclosureVersion,
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

public struct PracticeSessionCatalog: Codable, Equatable, Sendable {
    public var sessions: [PracticeSession]
    public init(sessions: [PracticeSession] = []) { self.sessions = sessions }
}

public struct KnotCaptureDraftCatalog: Codable, Equatable, Sendable {
    public var drafts: [KnotCaptureDraft]
    public init(drafts: [KnotCaptureDraft] = []) { self.drafts = drafts }
}

public struct KnotStageCatalog: Codable, Equatable, Sendable {
    public var stages: [KnotStage]
    public init(stages: [KnotStage] = []) { self.stages = stages }
}

public struct CoachTurnCatalog: Codable, Equatable, Sendable {
    public var turns: [CoachTurn]
    public init(turns: [CoachTurn] = []) { self.turns = turns }
}

public struct StepOverlayCatalog: Codable, Equatable, Sendable {
    public var overlays: [StepOverlay]
    public init(overlays: [StepOverlay] = []) { self.overlays = overlays }
}

public struct HandsFreePlanCatalog: Codable, Equatable, Sendable {
    public var plans: [HandsFreePlan]
    public init(plans: [HandsFreePlan] = []) { self.plans = plans }
}
