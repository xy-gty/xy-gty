import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct CellarRack: Codable, Hashable, Sendable {
    public var id: String
    public var name: String
    public var rowCount: Int
    public var binCountPerRow: Int
    public var createdAt: Date

    public init(
        id: String,
        name: String,
        rowCount: Int,
        binCountPerRow: Int,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.rowCount = rowCount
        self.binCountPerRow = binCountPerRow
        self.createdAt = createdAt
    }
}

public struct CellarBin: Codable, Hashable, Sendable {
    public var id: String
    public var rackId: String
    public var row: Int
    public var column: Int
    public var label: String

    public init(
        id: String,
        rackId: String,
        row: Int,
        column: Int,
        label: String
    ) {
        self.id = id
        self.rackId = rackId
        self.row = row
        self.column = column
        self.label = label
    }
}

public struct BottleEntry: Codable, Hashable, Sendable {
    public var id: String
    public var binId: String
    public var createdAt: Date
    public var photoLocalURL: String
    public var source: String
    public var status: String
    public var vintage: String?
    public var producer: String?
    public var varietal: String?
    public var region: String?
    public var disclaimerAck: Bool
    public var ageGateAck: Bool

    public init(
        id: String,
        binId: String,
        createdAt: Date,
        photoLocalURL: String,
        source: String,
        status: String,
        vintage: String? = nil,
        producer: String? = nil,
        varietal: String? = nil,
        region: String? = nil,
        disclaimerAck: Bool = false,
        ageGateAck: Bool = false
    ) {
        self.id = id
        self.binId = binId
        self.createdAt = createdAt
        self.photoLocalURL = photoLocalURL
        self.source = source
        self.status = status
        self.vintage = vintage
        self.producer = producer
        self.varietal = varietal
        self.region = region
        self.disclaimerAck = disclaimerAck
        self.ageGateAck = ageGateAck
    }
}

public struct LabelOCRResult: Codable, Hashable, Sendable {
    public var bottleId: String
    public var rawText: String
    public var structuredFields: [String: String]
    public var confidence: Double

    public init(
        bottleId: String,
        rawText: String,
        structuredFields: [String: String],
        confidence: Double
    ) {
        self.bottleId = bottleId
        self.rawText = rawText
        self.structuredFields = structuredFields
        self.confidence = confidence
    }
}

public struct DrinkingWindow: Codable, Hashable, Sendable {
    public var bottleId: String
    public var peakStart: Date?
    public var peakEnd: Date?
    public var status: String
    public var timelinePoints: [String]

    public init(
        bottleId: String,
        peakStart: Date?,
        peakEnd: Date?,
        status: String,
        timelinePoints: [String]
    ) {
        self.bottleId = bottleId
        self.peakStart = peakStart
        self.peakEnd = peakEnd
        self.status = status
        self.timelinePoints = timelinePoints
    }
}

public struct PairingNote: Codable, Hashable, Sendable {
    public var bottleId: String
    public var dish: String
    public var rationale: String
    public var informationalOnly: Bool

    public init(
        bottleId: String,
        dish: String,
        rationale: String,
        informationalOnly: Bool = true
    ) {
        self.bottleId = bottleId
        self.dish = dish
        self.rationale = rationale
        self.informationalOnly = informationalOnly
    }
}

public struct RackCardAnnotation: Codable, Hashable, Sendable {
    public var bottleId: String
    public var callouts: [String]
    public var imageLocalURL: String
    public var generatedAt: Date

    public init(
        bottleId: String,
        callouts: [String],
        imageLocalURL: String,
        generatedAt: Date
    ) {
        self.bottleId = bottleId
        self.callouts = callouts
        self.imageLocalURL = imageLocalURL
        self.generatedAt = generatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var bottleId: String?
    public var role: String
    public var text: String
    public var sttSource: String?
    public var createdAt: Date

    public init(
        bottleId: String?,
        role: String,
        text: String,
        sttSource: String?,
        createdAt: Date
    ) {
        self.bottleId = bottleId
        self.role = role
        self.text = text
        self.sttSource = sttSource
        self.createdAt = createdAt
    }
}

public struct PullBrief: Codable, Hashable, Sendable {
    public var bottleId: String
    public var scriptText: String
    public var spokenAt: Date?
    public var ttsLocale: String

