import Foundation

/// Shared domain entities frozen by technical_contract.v1 (AtomicCodableStore / local persistence).

public struct Brief: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var documentPhotoIDs: [UUID]
    public var extractedFieldIDs: [UUID]
    public var actionItemIDs: [UUID]
    public var summaryCardDraftID: UUID?
    public var recognizedType: String?

    public init(
        id: UUID = UUID(),
        title: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        documentPhotoIDs: [UUID] = [],
        extractedFieldIDs: [UUID] = [],
        actionItemIDs: [UUID] = [],
        summaryCardDraftID: UUID? = nil,
        recognizedType: String? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.documentPhotoIDs = documentPhotoIDs
        self.extractedFieldIDs = extractedFieldIDs
        self.actionItemIDs = actionItemIDs
        self.summaryCardDraftID = summaryCardDraftID
        self.recognizedType = recognizedType
    }
}

public struct DocumentPhoto: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var briefID: UUID
    public var localFileName: String
    public var importedAt: Date
    public var sourceKind: String

    public init(
        id: UUID = UUID(),
        briefID: UUID,
        localFileName: String,
        importedAt: Date = Date(),
        sourceKind: String = "photo_library"
    ) {
        self.id = id
        self.briefID = briefID
        self.localFileName = localFileName
        self.importedAt = importedAt
        self.sourceKind = sourceKind
    }
}

public struct ExtractedField: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var briefID: UUID
    public var key: String
    public var value: String
    public var confirmed: Bool

    public init(
        id: UUID = UUID(),
        briefID: UUID,
        key: String,
        value: String,
        confirmed: Bool = false
    ) {
        self.id = id
        self.briefID = briefID
        self.key = key
        self.value = value
        self.confirmed = confirmed
    }
}

public struct RecognitionDraft: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var briefID: UUID
    public var documentPhotoID: UUID
    public var proposedType: String
    public var proposedFields: [ExtractedField]
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        briefID: UUID,
        documentPhotoID: UUID,
        proposedType: String,
        proposedFields: [ExtractedField] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.briefID = briefID
        self.documentPhotoID = documentPhotoID
        self.proposedType = proposedType
        self.proposedFields = proposedFields
        self.createdAt = createdAt
    }
}

public struct ActionItem: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var briefID: UUID
    public var text: String
    public var deadline: Date?
    public var confirmed: Bool
    public var source: String

    public init(
        id: UUID = UUID(),
        briefID: UUID,
        text: String,
        deadline: Date? = nil,
        confirmed: Bool = false,
        source: String = "chat_extract"
    ) {
        self.id = id
        self.briefID = briefID
        self.text = text
        self.deadline = deadline
        self.confirmed = confirmed
        self.source = source
    }
}

public struct SummaryCardDraft: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var briefID: UUID
    public var headline: String
    public var body: String
    public var includesDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        briefID: UUID,
        headline: String = "",
        body: String = "",
        includesDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.briefID = briefID
        self.headline = headline
        self.body = body
        self.includesDisclaimer = includesDisclaimer
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
        provider: String = DocBriefIdentity.aiProvider,
        disclosureVersion: String = DocBriefIdentity.consentDisclosureVersion,
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

/// Session-scoped TTS briefing progress (session + step index; not AtomicCodableStore primary).
public struct BriefingSession: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var briefID: UUID
    public var stepIndex: Int
    public var utterableLines: [String]
    public var startedAt: Date

    public init(
        id: UUID = UUID(),
        briefID: UUID,
        stepIndex: Int = 0,
        utterableLines: [String] = [],
        startedAt: Date = Date()
    ) {
        self.id = id
        self.briefID = briefID
        self.stepIndex = stepIndex
        self.utterableLines = utterableLines
        self.startedAt = startedAt
    }
}

public struct BriefCatalog: Codable, Equatable, Sendable {
    public var briefs: [Brief]
    public init(briefs: [Brief] = []) { self.briefs = briefs }
}

public struct DocumentPhotoCatalog: Codable, Equatable, Sendable {
    public var photos: [DocumentPhoto]
    public init(photos: [DocumentPhoto] = []) { self.photos = photos }
}

public struct ExtractedFieldCatalog: Codable, Equatable, Sendable {
    public var fields: [ExtractedField]
    public init(fields: [ExtractedField] = []) { self.fields = fields }
}

public struct RecognitionDraftCatalog: Codable, Equatable, Sendable {
    public var drafts: [RecognitionDraft]
    public init(drafts: [RecognitionDraft] = []) { self.drafts = drafts }
}

public struct ActionItemCatalog: Codable, Equatable, Sendable {
    public var items: [ActionItem]
    public init(items: [ActionItem] = []) { self.items = items }
}

public struct SummaryCardDraftCatalog: Codable, Equatable, Sendable {
    public var drafts: [SummaryCardDraft]
    public init(drafts: [SummaryCardDraft] = []) { self.drafts = drafts }
}
