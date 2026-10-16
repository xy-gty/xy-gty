import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct ForageSession: Codable, Hashable, Sendable {
    public var id: String
    public var createdAt: Date
    public var photoLocalURL: String
    public var source: String
    public var subject: String
    public var status: String
    public var disclaimerAck: Bool

    public init(
        id: String,
        createdAt: Date,
        photoLocalURL: String,
        source: String,
        subject: String,
        status: String,
        disclaimerAck: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.photoLocalURL = photoLocalURL
        self.source = source
        self.subject = subject
        self.status = status
        self.disclaimerAck = disclaimerAck
    }
}

public struct SpeciesCandidate: Codable, Hashable, Sendable {
    public var sessionId: String
    public var displayName: String
    public var scientificName: String?
    public var confidence: Double
    public var rank: Int
    public var morphologyCues: [String]

    public init(
        sessionId: String,
        displayName: String,
        scientificName: String?,
        confidence: Double,
        rank: Int,
        morphologyCues: [String]
    ) {
        self.sessionId = sessionId
        self.displayName = displayName
        self.scientificName = scientificName
        self.confidence = confidence
        self.rank = rank
        self.morphologyCues = morphologyCues
    }
}

public struct MorphologyCallout: Codable, Hashable, Sendable {
    public var sessionId: String
    public var region: String
    public var label: String
    public var normalizedRect: [Double]
    public var note: String

    public init(
        sessionId: String,
        region: String,
        label: String,
        normalizedRect: [Double],
        note: String
    ) {
        self.sessionId = sessionId
        self.region = region
        self.label = label
        self.normalizedRect = normalizedRect
        self.note = note
    }
}

public struct CautionChip: Codable, Hashable, Sendable {
    public var sessionId: String
    public var kind: String
    public var title: String
    public var informationalOnly: Bool

    public init(
        sessionId: String,
        kind: String,
        title: String,
        informationalOnly: Bool = true
    ) {
        self.sessionId = sessionId
        self.kind = kind
        self.title = title
        self.informationalOnly = informationalOnly
    }
}

public struct OverlayAnnotation: Codable, Hashable, Sendable {
    public var sessionId: String
    public var callouts: [MorphologyCallout]
    public var imageLocalURL: String

    public init(
        sessionId: String,
        callouts: [MorphologyCallout],
        imageLocalURL: String
    ) {
        self.sessionId = sessionId
        self.callouts = callouts
        self.imageLocalURL = imageLocalURL
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

public struct FieldBrief: Codable, Hashable, Sendable {
    public var sessionId: String
    public var scriptText: String
    public var spokenAt: Date?
    public var ttsLocale: String

    public init(
        sessionId: String,
        scriptText: String,
        spokenAt: Date?,
        ttsLocale: String
    ) {
        self.sessionId = sessionId
        self.scriptText = scriptText
        self.spokenAt = spokenAt
        self.ttsLocale = ttsLocale
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
    public var alwaysShowEdibilityDisclaimer: Bool

    public init(
        ttsEnabled: Bool = true,
        speechInputEnabled: Bool = true,
        consentRevoked: Bool = false,
        alwaysShowEdibilityDisclaimer: Bool = true
    ) {
        self.ttsEnabled = ttsEnabled
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
        self.alwaysShowEdibilityDisclaimer = alwaysShowEdibilityDisclaimer
    }
}

/// Aggregate root persisted via AtomicCodableStore for restart restore.
public struct GillnoteState: Codable, Hashable, Sendable {
    public var sessions: [ForageSession]
    public var candidates: [SpeciesCandidate]
    public var callouts: [MorphologyCallout]
    public var chips: [CautionChip]
    public var overlays: [OverlayAnnotation]
    public var coachTurns: [CoachTurn]
    public var fieldBriefs: [FieldBrief]
    public var voiceNotes: [VoiceNote]
    public var settings: AppSettings

    public init(
        sessions: [ForageSession] = [],
        candidates: [SpeciesCandidate] = [],
        callouts: [MorphologyCallout] = [],
        chips: [CautionChip] = [],
        overlays: [OverlayAnnotation] = [],
        coachTurns: [CoachTurn] = [],
        fieldBriefs: [FieldBrief] = [],
        voiceNotes: [VoiceNote] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.sessions = sessions
        self.candidates = candidates
        self.callouts = callouts
        self.chips = chips
        self.overlays = overlays
        self.coachTurns = coachTurns
        self.fieldBriefs = fieldBriefs
        self.voiceNotes = voiceNotes
        self.settings = settings
    }
}
