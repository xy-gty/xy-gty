import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct MixSession: Codable, Hashable, Sendable {
    public var id: String
    public var createdAt: Date
    public var photoLocalURL: String
    public var source: String
    public var subject: String
    public var status: String

    public init(
        id: String,
        createdAt: Date,
        photoLocalURL: String,
        source: String,
        subject: String,
        status: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.photoLocalURL = photoLocalURL
        self.source = source
        self.subject = subject
        self.status = status
    }
}

public struct SpiritCandidate: Codable, Hashable, Sendable {
    public var sessionId: String
    public var displayName: String
    public var baseSpirit: String
    public var confidence: Double
    public var rank: Int
    public var labelCues: [String]

    public init(
        sessionId: String,
        displayName: String,
        baseSpirit: String,
        confidence: Double,
        rank: Int,
        labelCues: [String]
    ) {
        self.sessionId = sessionId
        self.displayName = displayName
        self.baseSpirit = baseSpirit
        self.confidence = confidence
        self.rank = rank
        self.labelCues = labelCues
    }
}

public struct PourStep: Codable, Hashable, Sendable {
    public var sessionId: String
    public var recipeId: String
    public var ordinal: Int
    public var action: String
    public var amountMl: Double?
    public var durationSec: Double?
    public var instruction: String

    public init(
        sessionId: String,
        recipeId: String,
        ordinal: Int,
        action: String,
        amountMl: Double?,
        durationSec: Double?,
        instruction: String
    ) {
        self.sessionId = sessionId
        self.recipeId = recipeId
        self.ordinal = ordinal
        self.action = action
        self.amountMl = amountMl
        self.durationSec = durationSec
        self.instruction = instruction
    }
}

public struct GarnishChip: Codable, Hashable, Sendable {
    public var sessionId: String
    public var recipeId: String
    public var name: String
    public var placed: Bool
    public var accentColor: String

    public init(
        sessionId: String,
        recipeId: String,
        name: String,
        placed: Bool,
        accentColor: String
    ) {
        self.sessionId = sessionId
        self.recipeId = recipeId
        self.name = name
        self.placed = placed
        self.accentColor = accentColor
    }
}

public struct RecipeCard: Codable, Hashable, Sendable {
    public var sessionId: String
    public var title: String
    public var baseSpirit: String
    public var steps: [PourStep]
    public var garnishChips: [GarnishChip]
    public var substituteNotes: String

    public init(
        sessionId: String,
        title: String,
        baseSpirit: String,
        steps: [PourStep],
        garnishChips: [GarnishChip],
        substituteNotes: String
    ) {
        self.sessionId = sessionId
        self.title = title
        self.baseSpirit = baseSpirit
        self.steps = steps
        self.garnishChips = garnishChips
        self.substituteNotes = substituteNotes
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var sessionId: String
    public var role: String
    public var text: String
    public var sttSource: String?
    public var createdAt: Date

    public init(
        sessionId: String,
        role: String,
        text: String,
        sttSource: String?,
        createdAt: Date
    ) {
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.sttSource = sttSource
        self.createdAt = createdAt
    }
}

public struct VoiceNote: Codable, Hashable, Sendable {
    public var sessionId: String?
    public var localAudioURL: String
    public var transcript: String?
    public var createdAt: Date

    public init(
        sessionId: String?,
        localAudioURL: String,
        transcript: String?,
        createdAt: Date
    ) {
        self.sessionId = sessionId
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

    public init(
        ttsEnabled: Bool = true,
        speechInputEnabled: Bool = true,
        consentRevoked: Bool = false
    ) {
        self.ttsEnabled = ttsEnabled
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
    }
}

/// Aggregate root persisted via AtomicCodableStore for restart restore.
public struct MixCueState: Codable, Hashable, Sendable {
    public var sessions: [MixSession]
    public var candidates: [SpiritCandidate]
    public var recipes: [RecipeCard]
    public var coachTurns: [CoachTurn]
    public var voiceNotes: [VoiceNote]
    public var settings: AppSettings

    public init(
        sessions: [MixSession] = [],
        candidates: [SpiritCandidate] = [],
        recipes: [RecipeCard] = [],
        coachTurns: [CoachTurn] = [],
        voiceNotes: [VoiceNote] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.sessions = sessions
        self.candidates = candidates
        self.recipes = recipes
        self.coachTurns = coachTurns
        self.voiceNotes = voiceNotes
        self.settings = settings
    }
}