    public init(
        bottleId: String,
        scriptText: String,
        spokenAt: Date?,
        ttsLocale: String
    ) {
        self.bottleId = bottleId
        self.scriptText = scriptText
        self.spokenAt = spokenAt
        self.ttsLocale = ttsLocale
    }
}

public struct VoiceNote: Codable, Hashable, Sendable {
    public var bottleId: String?
    public var binId: String?
    public var localAudioURL: String
    public var transcript: String?
    public var createdAt: Date

    public init(
        bottleId: String?,
        binId: String?,
        localAudioURL: String,
        transcript: String?,
        createdAt: Date
    ) {
        self.bottleId = bottleId
        self.binId = binId
        self.localAudioURL = localAudioURL
        self.transcript = transcript
        self.createdAt = createdAt
    }
}

public struct AIConsentRecord: Codable, Hashable, Sendable {
    public var provider: String
    public var disclosureVersion: String
    public var grantedAt: Date?
    public var revokedAt: Date?

    public init(
        provider: String,
        disclosureVersion: String,
        grantedAt: Date?,
        revokedAt: Date?
    ) {
        self.provider = provider
        self.disclosureVersion = disclosureVersion
        self.grantedAt = grantedAt
        self.revokedAt = revokedAt
    }
}

public struct AppSettings: Codable, Hashable, Sendable {
    public var ttsEnabled: Bool
    public var speechInputEnabled: Bool
    public var consentRevoked: Bool
    public var alwaysShowComplianceBanner: Bool
    public var ageGateAcknowledged: Bool

    public init(
        ttsEnabled: Bool = true,
        speechInputEnabled: Bool = true,
        consentRevoked: Bool = false,
        alwaysShowComplianceBanner: Bool = true,
        ageGateAcknowledged: Bool = false
    ) {
        self.ttsEnabled = ttsEnabled
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
        self.alwaysShowComplianceBanner = alwaysShowComplianceBanner
        self.ageGateAcknowledged = ageGateAcknowledged
    }
}

/// Aggregate root persisted via AtomicCodableStore for restart restore.
public struct CellarCueState: Codable, Hashable, Sendable {
    public var racks: [CellarRack]
    public var bins: [CellarBin]
    public var bottles: [BottleEntry]
    public var labelResults: [LabelOCRResult]
    public var drinkingWindows: [DrinkingWindow]
    public var pairingNotes: [PairingNote]
    public var rackCards: [RackCardAnnotation]
    public var coachTurns: [CoachTurn]
    public var pullBriefs: [PullBrief]
    public var voiceNotes: [VoiceNote]
    public var settings: AppSettings

    public init(
        racks: [CellarRack] = [],
        bins: [CellarBin] = [],
        bottles: [BottleEntry] = [],
        labelResults: [LabelOCRResult] = [],
        drinkingWindows: [DrinkingWindow] = [],
        pairingNotes: [PairingNote] = [],
        rackCards: [RackCardAnnotation] = [],
        coachTurns: [CoachTurn] = [],
        pullBriefs: [PullBrief] = [],
        voiceNotes: [VoiceNote] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.racks = racks
        self.bins = bins
        self.bottles = bottles
        self.labelResults = labelResults
        self.drinkingWindows = drinkingWindows
        self.pairingNotes = pairingNotes
        self.rackCards = rackCards
        self.coachTurns = coachTurns
        self.pullBriefs = pullBriefs
        self.voiceNotes = voiceNotes
        self.settings = settings
    }
}
