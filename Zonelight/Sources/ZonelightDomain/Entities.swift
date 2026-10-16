import Foundation
import AppRuntimeCore

/// Frozen technical-contract entities (scaffolding only; no UI).

public struct MeterSession: Codable, Hashable, Sendable {
    public var id: String
    public var createdAt: Date
    public var source: String
    public var status: String
    public var sceneNote: String?
    public var disclaimerAck: Bool

    public init(
        id: String,
        createdAt: Date,
        source: String,
        status: String,
        sceneNote: String? = nil,
        disclaimerAck: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.source = source
        self.status = status
        self.sceneNote = sceneNote
        self.disclaimerAck = disclaimerAck
    }
}

public struct SpotReading: Codable, Hashable, Sendable {
    public var sessionId: String
    public var evEstimate: Double
    public var luxHint: Double?
    public var zoneHint: String
    public var crossX: Double
    public var crossY: Double
    public var capturedAt: Date
    public var photoLocalURL: String?

    public init(
        sessionId: String,
        evEstimate: Double,
        luxHint: Double?,
        zoneHint: String,
        crossX: Double,
        crossY: Double,
        capturedAt: Date,
        photoLocalURL: String?
    ) {
        self.sessionId = sessionId
        self.evEstimate = evEstimate
        self.luxHint = luxHint
        self.zoneHint = zoneHint
        self.crossX = crossX
        self.crossY = crossY
        self.capturedAt = capturedAt
        self.photoLocalURL = photoLocalURL
    }
}

public struct ExposureID: Codable, Hashable, Sendable {
    public var sessionId: String
    public var ev: Double
    public var aperture: String
    public var shutter: String
    public var iso: String
    public var confidence: Double
    public var rationale: String
    public var complianceBanner: Bool

    public init(
        sessionId: String,
        ev: Double,
        aperture: String,
        shutter: String,
        iso: String,
        confidence: Double,
        rationale: String,
        complianceBanner: Bool = true
    ) {
        self.sessionId = sessionId
        self.ev = ev
        self.aperture = aperture
        self.shutter = shutter
        self.iso = iso
        self.confidence = confidence
        self.rationale = rationale
        self.complianceBanner = complianceBanner
    }
}

public struct ZoneDialState: Codable, Hashable, Sendable {
    public var sessionId: String
    public var selectedZone: String
    public var filmBias: String?
    public var digitalBias: String?

    public init(
        sessionId: String,
        selectedZone: String,
        filmBias: String? = nil,
        digitalBias: String? = nil
    ) {
        self.sessionId = sessionId
        self.selectedZone = selectedZone
        self.filmBias = filmBias
        self.digitalBias = digitalBias
    }
}

public struct CoachTurn: Codable, Hashable, Sendable {
    public var sessionId: String?
    public var role: String
    public var text: String
    public var strategy: String
    public var sttSource: String?
    public var createdAt: Date

    public init(
        sessionId: String?,
        role: String,
        text: String,
        strategy: String,
        sttSource: String?,
        createdAt: Date
    ) {
        self.sessionId = sessionId
        self.role = role
        self.text = text
        self.strategy = strategy
        self.sttSource = sttSource
        self.createdAt = createdAt
    }
}

public struct MeterCardAnnotation: Codable, Hashable, Sendable {
    public var sessionId: String
    public var callouts: [String]
    public var imageLocalURL: String
    public var generatedAt: Date

    public init(
        sessionId: String,
        callouts: [String],
        imageLocalURL: String,
        generatedAt: Date
    ) {
        self.sessionId = sessionId
        self.callouts = callouts
        self.imageLocalURL = imageLocalURL
        self.generatedAt = generatedAt
    }
}

public struct SetCallout: Codable, Hashable, Sendable {
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

/// Aggregate root persisted via AtomicCodableStore for restart restore.
public struct ZonelightState: Codable, Hashable, Sendable {
    public var sessions: [MeterSession]
    public var spotReadings: [SpotReading]
    public var exposureIDs: [ExposureID]
    public var zoneDialStates: [ZoneDialState]
    public var coachTurns: [CoachTurn]
    public var meterCards: [MeterCardAnnotation]
    public var setCallouts: [SetCallout]
    public var voiceNotes: [VoiceNote]
    public var settings: AppSettings

    public init(
        sessions: [MeterSession] = [],
        spotReadings: [SpotReading] = [],
        exposureIDs: [ExposureID] = [],
        zoneDialStates: [ZoneDialState] = [],
        coachTurns: [CoachTurn] = [],
        meterCards: [MeterCardAnnotation] = [],
        setCallouts: [SetCallout] = [],
        voiceNotes: [VoiceNote] = [],
        settings: AppSettings = AppSettings()
    ) {
        self.sessions = sessions
        self.spotReadings = spotReadings
        self.exposureIDs = exposureIDs
        self.zoneDialStates = zoneDialStates
        self.coachTurns = coachTurns
        self.meterCards = meterCards
        self.setCallouts = setCallouts
        self.voiceNotes = voiceNotes
        self.settings = settings
    }
}
