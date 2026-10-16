import Foundation

/// Shared domain entities frozen by technical_contract.v1 (AtomicCodableStore / local persistence).

public struct ClosetItem: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var localFileName: String
    public var category: String
    public var colorTone: String
    public var seasonHint: String
    public var tags: [String]
    public var confirmedAt: Date
    public var sourceKind: String

    public init(
        id: UUID = UUID(),
        localFileName: String,
        category: String = "",
        colorTone: String = "",
        seasonHint: String = "",
        tags: [String] = [],
        confirmedAt: Date = Date(),
        sourceKind: String = "photo_library"
    ) {
        self.id = id
        self.localFileName = localFileName
        self.category = category
        self.colorTone = colorTone
        self.seasonHint = seasonHint
        self.tags = tags
        self.confirmedAt = confirmedAt
        self.sourceKind = sourceKind
    }
}

public struct GarmentDraft: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var localFileName: String
    public var proposedCategory: String
    public var proposedColorTone: String
    public var proposedSeasonHint: String
    public var proposedTags: [String]
    public var sourceKind: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        localFileName: String,
        proposedCategory: String = "",
        proposedColorTone: String = "",
        proposedSeasonHint: String = "",
        proposedTags: [String] = [],
        sourceKind: String = "photo_library",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.localFileName = localFileName
        self.proposedCategory = proposedCategory
        self.proposedColorTone = proposedColorTone
        self.proposedSeasonHint = proposedSeasonHint
        self.proposedTags = proposedTags
        self.sourceKind = sourceKind
        self.createdAt = createdAt
    }
}

public struct OutfitPlan: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var promptText: String
    public var responseText: String
    public var weatherOccasionID: UUID?
    public var closetItemIDs: [UUID]
    public var includesStyleDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        promptText: String,
        responseText: String = "",
        weatherOccasionID: UUID? = nil,
        closetItemIDs: [UUID] = [],
        includesStyleDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.promptText = promptText
        self.responseText = responseText
        self.weatherOccasionID = weatherOccasionID
        self.closetItemIDs = closetItemIDs
        self.includesStyleDisclaimer = includesStyleDisclaimer
        self.createdAt = createdAt
    }
}

public struct FlatLayBoard: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var outfitPlanID: UUID?
    public var closetItemIDs: [UUID]
    public var localFileName: String
    public var status: String
    public var createdAt: Date
    public var savedAt: Date?

    public init(
        id: UUID = UUID(),
        outfitPlanID: UUID? = nil,
        closetItemIDs: [UUID] = [],
        localFileName: String = "",
        status: String = "draft",
        createdAt: Date = Date(),
        savedAt: Date? = nil
    ) {
        self.id = id
        self.outfitPlanID = outfitPlanID
        self.closetItemIDs = closetItemIDs
        self.localFileName = localFileName
        self.status = status
        self.createdAt = createdAt
        self.savedAt = savedAt
    }
}

public struct MorningBriefing: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var outfitPlanID: UUID?
    public var utterances: [String]
    public var weatherOccasionID: UUID?
    public var includesStyleDisclaimer: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        outfitPlanID: UUID? = nil,
        utterances: [String] = [],
        weatherOccasionID: UUID? = nil,
        includesStyleDisclaimer: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.outfitPlanID = outfitPlanID
        self.utterances = utterances
        self.weatherOccasionID = weatherOccasionID
        self.includesStyleDisclaimer = includesStyleDisclaimer
        self.createdAt = createdAt
    }
}

public struct WeatherOccasionContext: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var weatherSummary: String
    public var occasion: String
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        weatherSummary: String = "",
        occasion: String = "",
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.weatherSummary = weatherSummary
        self.occasion = occasion
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
        provider: String = HemlineIdentity.aiProvider,
        disclosureVersion: String = HemlineIdentity.consentDisclosureVersion,
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

public struct ClosetItemCatalog: Codable, Equatable, Sendable {
    public var items: [ClosetItem]
    public init(items: [ClosetItem] = []) { self.items = items }
}

public struct GarmentDraftCatalog: Codable, Equatable, Sendable {
    public var drafts: [GarmentDraft]
    public init(drafts: [GarmentDraft] = []) { self.drafts = drafts }
}

public struct OutfitPlanCatalog: Codable, Equatable, Sendable {
    public var plans: [OutfitPlan]
    public init(plans: [OutfitPlan] = []) { self.plans = plans }
}

public struct FlatLayBoardCatalog: Codable, Equatable, Sendable {
    public var boards: [FlatLayBoard]
    public init(boards: [FlatLayBoard] = []) { self.boards = boards }
}

public struct MorningBriefingCatalog: Codable, Equatable, Sendable {
    public var briefings: [MorningBriefing]
    public init(briefings: [MorningBriefing] = []) { self.briefings = briefings }
}

public struct WeatherOccasionCatalog: Codable, Equatable, Sendable {
    public var contexts: [WeatherOccasionContext]
    public init(contexts: [WeatherOccasionContext] = []) { self.contexts = contexts }
}
