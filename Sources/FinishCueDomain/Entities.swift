import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct HeatPack: Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var venueNote: String
    /// Snapshot of compliance banner text at pack creation.
    public var complianceSnapshot: String
    public var createdAt: Date
    public var updatedAt: Date
    public init(
        id: String,
        title: String,
        venueNote: String = "",
        complianceSnapshot: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.venueNote = venueNote
        self.complianceSnapshot = complianceSnapshot
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct FinishStrip: Codable, Hashable, Sendable {
    public var id: String
    public var heatPackId: String
    /// camera | photos
    public var source: String
    /// Local file ref for slit still or video finish keyframe.
    public var localMediaURL: String
    public var capturedAt: Date
    public init(
        id: String,
        heatPackId: String,
        source: String,
        localMediaURL: String,
        capturedAt: Date
    ) {
        self.id = id
        self.heatPackId = heatPackId
        self.source = source
        self.localMediaURL = localMediaURL
        self.capturedAt = capturedAt
    }
}

public struct LaneRead: Codable, Hashable, Sendable {
    public var id: String
    public var heatPackId: String
    public var finishStripId: String
    public var laneNumber: Int
    public var athleteLabel: String
    /// Draft or confirmed raw time string (e.g. "12.34").
    public var timeRead: String
    /// draft | confirmed | discarded
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        heatPackId: String,
        finishStripId: String,
        laneNumber: Int,
        athleteLabel: String = "",
        timeRead: String = "",
        status: String = "draft",
        updatedAt: Date
    ) {
        self.id = id
        self.heatPackId = heatPackId
        self.finishStripId = finishStripId
        self.laneNumber = laneNumber
        self.athleteLabel = athleteLabel
        self.timeRead = timeRead
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var id: String
    public var heatPackId: String
    /// user | coach
    public var role: String
    public var text: String
    /// Optional feedback mark from human review.
    public var feedbackMark: String?
    public var sttSource: Bool
    public var createdAt: Date
    public init(
        id: String,
        heatPackId: String,
        role: String,
        text: String,
        feedbackMark: String? = nil,
        sttSource: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.heatPackId = heatPackId
        self.role = role
        self.text = text
        self.feedbackMark = feedbackMark
        self.sttSource = sttSource
        self.createdAt = createdAt
    }
}

public struct FinishCard: Codable, Hashable, Sendable {
    public var id: String
    public var heatPackId: String
    public var finishStripId: String
    public var laneNumbers: [Int]
    public var timeChips: [String]
    /// Cropped strip local ref for annotated card.
    public var stripCropURL: String?
    /// draft | confirmed | discarded
    public var status: String
    public var updatedAt: Date
    public init(
        id: String,
        heatPackId: String,
        finishStripId: String,
        laneNumbers: [Int] = [],
        timeChips: [String] = [],
        stripCropURL: String? = nil,
        status: String = "draft",
        updatedAt: Date
    ) {
        self.id = id
        self.heatPackId = heatPackId
        self.finishStripId = finishStripId
        self.laneNumbers = laneNumbers
        self.timeChips = timeChips
        self.stripCropURL = stripCropURL
        self.status = status
        self.updatedAt = updatedAt
    }
}

public struct CalloutCue: Codable, Hashable, Sendable {
    public var id: String
    public var heatPackId: String
    /// start | time | lap
    public var cueKind: String
    public var text: String
    public var spokenAt: Date?
    public var sortIndex: Int
    public init(
        id: String,
        heatPackId: String,
        cueKind: String,
        text: String,
        spokenAt: Date? = nil,
        sortIndex: Int = 0
    ) {
        self.id = id
        self.heatPackId = heatPackId
        self.cueKind = cueKind
        self.text = text
        self.spokenAt = spokenAt
        self.sortIndex = sortIndex
    }
}

public struct AIConsentRecord: Codable, Hashable, Sendable {
    public var provider: String
    public var disclosureVersion: String
    public var grantedAt: Date
    public var revokedAt: Date?
    public init(
        provider: String,
        disclosureVersion: String,
        grantedAt: Date,
        revokedAt: Date? = nil
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
    public init(
        ttsEnabled: Bool = true,
        speechInputEnabled: Bool = true,
        consentRevoked: Bool = false,
        alwaysShowComplianceBanner: Bool = true
    ) {
        self.ttsEnabled = ttsEnabled
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
        self.alwaysShowComplianceBanner = alwaysShowComplianceBanner
    }
}

/// Aggregate root persisted via AtomicCodableStore\<FinishCueState\>.
public struct FinishCueState: Codable, Hashable, Sendable {
    public var heatPacks: [HeatPack]
    public var finishStrips: [FinishStrip]
    public var laneReads: [LaneRead]
    public var coachTurns: [CoachTurn]
    public var finishCards: [FinishCard]
    public var calloutCues: [CalloutCue]
    public var settings: AppSettings
    public init(
        heatPacks: [HeatPack] = [],
        finishStrips: [FinishStrip] = [],
        laneReads: [LaneRead] = [],
        coachTurns: [CoachTurn] = [],
        finishCards: [FinishCard] = [],
        calloutCues: [CalloutCue] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.heatPacks = heatPacks
        self.finishStrips = finishStrips
        self.laneReads = laneReads
        self.coachTurns = coachTurns
        self.finishCards = finishCards
        self.calloutCues = calloutCues
        self.settings = settings
    }
}
