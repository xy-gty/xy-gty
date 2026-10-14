import Foundation
import AppRuntimeCore

/// Caller-owned AtomicCodableStore facades for frozen entities. Ordinary saves never replace corrupt bytes.
public final class BendCoachStorageRoot: @unchecked Sendable {
    public let rootDirectory: URL
    public let jobSessions: AtomicCodableStore<JobSessionCatalog>
    public let bendQueries: AtomicCodableStore<BendQueryCatalog>
    public let photos: AtomicCodableStore<FieldPhotoCatalog>
    public let recognitionDrafts: AtomicCodableStore<BendRecognitionDraftCatalog>
    public let markups: AtomicCodableStore<BendMarkupCatalog>
    public let diagramOverlays: AtomicCodableStore<DiagramOverlayCatalog>
    public let coachingSteps: AtomicCodableStore<CoachingStepCatalog>
    public let unitPreference: AtomicCodableStore<UnitPreference>
    public let consentLocal: AtomicCodableStore<AIConsentRecord>

    public init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        let domain = rootDirectory.appendingPathComponent("domain", isDirectory: true)
        self.jobSessions = AtomicCodableStore(url: domain.appendingPathComponent("job-sessions.json"))
        self.bendQueries = AtomicCodableStore(url: domain.appendingPathComponent("bend-queries.json"))
        self.photos = AtomicCodableStore(url: domain.appendingPathComponent("field-photos.json"))
        self.recognitionDrafts = AtomicCodableStore(url: domain.appendingPathComponent("bend-recognition-drafts.json"))
        self.markups = AtomicCodableStore(url: domain.appendingPathComponent("bend-markups.json"))
        self.diagramOverlays = AtomicCodableStore(url: domain.appendingPathComponent("diagram-overlays.json"))
        self.coachingSteps = AtomicCodableStore(url: domain.appendingPathComponent("coaching-steps.json"))
        self.unitPreference = AtomicCodableStore(url: domain.appendingPathComponent("unit-preference.json"))
        self.consentLocal = AtomicCodableStore(url: domain.appendingPathComponent("ai-consent.json"))
    }

    public var photosDirectory: URL {
        rootDirectory.appendingPathComponent("photos", isDirectory: true)
    }

    public var diagramsDirectory: URL {
        rootDirectory.appendingPathComponent("diagrams", isDirectory: true)
    }

    public func photoFileURL(for photo: FieldPhoto) -> URL {
        photosDirectory.appendingPathComponent(photo.localFileName, isDirectory: false)
    }

    public func diagramFileURL(for overlay: DiagramOverlay) -> URL {
        diagramsDirectory.appendingPathComponent(overlay.localFileName, isDirectory: false)
    }
}
