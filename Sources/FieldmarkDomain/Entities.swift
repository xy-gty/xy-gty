import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct IDSession: Codable, Hashable, Sendable {
    public var id: String
    public var createdAt: Date
    public var photoLocalURL: String
    /// camera | photos
    public var source: String
    /// draft | identified | confirmed
    public var status: String
    public init(
        id: String,
        createdAt: Date,
        photoLocalURL: String,
        source: String,
        status: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.photoLocalURL = photoLocalURL
        self.source = source
        self.status = status
    }
}

public struct SpeciesCandidate: Codable, Hashable, Sendable {
    public var sessionId: String
    public var scientificName: String
    public var commonName: String
    public var confidence: Double
    public var rank: Int
    public var silhouetteKey: String
    public init(
        sessionId: String,
        scientificName: String,
        commonName: String,
        confidence: Double,
        rank: Int,
        silhouetteKey: String
    ) {
        self.sessionId = sessionId
        self.scientificName = scientificName
        self.commonName = commonName
        self.confidence = confidence
        self.rank = rank
        self.silhouetteKey = silhouetteKey
    }
}

public struct FieldMark: Codable, Hashable, Sendable {
    public var candidateId: String
    public var label: String
    public var bodyRegion: String
    public var salience: Double
    public var chipEmphasis: Bool
    public init(
        candidateId: String,
        label: String,
        bodyRegion: String,
        salience: Double,
        chipEmphasis: Bool
    ) {
        self.candidateId = candidateId
        self.label = label
        self.bodyRegion = bodyRegion
        self.salience = salience
        self.chipEmphasis = chipEmphasis
    }
}

public struct LookalikePair: Codable, Hashable, Sendable {
    public var sessionId: String
    public var leftCandidateId: String
    public var rightCandidateId: String
    public var contrastNotes: String
    public init(
        sessionId: String,
        leftCandidateId: String,
        rightCandidateId: String,
        contrastNotes: String
    ) {
        self.sessionId = sessionId
        self.leftCandidateId = leftCandidateId
        self.rightCandidateId = rightCandidateId
        self.contrastNotes = contrastNotes
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var sessionId: String
    /// user | coach
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

public struct OverlayCallout: Codable, Hashable, Sendable {
    public var markId: String
    public var x: Double
    public var y: Double
    public var label: String
    public init(markId: String, x: Double, y: Double, label: String) {
        self.markId = markId
        self.x = x
        self.y = y
        self.label = label
    }
}

public struct AnnotatedOverlay: Codable, Hashable, Sendable {
    public var sessionId: String
    public var photoLocalURL: String
    public var callouts: [OverlayCallout]
    public var createdAt: Date
    public init(
        sessionId: String,
        photoLocalURL: String,
        callouts: [OverlayCallout],
        createdAt: Date
    ) {
        self.sessionId = sessionId
        self.photoLocalURL = photoLocalURL
        self.callouts = callouts
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
    public var grantedAt: Date
    public var revokedAt: Date?
    public init(
        provider: String,
        disclosureVersion: String,
        grantedAt: Date,
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
    public init(ttsEnabled: Bool, speechInputEnabled: Bool, consentRevoked: Bool) {
        self.ttsEnabled = ttsEnabled
        self.speechInputEnabled = speechInputEnabled
        self.consentRevoked = consentRevoked
    }
}

/// Aggregate root persisted via AtomicCodableStore for restart restore.
public struct FieldmarkState: Codable, Hashable, Sendable {
    public var sessions: [IDSession]
    public var candidates: [SpeciesCandidate]
    public var fieldMarks: [FieldMark]
    public var lookalikePairs: [LookalikePair]
    public var coachTurns: [CoachTurn]
    public var overlays: [AnnotatedOverlay]
    public var voiceNotes: [VoiceNote]
    public var settings: AppSettings
    public init(
        sessions: [IDSession] = [],
        candidates: [SpeciesCandidate] = [],
        fieldMarks: [FieldMark] = [],
        lookalikePairs: [LookalikePair] = [],
        coachTurns: [CoachTurn] = [],
        overlays: [AnnotatedOverlay] = [],
        voiceNotes: [VoiceNote] = [],
        settings: AppSettings = AppSettings(
            ttsEnabled: true,
            speechInputEnabled: true,
            consentRevoked: false
        )
    ) {
        self.sessions = sessions
        self.candidates = candidates
        self.fieldMarks = fieldMarks
        self.lookalikePairs = lookalikePairs
        self.coachTurns = coachTurns
        self.overlays = overlays
        self.voiceNotes = voiceNotes
        self.settings = settings
    }
}
